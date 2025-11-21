"""
Configuration Routes Blueprint
All configuration-related routes extracted from app.py
"""

import calendar
from datetime import date, datetime, timedelta

from flask import Blueprint, jsonify, render_template, request, session
from flask_login import current_user, login_required

from constants import ANNUAL_MONTH, QUARTERLY_MONTHS, SEMIANNUAL_MONTHS, WEEKDAY_MAP
from utils import db_cursor, generate_available_periods
from create_tasks_for_period import should_create_task_for_period


def _ensure_task_type_for_rule(cursor, rule_id, title, alert_frequency, alert_day):
    """
    Crea un task_type y configuración de alerta para una regla personalizada si no existe.
    Retorna el task_type_id asociado.
    """
    if not rule_id:
        raise ValueError("rule_id es obligatorio para vincular la regla personalizada")

    cursor.execute(
        "SELECT task_type_id FROM custom_alert_rules WHERE id = %s", (rule_id,)
    )
    row = cursor.fetchone()
    if not row:
        raise ValueError(f"No se encontró la regla personalizada con id={rule_id}")

    if row and row.get("task_type_id"):
        return row["task_type_id"]

    # Calcular display_order al final
    cursor.execute("SELECT COALESCE(MAX(display_order), 0) + 1 AS ord FROM task_types")
    order_row = cursor.fetchone()
    display_order = order_row["ord"] if order_row else 100

    name = f"custom_{rule_id}"
    cursor.execute(
        """
        INSERT INTO task_types (name, display_name, periodicity, display_order)
        VALUES (%s, %s, %s, %s)
        RETURNING id
    """,
        (name, title, alert_frequency, display_order),
    )
    task_type_id = cursor.fetchone()["id"]

    # Vincular en la regla
    cursor.execute(
        "UPDATE custom_alert_rules SET task_type_id = %s WHERE id = %s",
        (task_type_id, rule_id),
    )

    # Crear alerta settings por defecto
    cursor.execute(
        """
        INSERT INTO alert_settings (task_type_id, alert_frequency, alert_day, enabled)
        VALUES (%s, %s, %s, TRUE)
        ON CONFLICT (task_type_id) DO NOTHING
    """,
        (task_type_id, alert_frequency, alert_day or "1"),
    )

    return task_type_id


def _seed_tasks_for_rule(cursor, task_type_id, periodicity, period):
    """
    Inserta tareas para todas las secciones activas en un periodo dado para un task_type.
    """
    if not should_create_task_for_period(period, periodicity):
        return

    cursor.execute("SELECT id FROM sections WHERE active = TRUE")
    sections = cursor.fetchall()
    for section in sections:
        cursor.execute(
            """
            INSERT INTO tasks (section_id, task_type_id, period, status)
            VALUES (%s, %s, %s, 'pending')
            ON CONFLICT (section_id, task_type_id, period) DO NOTHING
        """,
            (section["id"], task_type_id, period),
        )


def _create_date_for_month(year, month, alert_day):
    """Return a date within the month respecting the configured day (handles 29/30/31)."""
    try:
        target_day = int(alert_day)
    except (TypeError, ValueError):
        return None

    last_day = calendar.monthrange(year, month)[1]
    return date(year, month, min(target_day, last_day))


def _get_next_monthly_date(reference_date, alert_day, valid_months=None):
    """
    Compute the next date >= reference_date for the provided months list.
    If valid_months is None, it assumes every month is valid.
    """
    months_sequence = (
        sorted(valid_months) if valid_months else list(range(1, 13))
    )

    year = reference_date.year
    # Iterate up to 24 months ahead to ensure we find a match
    for _ in range(24):
        for month in months_sequence:
            if year == reference_date.year and month < reference_date.month:
                continue
            candidate = _create_date_for_month(year, month, alert_day)
            if candidate and candidate >= reference_date:
                return candidate
        year += 1
    return None


def _parse_date_value(value):
    """
    Convierte un valor (string o date) en un objeto date seguro.
    Devuelve None si no se puede parsear.
    """
    if not value:
        return None
    if isinstance(value, date):
        return value
    try:
        return datetime.strptime(str(value), "%Y-%m-%d").date()
    except (ValueError, TypeError):
        return None


