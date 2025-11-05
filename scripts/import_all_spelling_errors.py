#!/usr/bin/env python3
"""
Script para importar todas las palabras detectadas como errores al diccionario personalizado.

ADVERTENCIA: Este script añadirá TODAS las palabras marcadas como errores al diccionario,
incluyendo errores legítimos. Usar con precaución y revisar después.

Uso:
    python scripts/import_all_spelling_errors.py [--min-frequency N] [--dry-run]

Opciones:
    --min-frequency N    Solo importar palabras que aparezcan N o más veces (default: 1)
    --dry-run           Mostrar qué se importaría sin hacer cambios
    --category CAT      Categoría a asignar (default: 'other')
"""

import sys
import os
from collections import Counter

# Add parent directory to path to import modules
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from utils import db_cursor
from calidad.dictionary_manager import add_word_to_dictionary, get_dictionary_words


def extract_all_spelling_errors(min_frequency=1):
    """
    Extract all spelling errors from quality_checks table.

    Args:
        min_frequency: Minimum number of times a word must appear

    Returns:
        List of (word, frequency) tuples
    """
    print("📊 Extrayendo errores ortográficos de quality_checks...")

    with db_cursor(commit=False) as cursor:
        cursor.execute("""
            SELECT
                jsonb_array_elements(details->'spelling_errors')->>'word' as word
            FROM quality_checks
            WHERE check_type = 'spell_check'
                AND details->'spelling_errors' IS NOT NULL
                AND jsonb_array_length(details->'spelling_errors') > 0
        """)

        words = cursor.fetchall()

    # Count frequencies
    word_counter = Counter([w['word'] for w in words])

    # Filter by frequency
    filtered_words = [
        (word, count)
        for word, count in word_counter.items()
        if count >= min_frequency
    ]

    # Sort by frequency descending
    filtered_words.sort(key=lambda x: x[1], reverse=True)

    return filtered_words


def get_existing_words():
    """Get set of words already in dictionary (lowercase for comparison)."""
    existing = get_dictionary_words()
    return {w['word_lower'] for w in existing}


def import_words(words_to_import, category='other', dry_run=False):
    """
    Import words to custom dictionary.

    Args:
        words_to_import: List of (word, frequency) tuples
        category: Category to assign to words
        dry_run: If True, only print what would be done
    """
    existing_words = get_existing_words()

    # Filter out words already in dictionary
    new_words = [
        (word, freq)
        for word, freq in words_to_import
        if word.lower() not in existing_words
    ]

    print(f"\n{'=' * 80}")
    print(f"📋 RESUMEN:")
    print(f"{'=' * 80}")
    print(f"  Total de palabras únicas detectadas: {len(words_to_import)}")
    print(f"  Ya están en el diccionario: {len(words_to_import) - len(new_words)}")
    print(f"  Nuevas palabras a importar: {len(new_words)}")
    print(f"{'=' * 80}\n")

    if not new_words:
        print("✅ Todas las palabras ya están en el diccionario. No hay nada que importar.")
        return

    # Show top 20 words that will be imported
    print("📝 Top 20 palabras a importar (por frecuencia):")
    print(f"{'=' * 80}")
    for word, freq in new_words[:20]:
        print(f"  • {word:<30} → {freq:>3} apariciones")

    if len(new_words) > 20:
        print(f"  ... y {len(new_words) - 20} palabras más")
    print(f"{'=' * 80}\n")

    if dry_run:
        print("🔍 DRY RUN: No se realizaron cambios.")
        print("\nPara importar realmente, ejecuta sin --dry-run:")
        print(f"  python scripts/import_all_spelling_errors.py")
        return

    # Confirm before proceeding
    print("⚠️  ADVERTENCIA: Esta operación añadirá todas estas palabras al diccionario.")
    print("   Esto incluye errores reales que deberían marcarse como incorrectos.")
    print("   Se recomienda revisar el diccionario después de la importación.\n")

    response = input("¿Continuar con la importación? (escriba 'SI' para confirmar): ")

    if response.strip() != 'SI':
        print("\n❌ Importación cancelada.")
        return

    # Import words
    print(f"\n🚀 Importando {len(new_words)} palabras...")
    print("=" * 80)

    imported = 0
    errors = 0

    for word, frequency in new_words:
        try:
            result = add_word_to_dictionary(
                word=word,
                category=category,
                frequency=frequency,
                approved_by=1,  # System user
                notes=f'Importada masivamente desde errores de spell check (freq: {frequency})'
            )

            if result['success']:
                imported += 1
                if imported % 10 == 0:
                    print(f"  ✓ {imported}/{len(new_words)} palabras importadas...")
            else:
                errors += 1
                print(f"  ✗ Error importando '{word}': {result.get('message', 'Unknown error')}")

        except Exception as e:
            errors += 1
            print(f"  ✗ Excepción importando '{word}': {e}")

    print("=" * 80)
    print(f"\n✅ Importación completada!")
    print(f"  • Palabras importadas: {imported}")
    print(f"  • Errores: {errors}")
    print(f"\n📖 El diccionario ahora tiene {len(get_existing_words())} palabras.\n")

    if imported > 0:
        print("💡 RECOMENDACIÓN: Revisa el diccionario en /diccionario-personalizado")
        print("   y elimina cualquier error real que se haya importado por error.\n")


def main():
    """Main execution."""
    import argparse

    parser = argparse.ArgumentParser(
        description='Importar todas las palabras de errores ortográficos al diccionario',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Ejemplos:
  # Mostrar qué se importaría (sin cambios)
  python scripts/import_all_spelling_errors.py --dry-run

  # Importar solo palabras que aparezcan 3+ veces
  python scripts/import_all_spelling_errors.py --min-frequency 3

  # Importar todo con categoría específica
  python scripts/import_all_spelling_errors.py --category technical
        """
    )

    parser.add_argument(
        '--min-frequency',
        type=int,
        default=1,
        help='Frecuencia mínima de apariciones (default: 1)'
    )

    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Mostrar qué se importaría sin hacer cambios'
    )

    parser.add_argument(
        '--category',
        type=str,
        default='other',
        choices=['other', 'technical', 'geographic', 'brand', 'financial', 'verb', 'variant'],
        help='Categoría a asignar a las palabras (default: other)'
    )

    args = parser.parse_args()

    print("=" * 80)
    print("🔤 IMPORTACIÓN MASIVA DE ERRORES ORTOGRÁFICOS AL DICCIONARIO")
    print("=" * 80)

    # Extract words
    words = extract_all_spelling_errors(min_frequency=args.min_frequency)

    if not words:
        print("\n✅ No se encontraron palabras que cumplan los criterios.")
        return

    print(f"✓ Encontradas {len(words)} palabras únicas (frecuencia >= {args.min_frequency})")

    # Import
    import_words(words, category=args.category, dry_run=args.dry_run)


if __name__ == '__main__':
    main()
