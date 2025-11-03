"""
Crawler Progress Tracker
Tracks real-time progress of crawler execution using shared state.
"""

from datetime import datetime
import threading

class CrawlerProgressTracker:
    """
    Singleton class to track crawler progress in-memory.
    Thread-safe for concurrent access.
    """

    _instance = None
    _lock = threading.Lock()

    def __new__(cls):
        if cls._instance is None:
            with cls._lock:
                if cls._instance is None:
                    cls._instance = super().__new__(cls)
                    cls._instance._initialize()
        return cls._instance

    def _initialize(self):
        """Initialize tracker state."""
        self.is_running = False
        self.crawl_run_id = None
        self.started_at = None
        self.urls_discovered = 0
        self.urls_skipped = 0
        self.errors = 0
        self.last_url = None
        self.current_depth = 0
        self.queue_size = 0
        self.estimated_total = None  # Can be set from previous crawl
        self.cancel_requested = False  # Flag to request cancellation

    def start_crawl(self, crawl_run_id, estimated_total=None):
        """
        Mark crawl as started.

        Args:
            crawl_run_id: Database ID of crawl run
            estimated_total: Estimated total URLs (from previous crawl)
        """
        with self._lock:
            self.is_running = True
            self.crawl_run_id = crawl_run_id
            self.started_at = datetime.now()
            self.urls_discovered = 0
            self.urls_skipped = 0
            self.errors = 0
            self.last_url = None
            self.current_depth = 0
            self.queue_size = 0
            self.estimated_total = estimated_total
            self.cancel_requested = False  # Reset cancel flag

    def update_progress(self, urls_discovered=None, urls_skipped=None, errors=None,
                       last_url=None, current_depth=None, queue_size=None):
        """
        Update progress metrics.

        Args:
            urls_discovered: Total URLs discovered so far
            urls_skipped: Total URLs skipped
            errors: Total errors encountered
            last_url: Last URL processed
            current_depth: Current crawl depth
            queue_size: Current queue size
        """
        with self._lock:
            if urls_discovered is not None:
                self.urls_discovered = urls_discovered
            if urls_skipped is not None:
                self.urls_skipped = urls_skipped
            if errors is not None:
                self.errors = errors
            if last_url is not None:
                self.last_url = last_url
            if current_depth is not None:
                self.current_depth = current_depth
            if queue_size is not None:
                self.queue_size = queue_size

    def stop_crawl(self):
        """Mark crawl as finished."""
        with self._lock:
            self.is_running = False

    def request_cancel(self):
        """Request cancellation of current crawl."""
        with self._lock:
            if self.is_running:
                self.cancel_requested = True
                return True
            return False

    def is_cancel_requested(self):
        """Check if cancellation has been requested."""
        with self._lock:
            return self.cancel_requested

    def get_progress(self):
        """
        Get current progress snapshot.

        Returns:
            dict: Progress data including all metrics
        """
        with self._lock:
            if not self.is_running and self.started_at is None:
                return {
                    'is_running': False,
                    'message': 'No hay crawl en ejecución'
                }

            elapsed_seconds = 0
            urls_per_minute = 0
            estimated_remaining_minutes = None

            if self.started_at:
                elapsed = datetime.now() - self.started_at
                elapsed_seconds = int(elapsed.total_seconds())

                # Calculate speed (URLs/min)
                if elapsed_seconds > 0:
                    urls_per_minute = int((self.urls_discovered / elapsed_seconds) * 60)

                # Estimate remaining time if we have estimated_total
                if self.estimated_total and urls_per_minute > 0:
                    remaining_urls = self.estimated_total - self.urls_discovered
                    estimated_remaining_minutes = int(remaining_urls / urls_per_minute)

            # Calculate percentage if we have estimated_total
            percentage = None
            if self.estimated_total and self.estimated_total > 0:
                percentage = int((self.urls_discovered / self.estimated_total) * 100)

            return {
                'is_running': self.is_running,
                'crawl_run_id': self.crawl_run_id,
                'started_at': self.started_at.isoformat() if self.started_at else None,
                'elapsed_seconds': elapsed_seconds,
                'urls_discovered': self.urls_discovered,
                'urls_skipped': self.urls_skipped,
                'errors': self.errors,
                'last_url': self.last_url,
                'current_depth': self.current_depth,
                'queue_size': self.queue_size,
                'urls_per_minute': urls_per_minute,
                'estimated_total': self.estimated_total,
                'percentage': percentage,
                'estimated_remaining_minutes': estimated_remaining_minutes
            }


# Global singleton instance
progress_tracker = CrawlerProgressTracker()