def _calculate_next_due_date(
    frequency, alert_day, reference_date=None, deadline_date=None
):
    """
    Estimate the next due date for a custom alert rule starting from reference_date.
    Returns a `date` object or None if it cannot be determined.

    Args:
        frequency: Tipo de frecuencia configurada.
        alert_day: Día configurado para frecuencias recurrentes.
        reference_date: Fecha base para calcular el siguiente aviso.
        deadline_date: Fecha límite usada solo para frecuencia "deadline".
    """
    if reference_date is None:
        reference_date = datetime.now().date()

    freq = (frequency or "").lower()

    if freq == "deadline":
        deadline_obj = _parse_date_value(deadline_date)
        if not deadline_obj or reference_date >= deadline_obj:
            return None

        days_until = (deadline_obj - reference_date).days

        # Última semana: avisos específicos
        if days_until <= 7:
            for offset in (7, 4, 2, 1):
                candidate = deadline_obj - timedelta(days=offset)
                if candidate >= reference_date:
                    return candidate
            return None

        # Más de una semana: próximo día que caiga cada 7 días respecto al deadline
        remainder = days_until % 7
        if remainder == 0:
            return reference_date
        return reference_date + timedelta(days=remainder)

    if freq == "daily":
        return reference_date

    if freq == "weekly":
        weekday = WEEKDAY_MAP.get(alert_day or "")
        if weekday is None:
            return None
        days_ahead = (weekday - reference_date.weekday()) % 7
        return reference_date + timedelta(days=days_ahead)

    if freq == "biweekly":
        weekday = WEEKDAY_MAP.get(alert_day or "")
        if weekday is None:
            return None
        candidate = reference_date
        # Check next 28 days to find the next even-week occurrence
        for _ in range(28):
            if (
                candidate.weekday() == weekday
                and candidate.isocalendar()[1] % 2 == 0
            ):
                return candidate
            candidate += timedelta(days=1)
        return None

    if freq == "monthly":
        return _get_next_monthly_date(reference_date, alert_day)

    if freq == "quarterly":
        return _get_next_monthly_date(reference_date, alert_day, QUARTERLY_MONTHS)

    if freq in ("biannual", "semiannual"):
        return _get_next_monthly_date(reference_date, alert_day, SEMIANNUAL_MONTHS)

    if freq in ("annual", "yearly"):
        return _get_next_monthly_date(reference_date, alert_day, [ANNUAL_MONTH])

    return None

# Create blueprint
config_bp = Blueprint("config", __name__, url_prefix="/configuracion")


@config_bp.route("")
@login_required
def index():
    """
    Configuration page - Alerts and Notification preferences
    """
    # Get selected period from query params or session (default: current month)
    period = request.args.get("period")
    if not period:
        period = session.get("current_period", datetime.now().strftime("%Y-%m"))
    else:
        session["current_period"] = period

    current_period = period

    with db_cursor() as cursor:
        # Reparar reglas personalizadas antiguas que no tengan task_type asociado
        cursor.execute("""
            SELECT
                id,
                title,
                notes,
                alert_frequency,
                alert_day,
                deadline_date,
                enabled,
                created_at,
                created_by,
                task_type_id
            FROM custom_alert_rules
            ORDER BY enabled DESC, created_at DESC
        """)
        custom_alert_rules = [dict(row) for row in cursor.fetchall()]

        for rule in custom_alert_rules:
            if not rule.get("task_type_id"):
                task_type_id = _ensure_task_type_for_rule(
                    cursor,
                    rule["id"],
                    rule["title"],
                    rule["alert_frequency"],
                    rule.get("alert_day"),
                )
                _seed_tasks_for_rule(
                    cursor,
                    task_type_id,
                    rule["alert_frequency"],
                    current_period,
                )
                rule["task_type_id"] = task_type_id

            # Ensure there's at least one upcoming custom pending alert
            next_due = _calculate_next_due_date(
                rule["alert_frequency"],
                rule.get("alert_day"),
                deadline_date=rule.get("deadline_date"),
            )
            if next_due:
                cursor.execute(
                    """
                    SELECT 1
                    FROM custom_pending_alerts
                    WHERE title = %s
                      AND due_date >= %s
                      AND dismissed = FALSE
                    LIMIT 1
                """,
                    (rule["title"], datetime.now().date()),
                )
                if not cursor.fetchone():
                    cursor.execute(
                        """
                        INSERT INTO custom_pending_alerts (title, notes, due_date, created_by)
                        VALUES (%s, %s, %s, %s)
                        ON CONFLICT (title, due_date) DO NOTHING
                    """,
                        (
                            rule["title"],
                            rule.get("notes"),
                            next_due,
                            rule.get("created_by") or current_user.full_name,
                        ),
                    )

        # Get all task types (incluye las custom ya reparadas)
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
        alert_settings = {row["task_type_id"]: dict(row) for row in alert_settings_raw}

        # Merge task_types with their alert settings
        for task_type in task_types:
            task_type["alert"] = alert_settings.get(
                task_type["id"],
                {
                    "alert_frequency": task_type["periodicity"],
                    "alert_day": "1",  # default day
                    "enabled": True,
                },
            )

        # Get notification preferences for current user
        cursor.execute(
            """
            SELECT email, enable_email, enable_desktop, enable_in_app
            FROM notification_preferences
            WHERE user_name = %s
        """,
            (current_user.full_name,),
        )
        notification_prefs_row = cursor.fetchone()
        notification_prefs = (
            dict(notification_prefs_row)
            if notification_prefs_row
            else {
                "email": "",
                "enable_email": False,
                "enable_desktop": False,
                "enable_in_app": True,
            }
        )

        # Custom alerts (instancias)
        cursor.execute("""
            SELECT id, title, notes, due_date, dismissed, dismissed_at, created_at, created_by
            FROM custom_pending_alerts
            ORDER BY dismissed ASC, due_date ASC, id DESC
        """)
        custom_alerts = [dict(row) for row in cursor.fetchall()]

    # Generate available periods
    available_periods = generate_available_periods()

    return render_template(
        "configuracion.html",
        task_types=task_types,
        notification_prefs=notification_prefs,
        custom_alert_rules=custom_alert_rules,
        custom_alerts=custom_alerts,
        period=period,
        available_periods=available_periods,
        current_user=current_user,
    )


