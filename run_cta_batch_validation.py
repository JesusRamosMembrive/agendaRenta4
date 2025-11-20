#!/usr/bin/env python3
"""
Run CTA validation on priority URLs in batch.

This script validates all priority URLs and saves results to the database.
"""

import json
import time
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor, as_completed

import requests
from calidad.ctas import CTAChecker
from utils import get_db_connection


def get_priority_urls():
    """Get list of priority URLs from database."""
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id, url
        FROM discovered_urls
        WHERE is_priority = TRUE
        ORDER BY url
    """)

    urls = cursor.fetchall()
    cursor.close()
    conn.close()

    return urls


def fetch_html(url, timeout=10):
    """Fetch HTML content for a URL."""
    try:
        response = requests.get(
            url,
            timeout=timeout,
            headers={'User-Agent': 'Mozilla/5.0 (compatible; AgendaRenta4-CTA/1.0)'}
        )
        response.raise_for_status()
        return response.text
    except Exception as e:
        print(f"  ⚠️  Failed to fetch {url}: {str(e)}")
        return None


def save_check_result(url_id, url, result):
    """Save validation result to database."""
    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            INSERT INTO quality_checks (
                discovered_url_id,
                check_type,
                status,
                score,
                message,
                details,
                issues_found,
                execution_time_ms
            )
            VALUES (%s, %s, %s, %s, %s, %s::jsonb, %s, %s)
        """, (
            url_id,
            'cta_validation',
            result.status,
            result.score,
            result.message,
            json.dumps(result.details),
            result.issues_found,
            result.execution_time_ms
        ))

        conn.commit()

    except Exception as e:
        print(f"  ❌ Failed to save result for {url}: {str(e)}")
        conn.rollback()

    finally:
        cursor.close()
        conn.close()


def validate_url(url_id, url, checker):
    """Validate a single URL."""
    try:
        # Fetch HTML
        html_content = fetch_html(url)
        if not html_content:
            return None

        # Run validation
        result = checker.check(url, html_content)

        # Save to database
        save_check_result(url_id, url, result)

        return {
            'url': url,
            'status': result.status,
            'score': result.score,
            'issues': result.issues_found,
            'obj_issues': result.details.get('objective_issues', {}),
        }

    except Exception as e:
        print(f"  ❌ Error validating {url}: {str(e)}")
        return None


