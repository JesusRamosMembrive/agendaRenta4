"""
Custom Dictionary Manager

Manages the generation and maintenance of custom Hunspell dictionary files
from the custom_dictionary database table.
"""

import logging
import os
from typing import Any

from utils import db_cursor

logger = logging.getLogger(__name__)


def generate_custom_dictionary() -> dict[str, Any]:
    """
    Generate custom.dic and custom.aff files from custom_dictionary table.

    This creates Hunspell-compatible dictionary files that can be loaded
    alongside the main Spanish dictionary to handle domain-specific terms,
    brands, technical words, and approved false positives.

    Returns:
        Dictionary with generation statistics
    """
    try:
        # Get all approved words from database
        with db_cursor(commit=False) as cursor:
            cursor.execute("""
                SELECT word, word_lower, category
                FROM custom_dictionary
                ORDER BY word_lower
            """)
            words = cursor.fetchall()

        if not words:
            logger.warning("No words found in custom_dictionary table")
            return {
                "success": False,
                "message": "No words to generate",
                "word_count": 0,
            }

        # Ensure custom dictionary directory exists
        base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        custom_dir = os.path.join(base_dir, "dictionaries", "custom")
        os.makedirs(custom_dir, exist_ok=True)

        # Generate .dic file (word list)
        dic_path = os.path.join(custom_dir, "custom.dic")
        with open(dic_path, "w", encoding="utf-8") as f:
            # First line must be word count
            f.write(f"{len(words)}\n")
            # Then each word on its own line
            for word_row in words:
                f.write(f'{word_row["word"]}\n')

        # Generate .aff file (affix rules - minimal config for custom dict)
        aff_path = os.path.join(custom_dir, "custom.aff")
        with open(aff_path, "w", encoding="utf-8") as f:
            # Minimal Hunspell affix file for custom dictionary
            f.write("# Custom Dictionary Affix File\n")
            f.write("# Auto-generated from custom_dictionary table\n")
            f.write("# Do not edit manually - will be overwritten\n\n")
            f.write("SET UTF-8\n")
            f.write("WORDCHARS 0123456789\n")
            f.write("TRY esianrtolcdugmfpbvhñyqáéíóúüx\n")  # Spanish letter frequency

        logger.info(f"Custom dictionary generated successfully: {len(words)} words")
        logger.info(f"  .dic file: {dic_path}")
        logger.info(f"  .aff file: {aff_path}")

        # Group by category for stats
        category_stats = {}
        for word_row in words:
            category = word_row["category"] or "other"
            category_stats[category] = category_stats.get(category, 0) + 1

        return {
            "success": True,
            "word_count": len(words),
            "dic_path": dic_path,
            "aff_path": aff_path,
            "category_stats": category_stats,
        }

    except Exception as e:
        logger.error(f"Error generating custom dictionary: {e}", exc_info=True)
        return {"success": False, "message": str(e), "word_count": 0}