@config_bp.route("/urls")
@login_required
def urls():
    """
    URL management page (CRUD operations)
    """
    # Get selected period from query params or session (default: current month)
    period = request.args.get("period")
    if not period:
        period = session.get("current_period", datetime.now().strftime("%Y-%m"))
    else:
        session["current_period"] = period

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
        "configuracion_urls.html",
        sections=sections,
        period=period,
        available_periods=available_periods,
        current_user=current_user,
    )


@config_bp.route("/herramientas")
@login_required
def herramientas():
    """
    Automatic analysis tools configuration page
    """
    # Get selected period from query params or session (default: current month)
    period = request.args.get("period")
    if not period:
        period = session.get("current_period", datetime.now().strftime("%Y-%m"))
    else:
        session["current_period"] = period

    # Generate available periods for consistency with other config pages
    available_periods = generate_available_periods()

    return render_template(
        "configuracion_herramientas.html",
        period=period,
        available_periods=available_periods,
        current_user=current_user,
    )


@config_bp.route("/alertas", methods=["POST"])
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
                task_type_id = alert.get("task_type_id")
                alert_frequency = alert.get("alert_frequency")
                alert_day = alert.get("alert_day")
                enabled = alert.get("enabled", True)

                # Update or insert alert_settings
                cursor.execute(
                    """
                    INSERT INTO alert_settings (task_type_id, alert_frequency, alert_day, enabled)
                    VALUES (%s, %s, %s, %s)
                    ON CONFLICT (task_type_id)
                    DO UPDATE SET
                        alert_frequency = EXCLUDED.alert_frequency,
                        alert_day = EXCLUDED.alert_day,
                        enabled = EXCLUDED.enabled
                """,
                    (task_type_id, alert_frequency, alert_day, enabled),
                )

        return jsonify(
            {"success": True, "message": "Configuración de alertas guardada"}
        )

    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@config_bp.route("/notificaciones", methods=["POST"])
@login_required
def save_notification_preferences():
    """
    Save notification preferences for current user
    """
    try:
        email = request.form.get("email", "")
        enable_email = request.form.get("enable_email") == "true"
        enable_desktop = request.form.get("enable_desktop") == "true"
        enable_in_app = request.form.get("enable_in_app") == "true"

        with db_cursor() as cursor:
            # Update or insert notification preferences
            cursor.execute(
                """
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
            """,
                (
                    current_user.full_name,
                    email,
                    enable_email,
                    enable_desktop,
                    enable_in_app,
                ),
            )

        return jsonify(
            {"success": True, "message": "Preferencias de notificación guardadas"}
        )

    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@config_bp.route("/alerta-personalizada", methods=["POST"])
