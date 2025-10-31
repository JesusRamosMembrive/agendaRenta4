#!/usr/bin/env python3
"""
Monitor Validation Progress
Real-time monitoring of URL validation progress
"""

import os
import time
from datetime import datetime
from dotenv import load_dotenv
from utils import db_cursor

load_dotenv()


def clear_screen():
    """Clear terminal screen"""
    os.system('clear' if os.name != 'nt' else 'cls')


def get_validation_stats():
    """Get current validation statistics"""
    with db_cursor(commit=False) as cursor:
        # Get latest crawl run
        cursor.execute("""
            SELECT id, started_at, urls_discovered
            FROM crawl_runs
            ORDER BY id DESC
            LIMIT 1
        """)
        crawl_run = cursor.fetchone()

        if not crawl_run:
            return None

        # Get validation progress
        cursor.execute("""
            SELECT
                COUNT(*) as total_urls,
                COUNT(*) FILTER (WHERE last_checked IS NOT NULL) as validated,
                COUNT(*) FILTER (WHERE last_checked IS NULL) as pending,
                COUNT(*) FILTER (WHERE is_broken = TRUE) as broken,
                COUNT(*) FILTER (WHERE is_broken = FALSE AND last_checked IS NOT NULL) as ok,
                COUNT(*) FILTER (WHERE status_code >= 300 AND status_code < 400) as redirects,
                COUNT(*) FILTER (WHERE status_code >= 400 AND status_code < 500) as client_errors,
                COUNT(*) FILTER (WHERE status_code >= 500) as server_errors,
                COUNT(*) FILTER (WHERE is_priority = TRUE) as priority_total,
                COUNT(*) FILTER (WHERE is_priority = TRUE AND last_checked IS NOT NULL) as priority_validated
            FROM discovered_urls
            WHERE crawl_run_id = %s
        """, (crawl_run['id'],))

        stats = cursor.fetchone()

        return {
            'crawl_run': crawl_run,
            'stats': stats
        }


def print_progress_bar(current, total, width=50):
    """Print a progress bar"""
    if total == 0:
        percentage = 0
    else:
        percentage = (current / total) * 100

    filled = int(width * current / total) if total > 0 else 0
    bar = '█' * filled + '░' * (width - filled)

    return f"[{bar}] {percentage:.1f}% ({current}/{total})"


def format_time_elapsed(start_time):
    """Format elapsed time"""
    elapsed = datetime.now() - start_time
    minutes = int(elapsed.total_seconds() / 60)
    seconds = int(elapsed.total_seconds() % 60)
    return f"{minutes}m {seconds}s"


def estimate_time_remaining(validated, total, start_time):
    """Estimate time remaining"""
    if validated == 0:
        return "Calculating..."

    elapsed = (datetime.now() - start_time).total_seconds()
    avg_time_per_url = elapsed / validated
    remaining_urls = total - validated
    remaining_seconds = avg_time_per_url * remaining_urls

    minutes = int(remaining_seconds / 60)
    seconds = int(remaining_seconds % 60)

    return f"{minutes}m {seconds}s"


def monitor_validation(refresh_interval=5):
    """
    Monitor validation progress in real-time

    Args:
        refresh_interval: Seconds between updates (default: 5)
    """
    start_time = datetime.now()
    last_validated = 0

    print("=" * 80)
    print("URL VALIDATION MONITOR")
    print("=" * 80)
    print(f"\nStarted: {start_time.strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"Refresh interval: {refresh_interval} seconds")
    print("\nPress Ctrl+C to exit\n")

    try:
        while True:
            data = get_validation_stats()

            if not data:
                print("\n❌ No crawl runs found. Run crawler first.")
                break

            crawl_run = data['crawl_run']
            stats = data['stats']

            # Clear screen and print header
            clear_screen()
            print("=" * 80)
            print("URL VALIDATION MONITOR")
            print("=" * 80)
            print(f"Started: {start_time.strftime('%Y-%m-%d %H:%M:%S')}")
            print(f"Elapsed: {format_time_elapsed(start_time)}")
            print(f"Last update: {datetime.now().strftime('%H:%M:%S')}")
            print("=" * 80)

            # Progress bar
            validated = stats['validated']
            total = stats['total_urls']

            print(f"\n📊 Overall Progress:")
            print(f"   {print_progress_bar(validated, total)}")
            print(f"\n⏱️  Time Remaining: {estimate_time_remaining(validated, total, start_time)}")

            # Velocity calculation
            if validated > last_validated:
                urls_per_second = (validated - last_validated) / refresh_interval
                print(f"⚡ Current Speed: {urls_per_second * 60:.1f} URLs/minute")

            last_validated = validated

            # Statistics
            print("\n📈 Validation Statistics:")
            print(f"   Total URLs:      {total}")
            print(f"   ✅ Validated:    {validated}")
            print(f"   ⏳ Pending:      {stats['pending']}")

            print("\n🎯 Results:")
            print(f"   ✅ OK (2xx, 3xx):         {stats['ok']}")
            print(f"   ❌ Broken:                {stats['broken']}")
            print(f"      └─ 🔁 Redirects:       {stats['redirects']}")
            print(f"      └─ ⚠️  Client Errors:   {stats['client_errors']}")
            print(f"      └─ 💥 Server Errors:   {stats['server_errors']}")

            if stats['priority_total'] > 0:
                print(f"\n⭐ Priority URLs:")
                print(f"   Total:     {stats['priority_total']}")
                print(f"   Validated: {stats['priority_validated']}")

            # Health percentage
            if validated > 0:
                health_pct = (stats['ok'] / validated) * 100
                print(f"\n💚 Health Score: {health_pct:.1f}%")

            # Check if complete
            if validated == total:
                print("\n" + "=" * 80)
                print("✅ VALIDATION COMPLETED!")
                print("=" * 80)
                print(f"\nTotal time: {format_time_elapsed(start_time)}")
                print(f"URLs validated: {validated}")
                print(f"Success rate: {health_pct:.1f}%")
                print(f"\n📄 View results:")
                print(f"   - Web UI: http://localhost:5000/crawler/broken")
                print(f"   - Generate report: python generate_excel_report.py")
                break

            # Wait before next update
            time.sleep(refresh_interval)

    except KeyboardInterrupt:
        print("\n\n⚠️  Monitoring stopped by user")
        print(f"Elapsed time: {format_time_elapsed(start_time)}")
        print(f"Last known progress: {validated}/{total} URLs validated")


if __name__ == '__main__':
    import sys

    # Parse arguments
    refresh_interval = 5
    if len(sys.argv) > 1:
        try:
            refresh_interval = int(sys.argv[1])
        except ValueError:
            print(f"Invalid refresh interval: {sys.argv[1]}")
            print("Usage: python monitor_validation.py [refresh_interval_seconds]")
            sys.exit(1)

    monitor_validation(refresh_interval)
