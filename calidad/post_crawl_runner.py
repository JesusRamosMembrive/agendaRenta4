"""
Post-Crawl Quality Check Runner

Executes configured quality checks after a crawl completes.
Integrates with existing checkers (ImagenesChecker, URLValidator).
"""

import logging
from typing import List, Dict, Any, Optional
from utils import db_cursor
from constants import QualityCheckDefaults

logger = logging.getLogger(__name__)


class PostCrawlQualityRunner:
    """
    Orchestrates quality checks after crawl completion.

    Executes checks based on user configuration or manual selection.
    """

    AVAILABLE_CHECKS = {
        'broken_links': {
            'name': 'Validación de Enlaces Rotos',
            'description': 'Verifica que todos los enlaces funcionen correctamente',
            'icon': '🔗'
        },
        'image_quality': {
            'name': 'Calidad de Imágenes',
            'description': 'Analiza alt text, tamaño, formato y carga de imágenes',
            'icon': '🖼️'
        },
        'seo': {
            'name': 'Análisis SEO',
            'description': 'Verifica meta tags, títulos y estructura SEO (próximamente)',
            'icon': '🔍',
            'available': False
        },
        'performance': {
            'name': 'Performance',
            'description': 'Mide tiempos de carga y optimización (próximamente)',
            'icon': '⚡',
            'available': False
        },
        'accessibility': {
            'name': 'Accesibilidad',
            'description': 'Verifica estándares WCAG (próximamente)',
            'icon': '♿',
            'available': False
        }
    }

    def __init__(self, crawl_run_id: int):
        """
        Initialize runner for a specific crawl.

        Args:
            crawl_run_id: ID of the crawl run to analyze
        """
        self.crawl_run_id = crawl_run_id

    def _build_scope_query(self, base_query, scope):
        """
        Build SQL query with scope filter applied.

        Args:
            base_query: Base SQL query (should end with WHERE clause or ready for AND)
            scope: 'all' or 'priority'

        Returns:
            str: Complete query with scope filter
        """
        query = base_query
        if scope == 'priority':
            query += " AND is_priority = TRUE"
        return query

    def get_configured_checks(self, user_id: int) -> List[Dict[str, str]]:
        """
        Get list of checks configured to run automatically for a user.

        Args:
            user_id: User ID to check configuration

        Returns:
            List of dicts with check_type and scope (e.g., [{'check_type': 'broken_links', 'scope': 'all'}])
        """
        with db_cursor(commit=False) as cursor:
            cursor.execute("""
                SELECT check_type, scope
                FROM quality_check_config
                WHERE user_id = %s
                  AND enabled = TRUE
                  AND run_after_crawl = TRUE
            """, (user_id,))

            results = cursor.fetchall()
            return [{'check_type': row['check_type'], 'scope': row['scope']} for row in results]

    def run_configured_checks(self, user_id: int) -> Dict[str, Any]:
        """
        Run all checks configured for automatic execution.

        Args:
            user_id: User ID whose configuration to use

        Returns:
            Dictionary with execution results for each check
        """
        check_configs = self.get_configured_checks(user_id)

        if not check_configs:
            logger.info(f"No automatic checks configured for user {user_id}")
            return {
                'executed': False,
                'reason': 'No automatic checks configured',
                'checks': []
            }

        logger.info(f"Running {len(check_configs)} automatic checks for crawl {self.crawl_run_id}")
        return self.run_checks(check_configs)

    def run_checks(self, check_configs: List[Dict[str, str]]) -> Dict[str, Any]:
        """
        Run specified quality checks with their configured scopes.

        Args:
            check_configs: List of dicts with check_type and scope

        Returns:
            Dictionary with results for each check executed
        """
        results = {
            'executed': True,
            'crawl_run_id': self.crawl_run_id,
            'checks': []
        }

        for config in check_configs:
            check_type = config['check_type']
            scope = config['scope']

            if check_type not in self.AVAILABLE_CHECKS:
                logger.warning(f"Unknown check type: {check_type}")
                continue

            check_info = self.AVAILABLE_CHECKS[check_type]

            # Skip unavailable checks
            if not check_info.get('available', True):
                logger.info(f"Check '{check_type}' not yet available, skipping")
                results['checks'].append({
                    'check_type': check_type,
                    'status': 'unavailable',
                    'message': 'Feature not yet implemented'
                })
                continue

            # Execute check with scope
            try:
                logger.info(f"Executing check: {check_type} (scope: {scope})")
                check_result = self._execute_check_with_scope(check_type, scope)
                results['checks'].append(check_result)

            except Exception as e:
                logger.error(f"Error executing check '{check_type}': {e}")
                results['checks'].append({
                    'check_type': check_type,
                    'status': 'error',
                    'message': str(e)
                })

        return results

    def run_selected_checks(self, check_types: List[str]) -> Dict[str, Any]:
        """
        Run specified quality checks (legacy method - defaults to 'priority' scope).

        Args:
            check_types: List of check types to run

        Returns:
            Dictionary with results for each check executed
        """
        # Convert to new format with default scope
        check_configs = [{'check_type': ct, 'scope': 'priority'} for ct in check_types]
        return self.run_checks(check_configs)

    def _execute_check_with_scope(self, check_type: str, scope: str) -> Dict[str, Any]:
        """
        Execute a specific check type with a given scope.

        Args:
            check_type: Type of check to execute
            scope: Scope of URLs to check ('all' or 'priority')

        Returns:
            Dictionary with check execution results
        """
        if check_type == 'broken_links':
            return self._run_broken_links_check(scope)

        elif check_type == 'image_quality':
            return self._run_image_quality_check(scope)

        else:
            raise ValueError(f"Check type '{check_type}' not implemented")

    def _execute_check(self, check_type: str) -> Dict[str, Any]:
        """
        Execute a specific check type (legacy - defaults to 'priority' scope).

        Args:
            check_type: Type of check to execute

        Returns:
            Dictionary with check execution results
        """
        return self._execute_check_with_scope(check_type, 'priority')

    def _run_broken_links_check(self, scope: str = 'priority') -> Dict[str, Any]:
        """
        Run broken links validation.

        Args:
            scope: 'all' for all URLs, 'priority' for is_priority=TRUE only

        Returns:
            Dictionary with validation results
        """
        from crawler.validator import URLValidator

        # Build query based on scope - include status_code for change tracking
        base_query = """
            SELECT id, url, status_code
            FROM discovered_urls
            WHERE crawl_run_id = %s
              AND active = TRUE
        """
        query = self._build_scope_query(base_query, scope)
        query += " ORDER BY depth ASC"

        # Get URLs from this crawl run
        with db_cursor(commit=False) as cursor:
            cursor.execute(query, (self.crawl_run_id,))
            urls = cursor.fetchall()

        if not urls:
            return {
                'check_type': 'broken_links',
                'status': 'completed',
                'message': f'No URLs to validate (scope: {scope})',
                'stats': {'total': 0, 'validated': 0, 'broken': 0}
            }

        # Run validator - pass (id, url, previous_status_code) tuples
        validator_config = {
            'timeout': QualityCheckDefaults.BROKEN_LINKS_TIMEOUT,
            'max_retries': QualityCheckDefaults.BROKEN_LINKS_MAX_RETRIES,
            'delay': QualityCheckDefaults.BROKEN_LINKS_RETRY_DELAY
        }
        validator = URLValidator(validator_config)
        url_list = [(row['id'], row['url'], row['status_code']) for row in urls]
        stats = validator.validate_batch(url_list, track_changes=True)

        return {
            'check_type': 'broken_links',
            'status': 'completed',
            'message': f"Validated {stats['validated']} URLs (scope: {scope}), found {stats['broken']} broken",
            'stats': stats
        }

    def _run_image_quality_check(self, scope: str = 'priority') -> Dict[str, Any]:
        """
        Run image quality checks.

        Args:
            scope: 'all' for all URLs, 'priority' for is_priority=TRUE only

        Returns:
            Dictionary with check results
        """
        from calidad.imagenes import ImagenesChecker
        import json

        # Build query based on scope
        base_query = """
            SELECT id, url, depth
            FROM discovered_urls
            WHERE crawl_run_id = %s
              AND active = TRUE
              AND is_broken = FALSE
        """
        query = self._build_scope_query(base_query, scope)
        query += " ORDER BY depth ASC"

        # Get URLs from this crawl run
        with db_cursor(commit=False) as cursor:
            cursor.execute(query, (self.crawl_run_id,))
            urls = cursor.fetchall()

        if not urls:
            return {
                'check_type': 'image_quality',
                'status': 'completed',
                'message': f'No URLs to check (scope: {scope})',
                'stats': {'total': 0, 'processed': 0, 'successful': 0, 'failed': 0}
            }

        # Run image quality checks on each URL
        checker = ImagenesChecker()
        total = len(urls)
        processed = 0
        successful = 0
        failed = 0

        for url_row in urls:
            try:
                result = checker.check(url_row['url'])

                # Save result to quality_checks table with discovered_url_id
                with db_cursor() as cursor:
                    cursor.execute("""
                        INSERT INTO quality_checks (
                            discovered_url_id, check_type, status, score, message,
                            details, issues_found, execution_time_ms, checked_at
                        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, NOW())
                    """, (
                        url_row['id'],
                        'image_quality',
                        result.status,
                        result.score,
                        result.message,
                        json.dumps(result.details),
                        result.issues_found,
                        result.execution_time_ms
                    ))
                successful += 1
                processed += 1

            except Exception as e:
                logger.error(f"Error checking {url_row['url']}: {e}")
                failed += 1
                processed += 1

        return {
            'check_type': 'image_quality',
            'status': 'completed',
            'message': f"Checked {processed} URLs (scope: {scope}), {successful} saved to database",
            'stats': {
                'total': total,
                'processed': processed,
                'successful': successful,
                'failed': failed
            }
        }