@login_required
def add_custom_alert_rule():
    """
    Crea una regla de alerta personalizada recurrente.
    """
    try:
        title = (request.form.get("title") or "").strip()
        notes = (request.form.get("notes") or "").strip()
        alert_frequency = (request.form.get("alert_frequency") or "monthly").strip()
        alert_day = (request.form.get("alert_day") or "").strip()
        deadline_date_raw = (request.form.get("deadline_date") or "").strip()
        enabled = request.form.get("enabled", "true") == "true"

        deadline_date = None
        if alert_frequency == "deadline":
            if not deadline_date_raw:
                return jsonify({"success": False, "error": "Fecha límite obligatoria"}), 400
            deadline_date = _parse_date_value(deadline_date_raw)
            if not deadline_date:
                return jsonify(
                    {
                        "success": False,
                        "error": "Fecha de deadline inválida (usa YYYY-MM-DD)",
                    }
                ), 400

        if not title:
            return jsonify({"success": False, "error": "Título obligatorio"}), 400
        if alert_frequency not in ("daily", "deadline") and not alert_day:
            return jsonify({"success": False, "error": "Día obligatorio para esta frecuencia"}), 400

        with db_cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO custom_alert_rules (title, notes, alert_frequency, alert_day, deadline_date, enabled, created_by)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
                ON CONFLICT (title) DO NOTHING
                RETURNING id
            """,
                (
                    title,
                    notes or None,
                    alert_frequency,
                    alert_day or None,
                    deadline_date,
                    enabled,
                    current_user.full_name,
                ),
            )

            new_row = cursor.fetchone()
            if not new_row:
                return jsonify(
                    {"success": False, "error": "Ya existe una alerta con ese título"}
                ), 400

            new_id = int(new_row["id"])

            # Crear task_type + alert_setting y semilla de tareas para el mes actual
            task_type_id = _ensure_task_type_for_rule(
                cursor, new_id, title, alert_frequency, alert_day
            )

            # Crear tareas para el periodo actual para que aparezca en Inicio/Pendientes
            current_period = datetime.now().strftime("%Y-%m")
            _seed_tasks_for_rule(cursor, task_type_id, alert_frequency, current_period)

            # Crear la primera alerta pendiente para que aparezca en /alertas
            next_due = _calculate_next_due_date(
                alert_frequency, alert_day, deadline_date=deadline_date
            )
            if next_due:
                cursor.execute(
                    """
                    INSERT INTO custom_pending_alerts (title, notes, due_date, created_by)
                    VALUES (%s, %s, %s, %s)
                    ON CONFLICT (title, due_date) DO NOTHING
                """,
                    (
                        title,
                        notes or None,
                        next_due,
                        current_user.full_name,
                    ),
                )

        return jsonify(
            {
                "success": True,
                "id": new_id,
                "message": "Regla de alerta personalizada creada",
                "title": title,
                "alert_frequency": alert_frequency,
                "alert_day": alert_day,
                "deadline_date": deadline_date.isoformat() if deadline_date else None,
                "notes": notes,
                "enabled": enabled,
            }
        )

    except ValueError as e:
        return jsonify({"success": False, "error": str(e)}), 400
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@config_bp.route("/alerta-personalizada/toggle/<int:rule_id>", methods=["POST"])
@login_required
def toggle_custom_alert_rule(rule_id):
    """
    Activa/desactiva una regla personalizada
    """
    try:
        with db_cursor() as cursor:
            cursor.execute(
                "SELECT enabled, task_type_id, alert_frequency, alert_day FROM custom_alert_rules WHERE id = %s",
                (rule_id,),
            )
            row = cursor.fetchone()
            if not row:
                return jsonify({"success": False, "error": "Regla no encontrada"}), 404

            new_enabled = not row["enabled"]
            cursor.execute(
                """
                UPDATE custom_alert_rules
                SET enabled = %s
                WHERE id = %s
            """,
                (new_enabled, rule_id),
            )

            # Si la activamos y no hay task_type, crear
            if new_enabled:
                task_type_id = row.get("task_type_id")
                if not task_type_id:
                    task_type_id = _ensure_task_type_for_rule(
                        cursor,
                        rule_id,
                        f"custom_{rule_id}",
                        row.get("alert_frequency", "monthly"),
                        None,
                    )
                # Sembrar tareas para el periodo actual
                current_period = datetime.now().strftime("%Y-%m")
                cursor.execute(
                    """
                    SELECT alert_frequency FROM custom_alert_rules WHERE id = %s
                """,
                    (rule_id,),
                )
                freq_row = cursor.fetchone()
                freq = freq_row["alert_frequency"] if freq_row else "monthly"
                _seed_tasks_for_rule(cursor, task_type_id, freq, current_period)

        return jsonify({"success": True, "enabled": new_enabled})

    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@config_bp.route("/alerta-personalizada/delete/<int:rule_id>", methods=["POST"])
@login_required
def delete_custom_alert_rule(rule_id):
    """
    Elimina una regla de alerta personalizada
    """
    try:
        with db_cursor() as cursor:
            # Obtener task_type_id y título
            cursor.execute(
                "SELECT task_type_id, title FROM custom_alert_rules WHERE id = %s",
                (rule_id,),
            )
            row = cursor.fetchone()
            if not row:
                return jsonify({"success": False, "error": "Regla no encontrada"}), 404

            task_type_id = row.get("task_type_id")
            title = row.get("title")

            # Borrar tareas asociadas y settings si aplica
            if task_type_id:
                cursor.execute(
                    "DELETE FROM tasks WHERE task_type_id = %s",
                    (task_type_id,),
                )
                cursor.execute(
                    "DELETE FROM alert_settings WHERE task_type_id = %s",
                    (task_type_id,),
                )
                cursor.execute(
                    "DELETE FROM pending_alerts WHERE task_type_id = %s",
                    (task_type_id,),
                )
                cursor.execute(
                    "DELETE FROM task_types WHERE id = %s",
                    (task_type_id,),
                )

            # Borrar alertas pendientes personalizadas con ese título
            cursor.execute(
                "DELETE FROM custom_pending_alerts WHERE title = %s",
                (title,),
            )

            # Borrar la regla
            cursor.execute(
                "DELETE FROM custom_alert_rules WHERE id = %s", (rule_id,)
            )
        return jsonify({"success": True, "message": "Regla eliminada"})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@config_bp.route("/url/add", methods=["POST"])
@login_required
def add_url():
    """
    Add new URL/section
    """
    try:
        name = request.form.get("name", "").strip()
        url = request.form.get("url", "").strip()

        if not name or not url:
            return jsonify(
                {"success": False, "error": "Nombre y URL son obligatorios"}
            ), 400

        with db_cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO sections (name, url, active, created_at)
                VALUES (%s, %s, 1, CURRENT_TIMESTAMP)
                RETURNING id
            """,
                (name, url),
            )

            new_id = cursor.fetchone()["id"]

        return jsonify(
            {"success": True, "id": new_id, "message": "URL agregada correctamente"}
        )

    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@config_bp.route("/url/edit/<int:url_id>", methods=["POST"])
