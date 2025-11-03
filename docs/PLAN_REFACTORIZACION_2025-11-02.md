# Plan de Refactorización - Agenda Renta4

**Fecha**: 2025-11-02
**Autor**: Auditoría automatizada + Claude Code
**Estado**: Pendiente de ejecución
**Duración estimada**: 5 horas total (dividido en 5 fases)

---

## 📊 RESUMEN EJECUTIVO

### Problemas Encontrados
- **🔴 Críticos (Seguridad/Bugs)**: 3 problemas
- **🟡 Alta prioridad (Mantenibilidad)**: 26 problemas
- **🟢 Media prioridad (Calidad)**: 10 problemas
- **Total**: 39 problemas identificados

### Archivos Afectados
| Archivo | Problemas | Prioridad |
|---------|-----------|-----------|
| `app.py` | 19 | 🔴 CRÍTICA |
| `crawler/routes.py` | 7 | 🟡 ALTA |
| `calidad/imagenes.py` | 5 | 🟡 ALTA |
| `calidad/post_crawl_runner.py` | 3 | 🟡 ALTA |
| `crawler/crawler.py` | 1 | 🟡 ALTA |
| `utils.py` | 0 | ✅ OK |
| `constants.py` | 0 | ✅ OK |

---

## 🎯 FASES DE REFACTORIZACIÓN

### **FASE 1: SEGURIDAD CRÍTICA** ⚠️
**Duración**: 30 minutos
**Prioridad**: 🔴 CRÍTICA - EJECUTAR INMEDIATAMENTE
**Archivos**: `app.py`

#### Problema 1.1: Secret Key Insegura
**Ubicación**: `app.py:43`

**Código actual**:
```python
app.secret_key = os.getenv("SECRET_KEY", "dev-secret-key-change-in-production")
```

**Problema**: Si falta la variable de entorno, usa un default conocido públicamente.

**Solución**:
```python
secret_key = os.getenv("SECRET_KEY")
if not secret_key:
    raise ValueError("❌ CRITICAL: SECRET_KEY environment variable is required in production")
app.secret_key = secret_key
```

**Impacto**: Elimina vulnerabilidad de seguridad crítica.

---

#### Problema 1.2: URL Hardcoded en Emails
**Ubicación**: `app.py:466`

**Código actual**:
```python
<a href="http://localhost:5000/alertas" class="btn btn-primary">Ver Alertas</a>
```

**Problema**: En producción apunta a localhost, los links no funcionan.

**Solución**:
```python
<a href="{{ url_for('alertas', _external=True) }}" class="btn btn-primary">Ver Alertas</a>
```

**Impacto**: Links en emails funcionarán correctamente en producción.

---

#### Problema 1.3: Fecha Hardcoded en Query
**Ubicación**: `app.py:798`

**Código actual**:
```python
WHERE t.period >= '2025-10'
```

**Problema**: Dejará de funcionar correctamente a partir de 2026.

**Solución**:
```python
from datetime import datetime, timedelta

# En la función realizadas()
cutoff_date = (datetime.now() - timedelta(days=90)).strftime('%Y-%m')

cursor.execute("""
    SELECT ...
    WHERE t.period >= %s
    ORDER BY t.period DESC, t.date DESC
""", (cutoff_date,))
```

**Impacto**: Query funcionará dinámicamente siempre mostrando últimos 3 meses.

---

### **FASE 2: CONSTANTS CLEANUP** 📦
**Duración**: 45 minutos
**Prioridad**: 🟡 ALTA
**Archivos**: `constants.py`, `app.py`, `calidad/imagenes.py`, `crawler/routes.py`

#### Objetivo
Centralizar todos los números mágicos y strings hardcodeados en `constants.py`.

#### Magic Numbers Identificados

**2.1: SMTP Settings** (`app.py:47`)
```python
# constants.py - AÑADIR
DEFAULT_SMTP_PORT = 587
EMAIL_TIMEOUT_SECONDS = 30
```

**2.2: Alert Frequencies - Meses Especiales** (`app.py:337, 341, 345`)
```python
# constants.py - AÑADIR
QUARTERLY_MONTHS = [1, 4, 7, 10]  # Enero, Abril, Julio, Octubre
SEMIANNUAL_MONTHS = [1, 7]         # Enero, Julio
ANNUAL_MONTH = 1                   # Enero
```

