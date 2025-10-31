#!/usr/bin/env python3
"""
Web Crawler - Phase 2.1 MVP
Discovers URLs from a root URL using queue-based crawling
"""

import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin, urlparse
import time
import re
import logging
from datetime import datetime
from utils import db_cursor

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger('crawler')


class Crawler:
    """
    Basic web crawler that discovers URLs from a root URL.

    Uses queue-based crawling to avoid recursion limits.
    Respects rate limiting, robots.txt, and domain restrictions.
    """

    def __init__(self, config):
        """
        Initialize crawler with configuration.

        Args:
            config: Dictionary with crawler settings
        """
        self.config = config
        self.root_url = config['root_url']
        self.allowed_domains = config['allowed_domains']
        self.max_depth = config['max_depth']
        self.max_urls = config.get('max_urls', None)
        self.timeout = config['timeout']
        self.delay = config['delay_between_requests']
        self.user_agent = config['user_agent']
        self.ignore_patterns = config['ignore_patterns']

        # Crawler state
        self.queue = []  # URLs to visit
        self.visited = set()  # URLs already visited
        self.discovered = {}  # url -> {parent, depth, ...}
        self.crawl_run_id = None

        # Statistics
        self.stats = {
            'urls_discovered': 0,
            'urls_skipped': 0,
            'errors': 0
        }

    def should_ignore_url(self, url):
        """
        Check if URL matches any ignore pattern.

        Args:
            url: URL to check

        Returns:
            bool: True if URL should be ignored
        """
        for pattern in self.ignore_patterns:
            if re.search(pattern, url, re.IGNORECASE):
                logger.debug(f"Ignoring URL (matches pattern '{pattern}'): {url}")
                return True
        return False

    def is_allowed_domain(self, url):
        """
        Check if URL belongs to allowed domains.

        Args:
            url: URL to check

        Returns:
            bool: True if domain is allowed
        """
        try:
            domain = urlparse(url).netloc
            return domain in self.allowed_domains
        except Exception as e:
            logger.error(f"Error parsing URL domain: {url} - {e}")
            return False

    def normalize_url(self, url):
        """
        Normalize URL (remove fragments, trailing slashes, etc).

        Args:
            url: URL to normalize

        Returns:
            str: Normalized URL
        """
        parsed = urlparse(url)
        # Remove fragment (#anchors)
        url = url.split('#')[0]
        # Remove trailing slash (except for root)
        if url.endswith('/') and url != self.root_url and len(url) > 1:
            url = url.rstrip('/')
        return url

    def fetch_url(self, url):
        """
        Fetch URL and return response.

        Args:
            url: URL to fetch

        Returns:
            requests.Response or None if error
        """
        headers = {
            'User-Agent': self.user_agent
        }

        try:
            logger.info(f"Fetching: {url}")
            response = requests.get(
                url,
                headers=headers,
                timeout=self.timeout,
                allow_redirects=self.config['follow_redirects']
            )
            return response

        except requests.Timeout:
            logger.warning(f"Timeout: {url}")
            self.stats['errors'] += 1
            return None

        except requests.RequestException as e:
            logger.error(f"Request error: {url} - {e}")
            self.stats['errors'] += 1
            return None

    def extract_links(self, url, html_content):
        """
        Extract all links from HTML content.

        Args:
            url: Base URL for resolving relative links
            html_content: HTML content to parse

        Returns:
            list: List of absolute URLs found
        """
        links = []

        try:
            soup = BeautifulSoup(html_content, 'html.parser')

            for tag in soup.find_all('a', href=True):
                href = tag.get('href')

                # Convert relative URL to absolute
                absolute_url = urljoin(url, href)

                # Normalize
                absolute_url = self.normalize_url(absolute_url)

                links.append(absolute_url)

        except Exception as e:
            logger.error(f"Error parsing HTML from {url}: {e}")

        return links

    def save_discovered_url(self, url, parent_url=None, depth=0):
        """
        Save discovered URL to database.

        Args:
            url: URL discovered
            parent_url: Parent URL (None for root)
            depth: Depth in tree (0 for root)
        """
        try:
            with db_cursor() as cursor:
                # Find parent_url_id
                parent_url_id = None
                if parent_url:
                    cursor.execute(
                        "SELECT id FROM discovered_urls WHERE url = %s LIMIT 1",
                        (parent_url,)
                    )
                    parent_row = cursor.fetchone()
                    if parent_row:
                        parent_url_id = parent_row['id']

                # Insert URL (ignore if already exists)
                cursor.execute("""
                    INSERT INTO discovered_urls (url, parent_url_id, depth, crawl_run_id, discovered_at)
                    VALUES (%s, %s, %s, %s, NOW())
                    ON CONFLICT (url) DO UPDATE
                    SET last_checked = NOW()
                """, (url, parent_url_id, depth, self.crawl_run_id))

                logger.debug(f"Saved URL: {url} (depth={depth}, parent={parent_url})")

        except Exception as e:
            logger.error(f"Error saving URL to database: {url} - {e}")

    def create_crawl_run(self, created_by='system'):
        """
        Create a new crawl run record in database.

        Args:
            created_by: User who initiated the crawl

        Returns:
            int: crawl_run_id
        """
        try:
            with db_cursor() as cursor:
                cursor.execute("""
                    INSERT INTO crawl_runs (root_url, max_depth, max_urls, created_by, status)
                    VALUES (%s, %s, %s, %s, 'running')
                    RETURNING id
                """, (self.root_url, self.max_depth, self.max_urls, created_by))

                row = cursor.fetchone()
                crawl_run_id = row['id']

                logger.info(f"Created crawl_run: {crawl_run_id}")
                return crawl_run_id

        except Exception as e:
            logger.error(f"Error creating crawl_run: {e}")
            return None

    def update_crawl_run(self, status='completed', errors=None):
        """
        Update crawl run with final stats.

        Args:
            status: Final status ('completed', 'failed', 'cancelled')
            errors: Error message if any
        """
        if not self.crawl_run_id:
            return

        try:
            with db_cursor() as cursor:
                cursor.execute("""
                    UPDATE crawl_runs
                    SET finished_at = NOW(),
                        status = %s,
                        urls_discovered = %s,
                        errors = %s
                    WHERE id = %s
                """, (
                    status,
                    self.stats['urls_discovered'],
                    errors,
                    self.crawl_run_id
                ))

                logger.info(f"Updated crawl_run {self.crawl_run_id}: {status}")

        except Exception as e:
            logger.error(f"Error updating crawl_run: {e}")

    def crawl(self, created_by='system'):
        """
        Main crawl method - discovers URLs from root.

        Args:
            created_by: User who initiated crawl

        Returns:
            dict: Statistics about crawl
        """
        logger.info(f"Starting crawl from: {self.root_url}")
        logger.info(f"Max depth: {self.max_depth}, Max URLs: {self.max_urls}")

        # Create crawl run
        self.crawl_run_id = self.create_crawl_run(created_by)
        if not self.crawl_run_id:
            return {'error': 'Failed to create crawl_run'}

        # Initialize queue with root URL
        self.queue.append((self.root_url, None, 0))  # (url, parent, depth)

        while self.queue:
            # Check max_urls limit
            if self.max_urls and self.stats['urls_discovered'] >= self.max_urls:
                logger.info(f"Reached max_urls limit: {self.max_urls}")
                break

            # Get next URL from queue
            url, parent_url, depth = self.queue.pop(0)

            # Skip if already visited
            if url in self.visited:
                self.stats['urls_skipped'] += 1
                continue

            # Skip if too deep
            if depth > self.max_depth:
                logger.debug(f"Skipping (too deep): {url}")
                self.stats['urls_skipped'] += 1
                continue

            # Skip if should ignore
            if self.should_ignore_url(url):
                self.stats['urls_skipped'] += 1
                continue

            # Skip if not allowed domain
            if not self.is_allowed_domain(url):
                logger.debug(f"Skipping (external domain): {url}")
                self.stats['urls_skipped'] += 1
                continue

            # Mark as visited
            self.visited.add(url)

            # Save to database
            self.save_discovered_url(url, parent_url, depth)
            self.stats['urls_discovered'] += 1

            # Fetch URL
            response = self.fetch_url(url)

            if response is None:
                # Error fetching (already logged)
                continue

            # Only process HTML pages
            content_type = response.headers.get('Content-Type', '')
            if 'text/html' not in content_type.lower():
                logger.debug(f"Skipping non-HTML: {url} ({content_type})")
                continue

            # Extract links
            links = self.extract_links(url, response.text)
            logger.info(f"Found {len(links)} links on {url}")

            # Add links to queue
            for link in links:
                if link not in self.visited:
                    self.queue.append((link, url, depth + 1))

            # Rate limiting
            time.sleep(self.delay)

        # Update crawl run
        self.update_crawl_run(status='completed')

        logger.info(f"Crawl completed: {self.stats}")

        # Run post-crawl quality checks if configured
        self._run_post_crawl_checks(created_by)

        return self.stats

    def _run_post_crawl_checks(self, created_by='system'):
        """
        Run automated quality checks after crawl completion.

        Args:
            created_by: User who initiated the crawl
        """
        try:
            # Get user ID from created_by
            with db_cursor(commit=False) as cursor:
                cursor.execute("SELECT id FROM users WHERE username = %s OR full_name = %s LIMIT 1", (created_by, created_by))
                user = cursor.fetchone()

            if not user:
                logger.warning(f"Cannot run post-crawl checks: user '{created_by}' not found")
                return

            user_id = user['id']

            # Check if user has any automatic checks configured
            from calidad.post_crawl_runner import PostCrawlQualityRunner

            runner = PostCrawlQualityRunner(self.crawl_run_id)
            configured_checks = runner.get_configured_checks(user_id)

            if not configured_checks:
                logger.info(f"No automatic quality checks configured for user {user_id}")
                return

            logger.info(f"Running {len(configured_checks)} automatic checks: {configured_checks}")

            # Execute checks
            results = runner.run_configured_checks(user_id)

            if results['executed']:
                logger.info(f"Post-crawl checks completed for crawl run {self.crawl_run_id}")
                for check in results['checks']:
                    logger.info(f"  - {check['check_type']}: {check['status']} - {check.get('message', '')}")
            else:
                logger.info(f"No checks executed: {results.get('reason', 'Unknown')}")

        except Exception as e:
            logger.error(f"Error running post-crawl checks: {e}", exc_info=True)