@login_required
def edit_url(url_id):
    """
    Edit existing URL/section
    """
    try:
        name = request.form.get("name", "").strip()
        url = request.form.get("url", "").strip()

        if not name or not url:
            return jsonify(
                {"success": False, "error": "Nombre y URL son obligatorios"}
            ), 400

        with db_cursor() as cursor:
            cursor.execute(
                """
                UPDATE sections
                SET name = %s, url = %s
                WHERE id = %s
            """,
                (name, url, url_id),
            )

        return jsonify({"success": True, "message": "URL actualizada correctamente"})

    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@config_bp.route("/url/toggle/<int:url_id>", methods=["POST"])
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
                return jsonify({"success": False, "error": "URL no encontrada"}), 404

            new_status = 0 if row["active"] else 1

            cursor.execute(
                """
                UPDATE sections
                SET active = %s
                WHERE id = %s
            """,
                (new_status, url_id),
            )

        return jsonify(
            {"success": True, "active": new_status, "message": "Estado actualizado"}
        )

    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@config_bp.route("/url/delete/<int:url_id>", methods=["POST"])
@login_required
def delete_url(url_id):
    """
    Delete URL/section (only if no associated tasks)
    """
    try:
        with db_cursor() as cursor:
            # Check if there are tasks associated
            cursor.execute(
                "SELECT COUNT(*) as count FROM tasks WHERE section_id = %s", (url_id,)
            )
            count = cursor.fetchone()["count"]

            if count > 0:
                return jsonify(
                    {
                        "success": False,
                        "error": f"No se puede eliminar. Hay {count} tareas asociadas a esta URL.",
                    }
                ), 400

            # Delete section
            cursor.execute("DELETE FROM sections WHERE id = %s", (url_id,))

        return jsonify({"success": True, "message": "URL eliminada correctamente"})

    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500