def add_word_to_dictionary(
    word: str,
    category: str = "other",
    frequency: int = 0,
    approved_by: int | None = None,
    notes: str | None = None,
) -> dict[str, Any]:
    """
    Add a word to the custom dictionary.

    Args:
        word: The word to add (case will be preserved)
        category: Word category (technical, geographic, brand, financial, etc.)
        frequency: How many times this word appeared as error
        approved_by: User ID who approved this word
        notes: Optional notes about why word was added

    Returns:
        Dictionary with result information
    """
    try:
        with db_cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO custom_dictionary (word, word_lower, category, frequency, approved_by, notes)
                VALUES (%s, %s, %s, %s, %s, %s)
                ON CONFLICT (word_lower) DO UPDATE
                    SET frequency = custom_dictionary.frequency + EXCLUDED.frequency,
                        category = EXCLUDED.category,
                        notes = EXCLUDED.notes,
                        updated_at = CURRENT_TIMESTAMP
                RETURNING id, word
            """,
                (word, word.lower(), category, frequency, approved_by, notes),
            )

            result = cursor.fetchone()

        logger.info(
            f"Added word to custom dictionary: '{word}' (id={result['id']}, category={category})"
        )

        # Regenerate dictionary files
        gen_result = generate_custom_dictionary()

        return {
            "success": True,
            "word_id": result["id"],
            "word": result["word"],
            "dictionary_regenerated": gen_result["success"],
        }

    except Exception as e:
        logger.error(f"Error adding word to dictionary: {e}", exc_info=True)
        return {"success": False, "message": str(e)}


def remove_word_from_dictionary(word: str) -> dict[str, Any]:
    """
    Remove a word from the custom dictionary.

    Args:
        word: The word to remove (case-insensitive)

    Returns:
        Dictionary with result information
    """
    try:
        with db_cursor() as cursor:
            cursor.execute(
                """
                DELETE FROM custom_dictionary
                WHERE word_lower = %s
                RETURNING word
            """,
                (word.lower(),),
            )

            result = cursor.fetchone()

        if not result:
            return {
                "success": False,
                "message": f"Word '{word}' not found in dictionary",
            }

        logger.info(f"Removed word from custom dictionary: '{result['word']}'")

        # Regenerate dictionary files
        gen_result = generate_custom_dictionary()

        return {
            "success": True,
            "word": result["word"],
            "dictionary_regenerated": gen_result["success"],
        }

    except Exception as e:
        logger.error(f"Error removing word from dictionary: {e}", exc_info=True)
        return {"success": False, "message": str(e)}


def get_dictionary_words() -> list[dict[str, Any]]:
    """
    Get all words currently in the custom dictionary.

    Returns:
        List of word dictionaries with metadata
    """
    try:
        with db_cursor(commit=False) as cursor:
            cursor.execute("""
                SELECT
                    id, word, word_lower, category, frequency,
                    approved_by, approved_at, notes, created_at, updated_at
                FROM custom_dictionary
                ORDER BY frequency DESC, word_lower
            """)

            return cursor.fetchall()

    except Exception as e:
        logger.error(f"Error fetching dictionary words: {e}", exc_info=True)
        return []


def get_dictionary_stats() -> dict[str, Any]:
    """
    Get statistics about the custom dictionary.

    Returns:
        Dictionary with stats
    """
    try:
        with db_cursor(commit=False) as cursor:
            # Total words
            cursor.execute("SELECT COUNT(*) as total FROM custom_dictionary")
            total = cursor.fetchone()["total"]

            # By category
            cursor.execute("""
                SELECT category, COUNT(*) as count
                FROM custom_dictionary
                GROUP BY category
                ORDER BY count DESC
            """)
            by_category = cursor.fetchall()

            # Recent additions
            cursor.execute("""
                SELECT COUNT(*) as count
                FROM custom_dictionary
                WHERE approved_at > NOW() - INTERVAL '7 days'
            """)
            recent = cursor.fetchone()["count"]

        return {
            "total_words": total,
            "by_category": {row["category"]: row["count"] for row in by_category},
            "added_last_week": recent,
        }

    except Exception as e:
        logger.error(f"Error fetching dictionary stats: {e}", exc_info=True)
        return {"total_words": 0, "by_category": {}, "added_last_week": 0}


if __name__ == "__main__":
    # CLI usage: python -m calidad.dictionary_manager
    print("Generating custom Hunspell dictionary...")
    result = generate_custom_dictionary()

    if result["success"]:
        print(f"✅ Success! Generated dictionary with {result['word_count']} words")
        print(f"   📁 {result['dic_path']}")
        print(f"   📁 {result['aff_path']}")
        if result["category_stats"]:
            print("\n   Category breakdown:")
            for category, count in sorted(
                result["category_stats"].items(), key=lambda x: -x[1]
            ):
                print(f"     • {category}: {count} words")
    else:
        print(f"❌ Error: {result['message']}")
