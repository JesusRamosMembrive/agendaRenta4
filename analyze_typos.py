#!/usr/bin/env python3
"""
Analyze typos in hardcoded URLs
Find similar URLs in discovered set that might be corrections
"""

from difflib import SequenceMatcher

from dotenv import load_dotenv

from utils import db_cursor

load_dotenv()


def get_missing_urls():
    """Get URLs that are in sections but not discovered"""
    with db_cursor() as cursor:
        cursor.execute("""
            SELECT s.id, s.url, s.name
            FROM sections s
            WHERE s.active = TRUE
              AND s.url NOT IN (
                SELECT url FROM discovered_urls WHERE crawl_run_id = 2
              )
            ORDER BY s.url
        """)
        return cursor.fetchall()


def get_discovered_urls():
    """Get all discovered URLs"""
    with db_cursor() as cursor:
        cursor.execute("""
            SELECT url
            FROM discovered_urls
            WHERE crawl_run_id = 2
        """)
        return [row["url"] for row in cursor.fetchall()]


def similarity(a, b):
    """Calculate similarity ratio between two strings"""
    return SequenceMatcher(None, a, b).ratio()


def find_closest_match(missing_url, discovered_urls, threshold=0.85):
    """Find closest matching URL from discovered set"""
    best_match = None
    best_ratio = 0

    for discovered_url in discovered_urls:
        ratio = similarity(missing_url, discovered_url)
        if ratio > best_ratio and ratio >= threshold:
            best_ratio = ratio
            best_match = discovered_url

    return best_match, best_ratio


def categorize_errors(missing_urls, discovered_urls):
    """Categorize missing URLs into error types"""

    typos = []  # Clear typos with high similarity match
    not_found = []  # URLs genuinely not found

    for missing in missing_urls:
        url = missing["url"]

        # Find closest match
        match, ratio = find_closest_match(url, discovered_urls)

        if match and ratio >= 0.85:
            # Likely a typo
            typos.append(
                {
                    "id": missing["id"],
                    "wrong_url": url,
                    "correct_url": match,
                    "name": missing["name"],
                    "similarity": ratio,
                }
            )
        else:
            # Genuinely not found
            not_found.append(
                {
                    "id": missing["id"],
                    "url": url,
                    "name": missing["name"],
                    "best_match": match,
                    "similarity": ratio if match else 0,
                }
            )

    return typos, not_found


def identify_obvious_typos(typos):
    """Identify obvious character-level typos"""
    obvious = []

    for typo in typos:
        wrong = typo["wrong_url"]
        correct = typo["correct_url"]

        # Find differences
        if len(wrong) == len(correct):
            # Same length - likely single char substitution/transposition
            diffs = sum(1 for a, b in zip(wrong, correct, strict=False) if a != b)
            if diffs <= 2:
                obvious.append(
                    {**typo, "diff_type": "substitution", "diff_count": diffs}
                )
        elif abs(len(wrong) - len(correct)) <= 2:
            # Length differs by 1-2 - likely insertion/deletion
            obvious.append(
                {
                    **typo,
                    "diff_type": "insertion/deletion",
                    "diff_count": abs(len(wrong) - len(correct)),
                }
            )

    return obvious


