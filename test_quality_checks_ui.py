#!/usr/bin/env python3
"""
Script de prueba end-to-end para Quality Checks Post-Crawl
Ejecuta las pruebas descritas en TESTING_POST_CRAWL.md de forma automatizada
"""

import json
import time
from typing import Any

import requests

BASE_URL = "http://127.0.0.1:5000"


class ColoredOutput:
    """Helper para output con colores"""

    GREEN = "\033[92m"
    RED = "\033[91m"
    YELLOW = "\033[93m"
    BLUE = "\033[94m"
    RESET = "\033[0m"
    BOLD = "\033[1m"

    @staticmethod
    def success(msg: str):
        print(f"{ColoredOutput.GREEN}✓ {msg}{ColoredOutput.RESET}")

    @staticmethod
    def error(msg: str):
        print(f"{ColoredOutput.RED}✗ {msg}{ColoredOutput.RESET}")

    @staticmethod
    def info(msg: str):
        print(f"{ColoredOutput.BLUE}ℹ {msg}{ColoredOutput.RESET}")

    @staticmethod
    def warning(msg: str):
        print(f"{ColoredOutput.YELLOW}⚠ {msg}{ColoredOutput.RESET}")

    @staticmethod
    def header(msg: str):
        print(
            f"\n{ColoredOutput.BOLD}{ColoredOutput.BLUE}{'='*60}{ColoredOutput.RESET}"
        )
        print(f"{ColoredOutput.BOLD}{ColoredOutput.BLUE}{msg}{ColoredOutput.RESET}")
        print(
            f"{ColoredOutput.BOLD}{ColoredOutput.BLUE}{'='*60}{ColoredOutput.RESET}\n"
        )


def test_get_quality_checks_config(session: requests.Session) -> dict[str, Any]:
    """Test GET /crawler/config/checks"""
    ColoredOutput.header("TEST 1: Obtener Configuración de Quality Checks")

    try:
        response = session.get(f"{BASE_URL}/crawler/config/checks")

        if response.status_code == 200:
            ColoredOutput.success(
                f"Endpoint respondió correctamente (HTTP {response.status_code})"
            )

            data = response.json()
            ColoredOutput.info(f"Checks disponibles: {len(data.get('checks', []))}")

            for check in data.get("checks", []):
                status = "✓ Habilitado" if check["enabled"] else "○ Deshabilitado"
                auto = "(auto)" if check.get("run_after_crawl") else ""
                available = "" if check.get("available", True) else "(próximamente)"
                print(f"  {check['icon']} {check['name']}: {status} {auto} {available}")

            return data
        else:
            ColoredOutput.error(f"Endpoint falló (HTTP {response.status_code})")
            print(f"Response: {response.text[:200]}")
            return {}

    except Exception as e:
        ColoredOutput.error(f"Error: {str(e)}")
        return {}


def test_save_quality_checks_config(session: requests.Session) -> bool:
    """Test POST /crawler/config/checks - Habilita image_quality con auto-run"""
    ColoredOutput.header("TEST 2: Guardar Configuración (Habilitar image_quality)")

    try:
        # Configuración: Habilitar image_quality con ejecución automática
        config = {
            "check_type": "image_quality",
            "enabled": True,
            "run_after_crawl": True,
        }

        ColoredOutput.info(f"Guardando configuración: {json.dumps(config, indent=2)}")

        response = session.post(
            f"{BASE_URL}/crawler/config/checks",
            json=config,
            headers={"Content-Type": "application/json"},
        )

        if response.status_code == 200:
            data = response.json()
            ColoredOutput.success(
                f"Configuración guardada: {data.get('message', 'OK')}"
            )
            return True
        else:
            ColoredOutput.error(f"Falló al guardar (HTTP {response.status_code})")
            print(f"Response: {response.text[:200]}")
            return False

    except Exception as e:
        ColoredOutput.error(f"Error: {str(e)}")
        return False


def test_crawl_with_auto_checks(session: requests.Session) -> int:
    """Test crawl pequeño con checks automáticos"""
    ColoredOutput.header("TEST 3: Ejecutar Crawl de Prueba (5 URLs máximo)")

    try:
        # Configurar crawl pequeño
        crawl_config = {"url": "https://www.r4.com", "max_depth": 1, "max_urls": 5}

        ColoredOutput.info(
            f"Iniciando crawl: {crawl_config['url']} (máx. {crawl_config['max_urls']} URLs)"
        )

        response = session.post(
            f"{BASE_URL}/crawler/start",
            json=crawl_config,
            headers={"Content-Type": "application/json"},
        )

        if response.status_code in [200, 302]:
            ColoredOutput.success("Crawl iniciado correctamente")

            # Esperar un poco para que el crawl se complete
            ColoredOutput.info(
                "Esperando que el crawl se complete (esto puede tomar 30-60 segundos)..."
            )

            # Poll para ver cuándo termina
            max_wait = 120  # 2 minutos máximo
            elapsed = 0
            poll_interval = 5

            while elapsed < max_wait:
                time.sleep(poll_interval)
                elapsed += poll_interval

                # Verificar si hay resultados
                results_response = session.get(f"{BASE_URL}/crawler/results")
                if results_response.status_code == 200:
                    # Obtener el ID del último crawl
                    # (esto es simplificado, en producción parsearíamos el HTML)
                    ColoredOutput.info(f"Esperando... ({elapsed}s / {max_wait}s)")

                    # Por simplicidad, esperamos 60 segundos
                    if elapsed >= 60:
                        ColoredOutput.warning(
                            "Asumiendo que el crawl terminó (60s transcurridos)"
                        )
                        return 1  # Asumimos crawl_run_id = último

            ColoredOutput.warning("Timeout esperando el crawl")
            return 0

        else:
            ColoredOutput.error(f"Falló al iniciar crawl (HTTP {response.status_code})")
            print(f"Response: {response.text[:200]}")
            return 0

    except Exception as e:
        ColoredOutput.error(f"Error: {str(e)}")
        return 0


