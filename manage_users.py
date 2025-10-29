#!/usr/bin/env python3
"""
Script para gestionar usuarios de Agenda Renta4
Uso:
    python3 manage_users.py add <username> <password> "<nombre completo>"
    python3 manage_users.py list
    python3 manage_users.py delete <username>
    python3 manage_users.py change-password <username> <nueva_contraseña>
"""

import sqlite3
import sys
from werkzeug.security import generate_password_hash, check_password_hash

DATABASE_PATH = 'agendaRenta4.db'

def get_db_connection():
    """Get database connection"""
    conn = sqlite3.connect(DATABASE_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def add_user(username, password, full_name):
    """Add a new user"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Hash the password
        password_hash = generate_password_hash(password)

        cursor.execute("""
            INSERT INTO users (username, password_hash, full_name)
            VALUES (?, ?, ?)
        """, (username, password_hash, full_name))

        conn.commit()
        conn.close()

        print(f"✓ Usuario creado exitosamente:")
        print(f"  Usuario: {username}")
        print(f"  Nombre: {full_name}")
        print(f"  Contraseña: {password}")
        return True

    except sqlite3.IntegrityError:
        print(f"✗ Error: El usuario '{username}' ya existe")
        return False
    except Exception as e:
        print(f"✗ Error: {e}")
        return False

def list_users():
    """List all users"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute("""
            SELECT id, username, full_name, created_at
            FROM users
            ORDER BY created_at DESC
        """)

        users = cursor.fetchall()
        conn.close()

        if not users:
            print("No hay usuarios registrados")
            return

        print("\n" + "="*70)
        print("USUARIOS REGISTRADOS")
        print("="*70)
        print(f"{'ID':<5} {'Usuario':<20} {'Nombre Completo':<25} {'Creado'}")
        print("-"*70)

        for user in users:
            created_date = user['created_at'][:10] if user['created_at'] else 'N/A'
            print(f"{user['id']:<5} {user['username']:<20} {user['full_name']:<25} {created_date}")

        print("="*70)
        print(f"Total: {len(users)} usuario(s)\n")

    except Exception as e:
        print(f"✗ Error: {e}")

def delete_user(username):
    """Delete a user"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Check if user exists
        cursor.execute("SELECT id, username, full_name FROM users WHERE username = ?", (username,))
        user = cursor.fetchone()

        if not user:
            print(f"✗ Error: El usuario '{username}' no existe")
            conn.close()
            return False

        # Confirm deletion
        print(f"\n⚠️  ¿Estás seguro de que quieres eliminar el usuario?")
        print(f"   Usuario: {user['username']}")
        print(f"   Nombre: {user['full_name']}")
        confirmation = input("\nEscribe 'SI' para confirmar: ")

        if confirmation.upper() != 'SI':
            print("Operación cancelada")
            conn.close()
            return False

        cursor.execute("DELETE FROM users WHERE username = ?", (username,))
        conn.commit()
        conn.close()

        print(f"✓ Usuario '{username}' eliminado exitosamente")
        return True

    except Exception as e:
        print(f"✗ Error: {e}")
        return False

def change_password(username, new_password):
    """Change user password"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Check if user exists
        cursor.execute("SELECT id, full_name FROM users WHERE username = ?", (username,))
        user = cursor.fetchone()

        if not user:
            print(f"✗ Error: El usuario '{username}' no existe")
            conn.close()
            return False

        # Hash new password
        password_hash = generate_password_hash(new_password)

        cursor.execute("""
            UPDATE users
            SET password_hash = ?
            WHERE username = ?
        """, (password_hash, username))

        conn.commit()
        conn.close()

        print(f"✓ Contraseña cambiada exitosamente para usuario '{username}'")
        print(f"  Nueva contraseña: {new_password}")
        return True

    except Exception as e:
        print(f"✗ Error: {e}")
        return False

def show_help():
    """Show usage help"""
    print("""
Gestión de Usuarios - Agenda Renta4
=====================================

Uso:
    python3 manage_users.py <comando> [argumentos]

Comandos disponibles:

    add <username> <password> "<nombre completo>"
        Crear un nuevo usuario
        Ejemplo: python3 manage_users.py add admin pass123 "Administrador"

    list
        Listar todos los usuarios registrados
        Ejemplo: python3 manage_users.py list

    delete <username>
        Eliminar un usuario existente
        Ejemplo: python3 manage_users.py delete admin

    change-password <username> <nueva_contraseña>
        Cambiar la contraseña de un usuario
        Ejemplo: python3 manage_users.py change-password admin nuevapass123

    help
        Mostrar esta ayuda

Notas:
    - Los nombres de usuario deben ser únicos
    - Las contraseñas se almacenan hasheadas (seguras)
    - El nombre completo debe ir entre comillas si contiene espacios
""")

def main():
    if len(sys.argv) < 2:
        show_help()
        sys.exit(1)

    command = sys.argv[1].lower()

    if command == 'help' or command == '--help' or command == '-h':
        show_help()

    elif command == 'add':
        if len(sys.argv) != 5:
            print("✗ Error: Uso incorrecto")
            print("   Uso: python3 manage_users.py add <username> <password> \"<nombre completo>\"")
            sys.exit(1)
        username = sys.argv[2]
        password = sys.argv[3]
        full_name = sys.argv[4]
        add_user(username, password, full_name)

    elif command == 'list':
        list_users()

    elif command == 'delete':
        if len(sys.argv) != 3:
            print("✗ Error: Uso incorrecto")
            print("   Uso: python3 manage_users.py delete <username>")
            sys.exit(1)
        username = sys.argv[2]
        delete_user(username)

    elif command == 'change-password':
        if len(sys.argv) != 4:
            print("✗ Error: Uso incorrecto")
            print("   Uso: python3 manage_users.py change-password <username> <nueva_contraseña>")
            sys.exit(1)
        username = sys.argv[2]
        new_password = sys.argv[3]
        change_password(username, new_password)

    else:
        print(f"✗ Error: Comando desconocido '{command}'")
        print("   Usa 'python3 manage_users.py help' para ver los comandos disponibles")
        sys.exit(1)

if __name__ == '__main__':
    main()
