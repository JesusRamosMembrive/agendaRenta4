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
    List of ALL pending tasks (not marked as OK or Problem)
    Generates all possible combinations and excludes completed/problem tasks
    """
    period = session.get('current_period', datetime.now().strftime('%Y-%m'))
    current_period = datetime.now().strftime('%Y-%m')

    conn = get_db_connection()
    cursor = conn.cursor()

    # Get all active sections
    cursor.execute("SELECT id, name, url FROM sections WHERE active = 1 ORDER BY name ASC")
    sections = cursor.fetchall()

    # Get all task types
    cursor.execute("SELECT id, display_name, periodicity, display_order FROM task_types ORDER BY display_order ASC")
    task_types = cursor.fetchall()

    # Get all tasks that are OK or Problem for current period
    cursor.execute("""
        SELECT section_id, task_type_id, status
        FROM tasks
        WHERE period = ? AND status IN ('ok', 'problem')
    """, (current_period,))
    completed_tasks = cursor.fetchall()

    # Create a set of (section_id, task_type_id) tuples that are already done
    completed_set = {(task['section_id'], task['task_type_id']) for task in completed_tasks}

    # Generate all pending tasks (combinations not in completed_set)
    pending_tasks = []
    for section in sections:
        for task_type in task_types:
            task_key = (section['id'], task_type['id'])
            if task_key not in completed_set:
                pending_tasks.append({
                    'id': None,
                    'period': current_period,
                    'status': 'pending',
                    'section_name': section['name'],
                    'section_url': section['url'],
                    'task_type_name': task_type['display_name'],
                    'periodicity': task_type['periodicity'],
                    'observations': None,
                    'completed_date': None,
                    'completed_by': None
                })

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
    Configuration page - CRUD for URLs, Alerts and Notification preferences
    """
    conn = get_db_connection()
    cursor = conn.cursor()
    current_user = 'José Ramos'

    # Get all task types
    cursor.execute("""
        SELECT id, name, display_name, periodicity, display_order
        FROM task_types
        ORDER BY display_order ASC
    """)
    task_types = [dict(row) for row in cursor.fetchall()]

    # Get alert settings for each task type
    cursor.execute("""
        SELECT task_type_id, alert_frequency, alert_day, enabled
        FROM alert_settings
    """)
    alert_settings_raw = cursor.fetchall()
    alert_settings = {row['task_type_id']: dict(row) for row in alert_settings_raw}

    # Merge task_types with their alert settings
    for task_type in task_types:
        task_type['alert'] = alert_settings.get(task_type['id'], {
            'alert_frequency': task_type['periodicity'],
            'alert_day': '1',  # default day
            'enabled': True
        })

    # Get notification preferences for current user
    cursor.execute("""
        SELECT email, enable_email, enable_desktop, enable_in_app
        FROM notification_preferences
        WHERE user_name = ?
    """, (current_user,))
    notification_prefs_row = cursor.fetchone()
    notification_prefs = dict(notification_prefs_row) if notification_prefs_row else {
        'email': '',
        'enable_email': False,
        'enable_desktop': False,
        'enable_in_app': True
    }

    # Get all sections (URLs)
    cursor.execute("""
        SELECT id, name, url, active, created_at
        FROM sections
        ORDER BY name ASC
    """)
    sections = [dict(row) for row in cursor.fetchall()]

    conn.close()

    # Generate available periods
    available_periods = generate_available_periods()

    return render_template(
        'configuracion.html',
        task_types=task_types,
        notification_prefs=notification_prefs,
        sections=sections,
        available_periods=available_periods,
        current_user=current_user
    )


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
# CONFIGURATION ROUTES
# ==============================================================================

