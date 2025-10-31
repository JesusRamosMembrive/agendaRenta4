#!/usr/bin/env python3
"""
Agenda Renta4 - Seed Users
Pobla la tabla 'users' con usuarios de prueba para notificaciones.
"""

import sys
import os
from pathlib import Path
from utils import db_cursor
import psycopg2


def seed_users():
    """
    Inserta usuarios de prueba en la tabla 'users'.
    """
    print(f"👥 Poblando usuarios...\n")

    # Usuarios de prueba
    users_data = [
        # (name, email, notify_email, notify_browser, active)
        ('María García', 'maria.garcia@r4.com', True, True, True),
        ('José Ramos', 'jose.ramos@r4.com', True, True, True),
    ]

    inserted = 0
    skipped = 0

    with db_cursor() as cursor:
        for name, email, notify_email, notify_browser, active in users_data:
            try:
                cursor.execute("""
                    INSERT INTO users (name, email, notify_email, notify_browser, active)
                    VALUES (%s, %s, %s, %s, %s)
                """, (name, email, notify_email, notify_browser, active))
                inserted += 1
                print(f"   ✓ {name}")
                print(f"     Email: {email}")
                print(f"     Notificaciones: Email={'✓' if notify_email else '✗'}, Browser={'✓' if notify_browser else '✗'}")
            except psycopg2.IntegrityError:
                # Email duplicado (ya existe)
                skipped += 1
                print(f"   ⚠️  {name} ({email}) ya existe (skip)")

    # Resumen
    print("\n" + "=" * 80)
    print(f"📊 RESUMEN:")
    print(f"   - Usuarios insertados: {inserted}")
    print(f"   - Usuarios omitidos (ya existían): {skipped}")
    print("=" * 80 + "\n")

    if inserted > 0:
        print(f"✅ {inserted} usuarios creados correctamente\n")


def list_users():
    """
    Lista todos los usuarios en la BD.
    """
    print(f"\n👥 Usuarios en la base de datos:\n")

    with db_cursor() as cursor:
        cursor.execute("""
            SELECT id, name, email, notify_email, notify_browser, active
            FROM users
            ORDER BY id
        """)

        users = cursor.fetchall()

        if not users:
            print("   (No hay usuarios)\n")
            return

        for user in users:
            status = "✓ ACTIVO" if user['active'] else "✗ INACTIVO"
            print(f"   ID {user['id']}: {user['name']} ({status})")
            print(f"           Email: {user['email']}")
            print(f"           Notificaciones: Email={'✓' if user['notify_email'] else '✗'}, Browser={'✓' if user['notify_browser'] else '✗'}")
            print()


def main():
    """
    Script principal.
    """
    import argparse

    parser = argparse.ArgumentParser(description='Pobla usuarios de prueba')
    parser.add_argument('--list', action='store_true', help='Listar usuarios existentes')
    args = parser.parse_args()

    if args.list:
        list_users()
    else:
        seed_users()
        list_users()


if __name__ == '__main__':
    main()
