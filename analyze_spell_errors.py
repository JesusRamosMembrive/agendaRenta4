#!/usr/bin/env python3
"""
Analyze spell checker errors to identify false positives.
"""

import sys
from collections import Counter
from calidad.spell import SpellChecker

def analyze_url(url: str):
    """Analyze spelling errors for a URL."""
    print(f"\nAnalyzing: {url}")
    print("="*80)

    checker = SpellChecker()
    result = checker.check(url)

    if result.details and result.details.get('spelling_errors'):
        errors = result.details['spelling_errors']

        # Count word frequency
        word_counter = Counter()
        for error in errors:
            word_counter[error['word'].lower()] += 1

        print(f"\nTotal unique words flagged: {len(word_counter)}")
        print(f"Total error instances: {sum(word_counter.values())}")

        print("\nMost common 'errors' (likely false positives):")
        for word, count in word_counter.most_common(30):
            print(f"  {word:20} - {count} times")

        return list(word_counter.keys())

    return []


def main():
    """Run analysis."""
    urls = [
        "https://www.r4.com",
        "https://www.r4.com/fondos"
    ]

    all_words = []
    for url in urls:
        try:
            words = analyze_url(url)
            all_words.extend(words)
        except Exception as e:
            print(f"Error analyzing {url}: {e}")

    # Generate dictionary addition code
    print("\n" + "="*80)
    print("SUGGESTED WORDS TO ADD TO DICTIONARY:")
    print("="*80)

    unique_words = sorted(set(all_words))
    print("\nPython set format:")
    print("{")
    for i in range(0, len(unique_words), 5):
        batch = unique_words[i:i+5]
        print("    " + ", ".join(f"'{w}'" for w in batch) + ",")
    print("}")


if __name__ == "__main__":
    sys.exit(main())
