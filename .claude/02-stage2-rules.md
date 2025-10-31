# ETAPA 2: CRAWLER AUTOMÁTICO

## Contexto
Stage 1 está **completo y en producción**. Stage 2 es un salto cualitativo:
- De manual → Automático
- De Excel hardcodeado → Descubrimiento dinámico
- De revisión humana → Validación automatizada

## Objetivo Principal
**Construir un web crawler que descubra automáticamente el árbol de URLs del sitio.**

### Lo que reemplaza
- ❌ Excel "251028_Árbol web - control calidad.xlsx"
- ❌ Script manual `load_sections.py`
- ❌ Lista hardcodeada de 173 URLs
- ✅ Sistema de descubrimiento automático desde URL raíz

---

## Requisitos Funcionales

### 1. Descubrimiento de URLs (Core)
- **Input**: 1 URL raíz (ej: https://www.r4.com)
- **Proceso**: Crawler que sigue enlaces internos recursivamente
- **Output**: Árbol de páginas descubiertas → tabla `discovered_urls`
- **Respeta**: robots.txt, rate limiting, dominios permitidos

### 2. Validación de URLs
- **Detectar enlaces rotos** (404, 500, timeouts)
- **Detectar enlaces incorrectos** (malformados, loops, redirects sospechosos)
- **Crear árbol navegable** (parent → children relationships)

### 3. Automatización End-to-End
- **Cron job** para ejecutar crawler periódicamente
- **Sistema de alertas** cuando encuentra problemas
- **Envío de emails** automático con resumen
- **Sin intervención manual** una vez configurado

---

## Criterio de Éxito Stage 2
- [ ] Crawler descubre URLs desde raíz automáticamente
- [ ] Detecta y reporta enlaces rotos/incorrectos
- [ ] Construye árbol de páginas navegable en UI
- [ ] Se ejecuta automáticamente (cron/scheduler)
- [ ] Envía alertas por email cuando encuentra problemas
- [ ] Reemplaza completamente el flujo manual de Excel

---

## Stack Tecnológico

### Opción A: Requests + BeautifulSoup (ELEGIDA) ✅
**Pros:**
- Rápido, ligero
- Fácil de debuggear
- Ya usamos requests en el proyecto
- Suficiente para HTML estático

**Contras:**
- No ejecuta JavaScript
- Limitado para SPAs (Single Page Apps)

**Decisión**: Empezar con esta opción. Reevaluar si el sitio requiere JavaScript.

### Opción B: Scrapy (Descartada para MVP)
**Por qué descartada:**
- Curva de aprendizaje innecesaria
- Más dependencias
- Overkill para empezar

**Reconsiderar si**: Necesitamos crawlear múltiples sitios en paralelo

### Opción C: Playwright (PROHIBIDO Stage 2)
**Por qué prohibido:**
- Necesita navegador headless (pesado)
- Más lento
- Complejidad innecesaria para Stage 2

**Solo considerar en Stage 3**: Si el sitio absolutamente requiere JavaScript

---

## Arquitectura Propuesta

### Nuevas Tablas BD

#### `discovered_urls`
```sql
CREATE TABLE discovered_urls (
    id SERIAL PRIMARY KEY,
    url TEXT UNIQUE NOT NULL,
    parent_url_id INTEGER REFERENCES discovered_urls(id),
    depth INTEGER NOT NULL DEFAULT 0,  -- Nivel en el árbol (0=raíz)
    discovered_at TIMESTAMP DEFAULT NOW(),
    last_checked TIMESTAMP,
    status_code INTEGER,  -- HTTP status (200, 404, etc)
    response_time FLOAT,  -- Milisegundos
    is_broken BOOLEAN DEFAULT FALSE,
    error_message TEXT,
    active BOOLEAN DEFAULT TRUE,
    crawl_run_id INTEGER REFERENCES crawl_runs(id)
);

CREATE INDEX idx_discovered_urls_parent ON discovered_urls(parent_url_id);
CREATE INDEX idx_discovered_urls_broken ON discovered_urls(is_broken);
CREATE INDEX idx_discovered_urls_crawl_run ON discovered_urls(crawl_run_id);
```

#### `crawl_runs`
```sql
CREATE TABLE crawl_runs (
    id SERIAL PRIMARY KEY,
    started_at TIMESTAMP DEFAULT NOW(),
    finished_at TIMESTAMP,
    status TEXT CHECK (status IN ('running', 'completed', 'failed', 'cancelled')),
    root_url TEXT NOT NULL,
    max_depth INTEGER DEFAULT 5,
    urls_discovered INTEGER DEFAULT 0,
    urls_broken INTEGER DEFAULT 0,
    urls_timeout INTEGER DEFAULT 0,
    errors TEXT,
    created_by TEXT  -- user_name que inició el crawl
);

CREATE INDEX idx_crawl_runs_status ON crawl_runs(status);
CREATE INDEX idx_crawl_runs_started ON crawl_runs(started_at DESC);
```

#### `url_changes`
```sql
CREATE TABLE url_changes (
    id SERIAL PRIMARY KEY,
    url_id INTEGER REFERENCES discovered_urls(id) ON DELETE CASCADE,
    change_type TEXT CHECK (change_type IN ('new', 'broken', 'fixed', 'removed', 'status_change')),
    old_value TEXT,
    new_value TEXT,
    detected_at TIMESTAMP DEFAULT NOW(),
    details TEXT
);

CREATE INDEX idx_url_changes_url_id ON url_changes(url_id);
CREATE INDEX idx_url_changes_type ON url_changes(change_type);
CREATE INDEX idx_url_changes_detected ON url_changes(detected_at DESC);
```

---

### Estructura de Archivos (Stage 2)

```
agendaRenta4/
├── app.py                       # Flask app (Stage 1 + nuevas rutas crawler)
├── utils.py                     # Utilidades compartidas
├── constants.py                 # Constantes
├── crawler/                     # 🆕 Módulo crawler (Stage 2)
│   ├── __init__.py
│   ├── crawler.py               # Lógica principal de crawling
│   ├── validator.py             # Validación de enlaces
│   ├── scheduler.py             # Tareas periódicas (APScheduler)
│   └── config.py                # Configuración específica del crawler
├── templates/
│   ├── base.html
│   ├── inicio.html
│   ├── ...                      # Templates Stage 1
│   ├── crawler/                 # 🆕 Templates crawler (Stage 2)
│   │   ├── dashboard.html       # Vista del árbol de URLs
│   │   └── results.html         # Resultados de última ejecución
│   └── emails/
│       ├── alert_notification.html  # Stage 1
│       └── crawler_report.html      # 🆕 Email resumen crawler (Stage 2)
├── static/
│   ├── css/
│   │   └── style.css            # Estilos compartidos
│   └── js/
│       └── crawler_tree.js      # 🆕 JS para árbol navegable (Stage 2)
├── scripts/
│   ├── create_tasks_for_period.py
│   ├── load_sections.py         # ⚠️ Deprecar en Stage 2
│   └── run_crawler.py           # 🆕 Script para cron (Stage 2)
└── migrations/
    └── 002_add_crawler_tables.sql  # 🆕 SQL para crear tablas (Stage 2)
```

**Total archivos nuevos Stage 2**: ~10 archivos
**Total archivos proyecto**: 25-30 archivos (sigue siendo manejable)

---

## Reglas de Stage 2

### ✅ PERMITIDO en Stage 2

#### Estructura y Código
- Crear módulo `crawler/` separado (4-5 archivos)
- Nuevas tablas en BD (3 tablas + índices)
- Nuevas rutas en app.py (<10 rutas):
  - `/crawler` - Dashboard
  - `/crawler/start` - Iniciar crawl manual
  - `/crawler/status/<id>` - Estado de crawl
  - `/crawler/results/<id>` - Resultados detallados
  - `/crawler/tree` - Vista de árbol
- Background jobs con APScheduler
- Nuevas dependencias: `requests`, `beautifulsoup4`, `apscheduler`

#### Complejidad Permitida
- **Clases** si hay estado complejo:
  - `Crawler` class con estado (queue, visited, stats)
  - `URLValidator` class con configuración
- **Separar responsabilidades**:
  - crawler.py → descubrimiento
  - validator.py → validación
  - scheduler.py → automatización
- **Config específico**: crawler/config.py para settings del crawler

#### Abstracciones Justificadas
- **Queue-based crawling** → manejar 1000+ URLs sin recursión infinita
- **Visitor pattern** → marcar URLs visitadas
- **Rate limiter** → no saturar servidor

### ❌ PROHIBIDO en Stage 2

#### NO Sobre-ingeniería
- ❌ Refactorizar app.py en blueprints (solo si app.py > 1,500 líneas)
- ❌ Repository pattern para BD (queries directos funcionan)
- ❌ Factory pattern para crawler (solo 1 implementación)
- ❌ Interfaces/ABC sin 2+ implementaciones reales
- ❌ Dependency injection framework (YAGNI)

#### NO Scope Creep
- ❌ Machine Learning / detección inteligente de problemas
- ❌ Navegador headless (Playwright/Selenium)
- ❌ Comparación de contenido HTML (Stage 3)
- ❌ Performance monitoring avanzado (Stage 3)
- ❌ Sistema de usuarios/permisos avanzado (mantener Stage 1)
- ❌ Multi-tenancy / múltiples clientes

#### NO Optimizaciones Prematuras
- ❌ Paralelización con threads/async (empezar síncrono)
- ❌ Caché de requests (empezar sin caché)
- ❌ Base de datos separada para crawler (usar PostgreSQL existente)
- ❌ Microservicios (mantener monolito)

---

## Fases de Implementación

### Fase 2.1: Crawler Básico (MVP) 🎯
**Duración estimada**: 2-3 sesiones
**Objetivo**: Probar concepto con límite de 50 URLs

**Tareas:**
- [ ] Crear tabla `discovered_urls` y `crawl_runs`
- [ ] Script `crawler.py` con crawling básico:
  - Fetch URL con requests
  - Parse HTML con BeautifulSoup
  - Extraer enlaces `<a href="...">`
  - Seguir solo enlaces internos (mismo dominio)
  - Guardar en BD con parent_url_id
- [ ] **Límite**: 50 URLs máximo para pruebas
- [ ] Respetar rate limiting: 1 request/segundo
- [ ] Timeout: 10 segundos por request
- [ ] Ruta `/crawler/start` para iniciar crawl manual
- [ ] Ruta `/crawler/results` para ver URLs descubiertas (tabla simple)

**Criterio de éxito Fase 2.1:**
- ✅ Descubre 50 URLs de prueba desde URL raíz
- ✅ Las muestra en UI (tabla simple)
- ✅ Respeta rate limiting y timeout
- ✅ No crashea con enlaces malformados

**NO hacer en Fase 2.1:**
- ❌ Detección de enlaces rotos (Fase 2.2)
- ❌ Árbol navegable (Fase 2.4)
- ❌ Automatización (Fase 2.3)
- ❌ Emails (Fase 2.3)

---

### Fase 2.2: Validación y Detección 🔍
**Duración estimada**: 2 sesiones
**Objetivo**: Detectar problemas en las URLs descubiertas

**Tareas:**
- [ ] `validator.py` para validar cada URL:
  - Verificar status_code (200=OK, 404=broken, 500=error)
  - Medir response_time
  - Detectar redirects (301, 302)
  - Detectar timeouts
- [ ] Actualizar `discovered_urls` con:
  - `status_code`
  - `is_broken`
  - `error_message`
- [ ] Crear tabla `url_changes` para histórico
- [ ] Marcar cambios: 'new', 'broken', 'fixed'
- [ ] Ruta `/crawler/broken` para ver solo enlaces rotos
- [ ] Badge en sidebar: "Enlaces rotos: 5"

**Criterio de éxito Fase 2.2:**
- ✅ Identifica enlaces rotos en las 50 URLs de prueba
- ✅ Muestra solo enlaces rotos en UI
- ✅ Guarda histórico de cambios
- ✅ Badge en sidebar actualizado

**NO hacer en Fase 2.2:**
- ❌ Validación avanzada (loops, redirects sospechosos) → opcional
- ❌ Performance monitoring → Stage 3

---

### Fase 2.3: Escalar y Automatizar 🤖
**Duración estimada**: 2 sesiones
**Objetivo**: Crawl completo + automatización

**Tareas:**
- [ ] **Quitar límite de 50 URLs** → crawl completo
- [ ] Añadir max_depth configurable (default: 5 niveles)
- [ ] Script `run_crawler.py` para ejecutar desde cron:
  ```python
  #!/usr/bin/env python3
  from crawler.crawler import Crawler
  from crawler.config import CRAWLER_CONFIG

  crawler = Crawler(CRAWLER_CONFIG)
  crawler.run()
  ```
- [ ] Configurar APScheduler en app.py:
  - Ejecutar crawler 1x/día a las 3:00 AM
  - Job en background (no bloquear Flask)
- [ ] Sistema de alertas:
  - Si encuentra >10 enlaces rotos → crear alerta
  - Si encuentra >50 nuevas URLs → notificar
- [ ] Template `emails/crawler_report.html`
- [ ] Envío automático de email con resumen:
  - URLs descubiertas
  - Enlaces rotos encontrados
  - Tiempo de ejecución
- [ ] Ruta `/crawler/schedule` para configurar frecuencia

**Criterio de éxito Fase 2.3:**
- ✅ Crawler corre automáticamente 1x/día
- ✅ No requiere intervención manual
- ✅ Envía email con resumen
- ✅ Crea alertas cuando encuentra problemas

**Configuración cron alternativa (si APScheduler no funciona):**
```bash
# Ejecutar crawler diariamente a las 3:00 AM
0 3 * * * cd /home/user/agendaRenta4 && /usr/bin/python3 scripts/run_crawler.py
```

---

### Fase 2.4: Árbol Navegable UI 🌳
**Duración estimada**: 1-2 sesiones
**Objetivo**: UI bonita para explorar árbol de URLs

**Tareas:**
- [ ] Template `crawler/dashboard.html` con árbol navegable
- [ ] JavaScript `crawler_tree.js` para:
  - Renderizar árbol jerárquico (parent/children)
  - Expandir/colapsar nodos
  - Resaltar enlaces rotos (rojo)
  - Mostrar depth, status_code en hover
- [ ] Filtros en UI:
  - "Solo enlaces rotos"
  - "Por profundidad (depth)"
  - "Por dominio"
- [ ] Búsqueda: buscar URL en árbol
- [ ] Botón "Re-crawl Now" para forzar ejecución manual
- [ ] Exportar árbol a JSON/CSV

**Criterio de éxito Fase 2.4:**
- ✅ Árbol navegable visualmente atractivo
- ✅ Fácil encontrar enlaces rotos
- ✅ Filtros funcionan
- ✅ Botón re-crawl funciona

**Inspiración UI:**
- Tree view colapsable (como explorador de archivos)
- Usar librería JS: d3.js, jsTree, o simple recursión HTML

---

## Integración con Stage 1

### Opción A: Convivencia Temporal (RECOMENDADA para Stage 2)
- Tabla `sections` **mantiene** las 173 URLs actuales (Stage 1)
- Tabla `discovered_urls` es **paralela** (solo lectura Stage 2)
- Stage 1 sigue funcionando igual
- En Stage 3: Migración gradual sections → discovered_urls

**Pros:**
- Stage 1 no se rompe
- Podemos comparar manual vs automático
- Transición gradual

**Contras:**
- 2 fuentes de verdad temporalmente

### Opción B: Reemplazo Completo (Stage 3)
- Deprecar tabla `sections`
- Migrar datos sections → discovered_urls
- Todas las tareas usan discovered_urls
- Eliminar load_sections.py

**Decisión**: Empezar con Opción A en Stage 2, evaluar Opción B en Stage 3

---

## Configuración del Crawler

### crawler/config.py
```python
CRAWLER_CONFIG = {
    # URLs
    'root_url': 'https://www.r4.com',
    'allowed_domains': ['www.r4.com', 'r4.com'],

    # Límites
    'max_depth': 5,
    'max_urls': None,  # None = sin límite
    'timeout': 10,  # segundos

    # Rate limiting
    'delay_between_requests': 1.0,  # segundos
    'max_retries': 3,

    # Comportamiento
    'follow_redirects': True,
    'respect_robots_txt': True,
    'user_agent': 'AgendaRenta4-Crawler/2.0 (monitoring)',

    # Filtros
    'ignore_patterns': [
        r'/static/',
        r'/media/',
        r'\.pdf$',
        r'\.jpg$',
        r'\.png$',
    ],

    # Alertas
    'alert_threshold_broken_links': 10,
    'alert_threshold_new_urls': 50,
}
```

---

## Rendimiento y Límites

### Rate Limiting
- **1 request/segundo** (configurable)
- Sleep entre requests: `time.sleep(delay)`
- Respetar `Retry-After` header si servidor pide espera

### Timeouts
- **10 segundos** por request (configurable)
- Si timeout → marcar como error, no crashear crawler

### Max Depth
- **5 niveles** por defecto (configurable)
- Nivel 0: URL raíz
- Nivel 1: Enlaces desde raíz
- Nivel 2: Enlaces desde nivel 1
- etc.

### Max URLs
- **Sin límite** en producción (Fase 2.3+)
- **50 URLs** en Fase 2.1 (MVP testing)
- Configurable en `CRAWLER_CONFIG`

### Memoria
- **No cargar todo en memoria** → usar BD como queue
- Procesar URL → guardar → marcar como visitado
- Queue: SELECT urls WHERE status_code IS NULL LIMIT 100

---

## Seguridad

### Respetar robots.txt
```python
from urllib.robotparser import RobotFileParser

rp = RobotFileParser()
rp.set_url(f"{root_url}/robots.txt")
rp.read()

if rp.can_fetch(user_agent, url):
    # Crawl permitido
else:
    # Skip URL
```

### User-Agent Identificable
```python
headers = {
    'User-Agent': 'AgendaRenta4-Crawler/2.0 (monitoring; +https://ejemplo.com/crawler-info)'
}
```

### Solo Dominio Permitido
```python
from urllib.parse import urlparse

def is_allowed_domain(url, allowed_domains):
    domain = urlparse(url).netloc
    return domain in allowed_domains
```

### Autenticación (si el sitio requiere login)
```python
session = requests.Session()
session.post(login_url, data={'user': 'X', 'pass': 'Y'})
# Usar session.get() en lugar de requests.get()
```

**Nota**: Si el sitio requiere autenticación compleja, evaluar si crawler es viable

---

## Monitoreo y Logs

### Logs Detallados
```python
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('logs/crawler.log'),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger('crawler')

logger.info(f"Crawling URL: {url}")
logger.warning(f"Broken link: {url} (status={status_code})")
logger.error(f"Timeout: {url}")
```

### Tabla crawl_runs (Histórico)
- Guardar cada ejecución con stats:
  - URLs descubiertas
  - Enlaces rotos
  - Tiempo de ejecución
- Permite análisis histórico:
  - "¿Cuántos enlaces rotos había hace 1 mes?"
  - "¿Cuánto ha crecido el sitio?"

### Dashboard en Tiempo Real
- Ruta `/crawler/live` (opcional Fase 2.4)
- Mostrar crawler corriendo en vivo:
  - URLs procesadas / total
  - Velocidad (URLs/min)
  - Enlaces rotos encontrados
  - Progreso: barra de progreso
- WebSocket para updates en tiempo real (opcional)

---

## Anti-Patterns a Evitar

### ❌ Crawler Recursivo Infinito
**Problema:**
```python
def crawl(url, depth=0):
    links = get_links(url)
    for link in links:
        crawl(link, depth+1)  # Stack overflow!
```

**Solución:**
```python
queue = [root_url]
visited = set()

while queue:
    url = queue.pop(0)
    if url in visited:
        continue

    visited.add(url)
    links = get_links(url)
    queue.extend(links)
```

### ❌ Requests Sin Timeout
**Problema:**
```python
response = requests.get(url)  # Puede colgar forever
```

**Solución:**
```python
response = requests.get(url, timeout=10)
```

### ❌ Ignorar Rate Limiting
**Problema:**
```python
for url in urls:
    fetch(url)  # Spam al servidor!
```

**Solución:**
```python
for url in urls:
    fetch(url)
    time.sleep(1)  # Esperar 1 segundo
```

### ❌ Crawlear Sitios Externos
**Problema:**
```python
for link in all_links:
    crawl(link)  # Puede crawlear Google, Facebook, etc
```

**Solución:**
```python
for link in all_links:
    if is_allowed_domain(link, allowed_domains):
        crawl(link)
```

### ❌ Procesar Todo en Memoria
**Problema:**
```python
all_urls = []  # Lista de 10,000 URLs en RAM
```

**Solución:**
```python
# Usar BD como queue
cursor.execute("SELECT url FROM discovered_urls WHERE status_code IS NULL LIMIT 100")
```

### ❌ Mezclar Lógica Crawler con app.py
**Problema:**
- Poner crawler.py dentro de app.py (spaghetti code)

**Solución:**
- Módulo `crawler/` separado
- app.py solo tiene rutas que llaman al crawler

---

## Salida de Stage 2

**Cambiar a Stage 3 cuando:**
- ✅ Crawler funciona 100% automático en producción
- ✅ Detecta y reporta problemas sin fallos
- ✅ Has usado el sistema durante **2+ semanas**
- ✅ Tienes feedback real sobre qué mejorar
- ✅ Stage 1 y Stage 2 conviven estable

**Stage 3 Tentativo (basado en feedback Stage 2):**
- Comparación de contenido entre versiones
- Detección de cambios en elementos específicos HTML
- Performance monitoring (tiempos de carga)
- Migración completa: deprecar tabla `sections`
- O lo que Stage 2 revele como necesario

---

## Criterio de Calidad Stage 2

### Preguntas Clave (responder SÍ para considerar Stage 2 completo):

1. **Funcionalidad**
   - ¿El crawler descubre URLs automáticamente sin intervención manual? → SÍ
   - ¿Detecta enlaces rotos y reporta en UI? → SÍ
   - ¿Se ejecuta automáticamente (cron/scheduler)? → SÍ
   - ¿Envía alertas por email cuando hay problemas? → SÍ

2. **Robustez**
   - ¿Maneja timeouts sin crashear? → SÍ
   - ¿Respeta rate limiting? → SÍ
   - ¿Evita loops infinitos? → SÍ
   - ¿Logs detallados para debugging? → SÍ

3. **Usabilidad**
   - ¿Puedo ver el árbol de URLs fácilmente? → SÍ
   - ¿Puedo filtrar solo enlaces rotos? → SÍ
   - ¿Puedo forzar re-crawl manual? → SÍ
   - ¿El dashboard es intuitivo? → SÍ

4. **Mantenibilidad**
   - ¿El código está en módulo separado (`crawler/`)? → SÍ
   - ¿Stage 1 sigue funcionando sin cambios? → SÍ
   - ¿Puedo agregar validaciones nuevas fácilmente? → SÍ
   - ¿La configuración está centralizada? → SÍ

Si todas las respuestas son SÍ → **Stage 2 completado** ✅

---

## Notas Finales

### Filosofía Stage 2
- **Prioridad**: Funcionalidad sobre perfección
- **Iteración**: MVP rápido → mejorar basado en uso real
- **Pragmatismo**: Soluciones simples sobre arquitecturas complejas
- **Evidencia**: Solo añadir complejidad si hay dolor real

### Cuando Dudar
Si te encuentras pensando:
- "¿Debería abstraer esto?"
- "¿Necesito una interfaz aquí?"
- "¿Esto debe ser una clase?"

**Responde:**
1. ¿Resuelve un problema real (no teórico)?
2. ¿Hace el código más fácil de entender?
3. ¿Tengo 2+ casos de uso concretos?

Si las 3 respuestas son NO → **No lo hagas** (YAGNI)

### Recuerda
- Stage 1 funciona y está en producción
- Stage 2 no debe romper Stage 1
- Simple > Perfecto
- Código que funciona > Código "elegante"

---

**Éxito del proyecto = Stage 1 + Stage 2 funcionando en producción, NO arquitectura perfecta**
