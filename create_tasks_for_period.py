#!/usr/bin/env python3
"""
Agenda Renta4 - Create Tasks for Period
Genera tareas manualmente para un periodo dado (mes) según las periodicidades configuradas.
"""

import sys
import os
from pathlib import Path
import sqlite3
from datetime import datetime
import argparse


DATABASE_PATH = os.getenv('DATABASE_PATH', 'agendaRenta4.db')


def should_create_task_for_period(period, periodicity):
    """
    Determina si se debe crear una tarea para un periodo dado según su periodicidad.

    Args:
        period: Periodo en formato "YYYY-MM" (ej: "2025-11")
        periodicity: Tipo de periodicidad ("weekly", "monthly", "quarterly", "biannual", "yearly")

    Returns:
        True si se debe crear la tarea, False si no
    """
    try:
        year, month = map(int, period.split('-'))
    except:
        return False

    # Monthly: siempre crear (se crea todos los meses)
    if periodicity == 'monthly':
        return True

    # Weekly: crear 4 tareas (una por semana)
    # Para simplificar, creamos 1 tarea semanal cada mes
    # (En fase 2, el scheduler creará 4 tareas reales)
    if periodicity == 'weekly':
        return True

    # Quarterly: solo en meses 1, 4, 7, 10 (enero, abril, julio, octubre)
    if periodicity == 'quarterly':
        return month in [1, 4, 7, 10]

    # Biannual: solo en meses 1 y 7 (enero, julio)
    if periodicity == 'biannual':
        return month in [1, 7]

    # Yearly: solo en mes 1 (enero)
    if periodicity == 'yearly':
        return month == 1

    return False


def create_tasks_for_period(period, db_path, verbose=True):
    """
    Crea tareas para un periodo específico según las periodicidades configuradas.

    Args:
        period: Periodo en formato "YYYY-MM" (ej: "2025-11")
        db_path: Ruta a la base de datos SQLite
        verbose: Si True, muestra mensajes de progreso
    """
    if verbose:
        print(f"\n📅 Creando tareas para el periodo: {period}\n")

    # Conectar a BD
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    # Obtener todas las secciones activas
    cursor.execute("SELECT id, name FROM sections WHERE active = 1")
    sections = cursor.fetchall()

    if not sections:
        print("❌ No hay secciones activas en la BD")
        print("   Ejecuta primero: python load_sections.py")
        conn.close()
        return

    if verbose:
        print(f"📊 Secciones activas: {len(sections)}")

    # Obtener todos los tipos de tareas con sus periodicidades
    cursor.execute("""
        SELECT id, name, display_name, periodicity
        FROM task_types
        ORDER BY display_order
    """)
    task_types = cursor.fetchall()

    if not task_types:
        print("❌ No hay tipos de tareas en la BD")
        print("   Ejecuta primero: python database.py seed")
        conn.close()
        return

    if verbose:
        print(f"📋 Tipos de tareas: {len(task_types)}\n")

    # Estadísticas
    total_created = 0
    total_skipped = 0
    total_errors = 0

    # Para cada tipo de tarea
    for task_type in task_types:
        task_type_id = task_type['id']
        task_name = task_type['display_name']
        periodicity = task_type['periodicity']

        # Verificar si este tipo aplica a este periodo
        if not should_create_task_for_period(period, periodicity):
            if verbose:
                print(f"   ⏩ {task_name} ({periodicity}) - No aplica a este periodo")
            continue

        if verbose:
            print(f"   🔄 {task_name} ({periodicity}) - Creando tareas...")

        created_for_type = 0
        skipped_for_type = 0

        # Crear una tarea para cada sección
        for section in sections:
            section_id = section['id']

            try:
                cursor.execute("""
                    INSERT INTO tasks (section_id, task_type_id, period, status)
                    VALUES (?, ?, ?, 'pending')
                """, (section_id, task_type_id, period))
                created_for_type += 1
            except sqlite3.IntegrityError:
                # Ya existe una tarea para esta combinación (section + type + period)
                skipped_for_type += 1
            except Exception as e:
                total_errors += 1
                if verbose:
                    print(f"      ✗ Error creando tarea para sección {section_id}: {e}")

        total_created += created_for_type
        total_skipped += skipped_for_type

        if verbose:
            print(f"      ✓ Creadas: {created_for_type}, Omitidas: {skipped_for_type}")

    conn.commit()
    conn.close()

    # Resumen
    if verbose:
        print("\n" + "=" * 80)
        print(f"📊 RESUMEN:")
        print(f"   - Tareas creadas: {total_created}")
        print(f"   - Tareas omitidas (ya existían): {total_skipped}")
        print(f"   - Errores: {total_errors}")
        print("=" * 80 + "\n")

        if total_created > 0:
            print(f"✅ {total_created} tareas creadas correctamente para {period}\n")
        else:
            print(f"⚠️  No se crearon tareas nuevas (ya existían o no aplican a este periodo)\n")

    return total_created, total_skipped, total_errors


