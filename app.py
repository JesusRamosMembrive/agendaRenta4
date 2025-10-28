#!/usr/bin/env python3
"""
Agenda Renta4 - Task Manager Manual
Flask application principal
"""

import os
from datetime import datetime
from flask import Flask, render_template, request, redirect, url_for, flash, session, jsonify
from dotenv import load_dotenv
import sqlite3

# Load environment variables
load_dotenv()

# Initialize Flask app
app = Flask(__name__)
app.secret_key = os.getenv('SECRET_KEY', 'dev-secret-key-change-in-production')

# Configuration
DATABASE_PATH = os.getenv('DATABASE_PATH', 'agendaRenta4.db')


def get_db_connection():
    """
    Create and return a database connection.
    """
    conn = sqlite3.connect(DATABASE_PATH)
    conn.row_factory = sqlite3.Row  # Return rows as dict-like objects
    return conn


# ==============================================================================
# HELPER FUNCTIONS
# ==============================================================================

def generate_available_periods():
    """
    Generate list of available periods (last 6 months + next 6 months).
    Returns list of strings in format 'YYYY-MM'.
    """
    from dateutil.relativedelta import relativedelta

    current_date = datetime.now()
    periods = []

    # Last 6 months
    for i in range(6, 0, -1):
        past_date = current_date - relativedelta(months=i)
        periods.append(past_date.strftime('%Y-%m'))

    # Current month
    periods.append(current_date.strftime('%Y-%m'))

    # Next 6 months
    for i in range(1, 7):
        future_date = current_date + relativedelta(months=i)
        periods.append(future_date.strftime('%Y-%m'))

    return periods


def get_task_counts():
    """
    Get counts of pending, problem, and completed tasks.
    Returns dict with 'pending', 'problems', 'completed' counts.
    """
    conn = get_db_connection()
    cursor = conn.cursor()
    current_period = datetime.now().strftime('%Y-%m')

    # Count total possible tasks (active sections * task types) for current period
    cursor.execute("SELECT COUNT(*) as count FROM sections WHERE active = 1")
    total_sections = cursor.fetchone()['count']

    cursor.execute("SELECT COUNT(*) as count FROM task_types")
    total_task_types = cursor.fetchone()['count']

    total_possible_tasks = total_sections * total_task_types

    # Count completed tasks (status='ok') for current period
    cursor.execute("""
        SELECT COUNT(*) as count
        FROM tasks t
        INNER JOIN sections s ON t.section_id = s.id
        WHERE s.active = 1
          AND t.status = 'ok'
          AND t.period = ?
    """, (current_period,))
    ok_count = cursor.fetchone()['count']

    # Count problem tasks for current period
    cursor.execute("""
        SELECT COUNT(*) as count
        FROM tasks t
        INNER JOIN sections s ON t.section_id = s.id
        WHERE s.active = 1
          AND t.status = 'problem'
          AND t.period = ?
    """, (current_period,))
    problems_count = cursor.fetchone()['count']

    # Pending = Total possible - OK - Problems
    pending_count = total_possible_tasks - ok_count - problems_count

    # Count completed tasks (all history) for "Realizadas" page
    cursor.execute("""
        SELECT COUNT(*) as count
        FROM tasks t
        INNER JOIN sections s ON t.section_id = s.id
        WHERE s.active = 1
          AND t.status = 'ok'
    """)
    completed_count = cursor.fetchone()['count']

    conn.close()

    return {
        'pending': pending_count,
        'problems': problems_count,
        'completed': completed_count
    }


# ==============================================================================
# CONTEXT PROCESSORS
# ==============================================================================

@app.context_processor
def inject_task_counts():
    """
    Make task counts available to all templates
    """
    return {'task_counts': get_task_counts()}


# ==============================================================================
# TEMPLATE FILTERS
# ==============================================================================

@app.template_filter('format_date')
def format_date(date_str):
    """
    Format date string to Spanish format: dd/mm/yyyy
    """
    if not date_str:
        return ''
    try:
        date_obj = datetime.strptime(str(date_str), '%Y-%m-%d')
        return date_obj.strftime('%d/%m/%Y')
    except:
        return date_str


@app.template_filter('format_period')
def format_period(period_str):
    """
    Format period string from '2025-11' to 'Noviembre 2025'
    """
    if not period_str:
        return ''
    try:
        year, month = period_str.split('-')
        months_es = ['', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
                     'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre']
        return f"{months_es[int(month)]} {year}"
    except:
        return period_str


# ==============================================================================
# ROUTES
# ==============================================================================

@app.route('/')
def index():
    """
    Redirect to inicio page (main dashboard)
    """
    return redirect(url_for('inicio'))