**2.3: Pagination** (`crawler/routes.py:135, 454`)
```python
# constants.py - AÑADIR
URLS_PER_PAGE = 50
QUALITY_CHECKS_PER_PAGE = 20
```

**2.4: HTTP Status Codes** (`calidad/imagenes.py:122, 129`)
```python
# constants.py - AÑADIR
HTTP_FORBIDDEN = 403
HTTP_CLIENT_ERROR_MIN = 400
HTTP_SERVER_ERROR_MIN = 500
```

**2.5: Quality Check Defaults** (`calidad/post_crawl_runner.py:245`)
```python
# constants.py - AÑADIR
class QualityCheckDefaults:
    BROKEN_LINKS_TIMEOUT = 15
    BROKEN_LINKS_MAX_RETRIES = 2
    BROKEN_LINKS_RETRY_DELAY = 0.1
```

**2.6: Image Checker Settings** (`calidad/imagenes.py:23, 110`)
```python
# constants.py - AÑADIR
IMAGE_CHECK_TIMEOUT = 10
IMAGE_CHECK_IGNORE_EXTERNAL = True
USER_AGENT_IMAGE_CHECKER = 'Mozilla/5.0 (compatible; QualityChecker/1.0; +https://www.r4.com)'
```

**2.7: Email Defaults** (`app.py:53`)
```python
# constants.py - AÑADIR
DEFAULT_EMAIL_SENDER = "Agenda Renta4 <noreply@renta4.com>"
```

**2.8: Login Settings** (`app.py:584`)
```python
# constants.py - AÑADIR
LOGIN_SESSION_DAYS = 30
```

#### Pasos de Implementación
1. Añadir todas las constantes nuevas a `constants.py`
2. Reemplazar números/strings hardcodeados con referencias a constantes
3. Verificar que todo funciona con `python app.py`

---

### **FASE 3: FUNCTION SPLITTING** ✂️
**Duración**: 2 horas
**Prioridad**: 🟡 ALTA
**Archivos**: `app.py`, `crawler/crawler.py`

#### Objetivo
Dividir funciones >50 líneas en funciones más pequeñas, testables y mantenibles.

---

#### Refactor 3.1: `send_email_notifications()` (150 líneas!)
**Ubicación**: `app.py:353-502`

**Problema**: Función gigante que hace demasiadas cosas.

**Estructura actual**:
```python
def send_email_notifications(alert_list):
    # 1. Obtener preferencias de usuarios (30 líneas)
    # 2. Construir HTML del email (80 líneas)
    # 3. Enviar email a cada usuario (40 líneas)
```

**Solución - Dividir en 4 funciones**:

```python
def _get_email_recipients():
    """Obtiene lista de usuarios con notificaciones email habilitadas."""
    with db_cursor() as cursor:
        cursor.execute("""
            SELECT u.id, u.email, u.name
            FROM users u
            INNER JOIN notification_preferences np ON u.id = np.user_id
            WHERE np.email_enabled = TRUE
        """)
        return cursor.fetchall()

def _build_email_body(alerts_for_user):
    """Construye el HTML del cuerpo del email."""
    alert_rows = ""
    for alert in alerts_for_user:
        alert_rows += f"""
        <tr>
            <td>{alert['section_name']}</td>
            <td>{alert['task_type']}</td>
            <td>{alert['message']}</td>
        </tr>
        """

    return f"""
    <html>
        <body>
            <h2>Alertas Pendientes - Agenda Renta4</h2>
            <table>{alert_rows}</table>
            <a href="{url_for('alertas', _external=True)}">Ver Alertas</a>
        </body>
    </html>
    """

def _send_email_to_user(user, body):
    """Envía un email a un usuario específico."""
    try:
        msg = Message(
            subject="Alertas Pendientes - Agenda Renta4",
            sender=constants.DEFAULT_EMAIL_SENDER,
            recipients=[user['email']],
            html=body
        )
        mail.send(msg)
        return True
    except Exception as e:
        logger.error(f"Error sending email to {user['email']}: {e}")
        return False

def send_email_notifications(alert_list):
    """Función principal que orquesta el envío de emails."""
    recipients = _get_email_recipients()
    if not recipients:
        return

    for user in recipients:
        # Filtrar alertas del usuario
        user_alerts = [a for a in alert_list if a['user_id'] == user['id']]
        if not user_alerts:
            continue

        body = _build_email_body(user_alerts)
        _send_email_to_user(user, body)
```