def get_db_task_stats(db_path):
    """
    Muestra estadísticas de tareas en la BD.
    """
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    print(f"\n📊 Estadísticas de tareas en la BD:\n")

    # Total de tareas
    cursor.execute("SELECT COUNT(*) FROM tasks")
    total = cursor.fetchone()[0]
    print(f"   Total de tareas: {total}")

    # Por status
    cursor.execute("""
        SELECT status, COUNT(*) as count
        FROM tasks
        GROUP BY status
        ORDER BY count DESC
    """)
    print("\n   Por estado:")
    for row in cursor.fetchall():
        status, count = row
        print(f"      {status:12s}: {count:5d} tareas")

    # Por periodo
    cursor.execute("""
        SELECT period, COUNT(*) as count
        FROM tasks
        GROUP BY period
        ORDER BY period DESC
        LIMIT 10
    """)
    print("\n   Por periodo (últimos 10):")
    for row in cursor.fetchall():
        period, count = row
        print(f"      {period:12s}: {count:5d} tareas")

    conn.close()
    print()


def main():
    """
    Script principal con argumentos CLI.
    """
    parser = argparse.ArgumentParser(
        description='Crea tareas manualmente para un periodo dado',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Ejemplos:
  python create_tasks_for_period.py --period 2025-11
  python create_tasks_for_period.py --period 2025-12 --quiet
  python create_tasks_for_period.py --stats
  python create_tasks_for_period.py --next-months 3
        """
    )

    parser.add_argument(
        '--period',
        type=str,
        help='Periodo en formato YYYY-MM (ej: 2025-11)'
    )

    parser.add_argument(
        '--next-months',
        type=int,
        help='Crear tareas para los próximos N meses (desde hoy)'
    )

    parser.add_argument(
        '--stats',
        action='store_true',
        help='Mostrar estadísticas de tareas en la BD'
    )

    parser.add_argument(
        '--quiet',
        action='store_true',
        help='Modo silencioso (no mostrar mensajes de progreso)'
    )

    args = parser.parse_args()

    # Verificar que la BD existe
    if not Path(DATABASE_PATH).exists():
        print(f"❌ ERROR: Base de datos no encontrada: {DATABASE_PATH}")
        print(f"   Ejecuta primero: python database.py")
        sys.exit(1)

    # Modo stats
    if args.stats:
        get_db_task_stats(DATABASE_PATH)
        return

    # Determinar periodo(s) a crear
    periods_to_create = []

    if args.period:
        # Periodo específico
        periods_to_create.append(args.period)

    elif args.next_months:
        # Próximos N meses desde hoy
        from datetime import datetime, timedelta
        from dateutil.relativedelta import relativedelta

        current_date = datetime.now()
        for i in range(args.next_months):
            future_date = current_date + relativedelta(months=i)
            period = future_date.strftime('%Y-%m')
            periods_to_create.append(period)

    else:
        # Por defecto: mes actual
        current_period = datetime.now().strftime('%Y-%m')
        periods_to_create.append(current_period)

    # Crear tareas para cada periodo
    verbose = not args.quiet

    for period in periods_to_create:
        create_tasks_for_period(period, DATABASE_PATH, verbose=verbose)

    # Mostrar estadísticas finales
    if verbose:
        get_db_task_stats(DATABASE_PATH)


if __name__ == '__main__':
    main()
