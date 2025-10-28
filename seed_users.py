#!/usr/bin/env python3
"""
Agenda Renta4 - Seed Users
Pobla la tabla 'users' con usuarios de prueba para notificaciones.
"""

import sys
import os
from pathlib import Path
import sqlite3


DATABASE_PATH = os.getenv('DATABASE_PATH', 'agendaRenta4.db')


def seed_users(db_path):
    """
    Inserta usuarios de prueba en la tabla 'users'.
    """
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    print(f"👥 Poblando usuarios...\n")

    # Usuarios de prueba
    users_data = [
        # (name, email, notify_email, notify_browser, active)
        ('María García', 'maria.garcia@r4.com', 1, 1, 1),
        ('José Ramos', 'jose.ramos@r4.com', 1, 1, 1),
    ]

    inserted = 0
    skipped = 0

    for name, email, notify_email, notify_browser, active in users_data:
        try:
            cursor.execute("""
                INSERT INTO users (name, email, notify_email, notify_browser, active)
                VALUES (?, ?, ?, ?, ?)
            """, (name, email, notify_email, notify_browser, active))
            inserted += 1
            print(f"   ✓ {name}")
            print(f"     Email: {email}")
            print(f"     Notificaciones: Email={'✓' if notify_email else '✗'}, Browser={'✓' if notify_browser else '✗'}")
        except sqlite3.IntegrityError:
            # Email duplicado (ya existe)
            skipped += 1
            print(f"   ⚠️  {name} ({email}) ya existe (skip)")

    conn.commit()
    conn.close()

    # Resumen
    print("\n" + "=" * 80)
    print(f"📊 RESUMEN:")
    print(f"   - Usuarios insertados: {inserted}")
    print(f"   - Usuarios omitidos (ya existían): {skipped}")
    print("=" * 80 + "\n")

    if inserted > 0:
        print(f"✅ {inserted} usuarios creados correctamente\n")


def list_users(db_path):
    """
    Lista todos los usuarios en la BD.
    """
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    print(f"\n👥 Usuarios en la base de datos:\n")

    cursor.execute("""
        SELECT id, name, email, notify_email, notify_browser, active
        FROM users
        ORDER BY id
    """)

    users = cursor.fetchall()

    if not users:
        print("   (No hay usuarios)\n")
        conn.close()
        return

    for user in users:
        status = "✓ ACTIVO" if user['active'] else "✗ INACTIVO"
        print(f"   ID {user['id']}: {user['name']} ({status})")
        print(f"           Email: {user['email']}")
        print(f"           Notificaciones: Email={'✓' if user['notify_email'] else '✗'}, Browser={'✓' if user['notify_browser'] else '✗'}")
        print()

    conn.close()


def main():
    """
    Script principal.
    """
    import argparse

    parser = argparse.ArgumentParser(description='Pobla usuarios de prueba')
    parser.add_argument('--list', action='store_true', help='Listar usuarios existentes')
    args = parser.parse_args()

    # Verificar que la BD existe
    if not Path(DATABASE_PATH).exists():
        print(f"❌ ERROR: Base de datos no encontrada: {DATABASE_PATH}")
        print(f"   Ejecuta primero: python database.py")
        sys.exit(1)

    if args.list:
        list_users(DATABASE_PATH)
    else:
        seed_users(DATABASE_PATH)
        list_users(DATABASE_PATH)


if __name__ == '__main__':
    main()
