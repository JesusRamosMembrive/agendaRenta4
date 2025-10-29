#!/usr/bin/env python3
"""
Agenda Renta4 - Task Manager Manual
Flask application principal
"""

import os
import calendar
from datetime import datetime, date, timedelta
from flask import Flask, render_template, request, redirect, url_for, flash, session, jsonify
from flask_mail import Mail, Message
from dotenv import load_dotenv
import sqlite3

# Load environment variables
load_dotenv()

# Initialize Flask app
app = Flask(__name__)
app.secret_key = os.getenv('SECRET_KEY', 'dev-secret-key-change-in-production')

# Configuration
DATABASE_PATH = os.getenv('DATABASE_PATH', 'agendaRenta4.db')

# Email Configuration
app.config['MAIL_SERVER'] = os.getenv('MAIL_SERVER', 'smtp.gmail.com')
app.config['MAIL_PORT'] = int(os.getenv('MAIL_PORT', 587))
app.config['MAIL_USE_TLS'] = os.getenv('MAIL_USE_TLS', 'True') == 'True'
app.config['MAIL_USE_SSL'] = os.getenv('MAIL_USE_SSL', 'False') == 'True'
app.config['MAIL_USERNAME'] = os.getenv('MAIL_USERNAME')
app.config['MAIL_PASSWORD'] = os.getenv('MAIL_PASSWORD')
app.config['MAIL_DEFAULT_SENDER'] = os.getenv('MAIL_DEFAULT_SENDER', 'Agenda Renta4 <noreply@renta4.com>')
app.config['MAIL_DEBUG'] = os.getenv('MAIL_DEBUG', 'True') == 'True'

# Initialize Flask-Mail
mail = Mail(app)


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
    Get counts of pending, problem, completed tasks, and pending alerts.
    Returns dict with 'pending', 'problems', 'completed', 'alerts' counts.
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

    # Count pending alerts (not dismissed)
    cursor.execute("""
        SELECT COUNT(*) as count
        FROM pending_alerts
        WHERE dismissed = 0
    """)
    alerts_count = cursor.fetchone()['count']

    conn.close()

    return {
        'pending': pending_count,
        'problems': problems_count,
        'completed': completed_count,
        'alerts': alerts_count
    }


def generate_alerts(reference_date=None):
    """
    Generate pending alerts based on alert_settings configuration.
    Creates one alert per task_type (not per section).
    This function should be run periodically (daily) to create alerts.

    Args:
        reference_date: Date to use as reference (default: today)

    Returns:
        dict with stats: {'generated': count, 'skipped': count, 'errors': [], 'email_stats': {...}}
    """
    if reference_date is None:
        reference_date = date.today()

    conn = get_db_connection()
    cursor = conn.cursor()

    stats = {'generated': 0, 'skipped': 0, 'errors': [], 'email_stats': None}

    try:
        # Get all active alert settings
        cursor.execute("""
            SELECT task_type_id, alert_frequency, alert_day, enabled
            FROM alert_settings
            WHERE enabled = 1
        """)
        alert_settings = cursor.fetchall()

        for alert_setting in alert_settings:
            task_type_id = alert_setting['task_type_id']
            frequency = alert_setting['alert_frequency']
            alert_day = alert_setting['alert_day']

            # Check if today matches the alert criteria
            should_alert = check_alert_day(reference_date, frequency, alert_day)

            if not should_alert:
                stats['skipped'] += 1
                continue

            try:
                # Create one alert per task_type (not per section)
                cursor.execute("""
                    INSERT OR IGNORE INTO pending_alerts
                    (task_type_id, due_date)
                    VALUES (?, ?)
                """, (task_type_id, reference_date))

                if cursor.rowcount > 0:
                    stats['generated'] += 1
                else:
                    stats['skipped'] += 1

            except Exception as e:
                stats['errors'].append(f"Error creating alert for task_type={task_type_id}: {str(e)}")

        conn.commit()

        # If new alerts were generated, send email notifications
        if stats['generated'] > 0:
            # Fetch newly generated alerts for email
            cursor.execute("""
                SELECT
                    tt.display_name as task_type_name,
                    pa.due_date,
                    tt.periodicity
                FROM pending_alerts pa
                INNER JOIN task_types tt ON pa.task_type_id = tt.id
                WHERE pa.due_date = ?
                ORDER BY tt.display_name ASC
            """, (reference_date,))

            new_alerts = cursor.fetchall()

            # Send email notifications
            email_stats = send_email_notifications(new_alerts)
            stats['email_stats'] = email_stats

    except Exception as e:
        stats['errors'].append(f"Fatal error: {str(e)}")
    finally:
        conn.close()

    return stats


