#!/usr/bin/env python3
"""
Test script for optimized quality checks (PR #1).

Tests the new concurrent HTML fetching and threaded execution.
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
    """Count priority and total URLs for a crawl run."""
    with db_cursor(commit=False) as cursor:
        cursor.execute("""
            SELECT
                COUNT(*) FILTER (WHERE is_priority = TRUE AND active = TRUE AND is_broken = FALSE) as priority_urls,
                COUNT(*) FILTER (WHERE active = TRUE AND is_broken = FALSE) as total_urls
            FROM discovered_urls
            WHERE crawl_run_id = %s
        """, (crawl_run_id,))

        row = cursor.fetchone()
        return row['priority_urls'], row['total_urls']


def test_single_check(crawl_run_id, check_type, scope='priority', max_workers=10):
    """
    Test a single quality check with timing.

    Args:
        crawl_run_id: Crawl run ID to test
        check_type: 'image_quality' or 'spell_check'
        scope: 'priority' or 'all'
        max_workers: Number of concurrent workers
    """
    logger.info(f"\n{'='*80}")
    logger.info(f"Testing {check_type} with scope={scope} and {max_workers} workers")
    logger.info(f"{'='*80}\n")

    runner = PostCrawlQualityRunner(crawl_run_id, max_workers=max_workers)

    start_time = time.time()

    if check_type == 'image_quality':
        result = runner._run_image_quality_check(scope=scope)
    elif check_type == 'spell_check':
        result = runner._run_spell_check(scope=scope)
    else:
        logger.error(f"Unknown check type: {check_type}")
        return None

    elapsed = time.time() - start_time

    logger.info(f"\n{'='*80}")
    logger.info(f"RESULTS for {check_type} (scope={scope}, workers={max_workers})")
    logger.info(f"{'='*80}")
    logger.info(f"Status: {result['status']}")
    logger.info(f"Message: {result['message']}")
    logger.info(f"Stats: {result['stats']}")
    logger.info(f"Total time: {elapsed:.1f}s")
    logger.info(f"{'='*80}\n")

    return result


def main():
    """Run optimized quality checks test."""

    # Get latest crawl run
    crawl_run_id = get_latest_crawl_run_id()
    if not crawl_run_id:
        sys.exit(1)

    # Count URLs
    priority_count, total_count = count_priority_urls(crawl_run_id)
    logger.info(f"Priority URLs: {priority_count}")
    logger.info(f"Total URLs: {total_count}\n")

    if priority_count == 0:
        logger.error("No priority URLs found. Please mark some URLs as priority first.")
        sys.exit(1)

    # Test cases
    test_cases = [
        # (check_type, scope, max_workers)
        ('image_quality', 'priority', 10),
        ('spell_check', 'priority', 10),
    ]

    results = []

    for check_type, scope, max_workers in test_cases:
        try:
            result = test_single_check(crawl_run_id, check_type, scope, max_workers)
            results.append((check_type, scope, max_workers, result))

            # Small delay between tests
            time.sleep(2)

        except Exception as e:
            logger.error(f"Error testing {check_type}: {e}", exc_info=True)

    # Print summary
    logger.info(f"\n{'='*80}")
    logger.info("SUMMARY OF ALL TESTS")
    logger.info(f"{'='*80}")

    for check_type, scope, max_workers, result in results:
        if result:
            stats = result['stats']
            logger.info(
                f"{check_type:20s} | scope={scope:8s} | workers={max_workers:2d} | "
                f"{stats['successful']:3d}/{stats['total']:3d} successful | "
                f"{stats.get('elapsed_seconds', 0):6.1f}s | "
                f"{stats.get('urls_per_second', 0):5.1f} URLs/s"
            )

    logger.info(f"{'='*80}\n")
    logger.info("✅ All tests completed!")


if __name__ == '__main__':
    main()