**Beneficios**:
- Cada función tiene una responsabilidad única
- Más fácil de testear
- Más fácil de modificar (ej: cambiar HTML sin tocar lógica de envío)

---

#### Refactor 3.2: `generate_alerts()` (88 líneas)
**Ubicación**: `app.py:185-272`

**Problema**: Mezcla lógica de negocio con queries y notificaciones.

**Solución - Dividir en 3 funciones**:

```python
def _should_create_alert(task_type, alert_setting, today):
    """Determina si se debe crear una alerta para esta configuración."""
    if not alert_setting['enabled']:
        return False

    if not check_alert_day(today, alert_setting['frequency'], alert_setting['alert_day']):
        return False

    return True

def _save_alert(user_id, section_id, task_type_id, message):
    """Guarda una alerta en la base de datos."""
    with db_cursor(commit=True) as cursor:
        cursor.execute("""
            INSERT INTO pending_alerts (user_id, section_id, task_type_id, message, created_at, status)
            VALUES (%s, %s, %s, %s, NOW(), 'pending')
        """, (user_id, section_id, task_type_id, message))

def _send_alert_notifications(alert_list):
    """Envía notificaciones para las nuevas alertas."""
    # Email
    send_email_notifications(alert_list)

    # Browser (futuro)
    # send_browser_notifications(alert_list)

    # In-app (futuro)
    # create_in_app_notifications(alert_list)

def generate_alerts():
    """Función principal que genera alertas según configuración."""
    today = date.today()
    alerts_created = []

    with db_cursor() as cursor:
        # Obtener configuración
        cursor.execute("SELECT * FROM alert_settings WHERE enabled = TRUE")
        alert_settings = cursor.fetchall()

        for setting in alert_settings:
            if not _should_create_alert(setting['task_type'], setting, today):
                continue

            # Buscar secciones pendientes
            cursor.execute("""
                SELECT s.id, s.name
                FROM sections s
                LEFT JOIN tasks t ON s.id = t.section_id
                    AND t.task_type_id = %s
                    AND t.period = %s
                WHERE t.id IS NULL
            """, (setting['task_type_id'], today.strftime('%Y-%m')))

            pending_sections = cursor.fetchall()

            for section in pending_sections:
                message = f"Revisión pendiente: {setting['task_type']} en {section['name']}"
                _save_alert(setting['user_id'], section['id'], setting['task_type_id'], message)
                alerts_created.append({
                    'user_id': setting['user_id'],
                    'section_name': section['name'],
                    'task_type': setting['task_type'],
                    'message': message
                })

    if alerts_created:
        _send_alert_notifications(alerts_created)

    return len(alerts_created)
```

---

#### Refactor 3.3: `crawler.crawl()` (120 líneas)
**Ubicación**: `crawler/crawler.py:303-422`

**Problema**: Función muy larga con lógica compleja de crawling.

**Solución - Dividir en 4 funciones**:

```python
def _check_crawl_limits(self, urls_discovered, depth):
    """Verifica si se alcanzaron los límites de crawling."""
    if self.config.max_urls and urls_discovered >= self.config.max_urls:
        logger.info(f"Reached max_urls limit: {self.config.max_urls}")
        return True

    if depth > self.config.max_depth:
        logger.info(f"Reached max_depth limit: {self.config.max_depth}")
        return True

    return False

def _discover_links_from_page(self, soup, current_url):
    """Descubre y normaliza links de una página."""
    links = []
    for link in soup.find_all('a', href=True):
        href = link['href']
        absolute_url = urljoin(current_url, href)
        normalized = self._normalize_url(absolute_url)

        if self._should_crawl(normalized):
            links.append(normalized)

    return links

def _process_single_url(self, url, depth, parent_id=None):
    """Procesa una URL individual: descarga, parsea y guarda."""
    try:
        response = requests.get(url, timeout=self.config.timeout, headers=self.config.headers)
        status_code = response.status_code

        if status_code != 200:
            logger.warning(f"Non-200 status for {url}: {status_code}")
            self._save_url(url, status_code, depth, parent_id)
            return []

        soup = BeautifulSoup(response.content, 'html.parser')
        url_id = self._save_url(url, status_code, depth, parent_id)

        discovered_links = self._discover_links_from_page(soup, url)
        logger.info(f"Discovered {len(discovered_links)} links from {url}")

        return [(link, depth + 1, url_id) for link in discovered_links]

    except Exception as e:
        logger.error(f"Error processing {url}: {e}")
        self._save_url(url, error=str(e), depth=depth, parent_url_id=parent_id)
        return []

def crawl(self):
    """Función principal de crawling (orquestación)."""
    logger.info(f"Starting crawl from {self.config.start_url}")

    crawl_run_id = self._create_crawl_run()
    progress_tracker.start_crawl(crawl_run_id)

    queue = [(self.config.start_url, 0, None)]
    visited = set()
    urls_discovered = 0

    try:
        while queue:
            current_url, depth, parent_id = queue.pop(0)

            if current_url in visited:
                continue

            if self._check_crawl_limits(urls_discovered, depth):
                break

            visited.add(current_url)
            new_links = self._process_single_url(current_url, depth, parent_id)
            queue.extend(new_links)

            urls_discovered += 1
            progress_tracker.update_progress(
                urls_discovered=urls_discovered,
                last_url=current_url,
                current_depth=depth
            )

        self._complete_crawl_run(crawl_run_id, urls_discovered, success=True)
        logger.info(f"Crawl completed: {urls_discovered} URLs discovered")

    except Exception as e:
        logger.error(f"Crawl failed: {e}")
        self._complete_crawl_run(crawl_run_id, urls_discovered, success=False, error=str(e))
        raise
    finally:
        progress_tracker.stop_crawl()

    return crawl_run_id
```

---

#### Refactor 3.4: Otras funciones grandes

**Candidatos adicionales** (opcional, menor prioridad):
- `get_task_counts()` (73 líneas) → Dividir en `_count_pending()`, `_count_problems()`, `_count_alerts()`
- `check_alert_day()` (78 líneas) → Usar Strategy Pattern (ver Fase 5)
- `inicio()` (75 líneas) → Extraer `_get_sections_with_tasks()`
- `pendientes()` (71 líneas) → Extraer `_generate_pending_matrix()`

---

### **FASE 4: DRY - ELIMINAR CÓDIGO DUPLICADO** 🔄
**Duración**: 1 hora
**Prioridad**: 🟡 MEDIA
**Archivos**: `utils.py`, `crawler/routes.py`, `calidad/post_crawl_runner.py`

#### Objetivo
Eliminar patrones de código repetido mediante funciones helper reutilizables.

---

#### DRY 4.1: Obtener Último Crawl Run (usado 4 veces)

**Ubicaciones duplicadas**:
- `crawler/routes.py:207`
- `crawler/routes.py:527`
- `crawler/routes.py:785`
- `crawler/routes.py:848`

**Código repetido**:
```python
cursor.execute("""
    SELECT id, started_at, finished_at, urls_discovered, status
    FROM crawl_runs
    WHERE status = 'completed'
    ORDER BY id DESC
    LIMIT 1
""")
crawl_run = cursor.fetchone()
if not crawl_run:
    return jsonify({'error': 'No completed crawl found'}), 404
```

**Solución - Añadir a `utils.py`**:
```python
def get_latest_crawl_run(cursor, status='completed'):
    """
    Obtiene el crawl run más reciente con el estado especificado.

    Args:
        cursor: DB cursor
        status: Estado del crawl ('completed', 'running', 'failed', etc.)

    Returns:
        dict: Crawl run data o None si no existe
    """
    cursor.execute("""
        SELECT id, started_at, finished_at, urls_discovered, status
        FROM crawl_runs
        WHERE status = %s
        ORDER BY id DESC
        LIMIT 1
    """, (status,))
    return cursor.fetchone()
```