@app.route('/inicio')
def inicio():
    """
    Main dashboard - Table with all URLs and their 8 task types
    """
    # Get selected period from query params or session (default: current month)
    period = request.args.get('period')
    if not period:
        period = session.get('current_period', datetime.now().strftime('%Y-%m'))
    else:
        session['current_period'] = period

    # Get database connection
    conn = get_db_connection()
    cursor = conn.cursor()

    # Get all active sections (URLs)
    cursor.execute("""
        SELECT id, name, url
        FROM sections
        WHERE active = 1
        ORDER BY name ASC
    """)
    sections_raw = cursor.fetchall()

    # Get all task types (8 types)
    cursor.execute("""
        SELECT id, name, display_name, periodicity, display_order
        FROM task_types
        ORDER BY display_order ASC
    """)
    task_types = cursor.fetchall()

    # For each section, get tasks of the current period
    sections = []
    for section_row in sections_raw:
        section = dict(section_row)

        # Get tasks for this section in this period
        cursor.execute("""
            SELECT id, task_type_id, status, observations, completed_date, completed_by
            FROM tasks
            WHERE section_id = ? AND period = ?
        """, (section['id'], period))

        tasks = cursor.fetchall()

        # Create a dict indexed by task_type_id for easy lookup
        tasks_by_type = {}
        section_observations = None

        for task in tasks:
            tasks_by_type[task['task_type_id']] = dict(task)
            # Usar las observaciones de la primera tarea con observaciones
            if task['observations'] and not section_observations:
                section_observations = task['observations']

        section['tasks_by_type'] = tasks_by_type
        section['observations'] = section_observations
        sections.append(section)

    conn.close()

    # Generate available periods (last 6 months + next 6 months)
    available_periods = generate_available_periods()

    # Current user (hardcoded for now, in future get from session)
    current_user = 'José Ramos'

    return render_template(
        'inicio.html',
        period=period,
        sections=sections,
        task_types=task_types,
        available_periods=available_periods,
        current_user=current_user
    )


@app.route('/pendientes')
def pendientes():
    """
    List of pending tasks (status='pending' only - not yet reviewed)
    Shows tasks from 2025-10 onwards that have not been reviewed
    """
    period = session.get('current_period', datetime.now().strftime('%Y-%m'))
    current_period = datetime.now().strftime('%Y-%m')

    conn = get_db_connection()
    cursor = conn.cursor()

    # Query only pending tasks (not reviewed) from 2025-10 to current month
    cursor.execute("""
        SELECT
            t.id,
            t.period,
            t.status,
            t.observations,
            t.completed_date,
            t.completed_by,
            s.name as section_name,
            s.url as section_url,
            tt.display_name as task_type_name,
            tt.periodicity
        FROM tasks t
        INNER JOIN sections s ON t.section_id = s.id
        INNER JOIN task_types tt ON t.task_type_id = tt.id
        WHERE
            s.active = 1
            AND t.status = 'pending'
            AND t.period >= '2025-10'
            AND t.period <= ?
        ORDER BY t.period DESC, s.name ASC, tt.display_order ASC
    """, (current_period,))

    tasks_raw = cursor.fetchall()
    pending_tasks = [dict(row) for row in tasks_raw]

    conn.close()

    # Generate available periods
    available_periods = generate_available_periods()
    current_user = 'José Ramos'

    return render_template(
        'pendientes.html',
        period=period,
        pending_tasks=pending_tasks,
        available_periods=available_periods,
        current_user=current_user
    )


@app.route('/problemas')
def problemas():
    """
    List of tasks with problems (status='problem')
    Shows tasks from 2025-10 onwards that have issues
    """
    period = session.get('current_period', datetime.now().strftime('%Y-%m'))
    current_period = datetime.now().strftime('%Y-%m')

    conn = get_db_connection()
    cursor = conn.cursor()

    # Query problem tasks from 2025-10 to current month
    cursor.execute("""
        SELECT
            t.id,
            t.period,
            t.status,
            t.observations,
            t.completed_date,
            t.completed_by,
            s.name as section_name,
            s.url as section_url,
            tt.display_name as task_type_name,
            tt.periodicity
        FROM tasks t
        INNER JOIN sections s ON t.section_id = s.id
        INNER JOIN task_types tt ON t.task_type_id = tt.id
        WHERE
            s.active = 1
            AND t.status = 'problem'
            AND t.period >= '2025-10'
            AND t.period <= ?
        ORDER BY t.period DESC, s.name ASC, tt.display_order ASC
    """, (current_period,))

    tasks_raw = cursor.fetchall()
    problem_tasks = [dict(row) for row in tasks_raw]

    conn.close()

    # Generate available periods
    available_periods = generate_available_periods()
    current_user = 'José Ramos'

    return render_template(
        'problemas.html',
        period=period,
        problem_tasks=problem_tasks,
        available_periods=available_periods,
        current_user=current_user
    )