def check_alert_day(reference_date, frequency, alert_day):
    """
    Check if the reference_date matches the alert configuration.

    Args:
        reference_date: date object to check
        frequency: alert frequency (daily, weekly, biweekly, monthly, quarterly, semiannual, annual)
        alert_day: specific day configuration (day of week or day of month)

    Returns:
        bool: True if alert should be generated for this date
    """
    if frequency == 'daily':
        return True

    if frequency in ['weekly', 'biweekly']:
        # Map weekday names to numbers (monday=0, sunday=6)
        weekday_map = {
            'monday': 0, 'tuesday': 1, 'wednesday': 2, 'thursday': 3,
            'friday': 4, 'saturday': 5, 'sunday': 6
        }
        target_weekday = weekday_map.get(alert_day)

        if target_weekday is None:
            return False

        # Check if today is the configured weekday
        if reference_date.weekday() != target_weekday:
            return False

        # For biweekly, also check if it's an even/odd week
        # Simple implementation: alert on weeks where week_number % 2 == 0
        if frequency == 'biweekly':
            week_number = reference_date.isocalendar()[1]
            return week_number % 2 == 0

        return True

    if frequency in ['monthly', 'quarterly', 'semiannual', 'annual']:
        # Get target day (handle edge case for months with fewer days)
        try:
            target_day = int(alert_day)
        except (ValueError, TypeError):
            return False

        # Get last day of current month
        last_day = calendar.monthrange(reference_date.year, reference_date.month)[1]

        # Adjust target day if month doesn't have enough days
        effective_day = min(target_day, last_day)

        # Check if today is the target day
        if reference_date.day != effective_day:
            return False

        # Additional checks for quarterly/semiannual/annual
        if frequency == 'quarterly':
            # Alert only in Jan, Apr, Jul, Oct
            return reference_date.month in [1, 4, 7, 10]

        if frequency == 'semiannual':
            # Alert only in Jan and Jul
            return reference_date.month in [1, 7]

        if frequency == 'annual':
            # Alert only in January
            return reference_date.month == 1

        # Monthly: always true if day matches
        return True

    return False