**Uso después del refactor**:
```python
# crawler/routes.py
from utils import get_latest_crawl_run

with db_cursor() as cursor:
    crawl_run = get_latest_crawl_run(cursor)
    if not crawl_run:
        return jsonify({'error': 'No completed crawl found'}), 404
```

---

#### DRY 4.2: Paginación (usado 2 veces)

**Ubicaciones duplicadas**:
- `crawler/routes.py:134-140`
- `crawler/routes.py:454-460`

**Código repetido**:
```python
page = request.args.get('page', 1, type=int)
per_page = 50
offset = (page - 1) * per_page

# ... query ...

total_pages = (total + per_page - 1) // per_page
```

**Solución - Añadir a `utils.py`**:
```python
class Paginator:
    """Helper para calcular paginación de resultados."""

    def __init__(self, page=1, per_page=20):
        self.page = max(1, page)  # Asegurar page >= 1
        self.per_page = per_page

    @property
    def offset(self):
        """Offset para LIMIT/OFFSET en SQL."""
        return (self.page - 1) * self.per_page

    def total_pages(self, total_items):
        """Calcula total de páginas dado el total de items."""
        return (total_items + self.per_page - 1) // self.per_page

    def page_info(self, total_items):
        """Retorna dict con info de paginación para templates."""
        return {
            'page': self.page,
            'per_page': self.per_page,
            'total_pages': self.total_pages(total_items),
            'total_items': total_items,
            'has_prev': self.page > 1,
            'has_next': self.page < self.total_pages(total_items)
        }
```

**Uso después del refactor**:
```python
# crawler/routes.py
from utils import Paginator

page = request.args.get('page', 1, type=int)
paginator = Paginator(page=page, per_page=constants.URLS_PER_PAGE)

cursor.execute("""
    SELECT * FROM discovered_urls
    ORDER BY id DESC
    LIMIT %s OFFSET %s
""", (paginator.per_page, paginator.offset))

urls = cursor.fetchall()
pagination = paginator.page_info(total_urls)

return render_template('crawler/urls.html', urls=urls, pagination=pagination)
```

---

#### DRY 4.3: Build Scope Query (usado 2 veces)

**Ubicaciones duplicadas**:
- `calidad/post_crawl_runner.py:218-228`
- `calidad/post_crawl_runner.py:273-285`

**Código repetido**:
```python
query = """
    SELECT id, url, status_code
    FROM discovered_urls
    WHERE crawl_run_id = %s
"""
params = [crawl_run_id]

if scope == 'priority':
    query += " AND is_priority = TRUE"
```

**Solución - Añadir a `calidad/post_crawl_runner.py`**:
```python
def _build_scope_query(self, base_query, crawl_run_id, scope):
    """
    Construye query con filtro de scope.

    Args:
        base_query: Query SQL base
        crawl_run_id: ID del crawl run
        scope: 'all' o 'priority'

    Returns:
        tuple: (query_completo, params)
    """
    query = base_query + " WHERE crawl_run_id = %s"
    params = [crawl_run_id]

    if scope == 'priority':
        query += " AND is_priority = TRUE"

    return query, params
```

**Uso después del refactor**:
```python
base_query = """
    SELECT id, url, status_code
    FROM discovered_urls
"""
query, params = self._build_scope_query(base_query, crawl_run_id, scope)
cursor.execute(query, params)
```

---

### **FASE 5: NAMING & CONSISTENCY** 🏷️
**Duración**: 45 minutos
**Prioridad**: 🟢 MEDIA
**Archivos**: `app.py`, `crawler/crawler.py`, `crawler/routes.py`

#### Objetivo
Mejorar claridad del código mediante nombres descriptivos y patrones consistentes.

---

#### Naming 5.1: Variables Poco Claras

**Renombrados propuestos**:

| Archivo | Línea | Nombre Actual | Nombre Propuesto | Razón |
|---------|-------|---------------|------------------|-------|
| `app.py` | 354 | `alert_list` | `pending_alerts_to_notify` | Más específico |
| `app.py` | 388 | `email_enabled` | `email_prefs_row` | Evita confusión (es un dict, no bool) |
| `app.py` | 730 | `completed_set` | `completed_task_keys` | Indica que contiene keys, no tasks |
| `crawler/crawler.py` | 54 | `discovered` | `url_metadata_map` | Describe estructura (dict de metadata) |
| `crawler/routes.py` | 67 | `run_crawler_in_background` | `_crawl_worker` | Más corto, indica función privada |
| `calidad/post_crawl_runner.py` | 107 | `run_selected_checks_with_scope` | `run_checks` | Simplificar (scope es parámetro) |

**Ejemplo de refactor**:
```python
# Antes
def run_selected_checks_with_scope(check_types, scope):
    alert_list = []
    discovered = {}
    ...

# Después
def run_checks(check_types, scope):
    pending_alerts_to_notify = []
    url_metadata_map = {}
    ...
```

---

#### Naming 5.2: Consistencia en Loops

**Problema**: Nombres inconsistentes en loops.

**Inconsistencias encontradas**:
```python
# A veces singular:
for alert in alert_list:  # ❌ 'alert_list' no es plural correcto

# A veces con sufijo '_row':
for url_row in urls:  # ⚠️ Redundante si 'urls' ya implica que son rows

# A veces genérico:
for row in urls:  # ❌ Poco descriptivo
```

**Regla propuesta**:
```python
# ✅ USAR: Plural para colección, singular para item
for alert in alerts:
for url in urls:
for task in tasks:
for section in sections:

# ✅ Solo usar sufijo si hay ambigüedad:
for task_type in task_types:  # OK - evita confusión con 'task'
```

**Archivos a revisar**: `app.py`, `crawler/routes.py`, `calidad/post_crawl_runner.py`

---

#### Naming 5.3: Decorador para Manejo de Errores

**Problema**: Inconsistencia en manejo de errores en endpoints API.

**Algunos usan logger**:
```python
# crawler/routes.py:73
except Exception as e:
    logger.error(f"Error starting crawl: {str(e)}")
    return jsonify({'success': False, 'error': str(e)}), 500
```

**Otros no**:
```python
# app.py:923
except Exception as e:
    return jsonify({"success": False, "error": str(e)}), 500
```

**Solución - Crear decorador en `utils.py`**:
```python
from functools import wraps
import logging

logger = logging.getLogger(__name__)

def handle_api_errors(f):
    """
    Decorador para manejo consistente de errores en endpoints API.
    Captura excepciones, las loggea y retorna JSON error.
    """
    @wraps(f)
    def decorated_function(*args, **kwargs):
        try:
            return f(*args, **kwargs)
        except ValueError as e:
            # Errores de validación (400 Bad Request)
            logger.warning(f"Validation error in {f.__name__}: {str(e)}")
            return jsonify({'success': False, 'error': str(e)}), 400
        except Exception as e:
            # Errores inesperados (500 Internal Server Error)
            logger.error(f"Unexpected error in {f.__name__}: {str(e)}", exc_info=True)
            return jsonify({'success': False, 'error': 'Internal server error'}), 500
    return decorated_function
```

**Uso**:
```python
from utils import handle_api_errors

@app.route('/api/tasks/update', methods=['POST'])
@login_required
@handle_api_errors
def update_task():
    task_id = request.json.get('task_id')
    if not task_id:
        raise ValueError("task_id is required")

    # ... lógica ...
    return jsonify({'success': True})
```

---

#### Naming 5.4: Simplificar `check_alert_day()` con Strategy Pattern (Opcional)

**Ubicación**: `app.py:274-351` (78 líneas de ifs anidados)

**Problema**: Difícil de testear, mucha complejidad ciclomática.

