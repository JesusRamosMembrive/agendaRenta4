"""
HTML Fetcher Utility

Provides optimized HTML fetching with concurrent downloads for quality checks.
Implements connection pooling and retry logic for reliability.
"""

import logging
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import Dict, List, Tuple, Optional

import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

logger = logging.getLogger(__name__)


class HTMLFetcher:
    """
    Fetches HTML content for multiple URLs concurrently with connection pooling.

    Features:
    - Thread-pool based concurrent downloads
    - Automatic retry on failures
    - Connection pooling for efficiency
    - Progress tracking
    """

    def __init__(
        self,
        max_workers: int = 10,
        timeout: int = 10,
        max_retries: int = 3,
        backoff_factor: float = 0.5
    ):
        """
        Initialize HTML fetcher.

        Args:
            max_workers: Number of concurrent download threads
            timeout: Request timeout in seconds
            max_retries: Number of retries for failed requests
            backoff_factor: Backoff factor for retries (0.5 means 0.5s, 1s, 2s...)
        """
        self.max_workers = max_workers
        self.timeout = timeout

        # Configure session with retry logic and connection pooling
        self.session = requests.Session()

        retry_strategy = Retry(
            total=max_retries,
            backoff_factor=backoff_factor,
            status_forcelist=[429, 500, 502, 503, 504],
            allowed_methods=["GET", "HEAD"]
        )

        adapter = HTTPAdapter(
            max_retries=retry_strategy,
            pool_connections=max_workers,
            pool_maxsize=max_workers * 2
        )

        self.session.mount("http://", adapter)
        self.session.mount("https://", adapter)

        # Set default headers
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (compatible; AgendaRenta4/1.0; +https://www.r4.com)'
        })

    def fetch_single(self, url: str) -> Tuple[str, Optional[str], Optional[str]]:
        """
        Fetch HTML for a single URL.

        Args:
            url: URL to fetch

        Returns:
            Tuple of (url, html_content, error_message)
            - html_content is None if fetch failed
            - error_message is None if fetch succeeded
        """
        try:
            response = self.session.get(url, timeout=self.timeout)
            response.raise_for_status()
            return (url, response.text, None)

        except requests.Timeout:
            error_msg = "Request timeout"
            logger.warning(f"Timeout fetching {url}")
            return (url, None, error_msg)

        except requests.RequestException as e:
            error_msg = f"Request failed: {str(e)}"
            logger.warning(f"Error fetching {url}: {e}")
            return (url, None, error_msg)

        except Exception as e:
            error_msg = f"Unexpected error: {str(e)}"
            logger.error(f"Unexpected error fetching {url}: {e}")
            return (url, None, error_msg)

    def fetch_batch(
        self,
        urls: List[str],
        progress_callback=None
    ) -> Dict[str, Tuple[Optional[str], Optional[str]]]:
        """
        Fetch HTML for multiple URLs concurrently.

        Args:
            urls: List of URLs to fetch
            progress_callback: Optional callback(completed, total, url) for progress updates

        Returns:
            Dictionary mapping url -> (html_content, error_message)
            - html_content is None if fetch failed
            - error_message is None if fetch succeeded
        """
        results = {}
        total = len(urls)
        completed = 0

        logger.info(f"Starting concurrent HTML fetch for {total} URLs with {self.max_workers} workers...")
        start_time = time.time()

        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            # Submit all fetch tasks
            future_to_url = {
                executor.submit(self.fetch_single, url): url
                for url in urls
            }

            # Process results as they complete
            for future in as_completed(future_to_url):
                url, html_content, error = future.result()
                results[url] = (html_content, error)
                completed += 1

                # Log progress
                if progress_callback:
                    progress_callback(completed, total, url)

                # Progress logging every 10 URLs or first 3
                if completed <= 3 or completed % 10 == 0:
                    success_rate = sum(1 for h, e in results.values() if h is not None)
                    logger.info(
                        f"HTML fetch progress: {completed}/{total} "
                        f"({success_rate} successful, {completed - success_rate} failed)"
                    )

        elapsed = time.time() - start_time
        success_count = sum(1 for html, err in results.values() if html is not None)

        logger.info(
            f"HTML fetch complete: {success_count}/{total} successful in {elapsed:.1f}s "
            f"({total/elapsed:.1f} URLs/s)"
        )

        return results

    def close(self):
        """Close the session and release resources."""
        self.session.close()

    def __enter__(self):
        """Context manager entry."""
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit."""
        self.close()


def fetch_html_for_urls(
    urls: List[str],
    max_workers: int = 10,
    timeout: int = 10,
    progress_callback=None
) -> Dict[str, Tuple[Optional[str], Optional[str]]]:
    """
    Convenience function to fetch HTML for multiple URLs.

    Args:
        urls: List of URLs to fetch
        max_workers: Number of concurrent workers
        timeout: Request timeout in seconds
        progress_callback: Optional callback for progress updates

    Returns:
        Dictionary mapping url -> (html_content, error_message)
    """
    with HTMLFetcher(max_workers=max_workers, timeout=timeout) as fetcher:
        return fetcher.fetch_batch(urls, progress_callback)