def generate_report():
    """Generate typo analysis report"""

    print("=" * 100)
    print("ANÁLISIS DE ERRORES TIPOGRÁFICOS EN URLs HARDCODEADAS")
    print("=" * 100 + "\n")

    print("1. Obteniendo URLs faltantes...")
    missing_urls = get_missing_urls()
    print(f"   ✓ {len(missing_urls)} URLs faltantes")

    print("\n2. Obteniendo URLs descubiertas...")
    discovered_urls = get_discovered_urls()
    print(f"   ✓ {len(discovered_urls)} URLs descubiertas")

    print("\n3. Buscando coincidencias similares...")
    typos, not_found = categorize_errors(missing_urls, discovered_urls)
    print(f"   ✓ {len(typos)} posibles errores tipográficos")
    print(f"   ✓ {len(not_found)} URLs genuinamente no encontradas")

    print("\n4. Identificando errores obvios...")
    obvious = identify_obvious_typos(typos)

    # Print report
    print("\n" + "=" * 100)
    print("ERRORES TIPOGRÁFICOS ENCONTRADOS")
    print("=" * 100 + "\n")

    if typos:
        print(f"Total de errores tipográficos detectados: {len(typos)}\n")

        for i, typo in enumerate(sorted(typos, key=lambda x: -x["similarity"]), 1):
            print(f"{i}. {typo['name']}")
            print(f"   ❌ Incorrecto: {typo['wrong_url']}")
            print(f"   ✓  Correcto:   {typo['correct_url']}")
            print(f"   📊 Similitud:  {typo['similarity']*100:.1f}%")

            # Highlight differences
            wrong = typo["wrong_url"]
            correct = typo["correct_url"]

            # Find first difference
            for j, (w, c) in enumerate(zip(wrong, correct, strict=False)):
                if w != c:
                    start = max(0, j - 20)
                    end = min(len(wrong), j + 20)
                    print(f"   🔍 Diferencia: ...{wrong[start:end]}...")
                    print(f"                  ...{correct[start:end]}...")
                    break

            print()

    print("=" * 100)
    print("URLs GENUINAMENTE NO ENCONTRADAS")
    print("=" * 100 + "\n")

    if not_found:
        print(f"Total: {len(not_found)}\n")

        for i, item in enumerate(not_found, 1):
            print(f"{i}. {item['name']}")
            print(f"   URL: {item['url']}")
            if item["best_match"]:
                print(
                    f"   Más parecida ({item['similarity']*100:.1f}%): {item['best_match'][:80]}..."
                )
            print()

    # Save to file
    filename = f"analisis_typos_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"

    with open(filename, "w", encoding="utf-8") as f:
        f.write("ANÁLISIS DE ERRORES TIPOGRÁFICOS\n")
        f.write("=" * 100 + "\n\n")

        f.write("RESUMEN:\n")
        f.write(f"  - URLs faltantes totales: {len(missing_urls)}\n")
        f.write(f"  - Errores tipográficos: {len(typos)}\n")
        f.write(f"  - URLs no encontradas: {len(not_found)}\n\n")

        f.write("=" * 100 + "\n")
        f.write("CORRECCIONES SUGERIDAS\n")
        f.write("=" * 100 + "\n\n")

        f.write("-- SQL para corregir errores tipográficos:\n\n")

        for typo in sorted(typos, key=lambda x: x["id"]):
            f.write(f"-- {typo['name']}\n")
            f.write(
                f"UPDATE sections SET url = '{typo['correct_url']}' WHERE id = {typo['id']};\n"
            )
            f.write(f"-- Antes: {typo['wrong_url']}\n\n")

        f.write("\n" + "=" * 100 + "\n")
        f.write("URLs NO ENCONTRADAS (revisar manualmente)\n")
        f.write("=" * 100 + "\n\n")

        for item in not_found:
            f.write(f"ID: {item['id']}\n")
            f.write(f"Nombre: {item['name']}\n")
            f.write(f"URL: {item['url']}\n")
            if item["best_match"]:
                f.write(f"Más parecida: {item['best_match']}\n")
            f.write("\n")

    print(f"\n📄 Análisis guardado en: {filename}")

    return typos, not_found


if __name__ == "__main__":
    from datetime import datetime

    typos, not_found = generate_report()

    print("\n" + "=" * 100)
    print("✅ ANÁLISIS COMPLETADO")
    print("=" * 100)
    print("\n📊 Resumen:")
    print(f"   - Errores tipográficos: {len(typos)}")
    print(f"   - URLs no encontradas: {len(not_found)}")
    print("\n")