**Solución con Strategy Pattern**:
```python
# app.py - Refactor de check_alert_day()

def _check_daily_alert(reference_date, alert_day):
    """Las alertas diarias siempre se generan."""
    return True

def _check_weekly_alert(reference_date, alert_day):
    """Verifica si hoy es el día de la semana configurado."""
    return reference_date.weekday() == alert_day

def _check_biweekly_alert(reference_date, alert_day):
    """Verifica si hoy es el día y semana correctos (semanas pares)."""
    week_number = reference_date.isocalendar()[1]
    is_correct_week = week_number % 2 == 0
    is_correct_day = reference_date.weekday() == alert_day
    return is_correct_week and is_correct_day

def _check_monthly_alert(reference_date, alert_day):
    """Verifica si hoy es el día del mes configurado."""
    return reference_date.day == alert_day

def _check_quarterly_alert(reference_date, alert_day):
    """Verifica si estamos en mes trimestral (ene/abr/jul/oct) y día correcto."""
    is_quarterly_month = reference_date.month in constants.QUARTERLY_MONTHS
    is_correct_day = reference_date.day == alert_day
    return is_quarterly_month and is_correct_day

def _check_semiannual_alert(reference_date, alert_day):
    """Verifica si estamos en mes semestral (ene/jul) y día correcto."""
    is_semiannual_month = reference_date.month in constants.SEMIANNUAL_MONTHS
    is_correct_day = reference_date.day == alert_day
    return is_semiannual_month and is_correct_day

def _check_annual_alert(reference_date, alert_day):
    """Verifica si hoy es el día anual configurado (solo enero)."""
    is_january = reference_date.month == constants.ANNUAL_MONTH
    is_correct_day = reference_date.day == alert_day
    return is_january and is_correct_day

# Mapping de frecuencias a funciones checker
ALERT_CHECKERS = {
    'daily': _check_daily_alert,
    'weekly': _check_weekly_alert,
    'biweekly': _check_biweekly_alert,
    'monthly': _check_monthly_alert,
    'quarterly': _check_quarterly_alert,
    'semiannual': _check_semiannual_alert,
    'annual': _check_annual_alert,
}

def check_alert_day(reference_date, frequency, alert_day):
    """
    Verifica si se debe generar una alerta en la fecha dada.

    Args:
        reference_date: Fecha a verificar
        frequency: Tipo de frecuencia ('daily', 'weekly', etc.)
        alert_day: Día configurado (weekday, día del mes, etc.)

    Returns:
        bool: True si corresponde generar alerta
    """
    checker = ALERT_CHECKERS.get(frequency)
    if not checker:
        logger.warning(f"Unknown alert frequency: {frequency}")
        return False

    return checker(reference_date, alert_day)
```

**Beneficios**:
- Cada función es pequeña y fácil de testear
- Fácil añadir nuevas frecuencias sin tocar código existente
- Elimina 78 líneas de ifs anidados → 8 funciones de 5 líneas cada una
- Complejidad ciclomática baja

---

## 📝 CHECKLIST DE EJECUCIÓN

Usa esta checklist mañana al ejecutar el refactor:

### Preparación
- [ ] Crear branch de refactor: `git checkout -b refactor/code-cleanup-2025-11-02`
- [ ] Asegurar que tests actuales pasan (si existen)
- [ ] Backup de la BD de desarrollo

### Fase 1: Seguridad (30 min)
- [ ] Fix SECRET_KEY sin default
- [ ] Fix URL hardcoded en emails
- [ ] Fix fecha hardcoded en query
- [ ] **Testing**: Levantar app y verificar que funciona
- [ ] **Commit**: `git commit -m "fix: eliminate security vulnerabilities and hardcoded values"`

### Fase 2: Constants (45 min)
- [ ] Añadir 15+ constantes a `constants.py`
- [ ] Reemplazar magic numbers en `app.py`
- [ ] Reemplazar magic numbers en `calidad/imagenes.py`
- [ ] Reemplazar magic numbers en `crawler/routes.py`
- [ ] Reemplazar magic numbers en `calidad/post_crawl_runner.py`
- [ ] **Testing**: Ejecutar app y verificar comportamiento idéntico
- [ ] **Commit**: `git commit -m "refactor: centralize magic numbers to constants.py"`

### Fase 3: Function Splitting (2 horas)
- [ ] Refactor `send_email_notifications()` → 4 funciones
- [ ] Refactor `generate_alerts()` → 3 funciones
- [ ] Refactor `crawler.crawl()` → 4 funciones
- [ ] **Testing**: Ejecutar crawl completo y verificar que funciona
- [ ] **Testing**: Generar alertas manualmente
- [ ] **Commit**: `git commit -m "refactor: split large functions into smaller units"`

