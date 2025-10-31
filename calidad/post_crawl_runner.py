"""
Post-Crawl Quality Check Runner

Executes configured quality checks after a crawl completes.
Integrates with existing checkers (ImagenesChecker, URLValidator).
"""

import logging
from typing import List, Dict, Any, Optional
from utils import db_cursor

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

    def get_configured_checks(self, user_id: int) -> List[str]:
        """
        Get list of checks configured to run automatically for a user.

        Args:
            user_id: User ID to check configuration

        Returns:
            List of check types (e.g., ['broken_links', 'image_quality'])
        """
        with db_cursor(commit=False) as cursor:
            cursor.execute("""
                SELECT check_type
                FROM quality_check_config
                WHERE user_id = %s
                  AND enabled = TRUE
                  AND run_after_crawl = TRUE
            """, (user_id,))

            results = cursor.fetchall()
            return [row['check_type'] for row in results]

    def run_configured_checks(self, user_id: int) -> Dict[str, Any]:
        """
        Run all checks configured for automatic execution.

        Args:
            user_id: User ID whose configuration to use

        Returns:
            Dictionary with execution results for each check
        """
        check_types = self.get_configured_checks(user_id)

        if not check_types:
            logger.info(f"No automatic checks configured for user {user_id}")
            return {
                'executed': False,
                'reason': 'No automatic checks configured',
                'checks': []
            }

        logger.info(f"Running {len(check_types)} automatic checks for crawl {self.crawl_run_id}")
        return self.run_selected_checks(check_types)

    def run_selected_checks(self, check_types: List[str]) -> Dict[str, Any]:
        """
        Run specified quality checks.

        Args:
            check_types: List of check types to run

        Returns:
            Dictionary with results for each check executed
        """
        results = {
            'executed': True,
            'crawl_run_id': self.crawl_run_id,
            'checks': []
        }

        for check_type in check_types:
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

            # Execute check
            try:
                logger.info(f"Executing check: {check_type}")
                check_result = self._execute_check(check_type)
                results['checks'].append(check_result)

            except Exception as e:
                logger.error(f"Error executing check '{check_type}': {e}")
                results['checks'].append({
                    'check_type': check_type,
                    'status': 'error',
                    'message': str(e)
                })

        return results

    def _execute_check(self, check_type: str) -> Dict[str, Any]:
        """
        Execute a specific check type.

        Args:
            check_type: Type of check to execute

        Returns:
            Dictionary with check execution results
        """
        if check_type == 'broken_links':
            return self._run_broken_links_check()

        elif check_type == 'image_quality':
            return self._run_image_quality_check()

        else:
            raise ValueError(f"Check type '{check_type}' not implemented")

    def _run_broken_links_check(self) -> Dict[str, Any]:
        """
        Run broken links validation.

        Returns:
            Dictionary with validation results
        """
        from crawler.validator import URLValidator

        # Get URLs from this crawl run
        with db_cursor(commit=False) as cursor:
            cursor.execute("""
                SELECT id, url
                FROM discovered_urls
                WHERE crawl_run_id = %s
                  AND active = TRUE
                ORDER BY depth ASC
            """, (self.crawl_run_id,))

            urls = cursor.fetchall()

        if not urls:
            return {
                'check_type': 'broken_links',
                'status': 'completed',
                'message': 'No URLs to validate',
                'stats': {'total': 0, 'validated': 0, 'broken': 0}
            }

        # Run validator
        validator = URLValidator()
        url_list = [(row['id'], row['url']) for row in urls]
        stats = validator.validate_batch(url_list, track_changes=True)

        return {
            'check_type': 'broken_links',
            'status': 'completed',
            'message': f"Validated {stats['validated']} URLs, found {stats['broken']} broken",
            'stats': stats
        }

    def _run_image_quality_check(self) -> Dict[str, Any]:
        """
        Run image quality checks.

        Returns:
            Dictionary with check results
        """
        from calidad.imagenes import ImagenesChecker
        from calidad.batch import BatchQualityCheckRunner

        # Get section IDs from this crawl run that are in sections table
        with db_cursor(commit=False) as cursor:
            cursor.execute("""
                SELECT s.id
                FROM sections s
                INNER JOIN discovered_urls du ON s.url = du.url
                WHERE du.crawl_run_id = %s
                  AND s.active = TRUE
            """, (self.crawl_run_id,))

            sections = cursor.fetchall()

        if not sections:
            return {
                'check_type': 'image_quality',
                'status': 'completed',
                'message': 'No sections to check',
                'stats': {'total': 0, 'processed': 0, 'successful': 0, 'failed': 0}
            }

        # Run batch quality check
        section_ids = [row['id'] for row in sections]
        runner = BatchQualityCheckRunner(
            batch_type='image_quality',
            checker_class=ImagenesChecker,
            checker_config={'check_format': True}
        )

        result = runner.run_batch(section_ids, created_by='post_crawl_auto')

        return {
            'check_type': 'image_quality',
            'status': result['status'],
            'message': f"Checked {result['processed']} sections, {result['successful']} successful",
            'batch_id': result['batch_id'],
            'stats': {
                'total': result['total'],
                'processed': result['processed'],
                'successful': result['successful'],
                'failed': result['failed']
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
                run_after_crawl
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
            'run_after_crawl': config['run_after_crawl']
        })

    return result


def update_user_check_config(user_id: int, check_type: str, enabled: bool, run_after_crawl: bool) -> bool:
    """
    Update quality check configuration for a user.

    Args:
        user_id: User ID
        check_type: Type of check to configure
        enabled: Whether check is enabled
        run_after_crawl: Whether to run automatically after crawl

    Returns:
        True if successful
    """
    try:
        with db_cursor() as cursor:
            cursor.execute("""
                INSERT INTO quality_check_config (user_id, check_type, enabled, run_after_crawl, updated_at)
                VALUES (%s, %s, %s, %s, NOW())
                ON CONFLICT (user_id, check_type)
                DO UPDATE SET
                    enabled = EXCLUDED.enabled,
                    run_after_crawl = EXCLUDED.run_after_crawl,
                    updated_at = NOW()
            """, (user_id, check_type, enabled, run_after_crawl))

        logger.info(f"Updated check config for user {user_id}: {check_type} enabled={enabled} auto={run_after_crawl}")
        return True

    except Exception as e:
        logger.error(f"Error updating check config: {e}")
        return False
