#!/usr/bin/env python3
"""
Monitor active crawl progress in real-time
"""

import os
from dotenv import load_dotenv
from utils import db_cursor
from datetime import datetime
import time
import sys

load_dotenv()

def monitor_crawl():
    """Monitor the latest crawl run progress"""

    try:
        while True:
            os.system('clear' if os.name != 'nt' else 'cls')

            print("=" * 80)
            print("🕷️  CRAWL PROGRESS MONITOR")
            print("=" * 80)
            print(f"Updated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
            print("\n")

            with db_cursor() as cursor:
                # Get latest crawl run
                cursor.execute("""
                    SELECT
                        id,
                        started_at,
                        status,
                        urls_discovered,
                        created_by
                    FROM crawl_runs
                    ORDER BY id DESC
                    LIMIT 1
                """)

                crawl_run = cursor.fetchone()

                if not crawl_run:
                    print("No active crawl found.")
                    break

                print(f"Crawl Run ID: {crawl_run['id']}")
                print(f"Status: {crawl_run['status']}")
                print(f"Started: {crawl_run['started_at']}")
                print(f"Created By: {crawl_run['created_by']}")
                print(f"\n{'=' * 80}")

                # Get statistics
                cursor.execute("""
                    SELECT
                        COUNT(*) as total,
                        MAX(depth) as max_depth,
                        COUNT(DISTINCT depth) as depth_levels
                    FROM discovered_urls
                    WHERE crawl_run_id = %s
                """, (crawl_run['id'],))

                stats = cursor.fetchone()

                print(f"\n📊 STATISTICS:")
                print(f"   Total URLs Discovered: {stats['total']}")
                print(f"   Maximum Depth Reached: {stats['max_depth']}")
                print(f"   Depth Levels: {stats['depth_levels']}")

                # URLs by depth
                cursor.execute("""
                    SELECT depth, COUNT(*) as count
                    FROM discovered_urls
                    WHERE crawl_run_id = %s
                    GROUP BY depth
                    ORDER BY depth
                """, (crawl_run['id'],))

                depth_stats = cursor.fetchall()

                print(f"\n📈 URLs BY DEPTH:")
                for row in depth_stats:
                    print(f"   Depth {row['depth']}: {row['count']} URLs")

                # Recent URLs
                cursor.execute("""
                    SELECT url, depth, discovered_at
                    FROM discovered_urls
                    WHERE crawl_run_id = %s
                    ORDER BY id DESC
                    LIMIT 5
                """, (crawl_run['id'],))

                recent = cursor.fetchall()

                print(f"\n🆕 LATEST DISCOVERIES:")
                for row in recent:
                    print(f"   [{row['depth']}] {row['url'][:70]}...")

                if crawl_run['status'] == 'completed':
                    print(f"\n✅ Crawl completed!")
                    break
                elif crawl_run['status'] == 'failed':
                    print(f"\n❌ Crawl failed!")
                    break

                print(f"\n\n⏳ Crawling in progress... (refreshing every 5 seconds)")
                print(f"   Press Ctrl+C to stop monitoring (crawl will continue)")

            time.sleep(5)

    except KeyboardInterrupt:
        print(f"\n\n✋ Monitoring stopped (crawl continues in background)")
        sys.exit(0)

if __name__ == '__main__':
    monitor_crawl()
