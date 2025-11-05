#!/usr/bin/env python3
"""
Test script to verify custom dictionary is working correctly.
"""

from calidad.spell import SpellChecker

# Test text with words that should be in custom dictionary
test_text = """
Suscríbete a nuestro newsletter para recibir actualizaciones por mail.
España y Europa son mercados importantes para ETF y trading.
BlackRock y Vanguard son líderes en Renta4.
Contáctenos para más información sobre captcha y seguridad online.
"""

print("Testing custom dictionary integration...")
print("=" * 80)
print("\nTest text:")
print(test_text)
print("\n" + "=" * 80)

# Initialize spell checker
checker = SpellChecker()

# Check spelling
errors = checker._check_spelling(test_text)

print(f"\nFound {len(errors)} spelling errors:")
print("=" * 80)

if errors:
    for i, error in enumerate(errors, 1):
        print(f"\n{i}. Word: {error['word']}")
        print(f"   Context: {error['context']}")
        if error["suggestions"]:
            print(f"   Suggestions: {', '.join(error['suggestions'][:3])}")
else:
    print("\n✅ No spelling errors found! Custom dictionary is working correctly.")

print("\n" + "=" * 80)
print("Test complete.")