@app.route('/realizadas')
def realizadas():
    """
    List of completed tasks (status='ok')
    Shows complete history of all tasks marked as OK
    """
    period = session.get('current_period', datetime.now().strftime('%Y-%m'))

    conn = get_db_connection()
    cursor = conn.cursor()

    # Query all completed tasks (status='ok') from complete history
    cursor.execute("""
        SELECT
            t.id,
            t.period,
            t.completed_date,
            t.completed_by,
            s.name as section_name,
            s.url as section_url,
            tt.display_name as task_type_name,
            tt.periodicity
        FROM tasks t
        INNER JOIN sections s ON t.section_id = s.id
        INNER JOIN task_types tt ON t.task_type_id = tt.id
        WHERE
            s.active = 1
            AND t.status = 'ok'
        ORDER BY t.completed_date DESC, t.period DESC, s.name ASC
    """)

    tasks_raw = cursor.fetchall()
    completed_tasks = [dict(row) for row in tasks_raw]

    conn.close()

    # Generate available periods
    available_periods = generate_available_periods()
    current_user = 'José Ramos'

    return render_template(
        'realizadas.html',
        period=period,
        completed_tasks=completed_tasks,
        available_periods=available_periods,
        current_user=current_user
    )


@app.route('/configuracion')
def configuracion():
    """
    Configuration page - CRUD for URLs and task type periodicities
    """
    # TODO: Query sections and task_types from database
    return render_template('configuracion.html', sections=[], task_types=[])


@app.route('/tasks/update', methods=['POST'])
def update_task():
    """
    Update task status (ok/problem) via AJAX
    Returns JSON response
    """
    try:
        task_id = request.form.get('task_id')
        status = request.form.get('status')  # 'ok' or 'problem'
        section_id = request.form.get('section_id')
        task_type_id = request.form.get('task_type_id')
        period = request.form.get('period')

        conn = get_db_connection()
        cursor = conn.cursor()

        # Determine completed_date and completed_by based on status
        if status in ('ok', 'problem'):
            completed_date = datetime.now().strftime('%Y-%m-%d')
            completed_by = 'José Ramos'
        else:
            # status='pending' means not completed yet
            completed_date = None
            completed_by = None

        # If task_id exists, update existing task
        if task_id:
            cursor.execute("""
                UPDATE tasks
                SET status = ?,
                    completed_date = ?,
                    completed_by = ?
                WHERE id = ?
            """, (status, completed_date, completed_by, task_id))
            new_task_id = task_id
        else:
            # Create new task if it doesn't exist yet
            cursor.execute("""
                INSERT INTO tasks (section_id, task_type_id, period, status, completed_date, completed_by)
                VALUES (?, ?, ?, ?, ?, ?)
            """, (section_id, task_type_id, period, status, completed_date, completed_by))
            new_task_id = cursor.lastrowid

        conn.commit()
        conn.close()

        return jsonify({'success': True, 'task_id': new_task_id})

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/save_observations', methods=['POST'])
def save_observations():
    """
    Save observations for all tasks of a section (when there are problems)
    Returns JSON response
    """
    try:
        section_id = request.form.get('section_id')
        period = request.form.get('period')
        observations = request.form.get('observations', '')

        conn = get_db_connection()
        cursor = conn.cursor()

        # Update observations for all tasks of this section in this period
        cursor.execute("""
            UPDATE tasks
            SET observations = ?
            WHERE section_id = ? AND period = ?
        """, (observations, section_id, period))

        conn.commit()
        conn.close()

        return jsonify({'success': True})

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


# ==============================================================================
# ERROR HANDLERS
# ==============================================================================

@app.errorhandler(404)
def not_found(error):
    """
    Handle 404 errors
    """
    # Provide minimal context for base template
    return render_template(
        'errors/404.html',
        period=None,
        available_periods=[],
        current_user='José Ramos'
    ), 404


@app.errorhandler(500)
def internal_error(error):
    """
    Handle 500 errors
    """
    # Provide minimal context for base template
    return render_template(
        'errors/500.html',
        period=None,
        available_periods=[],
        current_user='José Ramos'
    ), 500


# ==============================================================================
# MAIN
# ==============================================================================

if __name__ == '__main__':
    # Check if database exists
    if not os.path.exists(DATABASE_PATH):
        print(f"⚠️  Database not found: {DATABASE_PATH}")
        print(f"   Run: python database.py")
        print()

    # Run Flask development server
    port = int(os.getenv('PORT', 5000))
    app.run(debug=True, host='0.0.0.0', port=port)