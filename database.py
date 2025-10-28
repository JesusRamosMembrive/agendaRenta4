#!/usr/bin/env python3
"""
Agenda Renta4 - Database Schema
Crea y inicializa la base de datos SQLite con las 4 tablas principales
"""

import sqlite3
import os
from datetime import datetime


DATABASE_PATH = os.getenv('DATABASE_PATH', 'agendaRenta4.db')


def init_db():
    """
    Crea las tablas de la base de datos si no existen.
    """
    conn = sqlite3.connect(DATABASE_PATH)
    cursor = conn.cursor()

    print(f"📊 Inicializando base de datos: {DATABASE_PATH}\n")

    # ===========================================================================
    # TABLA 1: sections (URLs/Secciones a revisar)
    # ===========================================================================
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS sections (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            url TEXT UNIQUE NOT NULL,
            active BOOLEAN DEFAULT 1,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    print("✅ Tabla 'sections' creada")

    # ===========================================================================
    # TABLA 2: task_types (8 tipos de tareas fijos)
    # ===========================================================================
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS task_types (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT UNIQUE NOT NULL,
            display_name TEXT NOT NULL,
            periodicity TEXT NOT NULL,
            display_order INTEGER DEFAULT 0
        )
    """)
    print("✅ Tabla 'task_types' creada")

    # ===========================================================================
    # TABLA 3: tasks (Instancias de tareas = URL × tipo × periodo)
    # ===========================================================================
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            section_id INTEGER NOT NULL,
            task_type_id INTEGER NOT NULL,
            period TEXT NOT NULL,
            status TEXT DEFAULT 'pending',
            observations TEXT,
            completed_date DATE,
            completed_by TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (section_id) REFERENCES sections(id),
            FOREIGN KEY (task_type_id) REFERENCES task_types(id),
            UNIQUE(section_id, task_type_id, period)
        )
    """)
    print("✅ Tabla 'tasks' creada")

    # ===========================================================================
    # TABLA 4: users (Usuarios para notificaciones)
    # ===========================================================================
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            notify_email BOOLEAN DEFAULT 1,
            notify_browser BOOLEAN DEFAULT 1,
            active BOOLEAN DEFAULT 1,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    print("✅ Tabla 'users' creada")

    conn.commit()
    conn.close()

    print("\n✅ Base de datos inicializada correctamente\n")


def seed_task_types():
    """
    Inserta los 8 tipos de tareas con sus periodicidades iniciales.
    """
    conn = sqlite3.connect(DATABASE_PATH)
    cursor = conn.cursor()

    print(f"🌱 Poblando tipos de tareas...\n")

    # Los 8 tipos de tareas con periodicidades iniciales
    task_types_data = [
        ('enlaces_rotos', 'Enlaces rotos', 'weekly', 1),
        ('enlaces_incorrectos', 'Enlaces incorrectos', 'weekly', 2),
        ('textos_erratas', 'Textos – erratas', 'monthly', 3),
        ('informacion_actualizada', 'Información actualizada', 'monthly', 4),
        ('preguntas_frecuentes', 'Preguntas frecuentes', 'quarterly', 5),
        ('ctas', 'CTAs', 'monthly', 6),
        ('imagenes', 'Imágenes', 'monthly', 7),
        ('diseno', 'Diseño', 'quarterly', 8),
    ]

    for name, display_name, periodicity, order in task_types_data:
        try:
            cursor.execute("""
                INSERT INTO task_types (name, display_name, periodicity, display_order)
                VALUES (?, ?, ?, ?)
            """, (name, display_name, periodicity, order))
            print(f"   ✓ {display_name} ({periodicity})")
        except sqlite3.IntegrityError:
            print(f"   ⚠️  {display_name} ya existe (skip)")

    conn.commit()
    conn.close()

    print("\n✅ Tipos de tareas poblados correctamente\n")


def drop_all_tables():
    """
    ⚠️ PELIGRO: Elimina todas las tablas (usar solo en desarrollo)
    """
    conn = sqlite3.connect(DATABASE_PATH)
    cursor = conn.cursor()

    print("⚠️  Eliminando todas las tablas...\n")

    cursor.execute("DROP TABLE IF EXISTS tasks")
    print("   ✗ Tabla 'tasks' eliminada")

    cursor.execute("DROP TABLE IF EXISTS users")
    print("   ✗ Tabla 'users' eliminada")

    cursor.execute("DROP TABLE IF EXISTS task_types")
    print("   ✗ Tabla 'task_types' eliminada")

    cursor.execute("DROP TABLE IF EXISTS sections")
    print("   ✗ Tabla 'sections' eliminada")

    conn.commit()
    conn.close()

    print("\n✅ Todas las tablas eliminadas\n")


def get_db_stats():
    """
    Muestra estadísticas de la base de datos (número de registros por tabla).
    """
    conn = sqlite3.connect(DATABASE_PATH)
    cursor = conn.cursor()

    print(f"📊 Estadísticas de la base de datos: {DATABASE_PATH}\n")

    tables = ['sections', 'task_types', 'tasks', 'users']

    for table in tables:
        cursor.execute(f"SELECT COUNT(*) FROM {table}")
        count = cursor.fetchone()[0]
        print(f"   {table:20s}: {count:5d} registros")

    conn.close()
    print()


def main():
    """
    Script principal - Inicializa la BD y pobla tipos de tareas.
    """
    import sys

    if len(sys.argv) > 1:
        command = sys.argv[1]

        if command == 'drop':
            confirm = input("⚠️  ¿Estás seguro de eliminar todas las tablas? (yes/no): ")
            if confirm.lower() == 'yes':
                drop_all_tables()
                init_db()
                seed_task_types()
            else:
                print("Operación cancelada")
                return

        elif command == 'stats':
            get_db_stats()
            return

        elif command == 'seed':
            seed_task_types()
            return

        else:
            print(f"Comando desconocido: {command}")
            print("Uso: python database.py [drop|stats|seed]")
            return

    # Comando por defecto: init + seed
    init_db()
    seed_task_types()
    get_db_stats()


if __name__ == '__main__':
    main()