def get_user_check_config(user_id: int) -> List[Dict[str, Any]]:
    """
    Get quality check configuration for a user.

    Args:
        user_id: User ID

    Returns:
        List of check configurations with metadata
    """
    with db_cursor(commit=False) as cursor:
        cursor.execute("""
            SELECT
                check_type,
                enabled,
                run_after_crawl,
                scope
            FROM quality_check_config
            WHERE user_id = %s
            ORDER BY check_type
        """, (user_id,))

        configs = cursor.fetchall()

    # Merge with available checks metadata
    result = []
    for config in configs:
        check_type = config['check_type']
        check_info = PostCrawlQualityRunner.AVAILABLE_CHECKS.get(check_type, {})

        result.append({
            'check_type': check_type,
            'name': check_info.get('name', check_type),
            'description': check_info.get('description', ''),
            'icon': check_info.get('icon', ''),
            'available': check_info.get('available', True),
            'enabled': config['enabled'],
            'run_after_crawl': config['run_after_crawl'],
            'scope': config['scope']
        })

    return result


def update_user_check_config(user_id: int, check_type: str, enabled: bool, run_after_crawl: bool, scope: str = 'priority') -> bool:
    """
    Update quality check configuration for a user.

    Args:
        user_id: User ID
        check_type: Type of check to configure
        enabled: Whether check is enabled
        run_after_crawl: Whether to run automatically after crawl
        scope: Scope of URLs to check ('all' or 'priority')

    Returns:
        True if successful
    """
    try:
        with db_cursor() as cursor:
            cursor.execute("""
                INSERT INTO quality_check_config (user_id, check_type, enabled, run_after_crawl, scope, updated_at)
                VALUES (%s, %s, %s, %s, %s, NOW())
                ON CONFLICT (user_id, check_type)
                DO UPDATE SET
                    enabled = EXCLUDED.enabled,
                    run_after_crawl = EXCLUDED.run_after_crawl,
                    scope = EXCLUDED.scope,
                    updated_at = NOW()
            """, (user_id, check_type, enabled, run_after_crawl, scope))

        logger.info(f"Updated check config for user {user_id}: {check_type} enabled={enabled} auto={run_after_crawl} scope={scope}")
        return True

    except Exception as e:
        logger.error(f"Error updating check config: {e}")
        return False
