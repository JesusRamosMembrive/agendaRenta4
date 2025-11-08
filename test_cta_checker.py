#!/usr/bin/env python3
"""
Test script for CTA Checker
Tests the checker with example URLs
"""

from calidad.ctas import CTAChecker
from utils import get_db_connection
import json

def test_checker():
    """Test the CTA checker with example URLs"""
    print("="*80)
    print("🧪 Testing CTA Checker")
    print("="*80 + "\n")

    # Get test URLs from sections table
    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            SELECT id, url FROM sections
            ORDER BY id LIMIT 3
        """)

        test_urls = cursor.fetchall()

        if not test_urls:
            print("❌ No URLs found in sections table")
            return

        # Create checker
        checker = CTAChecker()

        for row in test_urls:
            url_id = row[0]
            url = row[1]

            print(f"\n{'='*80}")
            print(f"Testing URL #{url_id}: {url}")
            print(f"{'='*80}\n")

            try:
                # Run check
                result = checker.check(url)

                print(f"✅ Check completed!")
                print(f"Status: {result.status}")
                print(f"Score: {result.score}/100")
                print(f"Message: {result.message}")
                print(f"Issues found: {result.issues_found}")
                print(f"Execution time: {result.execution_time_ms}ms")

                # Print details
                print(f"\n📊 Details:")
                print(f"  Total rules: {result.details.get('total_rules', 0)}")
                print(f"  Required rules: {result.details.get('required_rules', 0)}")
                print(f"  Optional rules: {result.details.get('optional_rules', 0)}")
                print(f"  CTAs found: {result.details.get('found_ctas', 0)}")

                # Print missing CTAs
                missing_required = result.details.get('missing_required', [])
                if missing_required:
                    print(f"\n  ❌ Missing required CTAs:")
                    for cta in missing_required:
                        print(f"    - '{cta['expected_text']}' → {cta['expected_url']}")

                # Print incorrect URLs
                incorrect_urls = result.details.get('incorrect_urls', [])
                if incorrect_urls:
                    print(f"\n  ⚠️  CTAs with incorrect URLs:")
                    for cta in incorrect_urls:
                        print(f"    - '{cta['cta_text']}'")
                        print(f"      Found: {cta['found_url']}")
                        print(f"      Expected: {cta['expected_url']}")

                # Print matched CTAs
                matched_ctas = result.details.get('matched_ctas', [])
                if matched_ctas:
                    print(f"\n  ✅ Matched CTAs:")
                    for cta in matched_ctas[:5]:  # Show first 5
                        print(f"    - '{cta['text']}' → {cta['url'][:50]}...")

                print()

            except Exception as e:
                print(f"❌ Error checking URL: {e}")
                import traceback
                traceback.print_exc()

        print("\n" + "="*80)
        print("✅ Test completed!")
        print("="*80)

    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    test_checker()
