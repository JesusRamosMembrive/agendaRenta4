#!/usr/bin/env python3
"""
URL Validator - Phase 2.2
Validates discovered URLs by checking status codes, response times, and detecting broken links
"""

import requests
import time
import logging
from datetime import datetime
from utils import db_cursor

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger('validator')


class URLValidator:
    """
    Validates URLs by checking HTTP status codes and measuring response times.

    Features:
    - Checks status codes (200=OK, 404=not found, 500=server error, etc.)
    - Measures response time in seconds
    - Detects broken links (4xx, 5xx errors)
    - Tracks redirects (301, 302)
    - Respects rate limiting
    - Updates database with validation results
    """

    def __init__(self, config):
        """
        Initialize validator with configuration.

        Args:
            config: Dictionary with validator settings
        """
        self.timeout = config.get('timeout', 15)
        self.delay = config.get('delay_between_requests', 0.5)
        self.user_agent = config.get('user_agent', 'AgendaRenta4-Validator/2.0')
        self.max_retries = config.get('max_retries', 2)

        self.session = requests.Session()
        self.session.headers.update({'User-Agent': self.user_agent})

        # Stats
        self.validated = 0
        self.broken = 0
        self.ok = 0
        self.redirects = 0
        self.errors = 0

    def validate_url(self, url_id, url):
        """
        Validate a single URL and update database.

        Args:
            url_id: ID in discovered_urls table
            url: URL string to validate

        Returns:
            dict with validation results
        """
        result = {
            'url_id': url_id,
            'url': url,
            'status_code': None,
            'response_time': None,
            'is_broken': False,
            'error_message': None,
            'redirect_url': None
        }

        start_time = time.time()

        try:
            # Make request with timeout
            response = self.session.get(
                url,
                timeout=self.timeout,
                allow_redirects=True
            )

            result['status_code'] = response.status_code
            result['response_time'] = time.time() - start_time

            # Check if broken
            if response.status_code >= 400:
                result['is_broken'] = True
                result['error_message'] = f"HTTP {response.status_code}"
                self.broken += 1
            else:
                self.ok += 1

            # Track redirects
            if response.history:
                result['redirect_url'] = response.url
                self.redirects += 1
                logger.info(f"Redirect: {url} -> {response.url}")

            self.validated += 1

        except requests.exceptions.Timeout:
            result['is_broken'] = True
            result['error_message'] = f"Timeout after {self.timeout}s"
            result['response_time'] = self.timeout
            self.broken += 1
            self.errors += 1
            logger.warning(f"Timeout: {url}")

        except requests.exceptions.ConnectionError as e:
            result['is_broken'] = True
            result['error_message'] = f"Connection error: {str(e)[:100]}"
            result['response_time'] = time.time() - start_time
            self.broken += 1
            self.errors += 1
            logger.warning(f"Connection error: {url}")

        except requests.exceptions.RequestException as e:
            result['is_broken'] = True
            result['error_message'] = f"Request failed: {str(e)[:100]}"
            result['response_time'] = time.time() - start_time
            self.broken += 1
            self.errors += 1
            logger.error(f"Request error: {url} - {e}")

        # Update database
        self._update_database(result)

        # Rate limiting
        time.sleep(self.delay)

        return result

    def _update_database(self, result):
        """Update discovered_urls table with validation results"""
        with db_cursor() as cursor:
            cursor.execute("""
                UPDATE discovered_urls
                SET
                    status_code = %s,
                    response_time = %s,
                    is_broken = %s,
                    error_message = %s,
                    last_checked = NOW()
                WHERE id = %s
            """, (
                result['status_code'],
                result['response_time'],
                result['is_broken'],
                result['error_message'],
                result['url_id']
            ))
            cursor.connection.commit()

    def validate_batch(self, urls, track_changes=True):
        """
        Validate multiple URLs.

        Args:
            urls: List of tuples (url_id, url, previous_status_code)
            track_changes: Whether to track status changes in url_changes table

        Returns:
            dict with batch statistics
        """
        logger.info(f"Starting validation of {len(urls)} URLs...")

        results = []
        for url_id, url, previous_status in urls:
            result = self.validate_url(url_id, url)
            results.append(result)

            # Track changes if requested
            if track_changes and previous_status is not None:
                self._track_change(url_id, previous_status, result['status_code'], result['is_broken'])

            # Progress logging
            if self.validated % 10 == 0:
                logger.info(f"Progress: {self.validated}/{len(urls)} URLs validated")

        stats = {
            'total': len(urls),
            'validated': self.validated,
            'ok': self.ok,
            'broken': self.broken,
            'redirects': self.redirects,
            'errors': self.errors
        }

        logger.info(f"Validation complete: {stats}")
        return stats

    def _track_change(self, url_id, old_status, new_status, is_broken):
        """Track status changes in url_changes table"""

        # Determine change type
        if old_status is None and new_status is not None:
            change_type = 'new'
        elif old_status == 200 and is_broken:
            change_type = 'broken'
        elif old_status >= 400 and not is_broken:
            change_type = 'fixed'
        elif old_status != new_status:
            change_type = 'status_change'
        else:
            return  # No change

        with db_cursor() as cursor:
            cursor.execute("""
                INSERT INTO url_changes (url_id, change_type, old_value, new_value, details)
                VALUES (%s, %s, %s, %s, %s)
            """, (
                url_id,
                change_type,
                str(old_status) if old_status else None,
                str(new_status) if new_status else None,
                f"Status changed from {old_status} to {new_status}"
            ))
            cursor.connection.commit()

            logger.info(f"Change tracked: URL {url_id} - {change_type}")

    def get_stats(self):
        """Get validation statistics"""
        return {
            'validated': self.validated,
            'ok': self.ok,
            'broken': self.broken,
            'redirects': self.redirects,
            'errors': self.errors
        }


def get_validation_config():
    """Get default validation configuration"""
    return {
        'timeout': 15,
        'delay_between_requests': 0.5,  # 2 requests/second
        'user_agent': 'AgendaRenta4-Validator/2.0 (quality monitoring; contact: admin@example.com)',
        'max_retries': 2
    }
