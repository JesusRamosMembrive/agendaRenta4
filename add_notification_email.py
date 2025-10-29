#!/usr/bin/env python3
"""
Script para añadir emails de notificación a la base de datos
Uso: python3 add_notification_email.py correo@ejemplo.com "Nombre Opcional"
"""

import sys
from utils import db_cursor
import sqlite3

def add_email(email, name=None):
    """Añadir un email de notificación a la base de datos"""
    try:
        with db_cursor() as cursor:
            cursor.execute("""
                INSERT INTO notification_emails (email, name, active)
                VALUES (?, ?, 1)
            """, (email, name or email))

        print(f"✓ Email añadido: {email} ({name or email})")

    except sqlite3.IntegrityError:
        print(f"✗ El email {email} ya existe en la base de datos")
    except Exception as e:
        print(f"✗ Error: {e}")

def list_emails():
    """Listar todos los emails de notificación"""
    with db_cursor(commit=False) as cursor:
        cursor.execute("""
            SELECT id, email, name, active, created_at
            FROM notification_emails
            ORDER BY id ASC
        """)

        rows = cursor.fetchall()

    if not rows:
        print("No hay emails configurados")
    else:
        print(f"\nEmails de notificación ({len(rows)}):")
        print("-" * 70)
        for row in rows:
            status = "✓ Activo" if row[3] else "✗ Inactivo"
            print(f"[{row[0]}] {row[1]:<30} {row[2]:<20} {status}")

def main():
    if len(sys.argv) < 2:
        print("Uso:")
        print("  python3 add_notification_email.py correo@ejemplo.com \"Nombre Opcional\"")
        print("  python3 add_notification_email.py --list")
        sys.exit(1)

    if sys.argv[1] == '--list':
        list_emails()
    else:
        email = sys.argv[1]
        name = sys.argv[2] if len(sys.argv) > 2 else None
        add_email(email, name)
        print()
        list_emails()

if __name__ == '__main__':
    main()