def test_verify_auto_checks_ran(session: requests.Session):
    """Verificar que los checks automáticos se ejecutaron"""
    ColoredOutput.header("TEST 4: Verificar Ejecución Automática de Checks")

    try:
        # Ir a la página de calidad de imágenes
        response = session.get(f"{BASE_URL}/crawler/quality")

        if response.status_code == 200:
            ColoredOutput.success("Página de calidad de imágenes accesible")

            # Buscar si hay resultados en el HTML (simplificado)
            html = response.text

            if "Total Checks:" in html or "total_checks" in html.lower():
                ColoredOutput.success("✓ Página muestra resultados de quality checks")

                # Intentar extraer estadísticas básicas (parsing simplificado)
                if "OK:" in html or "Warnings:" in html or "Errors:" in html:
                    ColoredOutput.info("Estadísticas encontradas en la página")
                else:
                    ColoredOutput.warning("No se encontraron estadísticas detalladas")
            else:
                ColoredOutput.warning(
                    "No se encontraron resultados de checks en la página"
                )
                ColoredOutput.info(
                    "Puede que los checks no se hayan ejecutado automáticamente"
                )
        else:
            ColoredOutput.error(
                f"No se pudo acceder a la página (HTTP {response.status_code})"
            )

    except Exception as e:
        ColoredOutput.error(f"Error: {str(e)}")


def main():
    """Ejecutar todos los tests"""
    print(
        f"\n{ColoredOutput.BOLD}🧪 Testing Quality Checks Post-Crawl System{ColoredOutput.RESET}"
    )
    print(f"{ColoredOutput.BOLD}Base URL: {BASE_URL}{ColoredOutput.RESET}\n")

    # Crear sesión
    session = requests.Session()

    # Login (simplificado - asumimos que no hay autenticación estricta en desarrollo)
    # En producción necesitaríamos hacer login real

    try:
        # Test 1: Obtener configuración
        config_data = test_get_quality_checks_config(session)

        if not config_data:
            ColoredOutput.error(
                "No se pudo obtener configuración inicial. Abortando tests."
            )
            return

        time.sleep(1)

        # Test 2: Guardar configuración
        if test_save_quality_checks_config(session):
            ColoredOutput.success("Configuración guardada exitosamente")
        else:
            ColoredOutput.warning("Continuando con los tests a pesar del fallo...")

        time.sleep(1)

        # Test 3: Ejecutar crawl (OPCIONAL - comentado por defecto para no saturar)
        ColoredOutput.warning("\nNOTA: El test de crawl está deshabilitado por defecto")
        ColoredOutput.info("Para habilitarlo, descomenta la línea en el código")
        ColoredOutput.info("Esto ejecutará un crawl real que puede tardar ~1 minuto\n")

        # DESCOMENTAR PARA EJECUTAR CRAWL REAL:
        # crawl_run_id = test_crawl_with_auto_checks(session)

        # if crawl_run_id:
        #     time.sleep(2)
        #     # Test 4: Verificar que los checks se ejecutaron
        #     test_verify_auto_checks_ran(session)

        ColoredOutput.header("RESUMEN")
        ColoredOutput.info("Tests de API completados")
        ColoredOutput.info("Para test completo end-to-end:")
        ColoredOutput.info("  1. Abre http://127.0.0.1:5000 en tu navegador")
        ColoredOutput.info("  2. Ve a Configuración > Herramientas de Análisis")
        ColoredOutput.info("  3. Activa 'Calidad de Imágenes' con auto-run")
        ColoredOutput.info("  4. Ejecuta un crawl pequeño (5 URLs)")
        ColoredOutput.info("  5. Revisa los logs de la terminal")
        ColoredOutput.info("  6. Ve a 'Calidad de Imágenes' para ver resultados")

    except KeyboardInterrupt:
        ColoredOutput.warning("\n\nTests interrumpidos por el usuario")
    except Exception as e:
        ColoredOutput.error(f"\n\nError inesperado: {str(e)}")
        import traceback

        traceback.print_exc()


if __name__ == "__main__":
    main()
