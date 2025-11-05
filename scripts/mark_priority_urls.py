#!/usr/bin/env python3
"""
Mark Priority URLs Script

Synchronizes the is_priority flag in discovered_urls based on sections table.

Business Rule:
- If a URL exists in sections (manual URLs) → is_priority = TRUE
- If a URL does NOT exist in sections → is_priority = FALSE

This script should be run:
- After each crawl (automatically)
- After adding/removing URLs in sections (manually)
- On demand via command line

Usage:
    python scripts/mark_priority_urls.py
"""

import sys
import os

# Add parent directory to path to import utils
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from utils import db_cursor


def sync_priority_urls():
    """
    Synchronize is_priority flag in discovered_urls based on sections table.

    Returns:
        dict: Statistics about the synchronization
    """

    print("Starting priority URL synchronization...")
    print("=" * 60)

    with db_cursor() as cursor:
        # Step 1: Get count of URLs in sections
        cursor.execute("SELECT COUNT(*) as count FROM sections")
        sections_count = cursor.fetchone()['count']
        print(f"✓ Found {sections_count} URLs in sections (Gestión de URLs)")

        # Step 2: Get current priority status
        cursor.execute("""
            SELECT
                COUNT(*) FILTER (WHERE is_priority = TRUE) as priority_count,
                COUNT(*) FILTER (WHERE is_priority = FALSE) as non_priority_count,
                COUNT(*) as total_count
            FROM discovered_urls
        """)
        before_stats = cursor.fetchone()
        print(f"✓ Before sync: {before_stats['priority_count']} priority, "
              f"{before_stats['non_priority_count']} non-priority, "
              f"{before_stats['total_count']} total")

        # Step 3: Reset all is_priority to FALSE
        cursor.execute("UPDATE discovered_urls SET is_priority = FALSE")
        print(f"✓ Reset all discovered_urls to non-priority")

        # Step 4: Mark as priority URLs that exist in sections
        # Match by normalized URL (remove trailing slashes for comparison)
        cursor.execute("""
            UPDATE discovered_urls du
            SET is_priority = TRUE
            FROM sections s
            WHERE TRIM(TRAILING '/' FROM du.url) = TRIM(TRAILING '/' FROM s.url)
        """)
        marked_count = cursor.rowcount
        print(f"✓ Marked {marked_count} URLs as priority (matched with sections)")

        # Step 5: Get final statistics
        cursor.execute("""
            SELECT
                COUNT(*) FILTER (WHERE is_priority = TRUE) as priority_count,
                COUNT(*) FILTER (WHERE is_priority = FALSE) as non_priority_count,
                COUNT(*) as total_count
            FROM discovered_urls
        """)
        after_stats = cursor.fetchone()

        # Step 6: Check for unmatched sections
        cursor.execute("""
            SELECT s.url, s.name
            FROM sections s
            LEFT JOIN discovered_urls du
                ON TRIM(TRAILING '/' FROM s.url) = TRIM(TRAILING '/' FROM du.url)
            WHERE du.id IS NULL
            ORDER BY s.name
        """)
        unmatched = cursor.fetchall()

        print("=" * 60)
        print("SYNCHRONIZATION RESULTS:")
        print(f"  • URLs in sections: {sections_count}")
        print(f"  • URLs marked as priority: {after_stats['priority_count']}")
        print(f"  • URLs marked as non-priority: {after_stats['non_priority_count']}")
        print(f"  • Total discovered URLs: {after_stats['total_count']}")

        if unmatched:
            print(f"\n⚠️  WARNING: {len(unmatched)} URLs in sections NOT found in discovered_urls:")
            for row in unmatched[:10]:  # Show first 10
                print(f"     - {row['name']}: {row['url']}")
            if len(unmatched) > 10:
                print(f"     ... and {len(unmatched) - 10} more")
            print(f"\n   These URLs may not have been crawled yet.")

        print("=" * 60)
        print("✅ Synchronization completed successfully!")

        return {
            'sections_count': sections_count,
            'before': {
                'priority': before_stats['priority_count'],
                'non_priority': before_stats['non_priority_count'],
                'total': before_stats['total_count']
            },
            'after': {
                'priority': after_stats['priority_count'],
                'non_priority': after_stats['non_priority_count'],
                'total': after_stats['total_count']
            },
            'marked_count': marked_count,
            'unmatched_count': len(unmatched)
        }


if __name__ == '__main__':
    try:
        stats = sync_priority_urls()
        sys.exit(0)
    except Exception as e:
        print(f"\n❌ ERROR: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        sys.exit(1)
