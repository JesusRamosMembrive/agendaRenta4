#!/usr/bin/env python3
"""
Test script to validate spell checker refactoring improvements.

Tests:
1. Improved text extraction (no navigation elements)
2. Reduced false positives (financial terms recognized)
3. Logging output for debugging
"""

import sys
import logging
from calidad.spell import SpellChecker

# Configure logging to see debug output
logging.basicConfig(
    level=logging.INFO,
    format='%(levelname)s - %(message)s'
)

def test_url(url: str, description: str):
    """Test spell checking on a single URL."""
    print(f"\n{'='*80}")
    print(f"Testing: {description}")
    print(f"URL: {url}")
    print('='*80)

    checker = SpellChecker()
    result = checker.check(url)

    print(f"\nStatus: {result.status}")
    print(f"Score: {result.score}/100")
    print(f"Message: {result.message}")
    print(f"Issues found: {result.issues_found}")
    print(f"Execution time: {result.execution_time_ms}ms")

    if result.details:
        print(f"\nTotal words checked: {result.details.get('total_words', 'N/A')}")
        print(f"Text length: {result.details.get('text_length', 'N/A')} characters")

        spelling_errors = result.details.get('spelling_errors', [])
        if spelling_errors:
            print(f"\nSpelling errors found ({len(spelling_errors)}):")
            for i, error in enumerate(spelling_errors[:5], 1):  # Show first 5
                print(f"\n  {i}. Word: {error['word']}")
                print(f"     Context: {error['context']}")
                if error.get('suggestions'):
                    print(f"     Suggestions: {', '.join(error['suggestions'][:3])}")

            if len(spelling_errors) > 5:
                print(f"\n  ... and {len(spelling_errors) - 5} more errors")
        else:
            print("\n✅ No spelling errors found!")

    return result


def main():
    """Run test suite."""
    print("="*80)
    print("SPELL CHECKER REFACTOR VALIDATION TEST")
    print("="*80)

    test_urls = [
        {
            "url": "https://www.r4.com",
            "description": "Homepage - Should have minimal/no errors, no navigation text",
            "expected_errors": 0
        },
        {
            "url": "https://www.r4.com/fondos",
            "description": "Fondos page - Financial terms should not be flagged",
            "expected_errors": 0
        },
        {
            "url": "https://www.r4.com/acciones",
            "description": "Acciones page - Investment terms should be recognized",
            "expected_errors": 0
        }
    ]

    results = []

    for test_case in test_urls:
        try:
            result = test_url(test_case["url"], test_case["description"])
            results.append({
                "url": test_case["url"],
                "result": result,
                "expected_errors": test_case["expected_errors"]
            })
        except Exception as e:
            print(f"\n❌ ERROR testing {test_case['url']}: {e}")
            results.append({
                "url": test_case["url"],
                "result": None,
                "expected_errors": test_case["expected_errors"]
            })

    # Summary
    print("\n" + "="*80)
    print("TEST SUMMARY")
    print("="*80)

    total_tests = len(results)
    passed_tests = 0

    for i, r in enumerate(results, 1):
        if r["result"]:
            status = "✅ PASS" if r["result"].issues_found <= r["expected_errors"] + 2 else "⚠️  REVIEW"
            if r["result"].issues_found <= r["expected_errors"] + 2:
                passed_tests += 1

            print(f"\n{i}. {r['url']}")
            print(f"   Status: {status}")
            print(f"   Errors found: {r['result'].issues_found} (expected: <={r['expected_errors'] + 2})")
            print(f"   Score: {r['result'].score}/100")
        else:
            print(f"\n{i}. {r['url']}")
            print(f"   Status: ❌ FAILED TO TEST")

    print(f"\n{'='*80}")
    print(f"RESULTS: {passed_tests}/{total_tests} tests passed")
    print(f"{'='*80}")

    # Check for common false positives in results
    print("\n" + "="*80)
    print("FALSE POSITIVE CHECK")
    print("="*80)

    common_words_to_check = [
        'obtenidos', 'invertidos', 'inversión', 'rentabilidad',
        'diversificación', 'liquidez', 'evolución'
    ]

    found_false_positives = []

    for r in results:
        if r["result"] and r["result"].details:
            errors = r["result"].details.get('spelling_errors', [])
            for error in errors:
                word = error['word'].lower()
                if word in common_words_to_check:
                    found_false_positives.append({
                        "url": r["url"],
                        "word": error['word'],
                        "context": error['context']
                    })

    if found_false_positives:
        print("\n⚠️  FOUND POTENTIAL FALSE POSITIVES:")
        for fp in found_false_positives:
            print(f"\n  Word: {fp['word']}")
            print(f"  URL: {fp['url']}")
            print(f"  Context: {fp['context']}")
    else:
        print("\n✅ No common false positives detected!")

    return 0 if passed_tests == total_tests else 1


if __name__ == "__main__":
    sys.exit(main())
