"""
Configuration Routes Blueprint
All configuration-related routes extracted from app.py
"""

from datetime import datetime
from flask import Blueprint, render_template, request, redirect, url_for, flash, jsonify
from flask_login import login_required, current_user
from utils import db_cursor, generate_available_periods

# Create blueprint
config_bp = Blueprint('config', __name__, url_prefix='/configuracion')


@config_bp.route('')
@login_required
def index():
    """
    Configuration page - Alerts and Notification preferences
    """
    with db_cursor(commit=False) as cursor:
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
            WHERE user_name = %s
        """, (current_user.full_name,))
        notification_prefs_row = cursor.fetchone()
        notification_prefs = dict(notification_prefs_row) if notification_prefs_row else {
            'email': '',
            'enable_email': False,
            'enable_desktop': False,
            'enable_in_app': True
        }

    # Generate available periods
    available_periods = generate_available_periods()

    return render_template(
        'configuracion.html',
        task_types=task_types,
        notification_prefs=notification_prefs,
        available_periods=available_periods,
        current_user=current_user
    )


@config_bp.route('/urls')
@login_required
def urls():
    """
    URL management page (CRUD operations)
    """
    with db_cursor(commit=False) as cursor:
        # Get all sections (URLs)
        cursor.execute("""
            SELECT id, name, url, active, created_at
            FROM sections
            ORDER BY name ASC
        """)
        sections = [dict(row) for row in cursor.fetchall()]

    # Generate available periods for consistency
    available_periods = generate_available_periods()

    return render_template(
        'configuracion_urls.html',
        sections=sections,
        available_periods=available_periods,
        current_user=current_user
    )


@config_bp.route('/herramientas')
@login_required
def herramientas():
    """
    Automatic analysis tools configuration page
    """
    # Generate available periods for consistency with other config pages
    available_periods = generate_available_periods()

    return render_template(
        'configuracion_herramientas.html',
        available_periods=available_periods,
        current_user=current_user
    )


@config_bp.route('/alertas', methods=['POST'])
@login_required
def save_alert_settings():
    """
    Save alert settings for all task types
    Expects JSON: [{ task_type_id, alert_frequency, alert_day, enabled }, ...]
    """
    try:
        alerts_data = request.get_json()

        with db_cursor() as cursor:
            for alert in alerts_data:
                task_type_id = alert.get('task_type_id')
                alert_frequency = alert.get('alert_frequency')
                alert_day = alert.get('alert_day')
                enabled = alert.get('enabled', True)

                # Update or insert alert_settings
                cursor.execute("""
                    INSERT INTO alert_settings (task_type_id, alert_frequency, alert_day, enabled)
                    VALUES (%s, %s, %s, %s)
                    ON CONFLICT (task_type_id)
                    DO UPDATE SET
                        alert_frequency = EXCLUDED.alert_frequency,
                        alert_day = EXCLUDED.alert_day,
                        enabled = EXCLUDED.enabled
                """, (task_type_id, alert_frequency, alert_day, enabled))

        return jsonify({'success': True, 'message': 'Configuración de alertas guardada'})

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@config_bp.route('/notificaciones', methods=['POST'])
@login_required
def save_notification_preferences():
    """
    Save notification preferences for current user
    """
    try:
        email = request.form.get('email', '')
        enable_email = request.form.get('enable_email') == 'true'
        enable_desktop = request.form.get('enable_desktop') == 'true'
        enable_in_app = request.form.get('enable_in_app') == 'true'

        with db_cursor() as cursor:
            # Update or insert notification preferences
            cursor.execute("""
                INSERT INTO notification_preferences
                (user_name, email, enable_email, enable_desktop, enable_in_app, updated_at)
                VALUES (%s, %s, %s, %s, %s, CURRENT_TIMESTAMP)
                ON CONFLICT (user_name)
                DO UPDATE SET
                    email = EXCLUDED.email,
                    enable_email = EXCLUDED.enable_email,
                    enable_desktop = EXCLUDED.enable_desktop,
                    enable_in_app = EXCLUDED.enable_in_app,
                    updated_at = CURRENT_TIMESTAMP
            """, (current_user.full_name, email, enable_email, enable_desktop, enable_in_app))

        return jsonify({'success': True, 'message': 'Preferencias de notificación guardadas'})

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@config_bp.route('/url/add', methods=['POST'])
@login_required
def add_url():
    """
    Add new URL/section
    """
    try:
        name = request.form.get('name', '').strip()
        url = request.form.get('url', '').strip()

        if not name or not url:
            return jsonify({'success': False, 'error': 'Nombre y URL son obligatorios'}), 400

        with db_cursor() as cursor:
            cursor.execute("""
                INSERT INTO sections (name, url, active, created_at)
                VALUES (%s, %s, 1, CURRENT_TIMESTAMP)
            """, (name, url))

            new_id = cursor.lastrowid

        return jsonify({'success': True, 'id': new_id, 'message': 'URL agregada correctamente'})

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@config_bp.route('/url/edit/<int:url_id>', methods=['POST'])
@login_required
def edit_url(url_id):
    """
    Edit existing URL/section
    """
    try:
        name = request.form.get('name', '').strip()
        url = request.form.get('url', '').strip()

        if not name or not url:
            return jsonify({'success': False, 'error': 'Nombre y URL son obligatorios'}), 400

        with db_cursor() as cursor:
            cursor.execute("""
                UPDATE sections
                SET name = %s, url = %s
                WHERE id = %s
            """, (name, url, url_id))

        return jsonify({'success': True, 'message': 'URL actualizada correctamente'})

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@config_bp.route('/url/toggle/<int:url_id>', methods=['POST'])
@login_required
def toggle_url(url_id):
    """
    Toggle active status of URL/section
    """
    try:
        with db_cursor() as cursor:
            # Get current status
            cursor.execute("SELECT active FROM sections WHERE id = %s", (url_id,))
            row = cursor.fetchone()

            if not row:
                return jsonify({'success': False, 'error': 'URL no encontrada'}), 404

            new_status = 0 if row['active'] else 1

            cursor.execute("""
                UPDATE sections
                SET active = %s
                WHERE id = %s
            """, (new_status, url_id))

        return jsonify({'success': True, 'active': new_status, 'message': 'Estado actualizado'})

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@config_bp.route('/url/delete/<int:url_id>', methods=['POST'])
@login_required
def delete_url(url_id):
    """
    Delete URL/section (only if no associated tasks)
    """
    try:
        with db_cursor() as cursor:
            # Check if there are tasks associated
            cursor.execute("SELECT COUNT(*) as count FROM tasks WHERE section_id = %s", (url_id,))
            count = cursor.fetchone()['count']

            if count > 0:
                return jsonify({
                    'success': False,
                    'error': f'No se puede eliminar. Hay {count} tareas asociadas a esta URL.'
                }), 400

            # Delete section
            cursor.execute("DELETE FROM sections WHERE id = %s", (url_id,))

        return jsonify({'success': True, 'message': 'URL eliminada correctamente'})

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500