### Fase 4: DRY (1 hora)
- [ ] Crear `get_latest_crawl_run()` en utils.py
- [ ] Crear clase `Paginator` en utils.py
- [ ] Crear `_build_scope_query()` en post_crawl_runner.py
- [ ] Reemplazar código duplicado en 4+ ubicaciones
- [ ] **Testing**: Verificar paginación y crawl runs
- [ ] **Commit**: `git commit -m "refactor: eliminate code duplication with helper functions"`

### Fase 5: Naming (45 min)
- [ ] Renombrar 6 variables poco claras
- [ ] Estandarizar loops (plurales correctos)
- [ ] Crear decorador `@handle_api_errors`
- [ ] (Opcional) Refactor `check_alert_day()` con Strategy Pattern
- [ ] **Testing**: Suite completa de tests
- [ ] **Commit**: `git commit -m "refactor: improve code clarity with better naming"`

### Finalización
- [ ] Actualizar `.claude/01-current-phase.md` con resumen
- [ ] Merge a main: `git checkout master && git merge refactor/code-cleanup-2025-11-02`
- [ ] Push a producción (si aplica)

---

## 🧪 TESTING RECOMENDADO

Después de cada fase, ejecutar estos tests:

### Test Básico
```bash
python app.py
# Verificar que levanta sin errores
```

### Test Funcional - Crawler
```bash
# 1. Ir a http://localhost:5000/crawler
# 2. Clic "Iniciar Crawl"
# 3. Verificar progreso en tiempo real
# 4. Esperar a que termine
# 5. Verificar resultados en dashboard
```

### Test Funcional - Alertas
```bash
# 1. Ir a http://localhost:5000/configuracion
# 2. Configurar alerta diaria
# 3. Ir a /admin/generate-alerts
# 4. Verificar que se crean alertas
# 5. Revisar emails enviados (si SMTP configurado)
```

### Test de Regresión
```sql
-- Verificar que datos siguen intactos
SELECT COUNT(*) FROM discovered_urls;
SELECT COUNT(*) FROM quality_checks;
SELECT COUNT(*) FROM tasks;
-- Comparar con valores pre-refactor
```

---

## ⚠️ ADVERTENCIAS Y CONSIDERACIONES

### Riesgos
1. **Cambios en funciones críticas**: Probar exhaustivamente alertas y emails
2. **Queries SQL modificados**: Verificar performance no se degrada
3. **Breaking changes**: Asegurar que no hay código externo dependiendo de nombres antiguos

### Rollback Plan
Si algo falla:
```bash
git checkout master
git branch -D refactor/code-cleanup-2025-11-02
# Restaurar backup de BD si necesario
```

### No Refactorizar (Fuera de scope)
- ❌ Tests unitarios (hacerlo en sesión separada)
- ❌ Migración de blueprints (no necesario aún)
- ❌ Cambios en DB schema
- ❌ Refactor de templates HTML/CSS

---

## 📊 MÉTRICAS ESPERADAS

### Antes del Refactor
- Funciones >50 líneas: **8**
- Magic numbers: **15**
- Código duplicado: **3 patrones**
- Complejidad ciclomática max: **~15**

### Después del Refactor
- Funciones >50 líneas: **≤2** (reducción 75%)
- Magic numbers: **≤3** (reducción 80%)
- Código duplicado: **0** (eliminado 100%)
- Complejidad ciclomática max: **≤8** (reducción 47%)

---

## 🎯 OBJETIVO FINAL

**Código más**:
- ✅ Mantenible (funciones pequeñas, nombres claros)
- ✅ Expandible (constantes centralizadas, helpers reutilizables)
- ✅ Legible (nombres descriptivos, lógica clara)
- ✅ Robusto (manejo de errores consistente, sin hardcoding)

**Sin sacrificar**:
- ✅ Simplicidad (no over-engineering)
- ✅ Funcionalidad (comportamiento idéntico)
- ✅ Performance (sin degradación)

---

**Preparado por**: Claude Code + Auditoría Automatizada
**Fecha**: 2025-11-02
**Próxima sesión**: Ejecutar fases según prioridad elegida
**Duración estimada total**: 5 horas (dividible en sesiones)