@app.route('/configuracion/alertas', methods=['POST'])
def save_alert_settings():
    """
    Save alert settings for all task types
    Expects JSON: [{ task_type_id, alert_frequency, alert_day, enabled }, ...]
    """
    try:
        alerts_data = request.get_json()

        conn = get_db_connection()
        cursor = conn.cursor()

        for alert in alerts_data:
            task_type_id = alert.get('task_type_id')
            alert_frequency = alert.get('alert_frequency')
            alert_day = alert.get('alert_day')
            enabled = alert.get('enabled', True)

            # Update or insert alert_settings
            cursor.execute("""
                INSERT OR REPLACE INTO alert_settings (task_type_id, alert_frequency, alert_day, enabled)
                VALUES (?, ?, ?, ?)
            """, (task_type_id, alert_frequency, alert_day, 1 if enabled else 0))

        conn.commit()
        conn.close()

        return jsonify({'success': True, 'message': 'Configuración de alertas guardada'})

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/configuracion/notificaciones', methods=['POST'])
def save_notification_preferences():
    """
    Save notification preferences for current user
    """
    try:
        email = request.form.get('email', '')
        enable_email = request.form.get('enable_email') == 'true'
        enable_desktop = request.form.get('enable_desktop') == 'true'
        enable_in_app = request.form.get('enable_in_app') == 'true'
        current_user = 'José Ramos'

        conn = get_db_connection()
        cursor = conn.cursor()

        # Update or insert notification preferences
        cursor.execute("""
            INSERT OR REPLACE INTO notification_preferences
            (id, user_name, email, enable_email, enable_desktop, enable_in_app, updated_at)
            VALUES (1, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
        """, (current_user, email, 1 if enable_email else 0, 1 if enable_desktop else 0, 1 if enable_in_app else 0))

        conn.commit()
        conn.close()

        return jsonify({'success': True, 'message': 'Preferencias de notificación guardadas'})

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/configuracion/url/add', methods=['POST'])
def add_url():
    """
    Add new URL/section
    """
    try:
        name = request.form.get('name', '').strip()
        url = request.form.get('url', '').strip()

        if not name or not url:
            return jsonify({'success': False, 'error': 'Nombre y URL son obligatorios'}), 400

        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO sections (name, url, active, created_at)
            VALUES (?, ?, 1, CURRENT_TIMESTAMP)
        """, (name, url))

        new_id = cursor.lastrowid
        conn.commit()
        conn.close()

        return jsonify({'success': True, 'id': new_id, 'message': 'URL agregada correctamente'})

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/configuracion/url/edit/<int:url_id>', methods=['POST'])
def edit_url(url_id):
    """
    Edit existing URL/section
    """
    try:
        name = request.form.get('name', '').strip()
        url = request.form.get('url', '').strip()

        if not name or not url:
            return jsonify({'success': False, 'error': 'Nombre y URL son obligatorios'}), 400

        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute("""
            UPDATE sections
            SET name = ?, url = ?
            WHERE id = ?
        """, (name, url, url_id))

        conn.commit()
        conn.close()

        return jsonify({'success': True, 'message': 'URL actualizada correctamente'})

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/configuracion/url/toggle/<int:url_id>', methods=['POST'])
def toggle_url(url_id):
    """
    Toggle active status of URL/section
    """
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Get current status
        cursor.execute("SELECT active FROM sections WHERE id = ?", (url_id,))
        row = cursor.fetchone()

        if not row:
            return jsonify({'success': False, 'error': 'URL no encontrada'}), 404

        new_status = 0 if row['active'] else 1

        cursor.execute("""
            UPDATE sections
            SET active = ?
            WHERE id = ?
        """, (new_status, url_id))

        conn.commit()
        conn.close()

        return jsonify({'success': True, 'active': new_status, 'message': 'Estado actualizado'})

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/configuracion/url/delete/<int:url_id>', methods=['POST'])
def delete_url(url_id):
    """
    Delete URL/section (only if no associated tasks)
    """
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Check if there are tasks associated
        cursor.execute("SELECT COUNT(*) as count FROM tasks WHERE section_id = ?", (url_id,))
        count = cursor.fetchone()['count']

        if count > 0:
            return jsonify({
                'success': False,
                'error': f'No se puede eliminar. Hay {count} tareas asociadas a esta URL.'
            }), 400

        # Delete section
        cursor.execute("DELETE FROM sections WHERE id = ?", (url_id,))

        conn.commit()
        conn.close()

        return jsonify({'success': True, 'message': 'URL eliminada correctamente'})

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