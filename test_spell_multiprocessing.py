#!/usr/bin/env python3
"""
Test script for spell check with multiprocessing optimization.

Tests ProcessPoolExecutor vs ThreadPoolExecutor for CPU-bound spell checking.
"""

import sys
import time
import logging
from utils import db_cursor
from calidad.post_crawl_runner import PostCrawlQualityRunner

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


def get_latest_crawl_run_id():
    """Get the most recent crawl run ID."""
    with db_cursor(commit=False) as cursor:
        cursor.execute("""
            SELECT id, started_at, urls_discovered
            FROM crawl_runs
            ORDER BY id DESC
            LIMIT 1
        """)
        row = cursor.fetchone()

        if not row:
            logger.error("No crawl runs found in database")
            return None

        logger.info(f"Using crawl run #{row['id']} from {row['started_at']} ({row['urls_discovered']} URLs)")
        return row['id']


def count_priority_urls(crawl_run_id):
    """Count priority URLs for a crawl run."""
    with db_cursor(commit=False) as cursor:
        cursor.execute("""
            SELECT COUNT(*) as priority_urls
            FROM discovered_urls
            WHERE crawl_run_id = %s
              AND is_priority = TRUE
              AND active = TRUE
              AND is_broken = FALSE
        """, (crawl_run_id,))

        row = cursor.fetchone()
        return row['priority_urls']


def test_spell_check(crawl_run_id, max_workers=10):
    """
    Test spell check with multiprocessing.

    Args:
        crawl_run_id: Crawl run ID to test
        max_workers: Number of parallel processes
    """
    logger.info(f"\n{'='*80}")
    logger.info(f"Testing SPELL CHECK with {max_workers} CPU workers (ProcessPoolExecutor)")
    logger.info(f"{'='*80}\n")

    runner = PostCrawlQualityRunner(crawl_run_id, max_workers=max_workers)

    start_time = time.time()
    result = runner._run_spell_check(scope='priority')
    elapsed = time.time() - start_time

    logger.info(f"\n{'='*80}")
    logger.info(f"RESULTS for spell_check (workers={max_workers})")
    logger.info(f"{'='*80}")
    logger.info(f"Status: {result['status']}")
    logger.info(f"Message: {result['message']}")
    logger.info(f"Stats: {result['stats']}")
    logger.info(f"Total time: {elapsed:.1f}s")
    logger.info(f"{'='*80}\n")

    return result


def main():
    """Run spell check multiprocessing test."""

    # Get latest crawl run
    crawl_run_id = get_latest_crawl_run_id()
    if not crawl_run_id:
        sys.exit(1)

    # Count URLs
    priority_count = count_priority_urls(crawl_run_id)
    logger.info(f"Priority URLs to check: {priority_count}\n")

    if priority_count == 0:
        logger.error("No priority URLs found. Please mark some URLs as priority first.")
        sys.exit(1)

    # Test with different worker counts
    test_cases = [
        # max_workers
        10,  # Default
    ]

    results = []

    for max_workers in test_cases:
        try:
            result = test_spell_check(crawl_run_id, max_workers)
            results.append((max_workers, result))

            # Small delay between tests
            time.sleep(2)

        except Exception as e:
            logger.error(f"Error testing with {max_workers} workers: {e}", exc_info=True)

    # Print summary
    logger.info(f"\n{'='*80}")
    logger.info("SUMMARY OF SPELL CHECK TESTS")
    logger.info(f"{'='*80}")

    for max_workers, result in results:
        if result:
            stats = result['stats']
            logger.info(
                f"Workers: {max_workers:2d} | "
                f"{stats['successful']:3d}/{stats['total']:3d} successful | "
                f"{stats.get('elapsed_seconds', 0):6.1f}s | "
                f"{stats.get('urls_per_second', 0):5.1f} URLs/s"
            )

    logger.info(f"{'='*80}\n")
    logger.info("✅ Spell check multiprocessing test completed!")


if __name__ == '__main__':
    main()
