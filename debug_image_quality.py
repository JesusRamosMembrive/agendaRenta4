#!/usr/bin/env python3
"""
Script de depuración para el check de calidad de imágenes.
Ejecuta el análisis de imágenes directamente sin GUI.
"""

import logging
import sys

from calidad.post_crawl_runner import PostCrawlQualityRunner
from utils import db_cursor

# Configurar logging detallado
logging.basicConfig(
    level=logging.DEBUG,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)],
)

logger = logging.getLogger(__name__)


def main():
    print("=" * 80)
    print("SCRIPT DE DEPURACIÓN - CALIDAD DE IMÁGENES")
    print("=" * 80)

    # 1. Obtener último crawl completado
    print("\n[1] Buscando último crawl completado...")
    with db_cursor(commit=False) as cursor:
        cursor.execute("""
            SELECT id, root_url, started_at, finished_at, urls_discovered
            FROM crawl_runs
            WHERE status = 'completed'
            ORDER BY id DESC
            LIMIT 1
        """)
        crawl = cursor.fetchone()

    if not crawl:
        print("❌ ERROR: No hay crawls completados en la base de datos")
        return 1

    print("✓ Crawl encontrado:")
    print(f"  - ID: {crawl['id']}")
    print(f"  - Root URL: {crawl['root_url']}")
    print(f"  - Started: {crawl['started_at']}")
    print(f"  - Finished: {crawl['finished_at']}")
    print(f"  - URLs discovered: {crawl['urls_discovered']}")

    crawl_run_id = crawl["id"]

    # 2. Contar URLs prioritarias (no rotas)
    print(f"\n[2] Contando URLs prioritarias no rotas para crawl {crawl_run_id}...")
    with db_cursor(commit=False) as cursor:
        cursor.execute(
            """
            SELECT COUNT(*) as count
            FROM discovered_urls
            WHERE crawl_run_id = %s
              AND active = TRUE
              AND is_broken = FALSE
              AND is_priority = TRUE
        """,
            (crawl_run_id,),
        )
        count = cursor.fetchone()["count"]

    print(f"✓ URLs prioritarias no rotas: {count}")

    if count == 0:
        print("❌ ERROR: No hay URLs prioritarias para analizar")
        return 1

    # 3. Mostrar primeras 5 URLs que se van a analizar
    print("\n[3] Primeras 5 URLs que se analizarán:")
    with db_cursor(commit=False) as cursor:
        cursor.execute(
            """
            SELECT id, url, depth
            FROM discovered_urls
            WHERE crawl_run_id = %s
              AND active = TRUE
              AND is_broken = FALSE
              AND is_priority = TRUE
            ORDER BY depth ASC
            LIMIT 5
        """,
            (crawl_run_id,),
        )
        sample_urls = cursor.fetchall()

    for i, url_row in enumerate(sample_urls, 1):
        print(f"  {i}. URL: {url_row['url']}")
        print(f"     ID: {url_row['id']}, Depth: {url_row['depth']}")

    # 4. Preguntar al usuario si continuar
    print(f"\n[4] ¿Continuar con el análisis de {count} URLs?")
    print(f"    Tiempo estimado: ~{count * 3 / 60:.1f} minutos")
    print("    (Cada URL tarda ~3 segundos en procesarse)")
    response = input("Escribe 'si' para continuar: ")

    if response.lower() not in ["si", "sí", "s", "y", "yes"]:
        print("❌ Cancelado por el usuario")
        return 0

    # 5. Ejecutar análisis con scope 'priority'
    print("\n[5] Ejecutando análisis de calidad de imágenes (scope: priority)...")
    print("=" * 80)

    try:
        runner = PostCrawlQualityRunner(crawl_run_id)

        # Configuración del check
        check_configs = [{"check_type": "image_quality", "scope": "priority"}]

        # Ejecutar
        results = runner.run_checks(check_configs)

        print("\n" + "=" * 80)
        print("[6] RESULTADOS")
        print("=" * 80)

        print(f"\n✓ Ejecutado: {results.get('executed', False)}")
        print(f"✓ Crawl Run ID: {results.get('crawl_run_id')}")
        print(f"✓ Checks ejecutados: {len(results.get('checks', []))}")

        for check in results.get("checks", []):
            print(f"\n--- Check: {check.get('check_type')} ---")
            print(f"  Status: {check.get('status')}")
            print(f"  Message: {check.get('message')}")

            stats = check.get("stats", {})
            if stats:
                print("  Stats:")
                for key, value in stats.items():
                    print(f"    - {key}: {value}")

        print("\n✅ Análisis completado exitosamente")
        return 0

    except Exception as e:
        print("\n" + "=" * 80)
        print("❌ ERROR AL EJECUTAR ANÁLISIS")
        print("=" * 80)
        print(f"Tipo de error: {type(e).__name__}")
        print(f"Mensaje: {e}")

        import traceback

        print("\nTraceback completo:")
        print(traceback.format_exc())

        return 1


if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)
