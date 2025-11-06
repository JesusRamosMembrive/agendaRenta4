#!/usr/bin/env python3
"""
URL Validation Script
Validates discovered URLs and updates database with status codes and response times
"""

from datetime import datetime

from dotenv import load_dotenv

from crawler.validator import URLValidator, get_validation_config
from utils import db_cursor

load_dotenv()


def get_urls_to_validate(priority_only=False, crawl_run_id=None):
    """
    Get URLs that need validation.

    Args:
        priority_only: If True, only validate priority URLs
        crawl_run_id: Specific crawl run to validate (defaults to latest)

    Returns:
        List of tuples (url_id, url, previous_status_code)
    """
    with db_cursor() as cursor:
        # Get latest crawl run if not specified
        if crawl_run_id is None:
            cursor.execute("""
                SELECT id FROM crawl_runs
                ORDER BY id DESC
                LIMIT 1
            """)
            result = cursor.fetchone()
            if not result:
                print("❌ No crawl runs found. Run crawler first.")
                return []
            crawl_run_id = result["id"]

        # Build query
        query = """
            SELECT
                id,
                url,
                status_code
            FROM discovered_urls
            WHERE crawl_run_id = %s
        """

        params = [crawl_run_id]

        if priority_only:
            query += " AND is_priority = TRUE"

        query += " ORDER BY is_priority DESC, id"

        cursor.execute(query, params)
        return cursor.fetchall()


def validate_urls(priority_only=False, crawl_run_id=None):
    """
    Main validation function.

    Args:
        priority_only: If True, only validate priority URLs
        crawl_run_id: Specific crawl run to validate
    """

    print("=" * 80)
    print("URL VALIDATION - PHASE 2.2")
    print("=" * 80)

    # Get URLs to validate
    print("\n1. Getting URLs to validate...")
    urls = get_urls_to_validate(priority_only, crawl_run_id)

    if not urls:
        print("   ⚠️  No URLs found to validate")
        return

    priority_count = sum(1 for u in urls if u.get("is_priority", False))

    print(f"   ✓ Found {len(urls)} URLs to validate")
    if priority_only:
        print("   ⭐ Validating ONLY priority URLs")
    else:
        print(f"   ⭐ Priority URLs: {priority_count}")
        print(f"   📄 Non-priority URLs: {len(urls) - priority_count}")

    # Confirm before proceeding
    print(f"\n⚠️  This will make {len(urls)} HTTP requests to validate URLs.")
    print(f"   Estimated time: ~{len(urls) * 0.5 / 60:.1f} minutes (rate limited)")

    response = input("\n   Proceed with validation? (y/n): ").strip().lower()
    if response != "y":
        print("\n   ❌ Validation cancelled by user")
        return

    # Create validator
    print("\n2. Initializing validator...")
    config = get_validation_config()
    validator = URLValidator(config)

    print(f"   ✓ Timeout: {config['timeout']}s")
    print(
        f"   ✓ Rate limit: {1 / config['delay_between_requests']:.1f} requests/second"
    )

    # Prepare URLs for validation
    urls_to_validate = [(url["id"], url["url"], url.get("status_code")) for url in urls]

    # Validate
    print("\n3. Validating URLs...")
    print(f"   Started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

    start_time = datetime.now()
    stats = validator.validate_batch(urls_to_validate, track_changes=True)
    end_time = datetime.now()

    duration = (end_time - start_time).total_seconds()

    # Print results
    print("\n" + "=" * 80)
    print("VALIDATION RESULTS")
    print("=" * 80)

    print(f"\n⏱️  Duration: {duration:.1f} seconds ({duration / 60:.1f} minutes)")
    print("\n📊 Statistics:")
    print(f"   - Total URLs validated: {stats['validated']}")
    print(f"   - ✅ OK (2xx, 3xx):     {stats['ok']}")
    print(f"   - ❌ Broken (4xx, 5xx): {stats['broken']}")
    print(f"   - 🔄 Redirects:         {stats['redirects']}")
    print(f"   - ⚠️  Errors (timeout): {stats['errors']}")

    # Calculate percentages
    if stats["validated"] > 0:
        ok_pct = (stats["ok"] / stats["validated"]) * 100
        broken_pct = (stats["broken"] / stats["validated"]) * 100

        print("\n📈 Health:")
        print(f"   - OK:     {ok_pct:.1f}%")
        print(f"   - Broken: {broken_pct:.1f}%")

    # Get broken URLs summary
    print("\n4. Checking broken URLs...")
    with db_cursor() as cursor:
        cursor.execute(
            """
            SELECT
                COUNT(*) FILTER (WHERE is_priority = TRUE) as priority_broken,
                COUNT(*) FILTER (WHERE is_priority = FALSE) as non_priority_broken,
                COUNT(*) as total_broken
            FROM discovered_urls
            WHERE is_broken = TRUE AND crawl_run_id = %s
        """,
            (crawl_run_id if crawl_run_id else urls[0]["id"],),
        )

        broken_stats = cursor.fetchone()

        print("\n   ⚠️  Broken URLs found:")
        print(f"   - ⭐ Priority:     {broken_stats['priority_broken']}")
        print(f"   - 📄 Non-priority: {broken_stats['non_priority_broken']}")
        print(f"   - Total:          {broken_stats['total_broken']}")

    print("\n" + "=" * 80)
    print("✅ VALIDATION COMPLETED")
    print("=" * 80)

    print("\n📄 Next steps:")
    print('   - View broken links: python -c "from utils import db_cursor; ..."')
    print("   - Generate Excel report: python generate_excel_report.py")
    print("   - View in UI: http://localhost:5000/crawler/broken")

    return stats


if __name__ == "__main__":
    import sys

    priority_only = "--priority-only" in sys.argv or "-p" in sys.argv

    if priority_only:
        print("\n🎯 PRIORITY MODE: Validating only the 117 priority URLs\n")
    else:
        print("\n🌐 FULL MODE: Validating all discovered URLs\n")

    validate_urls(priority_only=priority_only)
