#!/usr/bin/env python3
"""
Mark Priority URLs
Marks the 117 manually audited URLs from sections table as priority in discovered_urls
"""

import os
from dotenv import load_dotenv
from utils import db_cursor

load_dotenv()

def get_priority_urls():
    """Get active URLs from sections table (manually curated list)"""
    with db_cursor() as cursor:
        cursor.execute("""
            SELECT id, name, url
            FROM sections
            WHERE active = TRUE
            ORDER BY id
        """)
        return cursor.fetchall()

def mark_priority_in_discovered():
    """Mark priority URLs in discovered_urls table"""

    print("=" * 80)
    print("MARKING PRIORITY URLs")
    print("=" * 80)

    # Get priority URLs from sections
    print("\n1. Getting priority URLs from sections table...")
    priority_urls = get_priority_urls()
    print(f"   ✓ Found {len(priority_urls)} active URLs in sections table")

    # Mark them as priority in discovered_urls
    print("\n2. Marking URLs as priority in discovered_urls...")

    with db_cursor() as cursor:
        marked_count = 0
        not_found_count = 0
        not_found_urls = []

        for section in priority_urls:
            url = section['url']

            # Check if URL exists in discovered_urls
            cursor.execute("""
                SELECT id FROM discovered_urls WHERE url = %s
            """, (url,))

            result = cursor.fetchone()

            if result:
                # Mark as priority
                cursor.execute("""
                    UPDATE discovered_urls
                    SET is_priority = TRUE
                    WHERE url = %s
                """, (url,))
                marked_count += 1
            else:
                not_found_count += 1
                not_found_urls.append({
                    'name': section['name'],
                    'url': url
                })

        # Commit changes
        cursor.connection.commit()

    # Print results
    print(f"\n   ✓ Marked {marked_count} URLs as priority")
    if not_found_count > 0:
        print(f"   ⚠ {not_found_count} URLs NOT FOUND in discovered_urls")

    # Show statistics
    print("\n3. Verifying results...")
    with db_cursor() as cursor:
        cursor.execute("""
            SELECT
                COUNT(*) FILTER (WHERE is_priority = TRUE) as priority_urls,
                COUNT(*) FILTER (WHERE is_priority = FALSE) as non_priority_urls,
                COUNT(*) as total_urls
            FROM discovered_urls
        """)

        stats = cursor.fetchone()

        print(f"\n   Statistics:")
        print(f"   - Priority URLs:     {stats['priority_urls']}")
        print(f"   - Non-Priority URLs: {stats['non_priority_urls']}")
        print(f"   - Total URLs:        {stats['total_urls']}")

    # Show not found URLs if any
    if not_found_urls:
        print("\n" + "=" * 80)
        print("⚠ URLs NOT FOUND in Discovered URLs")
        print("=" * 80)
        print(f"\nTotal: {len(not_found_urls)}\n")

        for i, item in enumerate(not_found_urls, 1):
            print(f"{i}. {item['name']}")
            print(f"   URL: {item['url']}")
            print()

    print("\n" + "=" * 80)
    print("✅ PRIORITY URLS MARKED SUCCESSFULLY")
    print("=" * 80)

    return marked_count, not_found_count

if __name__ == '__main__':
    marked, not_found = mark_priority_in_discovered()

    print(f"\n📊 Summary:")
    print(f"   - URLs marked as priority: {marked}")
    print(f"   - URLs not found: {not_found}")
    print(f"   - Success rate: {(marked / (marked + not_found) * 100):.1f}%")
    print()
