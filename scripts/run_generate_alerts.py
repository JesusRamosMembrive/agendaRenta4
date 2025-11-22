#!/usr/bin/env python3
"""
CLI para generar alertas pendientes de forma manual o programable (cron).

Uso:
  python scripts/run_generate_alerts.py            # usa la fecha de hoy
  python scripts/run_generate_alerts.py --date 2025-11-15
"""

import argparse
import os
import sys
from datetime import datetime

# Asegura que el root del repo está en PYTHONPATH
REPO_ROOT = os.path.dirname(os.path.dirname(__file__))
if REPO_ROOT not in sys.path:
    sys.path.insert(0, REPO_ROOT)

from app import generate_alerts  # noqa: E402 - importa app y configuración Flask


def parse_args():
    """Parsea argumentos CLI."""
    parser = argparse.ArgumentParser(
        description="Genera alertas según la configuración de alert_settings"
    )
    parser.add_argument(
        "--date",
        type=str,
        help="Fecha de referencia en formato YYYY-MM-DD (por defecto hoy)",
    )
    return parser.parse_args()


def main():
    args = parse_args()

    reference_date = None
    if args.date:
        try:
            reference_date = datetime.strptime(args.date, "%Y-%m-%d").date()
        except ValueError:
            print("❌ Formato de fecha inválido. Usa YYYY-MM-DD.", file=sys.stderr)
            sys.exit(1)

    stats = generate_alerts(reference_date)

    print("📣 Alertas generadas")
    print(f"   - Generadas: {stats.get('generated', 0)}")
    print(f"   - Omitidas:  {stats.get('skipped', 0)}")

    errors = stats.get("errors", [])
    if errors:
        print(f"   - Errores:   {len(errors)}")
        for err in errors:
            print(f"     • {err}")
    else:
        print("   - Errores:   0")

    email_stats = stats.get("email_stats")
    if email_stats:
        print("   - Emails:")
        print(f"       Enviados: {email_stats.get('sent', 0)}")
        print(f"       Fallidos: {email_stats.get('failed', 0)}")
        if email_stats.get("errors"):
            print("       Errores:")
            for err in email_stats["errors"]:
                print(f"         • {err}")

    # Salir con código 1 si hubo errores
    if errors or (email_stats and email_stats.get("failed")):
        sys.exit(1)


if __name__ == "__main__":
    main()
