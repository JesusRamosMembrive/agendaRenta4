#!/usr/bin/env python3
"""
Test script for objective CTA validations.

Tests the new objective validation features:
- Broken link detection
- Spelling check
- HTML attribute validation
- Duplicate detection
"""

from calidad.ctas import CTAChecker


def test_objective_validations():
    """Test CTA checker with objective validations."""

    print("🧪 Testing Objective CTA Validations")
    print("=" * 60)

    # Test URL
    test_url = "https://www.r4.com/planes-de-pensiones/categorias"

    # Create checker instance
    checker = CTAChecker(config={"timeout": 10})

    print(f"\n📍 Testing URL: {test_url}")
    print("-" * 60)

    # Run check
    result = checker.check(test_url)

    # Display results
    print(f"\n{'='*60}")
    print(f"Status: {result.status}")
    print(f"Score: {result.score}/100")
    print(f"Message: {result.message}")
    print(f"Issues found: {result.issues_found}")
    print(f"Execution time: {result.execution_time_ms}ms")

    # Debug: print all details keys
    print(f"\n🔍 DEBUG - Available detail keys: {list(result.details.keys())}")

    # Display objective validations details
    if 'objective_issues' in result.details:
        obj = result.details['objective_issues']

        print(f"\n{'='*60}")
        print("📊 Objective Validations:")
        print(f"{'='*60}")

        # Broken links
        if obj['broken_links']:
            print(f"\n🔗 Broken Links ({len(obj['broken_links'])}):")
            for bl in obj['broken_links']:
                print(f"  ❌ '{bl['cta_text']}' → {bl['cta_href']}")
                print(f"     Error: {bl['error']}")
        else:
            print("\n✅ No broken links found")

        # Spelling errors
        if obj['spelling_errors']:
            print(f"\n✏️ Spelling Errors ({len(obj['spelling_errors'])}):")
            for se in obj['spelling_errors']:
                print(f"  ⚠️ CTA: '{se['cta_text']}'")
                for word_info in se['misspelled_words']:
                    word = word_info['word']
                    suggestions = ', '.join(word_info['suggestions'][:3])
                    print(f"     • '{word}' → Sugerencias: {suggestions}")
        else:
            print("\n✅ No spelling errors found")

        # HTML issues
        if obj['html_issues']:
            print(f"\n🏷️ HTML Issues ({len(obj['html_issues'])}):")
            for hi in obj['html_issues']:
                print(f"  ❌ CTA: '{hi['cta_text']}'")
                print(f"     href: {hi['cta_href']}")
                for issue in hi['issues']:
                    print(f"     • {issue}")
        else:
            print("\n✅ No HTML issues found")

        # Duplicates
        if obj['duplicates']:
            print(f"\n🔄 Duplicate CTAs ({len(obj['duplicates'])}):")
            for dup in obj['duplicates']:
                print(f"  ⚠️ '{dup['text']}' appears {dup['url_count']} times with different URLs:")
                for url in dup['urls']:
                    print(f"     • {url}")
        else:
            print("\n✅ No duplicate CTAs found")

    # Display rule-based validation details (if any)
    print(f"\n{'='*60}")
    print("📋 Rule-based Validations:")
    print(f"{'='*60}")
    print(f"Total rules: {result.details.get('total_rules', 0)}")
    print(f"Required rules: {result.details.get('required_rules', 0)}")
    print(f"Optional rules: {result.details.get('optional_rules', 0)}")
    print(f"CTAs found: {result.details.get('found_ctas', 0)}")

    if result.details.get('matched_ctas'):
        print(f"\n✅ Matched CTAs ({len(result.details['matched_ctas'])}):")
        for cta in result.details['matched_ctas'][:5]:  # Show first 5
            print(f"  • '{cta['text']}' → {cta['url'][:60]}...")

    if result.details.get('missing_required'):
        print(f"\n❌ Missing Required CTAs ({len(result.details['missing_required'])}):")
        for cta in result.details['missing_required']:
            print(f"  • '{cta['expected_text']}' → {cta['expected_url']}")

    print(f"\n{'='*60}")
    print("✅ Test completed!")
    print(f"{'='*60}\n")


if __name__ == "__main__":
    test_objective_validations()
