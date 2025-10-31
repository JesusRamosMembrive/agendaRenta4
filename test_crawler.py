#!/usr/bin/env python3
"""
Test script for Phase 2.1 Crawler
Tests crawler functionality with 50 URL limit
"""

import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Now import crawler after env is loaded
from crawler import Crawler, CRAWLER_CONFIG

def test_crawler():
    """Test crawler with 50 URL limit"""

    print("=" * 60)
    print("Testing Phase 2.1 Crawler")
    print("=" * 60)
    print(f"\nConfiguration:")
    print(f"  Root URL: {CRAWLER_CONFIG['root_url']}")
    print(f"  Max URLs: {CRAWLER_CONFIG['max_urls']}")
    print(f"  Max Depth: {CRAWLER_CONFIG['max_depth']}")
    print(f"  Delay: {CRAWLER_CONFIG['delay_between_requests']}s")
    print("\n" + "=" * 60)
    print("Starting crawl... (this may take a few minutes)")
    print("=" * 60 + "\n")

    # Create crawler instance
    crawler = Crawler(CRAWLER_CONFIG)

    # Run crawl
    stats = crawler.crawl(created_by='test-script')

    # Print results
    print("\n" + "=" * 60)
    print("Crawl Completed!")
    print("=" * 60)
    print(f"\n✓ URLs Discovered: {stats['urls_discovered']}")
    print(f"⊘ URLs Skipped: {stats['urls_skipped']}")
    print(f"✗ Errors: {stats['errors']}")
    print("\n" + "=" * 60)

    # Verify results in database
    from utils import db_cursor

    with db_cursor() as cursor:
        # Get latest crawl run
        cursor.execute("""
            SELECT id, started_at, finished_at, status, urls_discovered
            FROM crawl_runs
            ORDER BY id DESC
            LIMIT 1
        """)
        crawl_run = cursor.fetchone()

        if crawl_run:
            print(f"\nDatabase Verification:")
            print(f"  Crawl Run ID: {crawl_run['id']}")
            print(f"  Status: {crawl_run['status']}")
            print(f"  URLs in DB: {crawl_run['urls_discovered']}")
            print(f"  Started: {crawl_run['started_at']}")
            print(f"  Finished: {crawl_run['finished_at']}")

        # Get sample URLs
        cursor.execute("""
            SELECT url, depth, status_code
            FROM discovered_urls
            ORDER BY id DESC
            LIMIT 5
        """)
        sample_urls = cursor.fetchall()

        if sample_urls:
            print(f"\nSample URLs discovered:")
            for url_row in sample_urls:
                status = url_row['status_code'] or 'pending'
                print(f"  [{url_row['depth']}] {url_row['url']} (status: {status})")

    print("\n" + "=" * 60)
    print("Test completed successfully! ✓")
    print("=" * 60)

if __name__ == '__main__':
    test_crawler()
