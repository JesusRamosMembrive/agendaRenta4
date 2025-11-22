#!/usr/bin/env python3
"""
Full Crawl and Comparison Script
Crawls entire r4.com site and compares with 173 hardcoded URLs
"""

from datetime import datetime

from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Import crawler
from crawler import CRAWLER_CONFIG_FULL, Crawler
from utils import db_cursor


def get_hardcoded_urls():
    """Get the 173 hardcoded URLs from sections table"""
    with db_cursor() as cursor:
        cursor.execute("""
            SELECT id, name, url
            FROM sections
            WHERE active = TRUE
            ORDER BY id
        """)
        return cursor.fetchall()


def run_full_crawl():
    """Run full crawl without limits"""
    print("=" * 80)
    print("FULL CRAWL OF R4.COM")
    print("=" * 80)
    print("\nConfiguration:")
    print(f"  Root URL: {CRAWLER_CONFIG_FULL['root_url']}")
    print(
        f"  Max URLs: {'UNLIMITED' if CRAWLER_CONFIG_FULL['max_urls'] is None else CRAWLER_CONFIG_FULL['max_urls']}"
    )
    print(f"  Max Depth: {CRAWLER_CONFIG_FULL['max_depth']}")
    print(f"  Delay: {CRAWLER_CONFIG_FULL['delay_between_requests']}s")
    print("\n⚠️  This may take a LONG time (potentially hours)")
    print(f"⏱  Started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 80 + "\n")

    # Create crawler instance
    crawler = Crawler(CRAWLER_CONFIG_FULL)

    # Run crawl
    stats = crawler.crawl(created_by="full-crawl-comparison")

    print("\n" + "=" * 80)
    print("CRAWL COMPLETED!")
    print("=" * 80)
    print(f"\n✓ URLs Discovered: {stats['urls_discovered']}")
    print(f"⊘ URLs Skipped: {stats['urls_skipped']}")
    print(f"✗ Errors: {stats['errors']}")
    print(f"⏱  Finished at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 80 + "\n")

    return stats


def compare_urls():
    """Compare discovered URLs with hardcoded URLs"""
    print("=" * 80)
    print("URL COMPARISON ANALYSIS")
    print("=" * 80 + "\n")

    # Get hardcoded URLs
    hardcoded = get_hardcoded_urls()
    hardcoded_urls = set(row["url"] for row in hardcoded)

    print(f"📋 Hardcoded URLs (from sections table): {len(hardcoded_urls)}")

    # Get discovered URLs from latest crawl
    with db_cursor() as cursor:
        # Get latest crawl_run_id
        cursor.execute("""
            SELECT id, urls_discovered
            FROM crawl_runs
            WHERE created_by = 'full-crawl-comparison'
            ORDER BY id DESC
            LIMIT 1
        """)
        crawl_run = cursor.fetchone()

        if not crawl_run:
            print("❌ No full crawl found in database")
            return

        crawl_run_id = crawl_run["id"]
        print(
            f"🕷️  Discovered URLs (crawl_run #{crawl_run_id}): {crawl_run['urls_discovered']}"
        )

        # Get all discovered URLs from this crawl
        cursor.execute(
            """
            SELECT url
            FROM discovered_urls
            WHERE crawl_run_id = %s
        """,
            (crawl_run_id,),
        )
        discovered = cursor.fetchall()
        discovered_urls = set(row["url"] for row in discovered)

    print("\n" + "=" * 80)
    print("COMPARISON RESULTS")
    print("=" * 80 + "\n")

    # Find URLs in hardcoded but NOT discovered
    missing_in_crawl = hardcoded_urls - discovered_urls
    print(
        f"❌ URLs in hardcoded list but NOT discovered by crawler: {len(missing_in_crawl)}"
    )

    if missing_in_crawl:
        print("\n  Missing URLs (first 20):")
        for i, url in enumerate(sorted(missing_in_crawl)[:20], 1):
            print(f"    {i}. {url}")
        if len(missing_in_crawl) > 20:
            print(f"    ... and {len(missing_in_crawl) - 20} more")

    # Find URLs discovered but NOT in hardcoded
    new_in_crawl = discovered_urls - hardcoded_urls
    print(f"\n✨ NEW URLs discovered (not in hardcoded list): {len(new_in_crawl)}")

    if new_in_crawl:
        print("\n  New URLs (first 20):")
        for i, url in enumerate(sorted(new_in_crawl)[:20], 1):
            print(f"    {i}. {url}")
        if len(new_in_crawl) > 20:
            print(f"    ... and {len(new_in_crawl) - 20} more")

    # Find exact matches
    exact_matches = hardcoded_urls & discovered_urls
    print(f"\n✓ URLs in BOTH lists (exact matches): {len(exact_matches)}")

    # Coverage percentage
    coverage = (len(exact_matches) / len(hardcoded_urls)) * 100 if hardcoded_urls else 0
    print(
        f"\n📊 Coverage: {coverage:.1f}% of hardcoded URLs were discovered by crawler"
    )

    print("\n" + "=" * 80)
    print("SUMMARY")
    print("=" * 80)
    print(f"  Hardcoded URLs: {len(hardcoded_urls)}")
    print(f"  Discovered URLs: {len(discovered_urls)}")
    print(f"  Exact Matches: {len(exact_matches)} ({coverage:.1f}%)")
    print(f"  Missing from Crawl: {len(missing_in_crawl)}")
    print(f"  New Discoveries: {len(new_in_crawl)}")
    print("=" * 80 + "\n")

    # Save detailed report
    save_detailed_report(
        hardcoded_urls,
        discovered_urls,
        exact_matches,
        missing_in_crawl,
        new_in_crawl,
        crawl_run_id,
    )


def save_detailed_report(hardcoded, discovered, matches, missing, new, crawl_run_id):
    """Save detailed comparison report to file"""
    filename = f"crawl_comparison_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"

    with open(filename, "w", encoding="utf-8") as f:
        f.write("=" * 80 + "\n")
        f.write("R4.COM CRAWL COMPARISON REPORT\n")
        f.write("=" * 80 + "\n\n")
        f.write(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write(f"Crawl Run ID: {crawl_run_id}\n\n")

        f.write("STATISTICS:\n")
        f.write(f"  - Hardcoded URLs: {len(hardcoded)}\n")
        f.write(f"  - Discovered URLs: {len(discovered)}\n")
        f.write(f"  - Exact Matches: {len(matches)}\n")
        f.write(f"  - Missing from Crawl: {len(missing)}\n")
        f.write(f"  - New Discoveries: {len(new)}\n")
        f.write(f"  - Coverage: {(len(matches) / len(hardcoded) * 100):.1f}%\n\n")

        f.write("=" * 80 + "\n")
        f.write("URLS IN HARDCODED LIST BUT NOT DISCOVERED\n")
        f.write("=" * 80 + "\n\n")
        if missing:
            for url in sorted(missing):
                f.write(f"{url}\n")
        else:
            f.write("(none)\n")

        f.write("\n" + "=" * 80 + "\n")
        f.write("NEW URLS DISCOVERED (NOT IN HARDCODED LIST)\n")
        f.write("=" * 80 + "\n\n")
        if new:
            for url in sorted(new):
                f.write(f"{url}\n")
        else:
            f.write("(none)\n")

        f.write("\n" + "=" * 80 + "\n")
        f.write("EXACT MATCHES (IN BOTH LISTS)\n")
        f.write("=" * 80 + "\n\n")
        if matches:
            for url in sorted(matches):
                f.write(f"{url}\n")
        else:
            f.write("(none)\n")

    print(f"📄 Detailed report saved to: {filename}")


if __name__ == "__main__":
    print("\n🕷️  R4.COM FULL CRAWL AND COMPARISON")
    print("   This script will:")
    print("   1. Crawl the entire r4.com website (NO LIMITS)")
    print("   2. Compare discovered URLs with 173 hardcoded URLs")
    print("   3. Generate a detailed comparison report\n")

    input("Press ENTER to start the full crawl (or Ctrl+C to cancel)...")

    # Step 1: Run full crawl
    stats = run_full_crawl()

    # Step 2: Compare and analyze
    compare_urls()

    print("\n✅ Process completed successfully!")