def print_summary(results):
    """Print summary of validation results."""
    print(f"\n{'='*80}")
    print("📊 VALIDATION SUMMARY")
    print(f"{'='*80}")

    total = len(results)
    by_status = {'ok': 0, 'warning': 0, 'error': 0}
    total_score = 0

    broken_links = []
    spelling_errors = []
    html_issues = []
    duplicates = []

    for r in results:
        if r:
            by_status[r['status']] = by_status.get(r['status'], 0) + 1
            total_score += r['score']

            # Collect objective issues
            obj = r.get('obj_issues', {})
            if obj.get('broken_links'):
                broken_links.extend([(r['url'], bl) for bl in obj['broken_links']])
            if obj.get('spelling_errors'):
                spelling_errors.extend([(r['url'], se) for se in obj['spelling_errors']])
            if obj.get('html_issues'):
                html_issues.extend([(r['url'], hi) for hi in obj['html_issues']])
            if obj.get('duplicates'):
                duplicates.extend([(r['url'], dup) for dup in obj['duplicates']])

    avg_score = total_score / total if total > 0 else 0

    print(f"\nTotal URLs validated: {total}")
    print(f"Average score: {avg_score:.1f}/100")
    print(f"\nStatus distribution:")
    print(f"  ✅ OK:      {by_status['ok']:3d} ({by_status['ok']/total*100:.1f}%)")
    print(f"  ⚠️  Warning: {by_status['warning']:3d} ({by_status['warning']/total*100:.1f}%)")
    print(f"  ❌ Error:   {by_status['error']:3d} ({by_status['error']/total*100:.1f}%)")

    # Objective issues summary
    print(f"\n{'='*80}")
    print("🔍 OBJECTIVE ISSUES FOUND")
    print(f"{'='*80}")

    print(f"\n🔗 Broken Links: {len(broken_links)}")
    if broken_links:
        for url, bl in broken_links[:10]:  # Show first 10
            print(f"  • {url}")
            print(f"    CTA: '{bl['cta_text']}' → {bl['cta_href']}")
            print(f"    Error: {bl['error']}")
        if len(broken_links) > 10:
            print(f"  ... and {len(broken_links) - 10} more")

    print(f"\n✏️  Spelling Errors: {len(spelling_errors)}")
    if spelling_errors:
        for url, se in spelling_errors[:5]:  # Show first 5
            print(f"  • {url}")
            print(f"    CTA: '{se['cta_text']}'")
            for word_info in se['misspelled_words'][:2]:
                word = word_info['word']
                suggestions = ', '.join(word_info['suggestions'][:2]) if word_info['suggestions'] else 'none'
                print(f"    Word: '{word}' → {suggestions}")
        if len(spelling_errors) > 5:
            print(f"  ... and {len(spelling_errors) - 5} more")

    print(f"\n🏷️  HTML Issues: {len(html_issues)}")
    if html_issues:
        for url, hi in html_issues[:10]:  # Show first 10
            print(f"  • {url}")
            print(f"    CTA: '{hi['cta_text']}'")
            print(f"    Issues: {', '.join(hi['issues'])}")
        if len(html_issues) > 10:
            print(f"  ... and {len(html_issues) - 10} more")

    print(f"\n🔄 Duplicate CTAs: {len(duplicates)}")
    if duplicates:
        for url, dup in duplicates[:5]:  # Show first 5
            print(f"  • {url}")
            print(f"    Text: '{dup['text']}' ({dup['url_count']} different URLs)")
        if len(duplicates) > 5:
            print(f"  ... and {len(duplicates) - 5} more")

    print(f"\n{'='*80}\n")


def main():
    """Main execution."""
    print("🚀 Starting CTA Batch Validation on Priority URLs")
    print("="*80)

    # Get priority URLs
    print("\n📋 Fetching priority URLs...")
    urls = get_priority_urls()
    print(f"✅ Found {len(urls)} priority URLs")

    # Create checker
    checker = CTAChecker(config={"timeout": 10})

    # Process URLs with threading
    print(f"\n🔄 Validating URLs (max 5 concurrent)...")
    results = []

    start_time = time.time()

    with ThreadPoolExecutor(max_workers=5) as executor:
        # Submit all tasks
        future_to_url = {
            executor.submit(validate_url, url_id, url, checker): (url_id, url)
            for url_id, url in urls
        }

        # Process completed tasks
        completed = 0
        for future in as_completed(future_to_url):
            url_id, url = future_to_url[future]
            completed += 1

            try:
                result = future.result()
                if result:
                    results.append(result)
                    status_icon = {'ok': '✅', 'warning': '⚠️', 'error': '❌'}.get(result['status'], '❓')
                    print(f"  [{completed}/{len(urls)}] {status_icon} {result['url'][:60]}... ({result['score']}/100)")
                else:
                    print(f"  [{completed}/{len(urls)}] ⚠️  Skipped {url[:60]}...")

            except Exception as e:
                print(f"  [{completed}/{len(urls)}] ❌ Error processing {url[:60]}...: {str(e)}")

    elapsed = time.time() - start_time

    print(f"\n⏱️  Total time: {elapsed:.1f}s ({elapsed/len(urls):.2f}s per URL)")

    # Print summary
    print_summary(results)

    print("✅ Batch validation completed!")
    print(f"📊 Results saved to quality_checks table")
    print(f"🔍 View results at: http://localhost:5000/crawler/cta-results")


if __name__ == "__main__":
    main()
