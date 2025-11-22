"""
CTA (Call-To-Action) Quality Checker

This checker validates that required CTAs are present on pages and point to
the correct URLs. It uses a rule-based system where expected CTAs are defined
per page type in the database.
"""

import re
import time
from typing import Any

import requests
from bs4 import BeautifulSoup

from calidad.base import QualityCheck, QualityCheckResult
from utils import get_db_connection


class CTAChecker(QualityCheck):
    """
    Checker that validates CTAs on a page against expected rules.

    Validates:
    - Presence of required CTAs
    - CTA text matches expected text
    - CTA URL matches expected URL pattern
    - Detects unexpected CTAs (warnings)

    Configuration:
        timeout: Request timeout in seconds (default: 10)
        strict_mode: If True, warnings count as errors (default: False)
    """

    def _get_check_type(self) -> str:
        return "cta_validation"

    def check(self, url: str, html_content: str | None = None) -> QualityCheckResult:
        """
        Check CTAs on the page against validation rules.

        Args:
            url: URL to check
            html_content: Optional pre-fetched HTML content

        Returns:
            QualityCheckResult with CTA validation analysis
        """
        start_time = time.time()

        # Validate URL
        if not self.validate_url(url):
            return self.create_result(
                status="error",
                score=0,
                message="Invalid URL provided",
                details={"error": "URL must start with http:// or https://"},
                issues_found=0,
                execution_time_ms=int((time.time() - start_time) * 1000),
            )

        # Get validation rules for this URL
        try:
            rules = self._get_validation_rules(url)
        except Exception as e:
            return self.create_result(
                status="error",
                score=0,
                message=f"Failed to fetch validation rules: {str(e)}",
                details={"error": str(e)},
                issues_found=0,
                execution_time_ms=int((time.time() - start_time) * 1000),
            )

        # If no rules found, skip validation
        if not rules:
            return self.create_result(
                status="ok",
                score=100,
                message="No CTA validation rules configured for this URL",
                details={"rules_found": 0, "info": "URL not assigned to any page type"},
                issues_found=0,
                execution_time_ms=int((time.time() - start_time) * 1000),
            )

        # Fetch HTML if not provided
        if html_content is None:
            try:
                timeout = self.config.get("timeout", 10)
                response = requests.get(url, timeout=timeout, headers={
                    'User-Agent': 'Mozilla/5.0 (compatible; AgendaRenta4-CTA/1.0)'
                })
                response.raise_for_status()
                html_content = response.text
            except Exception as e:
                return self.create_result(
                    status="error",
                    score=0,
                    message=f"Failed to fetch URL: {str(e)}",
                    details={"error": str(e)},
                    issues_found=0,
                    execution_time_ms=int((time.time() - start_time) * 1000),
                )

        # Extract CTAs from HTML
        try:
            found_ctas = self._extract_ctas(html_content)
        except Exception as e:
            return self.create_result(
                status="error",
                score=0,
                message=f"Failed to parse HTML: {str(e)}",
                details={"error": str(e)},
                issues_found=0,
                execution_time_ms=int((time.time() - start_time) * 1000),
            )

        # Run objective validations (always executed, regardless of rules)
        objective_issues = self._run_objective_validations(found_ctas, url)

        # Validate CTAs against rules
        validation_results = self._validate_ctas(rules, found_ctas, url)

        # Merge objective issues into validation results
        validation_results['objective_issues'] = objective_issues

        # Calculate score
        total_rules = len([r for r in rules if not r['is_optional']])
        missing_required = len(validation_results['missing_required'])
        incorrect_urls = len(validation_results['incorrect_urls'])

        # Count objective issues as errors/warnings
        obj_errors = len(objective_issues['broken_links']) + len(objective_issues['html_issues'])
        obj_warnings = len(objective_issues['spelling_errors']) + len(objective_issues['duplicates'])

        total_errors = missing_required + incorrect_urls + obj_errors

        if total_rules == 0 and len(found_ctas) == 0:
            score = 100
        elif total_rules == 0:
            # No rules, only objective validations
            if obj_errors > 0:
                score = max(0, 100 - (obj_errors * 20))
            else:
                score = 100
        else:
            # Combine rule-based and objective scoring
            rule_score = ((total_rules - (missing_required + incorrect_urls)) / total_rules) * 70
            objective_penalty = min(30, (obj_errors * 10) + (obj_warnings * 5))
            score = int(max(0, rule_score + (30 - objective_penalty)))

        # Determine status
        status = self.determine_status(score)
        if obj_warnings > 0 or (self.config.get("strict_mode", False) and validation_results['warnings']):
            if status == "ok":
                status = "warning"

        # Build message
        message_parts = []
        if missing_required > 0:
            message_parts.append(f"{missing_required} required CTAs missing")
        if incorrect_urls > 0:
            message_parts.append(f"{incorrect_urls} CTAs with incorrect URLs")
        if obj_errors > 0:
            message_parts.append(f"{obj_errors} objective issues")
        if obj_warnings > 0:
            message_parts.append(f"{obj_warnings} warnings")
        if validation_results['warnings']:
            message_parts.append(f"{len(validation_results['warnings'])} rule warnings")

        if not message_parts:
            if total_rules > 0:
                message = f"All {total_rules} required CTAs found and valid"
            else:
                message = f"All {len(found_ctas)} CTAs passed objective validations"
        else:
            message = ", ".join(message_parts)

        # Create result
        execution_time_ms = int((time.time() - start_time) * 1000)

        return self.create_result(
            status=status,
            score=score,
            message=message,
            details={
                "total_rules": len(rules),
                "required_rules": total_rules,
                "optional_rules": len([r for r in rules if r['is_optional']]),
                "found_ctas": len(found_ctas),
                "missing_required": validation_results['missing_required'],
                "missing_optional": validation_results['missing_optional'],
                "incorrect_urls": validation_results['incorrect_urls'],
                "warnings": validation_results['warnings'],
                "matched_ctas": validation_results['matched_ctas'],
                "objective_issues": objective_issues,
            },
            issues_found=total_errors,
            execution_time_ms=execution_time_ms,
        )

    def _get_validation_rules(self, url: str) -> list[dict[str, Any]]:
        """
        Get validation rules for a URL.
        Includes both global rules and page-type-specific rules.

        Args:
            url: URL to get rules for

        Returns:
            List of validation rules
        """
        conn = get_db_connection()
        cursor = conn.cursor()

        try:
            # Get URL ID from discovered_urls
            cursor.execute("SELECT id FROM discovered_urls WHERE url = %s", (url,))
            result = cursor.fetchone()

            if not result:
                # URL not in discovered_urls, only return global rules
                cursor.execute("""
                    SELECT r.id, r.expected_text, r.expected_url_pattern,
                           r.url_match_type, r.is_optional, r.priority, r.is_global,
                           NULL as page_type_name
                    FROM cta_validation_rules r
                    WHERE r.is_global = TRUE
                    ORDER BY r.priority DESC, r.expected_text
                """)
            else:
                url_id = result[0]

                # Get rules (global + assigned page types)
                cursor.execute("""
                    SELECT DISTINCT r.id, r.expected_text, r.expected_url_pattern,
                           r.url_match_type, r.is_optional, r.priority, r.is_global,
                           pt.name as page_type_name
                    FROM cta_validation_rules r
                    LEFT JOIN cta_page_types pt ON r.page_type_id = pt.id
                    LEFT JOIN cta_url_assignments a ON a.page_type_id = pt.id
                    WHERE r.is_global = TRUE
                       OR a.url_id = %s
                    ORDER BY r.priority DESC, r.expected_text
                """, (url_id,))

            rows = cursor.fetchall()

            rules = []
            for row in rows:
                rules.append({
                    'id': row[0],
                    'expected_text': row[1],
                    'expected_url_pattern': row[2],
                    'url_match_type': row[3],
                    'is_optional': row[4],
                    'priority': row[5],
                    'is_global': row[6],
                    'page_type_name': row[7],
                })

            return rules

        finally:
            cursor.close()
            conn.close()

    def _extract_ctas(self, html_content: str) -> list[dict[str, Any]]:
        """
        Extract CTAs from HTML content.

        Uses multiple detection strategies:
        - Common CSS classes (btn, button, cta, etc.)
        - ARIA roles
        - Keyword matching in text

        Args:
            html_content: HTML content to parse

        Returns:
            List of found CTAs with text, href, and metadata
        """
        soup = BeautifulSoup(html_content, 'html.parser')
        ctas = []
        seen = set()  # To avoid duplicates

        # Strategy 1: Find by common CTA classes
        cta_class_patterns = ['btn', 'button', 'cta', 'call-to-action', 'boton']
        for pattern in cta_class_patterns:
            elements = soup.find_all(class_=lambda x: x and pattern in x.lower() if x else False)
            for elem in elements:
                cta_info = self._extract_cta_info(elem)
                if cta_info:
                    key = (cta_info['text'].lower(), cta_info['href'])
                    if key not in seen:
                        seen.add(key)
                        ctas.append(cta_info)

        # Strategy 2: Find by ARIA roles
        aria_elements = soup.find_all(attrs={'role': ['button', 'link']})
        for elem in aria_elements:
            cta_info = self._extract_cta_info(elem)
            if cta_info:
                key = (cta_info['text'].lower(), cta_info['href'])
                if key not in seen:
                    seen.add(key)
                    ctas.append(cta_info)

        return ctas

    def _extract_cta_info(self, element) -> dict[str, Any] | None:
        """
        Extract CTA information from a BeautifulSoup element.

        Args:
            element: BeautifulSoup element

        Returns:
            Dictionary with CTA info or None if invalid
        """
        try:
            text = element.get_text(strip=True)
            if not text or len(text) > 100:  # Filter empty or very long texts
                return None

            # Get href
            href = element.get('href', '')

            # For buttons without href, check onclick or form action
            if not href and element.name == 'button':
                onclick = element.get('onclick', '')
                if onclick:
                    href = f"onclick:{onclick[:50]}"
                else:
                    form_parent = element.find_parent('form')
                    if form_parent:
                        href = form_parent.get('action', '')

            # Normalize relative URLs (we'll handle this in validation)

            return {
                'text': text,
                'href': href,
                'tag': element.name,
                'classes': ' '.join(element.get('class', [])) if element.get('class') else '',
            }
        except Exception:
            return None

    def _validate_ctas(
        self, rules: list[dict[str, Any]], found_ctas: list[dict[str, Any]], base_url: str
    ) -> dict[str, Any]:
        """
        Validate found CTAs against rules.

        Args:
            rules: List of validation rules
            found_ctas: List of CTAs found on page
            base_url: Base URL for resolving relative URLs

        Returns:
            Dictionary with validation results
        """
        missing_required = []
        missing_optional = []
        incorrect_urls = []
        warnings = []
        matched_ctas = []

        for rule in rules:
            expected_text = rule['expected_text']
            expected_url = rule['expected_url_pattern']
            url_match_type = rule['url_match_type']
            is_optional = rule['is_optional']

            # Find CTA matching expected text (case-insensitive, partial match)
            matching_cta = None
            for cta in found_ctas:
                if expected_text.lower() in cta['text'].lower():
                    matching_cta = cta
                    break

            if not matching_cta:
                # CTA not found
                if is_optional:
                    missing_optional.append({
                        'expected_text': expected_text,
                        'is_global': rule['is_global'],
                        'page_type': rule['page_type_name'],
                    })
                else:
                    missing_required.append({
                        'expected_text': expected_text,
                        'expected_url': expected_url,
                        'is_global': rule['is_global'],
                        'page_type': rule['page_type_name'],
                    })
            else:
                # CTA found, validate URL if expected_url is provided
                if expected_url:
                    url_matches = self._match_url(
                        matching_cta['href'], expected_url, url_match_type, base_url
                    )

                    if not url_matches:
                        incorrect_urls.append({
                            'cta_text': matching_cta['text'],
                            'found_url': matching_cta['href'],
                            'expected_url': expected_url,
                            'match_type': url_match_type,
                        })
                    else:
                        matched_ctas.append({
                            'text': matching_cta['text'],
                            'url': matching_cta['href'],
                            'rule': expected_text,
                        })
                else:
                    # No URL pattern to validate, just mark as matched
                    matched_ctas.append({
                        'text': matching_cta['text'],
                        'url': matching_cta['href'],
                        'rule': expected_text,
                    })

        return {
            'missing_required': missing_required,
            'missing_optional': missing_optional,
            'incorrect_urls': incorrect_urls,
            'warnings': warnings,
            'matched_ctas': matched_ctas,
        }

    def _match_url(
        self, found_url: str, expected_pattern: str, match_type: str, base_url: str
    ) -> bool:
        """
        Check if found URL matches expected pattern.

        Args:
            found_url: URL found in CTA
            expected_pattern: Expected URL pattern
            match_type: Type of match ('exact', 'contains', 'regex', 'domain')
            base_url: Base URL for resolving relative URLs

        Returns:
            True if URLs match according to match_type
        """
        if not found_url:
            return False

        # Normalize relative URLs
        if found_url.startswith('/'):
            from urllib.parse import urljoin
            found_url = urljoin(base_url, found_url)

        if match_type == 'exact':
            return found_url == expected_pattern
        elif match_type == 'contains':
            return expected_pattern in found_url
        elif match_type == 'regex':
            try:
                return bool(re.search(expected_pattern, found_url))
            except re.error:
                return False
        elif match_type == 'domain':
            from urllib.parse import urlparse
            found_domain = urlparse(found_url).netloc
            expected_domain = urlparse(expected_pattern).netloc
            return found_domain == expected_domain
        else:
            return False

    def _run_objective_validations(
        self, found_ctas: list[dict[str, Any]], base_url: str
    ) -> dict[str, Any]:
        """
        Run objective validations that don't require rules configuration.

        These validations detect obvious problems:
        - Broken links (HTTP errors)
        - Spelling errors in CTA text
        - Missing/invalid HTML attributes
        - Duplicate CTAs with different URLs

        Args:
            found_ctas: List of CTAs found on page
            base_url: Base URL for resolving relative URLs

        Returns:
            Dictionary with objective validation results
        """
        broken_links = []
        spelling_errors = []
        html_issues = []
        duplicates = []

        # Track CTA texts to detect duplicates
        cta_text_map = {}  # text -> list of URLs

        for cta in found_ctas:
            # Check 1: Validate HTML attributes
            html_check = self._check_html_attributes(cta)
            if html_check:
                html_issues.append(html_check)

            # Check 2: Validate link is not broken (only if href is valid)
            if cta['href'] and not cta['href'].startswith('onclick:'):
                broken_link_check = self._check_broken_link(cta, base_url)
                if broken_link_check:
                    broken_links.append(broken_link_check)

            # Check 3: Check spelling in CTA text
            spelling_check = self._check_spelling(cta)
            if spelling_check:
                spelling_errors.append(spelling_check)

            # Track for duplicate detection
            text_lower = cta['text'].lower().strip()
            if text_lower not in cta_text_map:
                cta_text_map[text_lower] = []
            cta_text_map[text_lower].append(cta['href'])

        # Check 4: Detect duplicate CTAs with different URLs
        for text, urls in cta_text_map.items():
            unique_urls = set(urls)
            if len(unique_urls) > 1:
                duplicates.append({
                    'text': text,
                    'url_count': len(unique_urls),
                    'urls': list(unique_urls),
                })

        return {
            'broken_links': broken_links,
            'spelling_errors': spelling_errors,
            'html_issues': html_issues,
            'duplicates': duplicates,
        }

    def _check_html_attributes(self, cta: dict[str, Any]) -> dict[str, Any] | None:
        """
        Check basic HTML attribute validity.

        Validates:
        - href is not empty
        - href is not just '#' or 'javascript:void(0)'
        - text is not empty

        Args:
            cta: CTA dictionary

        Returns:
            Issue dictionary or None if valid
        """
        issues = []

        # Check href validity
        href = cta.get('href', '').strip()
        if not href:
            issues.append("missing href attribute")
        elif href == '#':
            issues.append("href is just '#' (no destination)")
        elif href == 'javascript:void(0)':
            issues.append("href is 'javascript:void(0)' (no destination)")

        # Check text validity
        text = cta.get('text', '').strip()
        if not text:
            issues.append("missing visible text")

        if issues:
            return {
                'cta_text': cta.get('text', '[no text]'),
                'cta_href': cta.get('href', '[no href]'),
                'issues': issues,
            }

        return None

    def _check_broken_link(self, cta: dict[str, Any], base_url: str) -> dict[str, Any] | None:
        """
        Check if CTA link is broken (returns HTTP error).

        Args:
            cta: CTA dictionary
            base_url: Base URL for resolving relative URLs

        Returns:
            Issue dictionary or None if link is valid
        """
        href = cta.get('href', '').strip()
        if not href:
            return None

        # Normalize relative URLs
        if href.startswith('/'):
            from urllib.parse import urljoin
            href = urljoin(base_url, href)

        # Skip non-HTTP links
        if not href.startswith(('http://', 'https://')):
            return None

        # Check link status
        try:
            timeout = self.config.get("timeout", 10)
            response = requests.head(
                href,
                timeout=timeout,
                allow_redirects=True,
                headers={'User-Agent': 'Mozilla/5.0 (compatible; AgendaRenta4-CTA/1.0)'}
            )

            # Consider 4xx and 5xx as broken
            if response.status_code >= 400:
                return {
                    'cta_text': cta.get('text', '[no text]'),
                    'cta_href': href,
                    'status_code': response.status_code,
                    'error': f"HTTP {response.status_code}",
                }

        except requests.RequestException as e:
            return {
                'cta_text': cta.get('text', '[no text]'),
                'cta_href': href,
                'status_code': None,
                'error': str(e),
            }

        return None

    def _check_spelling(self, cta: dict[str, Any]) -> dict[str, Any] | None:
        """
        Check spelling in CTA text.

        Uses basic Spanish spell checking. Words in UPPERCASE (like acronyms)
        and numbers are ignored.

        Args:
            cta: CTA dictionary

        Returns:
            Issue dictionary or None if spelling is correct
        """
        text = cta.get('text', '').strip()
        if not text:
            return None

        try:
            from spellchecker import SpellChecker

            # Initialize Spanish spell checker
            spell = SpellChecker(language='es')

            # Custom dictionary with domain-specific words
            domain_words = {
                'renta4', 'r4', 'broker', 'online', 'easy', 'app',
                'fondos', 'etf', 'etfs', 'isin', 'sicav',
                'asesor', 'asesores', 'asesoramiento',
                'contratar', 'contratación', 'abre', 'abrir',
                'pruébanos', 'prefieres', 'días', 'cuenta',
                'descubrir', 'carteras', 'promoción', 'contactar',
                'fondo', 'pensiones', 'planes', 'clientes', 'portal',
            }
            spell.word_frequency.load_words(domain_words)

            # Extract words (ignore numbers and UPPERCASE acronyms)
            words = re.findall(r'\b[a-záéíóúñü]+\b', text.lower())

            # Check each word
            misspelled = []
            for word in words:
                # Skip very short words
                if len(word) <= 2:
                    continue

                # Check if misspelled
                if word not in spell:
                    # Get suggestions
                    suggestions = spell.candidates(word)
                    misspelled.append({
                        'word': word,
                        'suggestions': list(suggestions)[:3] if suggestions else [],
                    })

            if misspelled:
                return {
                    'cta_text': cta.get('text'),
                    'misspelled_words': misspelled,
                }

        except ImportError:
            # pyspellchecker not installed, skip spelling check
            pass
        except Exception:
            # Any other error, skip silently
            pass

        return None


# Legacy alias for backwards compatibility
CTAsChecker = CTAChecker