def send_email_notifications(alert_list):
    """
    Send email notifications for newly generated alerts.

    Args:
        alert_list: List of dicts with keys: task_type_name, due_date, etc.

    Returns:
        dict with stats: {'sent': count, 'failed': count, 'errors': []}
    """
    stats = {'sent': 0, 'failed': 0, 'errors': []}

    # Check if email notifications are enabled
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT enable_email FROM notification_preferences
        WHERE user_name = ? AND enable_email = 1
        LIMIT 1
    """, ('José Ramos',))

    email_enabled = cursor.fetchone()

    if not email_enabled:
        conn.close()
        stats['errors'].append('Email notifications not enabled')
        return stats

    # Get active email addresses
    cursor.execute("""
        SELECT email, name FROM notification_emails
        WHERE active = 1
        ORDER BY id ASC
    """)

    email_recipients = cursor.fetchall()
    conn.close()

    if not email_recipients:
        stats['errors'].append('No active email recipients configured')
        return stats

    # Check if SMTP is configured
    if not app.config['MAIL_USERNAME'] or not app.config['MAIL_PASSWORD']:
        stats['errors'].append('SMTP not configured. Set MAIL_USERNAME and MAIL_PASSWORD in .env')
        return stats

    # Prepare email content
    if not alert_list:
        return stats

    try:
        # Build email body
        html_body = f"""
        <html>
        <head>
            <style>
                body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
                .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
                .header {{ background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
                          color: white; padding: 20px; border-radius: 8px 8px 0 0; }}
                .content {{ background: #f9fafb; padding: 20px; }}
                .alert-item {{ background: white; padding: 15px; margin: 10px 0;
                               border-left: 4px solid #f59e0b; border-radius: 4px; }}
                .alert-title {{ font-weight: bold; color: #f59e0b; font-size: 1.1em; }}
                .alert-date {{ color: #6b7280; font-size: 0.9em; }}
                .footer {{ background: #1f2937; color: #9ca3af; padding: 15px;
                          border-radius: 0 0 8px 8px; text-align: center; font-size: 0.85em; }}
                .btn {{ background: #5b8cff; color: white; padding: 10px 20px;
                       text-decoration: none; border-radius: 6px; display: inline-block;
                       margin-top: 10px; }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h2 style="margin: 0;">⚠️ Nuevas Alertas - Agenda Renta4</h2>
                    <p style="margin: 5px 0 0 0; opacity: 0.9;">
                        Se han generado {len(alert_list)} nueva(s) alerta(s) pendiente(s)
                    </p>
                </div>

                <div class="content">
                    <p><strong>Hola,</strong></p>
                    <p>Se han generado las siguientes alertas que requieren tu atención:</p>
        """

        for alert in alert_list:
            html_body += f"""
                    <div class="alert-item">
                        <div class="alert-title">{alert['task_type_name']}</div>
                        <div class="alert-date">Fecha de aviso: {alert['due_date']}</div>
                        <p style="margin: 8px 0 0 0; color: #6b7280; font-size: 0.9em;">
                            Revisar todas las URLs para esta tarea
                        </p>
                    </div>
            """

        html_body += """
                    <p style="margin-top: 20px;">
                        <a href="http://localhost:5000/alertas" class="btn">Ver Alertas Pendientes</a>
                    </p>
                </div>

                <div class="footer">
                    <p style="margin: 0;">
                        Este es un mensaje automático de Agenda Renta4. Por favor, no respondas a este email.
                    </p>
                </div>
            </div>
        </body>
        </html>
        """

        # Send email to all recipients
        for recipient in email_recipients:
            try:
                msg = Message(
                    subject=f"🔔 {len(alert_list)} Nueva(s) Alerta(s) - Agenda Renta4",
                    recipients=[recipient['email']],
                    html=html_body
                )

                mail.send(msg)
                stats['sent'] += 1

            except Exception as e:
                stats['failed'] += 1
                stats['errors'].append(f"Failed to send to {recipient['email']}: {str(e)}")

    except Exception as e:
        stats['errors'].append(f"Error building email: {str(e)}")

    return stats


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
# ALERTS ROUTES
# ==============================================================================

@app.route('/admin/generate-alerts', methods=['POST'])
def trigger_generate_alerts():
    """
    Manually trigger alert generation for testing.
    Can accept optional date parameter (YYYY-MM-DD format).
    """
    try:
        # Get optional date from request
        date_str = request.form.get('date') or request.args.get('date')

        if date_str:
            try:
                reference_date = datetime.strptime(date_str, '%Y-%m-%d').date()
            except ValueError:
                return jsonify({'success': False, 'error': 'Invalid date format. Use YYYY-MM-DD'}), 400
        else:
            reference_date = None  # Will use today by default

        # Generate alerts
        stats = generate_alerts(reference_date)

        return jsonify({
            'success': True,
            'message': 'Alertas generadas correctamente',
            'stats': stats
        })

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/alertas')
def alertas():
    """
    Display ALL alerts (both active and dismissed)
    One alert per task_type, not per section
    """
    period = session.get('current_period', datetime.now().strftime('%Y-%m'))
    current_user = 'José Ramos'

    conn = get_db_connection()
    cursor = conn.cursor()

    # Get ALL alerts with task type info (both active and dismissed)
    cursor.execute("""
        SELECT
            pa.id,
            pa.due_date,
            pa.generated_at,
            pa.dismissed,
            pa.dismissed_at,
            tt.display_name as task_type_name,
            tt.periodicity
        FROM pending_alerts pa
        INNER JOIN task_types tt ON pa.task_type_id = tt.id
        ORDER BY pa.dismissed ASC, pa.due_date ASC, tt.display_order ASC
    """)

    alerts_raw = cursor.fetchall()
    all_alerts = [dict(row) for row in alerts_raw]

    conn.close()

    # Generate available periods
    available_periods = generate_available_periods()

    return render_template(
        'alertas.html',
        period=period,
        pending_alerts=all_alerts,
        available_periods=available_periods,
        current_user=current_user
    )


@app.route('/alertas/dismiss/<int:alert_id>', methods=['POST'])
def dismiss_alert(alert_id):
    """
    Toggle alert status (active ↔ dismissed)
    """
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Get current status
        cursor.execute("SELECT dismissed FROM pending_alerts WHERE id = ?", (alert_id,))
        row = cursor.fetchone()

        if not row:
            return jsonify({'success': False, 'error': 'Alerta no encontrada'}), 404

        current_dismissed = row['dismissed']
        new_dismissed = 0 if current_dismissed else 1

        # Toggle dismissed status
        if new_dismissed:
            # Mark as dismissed
            cursor.execute("""
                UPDATE pending_alerts
                SET dismissed = 1, dismissed_at = CURRENT_TIMESTAMP
                WHERE id = ?
            """, (alert_id,))
            message = 'Alerta marcada como resuelta'
        else:
            # Mark as active again
            cursor.execute("""
                UPDATE pending_alerts
                SET dismissed = 0, dismissed_at = NULL
                WHERE id = ?
            """, (alert_id,))
            message = 'Alerta reactivada'

        conn.commit()
        conn.close()

        return jsonify({
            'success': True,
            'message': message,
            'dismissed': new_dismissed
        })

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