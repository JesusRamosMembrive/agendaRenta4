#!/usr/bin/env python3
"""
Script para añadir emails de notificación a la base de datos
Uso: python3 add_notification_email.py correo@ejemplo.com "Nombre Opcional"
"""

import sqlite3
import sys

def add_email(email, name=None):
    """Añadir un email de notificación a la base de datos"""
    conn = sqlite3.connect('agendaRenta4.db')
    cursor = conn.cursor()

    try:
        cursor.execute("""
            INSERT INTO notification_emails (email, name, active)
            VALUES (?, ?, 1)
        """, (email, name or email))

        conn.commit()
        print(f"✓ Email añadido: {email} ({name or email})")

    except sqlite3.IntegrityError:
        print(f"✗ El email {email} ya existe en la base de datos")
    except Exception as e:
        print(f"✗ Error: {e}")
    finally:
        conn.close()

def list_emails():
    """Listar todos los emails de notificación"""
    conn = sqlite3.connect('agendaRenta4.db')
    cursor = conn.cursor()

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

    conn.close()

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
