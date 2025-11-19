#!/usr/bin/env python3
"""
Run CTA validation on a small batch (first 10 priority URLs) for testing.
"""

import json
import time
import requests
from calidad.ctas import CTAChecker
from utils import get_db_connection


def main():
    print("🚀 Starting Small Batch CTA Validation (10 URLs)")
    print("="*80)

    # Get first 10 priority URLs
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id, url
        FROM discovered_urls
        WHERE is_priority = TRUE
        ORDER BY url
        LIMIT 10
    """)

    urls = cursor.fetchall()
    cursor.close()
    conn.close()

    print(f"\n✅ Found {len(urls)} URLs to validate\n")

    # Create checker
    checker = CTAChecker(config={"timeout": 10})

    results = []

    for i, (url_id, url) in enumerate(urls, 1):
        print(f"[{i}/{len(urls)}] Validating: {url[:70]}...")

        try:
            # Fetch HTML
            response = requests.get(
                url,
                timeout=10,
                headers={'User-Agent': 'Mozilla/5.0 (compatible; AgendaRenta4-CTA/1.0)'}
            )
            response.raise_for_status()
            html_content = response.text

            # Run validation
            result = checker.check(url, html_content)

            # Save to database
            conn = get_db_connection()
            cursor = conn.cursor()

            cursor.execute("""
                INSERT INTO quality_checks (
                    discovered_url_id, check_type, status, score, message,
                    details, issues_found, execution_time_ms
                )
                VALUES (%s, %s, %s, %s, %s, %s::jsonb, %s, %s)
            """, (
                url_id, 'cta_validation', result.status, result.score,
                result.message, json.dumps(result.details), result.issues_found,
                result.execution_time_ms
            ))

            conn.commit()
            cursor.close()
            conn.close()

            # Display result
            status_icon = {'ok': '✅', 'warning': '⚠️', 'error': '❌'}.get(result.status, '❓')
            print(f"  {status_icon} Score: {result.score}/100 - {result.message}")

            # Show objective issues
            obj = result.details.get('objective_issues', {})
            if obj.get('broken_links'):
                print(f"     🔗 {len(obj['broken_links'])} broken links")
            if obj.get('spelling_errors'):
                print(f"     ✏️  {len(obj['spelling_errors'])} spelling errors")
            if obj.get('html_issues'):
                print(f"     🏷️  {len(obj['html_issues'])} HTML issues")
            if obj.get('duplicates'):
                print(f"     🔄 {len(obj['duplicates'])} duplicate CTAs")

            results.append(result)

        except Exception as e:
            print(f"  ❌ Error: {str(e)}")

        print()

    # Summary
    print("="*80)
    print("📊 SUMMARY")
    print("="*80)

    if results:
        avg_score = sum(r.score for r in results) / len(results)
        by_status = {'ok': 0, 'warning': 0, 'error': 0}
        for r in results:
            by_status[r.status] = by_status.get(r.status, 0) + 1

        print(f"\nTotal validated: {len(results)}")
        print(f"Average score: {avg_score:.1f}/100")
        print(f"\nStatus distribution:")
        print(f"  ✅ OK:      {by_status.get('ok', 0)}")
        print(f"  ⚠️  Warning: {by_status.get('warning', 0)}")
        print(f"  ❌ Error:   {by_status.get('error', 0)}")

    print(f"\n✅ Validation completed!")
    print(f"🔍 View results at: http://localhost:5000/crawler/cta-results\n")


if __name__ == "__main__":
    main()
