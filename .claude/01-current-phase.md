# Estado Actual

**Fecha**: 2025-10-31
**Etapa**: Transición Stage 2 → Stage 3
**Sesión Actual**: Documentación completa de Stage 3 y Plan de Mantenimiento

## 📚 DOCUMENTACIÓN STAGE 3 COMPLETADA (2025-10-31 noche)

**Planificación Completa de Automatización de 8 Tareas de Calidad**

### Documentos Creados

✅ **STAGE3_IMPLEMENTATION_PLAN.md** (1,100+ líneas)
- Plan detallado de 6 fases de implementación (Phase 3.0 - 3.6)
- 8 verificaciones de calidad automatizadas:
  1. ✅ Enlaces rotos/incorrectos (~90% completo en Stage 2)
  2. 🔲 Imágenes (alt text, tamaño, optimización)
  3. 🔲 CTAs (call-to-action buttons)
  4. 🔲 Textos - erratas (spelling/grammar)
  5. 🔲 Información actualizada (content changes)
  6. 🔲 FAQ (frequently asked questions)
  7. 🔲 Diseño (accessibility, contrast, responsive)
- Timeline: 3.5 meses (Nov 2025 - Feb 2026)
- Presupuesto: Solo herramientas gratuitas (BeautifulSoup, Pillow, pyspellchecker, etc.)
- Arquitectura modular: `calidad/` directory con checkers separados
- Dashboard unificado con 8 checks en vista consolidada
- Ejemplos de código Python detallados para cada fase
- Base de datos: Nueva tabla `quality_checks` para tracking
- Estrategia de testing: Probar en 10 URLs → 50 URLs → 173 URLs

✅ **MAINTENANCE_CHECKLIST.md** (800+ líneas)
- **Propósito**: Evitar que "vibe coding" se convierta en "dead coding"
- **Frecuencia**: Ejecutar entre CADA fase de Stage 3 (2-3 horas)
- **10 secciones de revisión**:
  1. Métricas de código (tamaño, complejidad, duplicación)
  2. Base de datos (tamaño, índices, N+1 queries)
  3. Arquitectura y diseño (responsabilidades, dependencias)
  4. Performance (tiempo de crawl, memoria)
  5. Testing (cobertura >70%, tests significativos)
  6. Seguridad (secretos, SQL injection, XSS)
  7. Documentación (README, docstrings, comentarios)
  8. Git (commits, branches)
  9. Decisiones técnicas (DECISIONS.md)
  10. Reflexión y planificación
- **Thresholds críticos**:
  * app.py <1,000 líneas (actualmente 1,647)
  * Ningún archivo >500 líneas
  * Crawl completo <30 minutos
  * Zero código duplicado en 3+ lugares
  * Zero código muerto
- **Herramientas**: radon, autoflake, vulture, flake8, black, pytest
- **Decisión tree**: Cuándo refactorizar vs continuar

### Próximos Pasos

**Antes de empezar Phase 3.0:**
- [ ] Hacer backup de base de datos actual
- [ ] Crear branch `stage3-development`
- [ ] Confirmar que Stage 2 está 100% funcional en producción
- [ ] Leer ambos documentos completos
- [ ] Ejecutar primer MAINTENANCE_CHECKLIST sobre código actual
- [ ] Instalar dependencias nuevas (Pillow, pyspellchecker, etc.)
- [ ] Crear estructura de carpetas `calidad/`

**Phase 3.0 (Preparación - 1 semana):**
- Refactorizar crawler de `app.py` a `crawler/engine.py`
- Crear módulo base `calidad/base.py` con clase `QualityCheck`
- Migración 006: Crear tabla `quality_checks`
- Reducir app.py de 1,647 líneas a ~1,000 líneas

**Phase 3.1 (Imágenes - 2 semanas):**
- Implementar `calidad/imagenes.py` con verificación completa
- Dashboard de imágenes con stats y filtros
- Testing en 10 URLs → ajustar → escalar a 173 URLs

### Filosofía de Stage 3

**Objetivo principal**: Minimizar trabajo manual de tu esposa
- De 8 horas/semana → 1 hora/semana
- Sistema notifica solo problemas reales (no falsos positivos)
- Excel completamente obsoleto

**Principios de implementación**:
- **Incremental**: Una tarea a la vez, validar antes de escalar
- **Falsos positivos mínimos**: Mejor no detectar algo que inundar con falsos positivos
- **Portfolio-ready**: Código limpio, documentado, demostrable
- **Solo herramientas gratuitas**: No APIs de pago, no GPT

### Archivos Creados

**Nuevos documentos (2):**
- `STAGE3_IMPLEMENTATION_PLAN.md` (1,100+ líneas)
- `MAINTENANCE_CHECKLIST.md` (800+ líneas)

**Modificados (1):**
- `.claude/01-current-phase.md` - Estado actualizado

---

## 🌳 PHASE 2.5 VISTA DE ÁRBOL NAVEGABLE COMPLETADA (2025-10-31 tarde)

**UI Jerárquica con Expand/Collapse y Filtros Avanzados**

### Implementación Completada

✅ **Nueva Ruta Flask (app.py:1545-1621)**
- `/crawler/tree` - Vista de árbol jerárquica
- Construcción de estructura parent-child desde base de datos
- Filtros: broken_only, max_depth, search_query
- Estadísticas en tiempo real

✅ **Template tree.html (300+ líneas)**
- Vista de árbol recursiva con macro Jinja2
- Expand/collapse con JavaScript vanilla (sin librerías)
- Botones: "Expandir todo", "Contraer todo"
- Auto-expand primer nivel al cargar
- Indentación visual proporcional a profundidad
- Colores semánticos (verde=OK, rojo=roto)

✅ **Filtros Avanzados**
- ☑️ **Solo enlaces rotos** - Checkbox con auto-submit
- 🔢 **Profundidad máxima** - Selector 0-10 niveles
- 🔍 **Búsqueda** - Input con ILIKE (insensible a mayúsculas)
- 🧹 **Limpiar filtros** - Botón para resetear

✅ **Características del Árbol**
- Icono de status (✅ OK, ❌ Roto, 🔄 Redirect, ⚠️ Otro)
- Metadata en cada nodo: depth, status_code, response_time, last_checked
- Links externos funcionales (target="_blank")
- Hover effects suaves
- Línea vertical conectando niveles

✅ **Navegación Integrada**
- Menú sidebar actualizado: 🌳 Vista de Árbol
- Dashboard con botón destacado verde
- Links cruzados entre vistas (árbol ↔ lista ↔ rotas)

### Archivos Creados/Modificados

**Nuevos archivos (1):**
- `templates/crawler/tree.html` (300+ líneas)

**Modificados (3):**
- `app.py` - Nueva ruta `/crawler/tree` (líneas 1545-1621)
- `templates/base.html` - Link en sidebar
- `templates/crawler/dashboard.html` - Botón "Vista de Árbol"

### Testing

✅ **Estructura de Datos Verificada**
```
Total URLs: 2,839
Root URLs: 1 (https://www.r4.com)
Max Depth: 10 niveles
Parent-child relationships: Correctas
```

---

## 🤖 PHASE 2.4 REVALIDACIÓN AUTOMÁTICA COMPLETADA (2025-10-31 mañana)

**Sistema de Revalidación Automática con Scheduler y Notificaciones**

### Implementación Completada

✅ **Módulo Scheduler (crawler/scheduler.py - 273 líneas)**
- Clase `ValidationScheduler` para revalidación automática
- Integración con APScheduler (BackgroundScheduler)
- Configuración de frecuencia: diaria, semanal
- Tracking automático de cambios (broken, fixed, status_change)
- Cálculo automático de Health Score
- Notificaciones por email cuando se detectan nuevos enlaces rotos
- Manejo de errores robusto con logging detallado

✅ **Base de Datos - Tabla health_snapshots (migration 004)**
- Almacena snapshots históricos de salud del sitio
- Campos: snapshot_date, health_score, total_urls, ok_urls, broken_urls, redirect_urls, error_urls
- Índice en snapshot_date para queries rápidas
- Permite análisis de tendencias temporales

✅ **Flask Routes - Health Dashboard & Scheduler (app.py:1440-1542)**
- `/crawler/health` - Dashboard con gráficos históricos
- `/crawler/scheduler` - Configuración del scheduler (GET/POST)
- Acciones: start, stop, run_now
- Integración completa con el sistema de validación existente

✅ **UI Templates**
- `templates/crawler/health.html` - Dashboard con Chart.js
  * Cards de métricas (Health Score, Total URLs, OK, Broken)
  * Gráfico de evolución histórica (últimos 30 días)
  * Indicador de tendencia (comparación 7 días)
  * Resumen de cambios recientes
- `templates/crawler/scheduler.html` - Configuración del scheduler
  * Estado actual (activo/inactivo, próxima ejecución)
  * Formulario de configuración (frecuencia, hora, minuto)
  * Ejecución manual inmediata
  * Panel informativo

✅ **Email Notifications (templates/emails/revalidation_report.html)**
- Email HTML responsive con estadísticas
- Lista de enlaces rotos detectados
- Priorización de URLs críticas
- Link directo al dashboard
- Diseño con colores semánticos

✅ **Menú Sidebar Actualizado (templates/base.html)**
- Nuevos enlaces: 💚 Health y ⚙️ Scheduler
- Navegación completa del módulo crawler

### Características del Sistema

**Scheduler Automático:**
- Frecuencia configurable (diaria, semanal)
- Hora y minuto personalizables
- Próxima ejecución visible en UI
- Start/Stop desde interfaz web

**Health Tracking:**
- Snapshots automáticos en cada revalidación
- Health Score: (OK URLs / Total URLs) * 100
- Gráfico histórico con Chart.js (dual-axis)
- Tendencia comparativa (7 días)

**Notificaciones Inteligentes:**
- Email solo cuando hay nuevos enlaces rotos
- Detección de cambios: new, broken, fixed, status_change
- Filtro últimas 24 horas
- Template HTML profesional

**Ejecución Manual:**
- Botón "Ejecutar Revalidación Ahora"
- Útil para testing y troubleshooting
- Ejecuta en contexto de Flask app

### Dependencias Añadidas

- `APScheduler==3.10.4` - Background scheduler
- `pytz`, `tzlocal` - Timezone handling (dependencies de APScheduler)

### Archivos Creados/Modificados

**Nuevos archivos (7):**
- `crawler/scheduler.py` (273 líneas)
- `migrations/004_add_health_snapshots.sql`
- `templates/crawler/health.html`
- `templates/crawler/scheduler.html`
- `templates/emails/revalidation_report.html`
- `test_scheduler.py` (166 líneas)

**Modificados (4):**
- `app.py` - 2 nuevas rutas (líneas 1440-1542)
- `templates/base.html` - Menú sidebar actualizado
- `templates/crawler/results.html` - Bugs visuales corregidos
- `requirements.txt` - APScheduler añadido

### Bugs Corregidos

✅ **Bug Visual /crawler/results**
- Enlaces rotos con fondo rosa y texto gris (ilegible)
- Badge de profundidad con texto gris sobre azul claro (ilegible)
- **Fix**: Colores contrastantes (#991b1b sobre rosa, #1e40af sobre azul)

### Testing

✅ **test_scheduler.py - Script de Pruebas**
- Check de database setup (health_snapshots table)
- Test de revalidación manual
- Test de configuración del scheduler (start/stop)
- Todos los tests pasan correctamente

**Resultados:**
```
✅ health_snapshots table exists
✅ discovered_urls table: 2839 URLs
   - Validated: 2788
   - Broken: 46
✅ Scheduler started successfully
   - Next Run: 2025-11-01 03:00:00
   - Trigger: cron[hour='3', minute='0']
✅ Scheduler stopped successfully
```

### Próximos Pasos Sugeridos

**🎯 OPCIÓN D: Despliegue en Producción (RECOMENDADO)**
1. Configurar variables de entorno en Render
2. Ejecutar migración 004 en producción
3. Configurar SMTP para emails (MAIL_SERVER, MAIL_USERNAME, MAIL_PASSWORD)
4. Activar scheduler desde UI en producción
5. Monitorear primeras ejecuciones

**Variables necesarias en Render:**
```bash
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USE_TLS=True
MAIL_USERNAME=tu-email@gmail.com
MAIL_PASSWORD=tu-app-password
MAIL_DEFAULT_SENDER=Agenda Renta4 <noreply@renta4.com>
```

**Comandos para producción:**
```bash
# 1. Ejecutar migración
psql $DATABASE_URL < migrations/004_add_health_snapshots.sql

# 2. Auto-start scheduler en app.py (descomentar líneas 1552-1553)
# from crawler.scheduler import start_scheduler
# start_scheduler(frequency='daily', hour=3, minute=0)
```

---

## 🎉 PHASE 2.3 VALIDACIÓN COMPLETA TERMINADA (2025-10-30 tarde)

**Validación de Todas las URLs Descubiertas por el Crawler**

### Ejecución de Validación Completa

✅ **Validación masiva ejecutada exitosamente**
- **2,788 URLs validadas** (99.8% del total descubierto)
- **Duración**: 52.1 minutos (3,124 segundos)
- **Rate limiting**: 2 req/segundo respetado
- **Inicio**: 2025-10-30 20:20:18
- **Fin**: 2025-10-30 21:12:21

### Resultados de Salud del Sitio

📊 **Estadísticas Generales:**
- ✅ **URLs OK (2xx, 3xx)**: 2,743 (98.4%)
- ❌ **Enlaces rotos (4xx, 5xx)**: 45 (1.6%)
- ⚠️ **Timeouts/Errores**: 1 (0.04%)
- 🔄 **Redirects detectados**: 392

💚 **Health Score: 98.4%** - Excelente salud general del sitio

⭐ **URLs Prioritarias: 117/117 OK (100%)** - Todas las URLs críticas funcionan correctamente

### Patrones de Errores Identificados

**45 URLs con HTTP 404:**

1. **Academia R4 (9 URLs)**
   - Formularios de cursos con IDs inexistentes
   - Patrón: `www.r4.com/academiar4/formulario-cursos?id=XXXX`
   - IDs rotos: 3636-3643, 4367

2. **Análisis de Compañías (múltiples URLs)**
   - Sección completa eliminada o reestructurada
   - Ejemplo: `www.r4.com/articulos-y-analisis/seguimiento-de-companias`
   - Artículos individuales también rotos

3. **Renta Fija (múltiples URLs)**
   - Sección de productos de renta fija eliminada
   - Ejemplo: `www.r4.com/broker-online/productos-de-inversion/renta-fija`

4. **URLs Malformadas (1 URL)**
   - Espacios codificados incorrectamente
   - Ejemplo: `www.r4.com/autor/%20`

**1 Timeout:**
- Error de conexión o respuesta muy lenta

### Herramientas Creadas

✅ **Script de Monitoreo (monitor_validation.py)**
- Monitor en tiempo real de progreso de validación
- Barra de progreso visual
- Estadísticas actualizadas cada 5 segundos (configurable)
- Velocidad de procesamiento (URLs/minuto)
- Estimación de tiempo restante
- Health score en vivo
- Auto-detección de completitud

✅ **Script de Exportación (export_broken_links.py)**
- Genera reporte detallado en formato TXT
- Agrupa enlaces por tipo de error (4xx, 5xx, timeouts)
- Identifica redirects problemáticos (→ 404)
- Lista todos los redirects para análisis
- Incluye recomendaciones de corrección

### Reportes Generados

📄 **Archivos creados (2025-10-30 21:30):**

1. **broken_links_report_20251030_213051.txt**
   - Reporte detallado de 46 problemas encontrados
   - Secciones: Broken URLs, Bad Redirects, Errors, All Redirects
   - Información completa: URL, código, tiempo de respuesta, profundidad, fecha

2. **informe_crawl_r4_20251030_213134.xlsx**
   - Informe Excel completo con 6 hojas
   - Incluye columnas de validación (estado, código, tiempo)
   - Colores condicionales (verde=OK, rojo=roto)

3. **urls_todas_20251030_213135.csv**
   - Respaldo en formato CSV

4. **urls_todas_20251030_213135.txt**
   - Lista simple de URLs

### Mejoras a la UI

✅ **Menú Lateral Actualizado (templates/base.html)**
- Nueva sección "Crawler" con divisor visual
- Tres enlaces principales:
  - 📊 Dashboard
  - 🌐 URLs Descubiertas
  - 🔍 Validación (con contador de enlaces rotos)
- Contador dinámico que muestra número de enlaces rotos en badge rojo
- Context processor actualizado para inyectar `broken_count` en todas las páginas

✅ **Fixes en UI /crawler/broken**
- Texto negro en cajas de información (antes gris ilegible)
- Stats cards mostrando números correctos (antes mostraba 0)
- Query SQL corregida para mostrar URLs validadas, no solo rotas

### Archivos Creados/Modificados

**Nuevos archivos:**
- `monitor_validation.py` (247 líneas) - Monitor de progreso en tiempo real
- `export_broken_links.py` (237 líneas) - Exportador de reportes de enlaces rotos

**Modificados:**
- `templates/base.html` - Nueva sección Crawler en sidebar (líneas 61-79)
- `app.py` - Context processor actualizado con `broken_count` (líneas 451-484)
- `templates/crawler/broken.html` - Fixes de colores y stats (múltiples líneas)

### Archivos de Reporte Generados

- `broken_links_report_20251030_213051.txt` (7KB)
- `informe_crawl_r4_20251030_213134.xlsx` (180KB)
- `urls_todas_20251030_213135.csv` (210KB)
- `urls_todas_20251030_213135.txt` (98KB)

### Próximos Pasos para Mañana

**🎯 OPCIÓN A: Phase 2.4 - Sistema de Revalidación Automática**
1. Crear cron job o scheduler para revalidar URLs periódicamente
2. Sistema de notificaciones por email cuando se detecten nuevos enlaces rotos
3. Dashboard con histórico de salud del sitio (gráficos temporales)
4. Comparación entre crawls (¿qué enlaces se rompieron desde el último crawl?)

**🎯 OPCIÓN B: Phase 2.5 - Corrección de Enlaces Rotos**
1. Analizar manualmente los 46 enlaces rotos identificados
2. Crear plan de corrección con prioridades
3. Coordinar con equipo de desarrollo para corregir enlaces
4. Re-crawl y revalidación post-corrección

**🎯 OPCIÓN C: Phase 3 - Comparación de Contenido**
1. Sistema de snapshots de contenido de páginas
2. Detección de cambios en contenido entre crawls
3. Alertas cuando páginas críticas cambien
4. Diff visual de cambios

**🎯 OPCIÓN D: Despliegue en Producción**
1. Preparar sistema de crawler para Render
2. Configurar PostgreSQL para almacenar crawls en producción
3. Programar crawls automáticos (ej: semanal)
4. Dashboard accesible para equipo

**Recomendación**: Opción D (Despliegue) o Opción A (Revalidación automática) para cerrar Phase 2 completamente antes de pasar a Phase 3.

---

## ✅ PHASE 2.2 VALIDACIÓN INICIAL COMPLETADA (2025-10-30 mañana)

**Sistema de Validación de URLs y Detección de Enlaces Rotos**

### Implementación Completada

✅ **Módulo Validador (crawler/validator.py - 237 líneas)**
- Clase `URLValidator` para verificar status codes HTTP
- Medición de response time en segundos
- Detección de enlaces rotos (4xx, 5xx, timeouts)
- Tracking de redirects (301, 302)
- Rate limiting: 2 requests/segundo
- Actualización automática de base de datos
- Tracking de cambios en tabla `url_changes`

✅ **Script de Validación (validate_urls.py - 143 líneas)**
- Valida todas las URLs descubiertas o solo prioritarias
- Modo `--priority-only` para validar solo las 117 URLs críticas
- Confirmación interactiva antes de ejecutar
- Estadísticas detalladas de validación
- Progress logging cada 10 URLs

✅ **Flask Route - Enlaces Rotos (app.py:1314-1362)**
- Nueva ruta `/crawler/broken` para visualizar enlaces rotos
- Filtra URLs con `is_broken = TRUE`
- Ordena por prioridad (prioritarias primero)
- Muestra estadísticas: total, prioritarias, nuevas

✅ **UI Template (templates/crawler/broken.html)**
- Dashboard visual con stats cards
- Tabla filtrable (todas/prioritarias/nuevas)
- Badges de status code con colores
- Información de error y tiempo de respuesta
- JavaScript para filtrado dinámico

✅ **Excel Mejorado con Datos de Validación**
- Nueva columna "Estado" con colores (✅ OK, ❌ Roto, ⚪ No validada)
- Columna "Código" con HTTP status code
- Columna "Tiempo(s)" con response time
- Hojas actualizadas: "Todas las URLs" y "URLs Prioritarias"

### Resultados de la Validación

**Test con 117 URLs Prioritarias:**
```
✅ 117/117 URLs validadas exitosamente
✅ 100% de salud - 0 enlaces rotos
⏱️  Duración: 75.5 segundos (1.3 minutos)
📊 Estadísticas:
   - OK (2xx, 3xx):     117
   - Broken (4xx, 5xx): 0
   - Redirects:         0
   - Errors (timeout):  0
```

### Archivos Creados/Modificados

**Nuevos archivos:**
- `crawler/validator.py`
- `validate_urls.py`
- `templates/crawler/broken.html`

**Modificados:**
- `app.py` - Nueva ruta `/crawler/broken`
- `generate_excel_report.py` - Añadidas columnas de validación

### Próximo Paso
Phase 2.2 completada exitosamente. El sistema puede ahora:
- Descubrir URLs automáticamente
- Marcar URLs prioritarias
- Validar salud de URLs
- Detectar enlaces rotos
- Generar reportes completos

---

## ⭐ PHASE 2.2 PREPARACIÓN COMPLETADA (2025-10-30)

**URLs Prioritarias - Sistema de Marcado**

### Implementación Completada

✅ **Migración de Base de Datos (migrations/003_add_priority_flag.sql)**
- Campo `is_priority` añadido a tabla `discovered_urls`
- Índice creado para queries rápidas por prioridad
- Preparación para validación selectiva de URLs críticas

✅ **Script de Marcado (mark_priority_urls.py - 79 líneas)**
- Marca automáticamente las 117 URLs de la lista manual como prioritarias
- Cruza datos entre tabla `sections` (manual) y `discovered_urls` (crawler)
- Resultado: 100% de éxito (117/117 URLs marcadas)

✅ **Reportes Excel Mejorados (generate_excel_report.py)**
- Nueva columna "⭐ Prioritaria" en hoja "Todas las URLs"
- Nueva hoja exclusiva "URLs Prioritarias" con 117 URLs destacadas
- Estadísticas actualizadas mostrando separación prioritarias/nuevas
- Highlight visual: fondo amarillo claro para URLs prioritarias

### Resultado Final
- **117 URLs prioritarias** marcadas (lista manual de auditoría)
- **2,722 URLs nuevas** descubiertas por crawler
- **Total: 2,839 URLs** en sistema

### Archivos Creados/Modificados

**Nuevos archivos:**
- `migrations/003_add_priority_flag.sql`
- `mark_priority_urls.py`

**Modificados:**
- `generate_excel_report.py` - Añadida columna prioritaria y nueva hoja

### Próximo Paso
Con las URLs prioritarias marcadas, el siguiente paso es implementar la **validación de URLs (Phase 2.2)** enfocándose primero en las 117 URLs críticas.

---

## 🕷️ PHASE 2.1 MVP COMPLETADO (2025-10-30)

**Web Crawler Automático - Descubrimiento de URLs**

### Implementación Completada

✅ **Base de datos (migrations/002_add_crawler_tables.sql)**
- Tabla `discovered_urls`: Almacena URLs descubiertas con depth, status_code, parent_url
- Tabla `crawl_runs`: Historial de ejecuciones del crawler
- Tabla `url_changes`: Tracking de cambios (preparada para Phase 2.2)

✅ **Crawler Engine (crawler/crawler.py - 362 líneas)**
- Queue-based crawling (evita recursión infinita)
- Rate limiting: 1 request/segundo
- Respeta dominios permitidos y profundidad máxima
- Normalización de URLs (fragmentos, trailing slashes)
- Extracción de links con BeautifulSoup
- Manejo de errores y timeouts

✅ **Configuración (crawler/config.py)**
- Límites MVP: 50 URLs, profundidad 3 niveles
- Timeout: 10 segundos por request
- Ignore patterns: /static/, PDFs, imágenes, etc.
- User-Agent identificable

✅ **Flask Routes (app.py líneas 1182-1311)**
- `/crawler` - Dashboard con stats y historial
- `/crawler/start` - Iniciar crawl manual (POST)
- `/crawler/results` - Lista paginada de URLs descubiertas
- `/crawler/results/<id>` - URLs de un crawl específico

✅ **Templates HTML**
- `templates/crawler/dashboard.html` - UI con stats cards y botón de inicio
- `templates/crawler/results.html` - Tabla de URLs con estados y profundidad

✅ **Testing**
- Test exitoso con 50 URLs descubiertas
- 0 errores durante el crawl
- Tiempo de ejecución: ~78 segundos
- 186 links encontrados en la página raíz
- URLs guardadas correctamente en base de datos

### Archivos Creados/Modificados

**Nuevos archivos:**
- `migrations/002_add_crawler_tables.sql`
- `crawler/__init__.py`
- `crawler/config.py`
- `crawler/crawler.py`
- `templates/crawler/dashboard.html`
- `templates/crawler/results.html`
- `test_crawler.py`

**Modificados:**
- `app.py` - 4 nuevas rutas Flask (líneas 1182-1311)
- `requirements.txt` - Añadido requests==2.31.0, beautifulsoup4==4.12.2

### Resultados del Test

```
URLs Discovered: 50
URLs Skipped: 5
Errors: 0
Crawl Duration: 78 seconds
```

**Estadísticas de descubrimiento:**
- Depth 0 (root): 1 URL
- Depth 1: 42 URLs
- Depth 2: 7 URLs
- Total links encontrados en homepage: 186

### Bugs Corregidos en el Proceso

1. **Encoding Error en crawler/__init__.py**
   - Error: `'utf-8' codec can't decode byte 0xe1` (caracter "ó" mal codificado)
   - Fix: Cambio "Automático" → "Automatico"

### Convivencia Temporal

La tabla `sections` (Stage 1) sigue funcionando. Las nuevas tablas del crawler (`discovered_urls`) conviven en paralelo, permitiendo:
- Comparar descubrimiento manual vs automático
- Stage 1 sigue operativo sin cambios
- Migración gradual en fases posteriores

---

## 🎉 STAGE 1 COMPLETADO Y EN PRODUCCIÓN

La aplicación está **desplegada y funcionando** en Render con PostgreSQL.

### Logros de la sesión final (2025-10-29 tarde)

✅ **Migración completa de SQLite a PostgreSQL**
- Migración exitosa de 1267 filas de datos
- Configuración de PostgreSQL local para desarrollo
- Actualización completa del código para PostgreSQL everywhere
- Eliminación de toda la lógica dual SQLite/PostgreSQL

✅ **Despliegue en producción (Render)**
- Aplicación desplegada y funcionando
- Base de datos PostgreSQL en Render
- Build exitoso con Python 3.11.9
- Todos los servicios comunicándose correctamente

---

## Progreso de la sesión final (2025-10-29 tarde)

### Migración PostgreSQL - Cambios Técnicos

**Archivos modificados:**

1. **utils.py** - Simplificación completa
   - ❌ Eliminado: `import sqlite3`
   - ❌ Eliminado: `DATABASE_PATH`
   - ❌ Eliminado: `adapt_query()` function
   - ❌ Eliminado: Lógica condicional SQLite/PostgreSQL
   - ✅ Solo PostgreSQL: `psycopg2` + `DATABASE_URL`
   - ✅ Context manager `db_cursor()` optimizado para PostgreSQL

2. **app.py** - 40+ queries actualizadas
   - Cambiados todos los placeholders `?` → `%s`
   - Eliminado import de `DATABASE_PATH` y `adapt_query`
   - Agregado `load_dotenv()` al inicio
   - Eliminada verificación de archivo de base de datos
   - Actualizado uso de booleanos (1/0 → TRUE/FALSE donde corresponde)

3. **manage_users.py** - Queries PostgreSQL
   - Cambiados 5 placeholders `?` → `%s`
   - `sqlite3.IntegrityError` → `psycopg2.IntegrityError`
   - Eliminado import de `DATABASE_PATH`

4. **.env** (local)
   - `DATABASE_URL=postgresql://jesusramos:dev-password@localhost/agendaRenta4`

**Migración de datos:**
- Script: `migrate_to_postgres.py`
- Datos migrados: 1267 filas
- Tablas: sections, task_types, tasks, alert_settings, notification_preferences, users, pending_alerts
- Conversión automática de booleanos SQLite (0/1) a PostgreSQL (FALSE/TRUE)
- Reset de sequences automático

**Commit:**
- Hash: `557a59b`
- Mensaje: "Migrate: Cambio completo de SQLite a PostgreSQL"
- Branch: `master`

### Problemas Resueltos en Migración

1. **Python version incompatibility**
   - Error: `psycopg2-binary` no compatible con Python 3.13.4
   - Solución: `runtime.txt` con Python 3.11.9 + psycopg2-binary 2.9.11

2. **Boolean type mismatch**
   - Error: PostgreSQL esperaba BOOLEAN pero recibía INTEGER
   - Solución: Actualización de migration script + 19 queries en código

3. **Database region mismatch**
   - Error: Web service y PostgreSQL en diferentes regiones
   - Solución: Recrear servicios en Frankfurt (misma región)

4. **SQL placeholder syntax**
   - Error: SQLite usa `?`, PostgreSQL usa `%s`
   - Solución: Cambio global de todos los placeholders (40+ queries)

5. **Import errors**
   - Error: Referencias a `DATABASE_PATH` y `adapt_query` inexistentes
   - Solución: Limpieza completa de imports obsoletos

---

## Sesión Anterior (2025-10-29 mañana)
**Objetivo**: Sistema de Alertas Automáticas

## Progreso sesión de alertas (2025-10-29 mañana)
- [x] Crear tabla `pending_alerts` en base de datos
- [x] Implementar función `generate_alerts()` para crear alertas según periodicidad
- [x] Implementar función `check_alert_day()` con lógica para todas las frecuencias
- [x] Crear rutas de alertas en app.py:
  - [x] POST `/admin/generate-alerts` - Generar alertas manualmente
  - [x] GET `/alertas` - Visualizar alertas pendientes (TODAS, no solo activas)
  - [x] POST `/alertas/dismiss/<id>` - Toggle alerta (activa ↔ resuelta)
- [x] Actualizar `get_task_counts()` para incluir contador de alertas
- [x] Agregar link y contador de alertas en sidebar (templates/base.html)
- [x] Crear template `alertas.html` con visualización completa
- [x] Agregar estilos CSS para `.alert-counter` con animación pulse
- [x] Probar generación de alertas: 8 alertas máximo (1 por tipo de tarea)
- [x] Probar toggle de alertas: funcionamiento correcto en ambas direcciones
- [x] Validar lógica de `check_alert_day()` con 10 casos de prueba (todos ✓)
- [x] **Corrección - Cambiar sistema de alertas:**
  - [x] Eliminar section_id de tabla pending_alerts
  - [x] Modificar generate_alerts() para crear solo 1 alerta por task_type
  - [x] Actualizar template para mostrar tipos de tarea en lugar de URLs
- [x] **Corrección - Implementar toggle de alertas:**
  - [x] Modificar endpoint dismiss para hacer toggle en lugar de solo resolver
  - [x] Actualizar template para mostrar TODAS las alertas (activas y resueltas)
  - [x] Diferenciar visualmente alertas resueltas (opacidad 50%, fondo verde)
  - [x] Cambiar botón dinámicamente: "✓ Resolver" ↔ "↻ Reactivar"
  - [x] Mostrar checkmark verde en alertas resueltas

## Progreso sesiones anteriores
- [x] Implementar función JavaScript `updateRowStatus()` para calcular color del status-dot
- [x] Integrar llamada automática después de cada cambio de estado
- [x] Inicializar status-dots al cargar la página
- [x] Corregir página /pendientes para mostrar TODAS las tareas pendientes (no solo las de BD)
- [x] Implementar página de Configuración completa:
  - [x] Sección de Alertas de Tareas (8 tipos con periodicidad y toggle)
  - [x] Sección de Tipo de Notificaciones (email, escritorio, in-app)
  - [x] Sección de Gestión de URLs (CRUD completo)
- [x] Crear 3 nuevas tablas en BD: alert_settings, notification_preferences, notifications
- [x] Implementar 6 nuevas rutas POST para guardar configuraciones
- [x] Agregar selector de día específico para alertas:
  - [x] Columna alert_day en tabla alert_settings
  - [x] Selector dinámico: días de la semana (semanal/quincenal) o días del mes (mensual/trimestral/etc)
  - [x] JavaScript para actualizar opciones según frecuencia elegida

## Progreso sesión anterior (2025-10-28)
- [x] Cambiar botones a solo iconos (✓ y ⚠)
- [x] Separar Pendientes (no revisadas) de Problemas (con incidencias)
- [x] Crear nueva ruta /problemas
- [x] Crear template problemas.html
- [x] Agregar contadores al sidebar (Pendientes, Problemas, Realizadas)
- [x] Corregir lógica de contador de pendientes (no contaba tareas sin registro en BD)
- [x] Mejorar contraste del banner de pendientes (amarillo claro → marrón oscuro)

## Implementación

### Archivos Modificados/Creados (Sesión actual - Sistema de Alertas)

**agendaRenta4.db** - Nueva tabla
- `pending_alerts` - Alertas pendientes generadas automáticamente
  * id, task_type_id, due_date, generated_at, dismissed, dismissed_at
  * UNIQUE constraint en (task_type_id, due_date) para evitar duplicados
  * **NOTA:** NO tiene section_id - una alerta por tipo de tarea, no por URL
  * Máximo 8 alertas simultáneas (una por cada tipo de tarea)

**app.py** - Nuevas funciones y rutas (líneas ~64-132, ~950-1048)
- Función `get_task_counts()` actualizada para incluir contador de alertas
- Función `generate_alerts(reference_date=None)` (líneas ~135-199)
  * Genera alertas según configuración de alert_settings
  * **Crea una alerta por task_type, NO por sección**
  * Verifica periodicidad con check_alert_day()
  * Crea registros en pending_alerts evitando duplicados
  * Retorna estadísticas: {generated, skipped, errors}
  * Máximo 8 alertas por ejecución (una por tipo de tarea)
- Función `check_alert_day(reference_date, frequency, alert_day)` (líneas ~214-285)
  * Valida si una fecha cumple criterios de alerta
  * Lógica para: daily, weekly, biweekly, monthly, quarterly, semiannual, annual
  * Edge case: usa min(target_day, last_day_of_month) para meses cortos
- POST `/admin/generate-alerts` - Endpoint para generar alertas manualmente
- GET `/alertas` - Página de visualización de alertas pendientes (sin JOIN a sections)
- POST `/alertas/dismiss/<id>` - Marcar alerta como resuelta

**templates/alertas.html** (NUEVO - ~172 líneas)
- Tabla con alertas pendientes mostrando:
  * Fecha de aviso, **tipo de tarea**, periodicidad, fecha de generación
  * Texto: "Revisar todas las URLs para esta tarea"
  * Botón "Resolver" para cada alerta
  * **SIN columna de URL/sección** - las alertas son genéricas por tipo
- Panel informativo sobre el sistema de alertas
- Panel de administración con botón para generar alertas manualmente
- JavaScript para:
  * Función `dismissAlert(id)` - Resolver alerta con confirmación
  * Función `generateAlerts()` - Generar alertas manualmente
  * Animación de fade-out al resolver
  * Recarga de página si no quedan alertas

**templates/base.html** (líneas 34-39)
- Nuevo link "Alertas" en navegación (entre Pendientes y Problemas)
- Contador `.nav-counter.alert-counter` solo visible si hay alertas > 0
- Recibe `task_counts.alerts` del context processor

**static/css/style.css** (líneas 118-131)
- `.nav-counter.alert-counter` - Estilo especial para contador de alertas
  * Color amarillo/warning (#f6c445)
  * Fondo semi-transparente rgba(246, 196, 69, 0.2)
  * Animación `pulse-alert` de 2s que pulsa la opacidad
- `.btn.btn-sm` - Botones pequeños (padding: 6px 10px, font-size: 13px)

### Archivos Modificados (Sesiones anteriores)

**templates/inicio.html** (líneas 115-269)
- Nueva función JavaScript `updateRowStatus(row)` (líneas 233-267)
- Calcula el color del status-dot basándose en botones activos:
  * Verde (sd-green): Todos los botones OK marcados (0 problemas, OK = total)
  * Rojo (sd-red): Más de 4 problemas
  * Naranja (sd-orange): Entre 1 y 4 problemas
  * Neutral (sd-neutral): Cualquier otro caso
- Llamada automática después de cada click en botones (línea 153)
- Inicialización al cargar página (líneas 227-229)
- Logs en consola para debugging

**app.py** - Ruta /pendientes (líneas 262-324)
- Cambiado de consulta SQL a generación de combinaciones
- Obtiene todas las secciones activas y tipos de tareas
- Genera todas las combinaciones posibles (173 secciones × 8 tipos = 1384)
- Excluye las que ya están marcadas como OK o Problema
- Muestra las restantes como pendientes (1376 en el ejemplo)
- Solución simple y directa siguiendo Stage 1

**agendaRenta4.db** - Nuevas tablas
- `alert_settings` - Configuración de alertas por tipo de tarea
  * task_type_id, alert_frequency (daily/weekly/biweekly/monthly/quarterly/semiannual/annual), alert_day (día específico), enabled
  * alert_day: NULL para daily, día de la semana (monday-sunday) para weekly/biweekly, día del mes (1-31) para monthly/quarterly/semiannual/annual
- `notification_preferences` - Preferencias de notificación del usuario
  * user_name, email, enable_email, enable_desktop, enable_in_app
- `notifications` - Notificaciones en app (para futuro)
  * user_name, task_type_id, message, created_at, read

**app.py** - Ruta GET /configuracion (líneas 430-496)
- Carga todos los task_types con sus alert_settings
- Carga notification_preferences del usuario actual
- Carga todas las sections (URLs)
- Renderiza template con todos los datos

**app.py** - Nuevas rutas POST (líneas 585-770)
- `/configuracion/alertas` - Guardar config de alertas (JSON batch update)
- `/configuracion/notificaciones` - Guardar preferencias de notificación
- `/configuracion/url/add` - Añadir nueva URL/sección
- `/configuracion/url/edit/<id>` - Editar URL existente
- `/configuracion/url/toggle/<id>` - Activar/desactivar URL
- `/configuracion/url/delete/<id>` - Eliminar URL (solo si no tiene tareas)

**templates/configuracion.html** (NUEVO - ~730 líneas)
- Sección 1: Alertas de Tareas
  * Tabla con 8 task_types
  * Select de periodicidad (7 opciones: diario, semanal, quincenal, mensual, trimestral, semestral, anual)
  * Select de día de aviso (dinámico según frecuencia):
    - Diario: deshabilitado ("Todos los días")
    - Semanal/Quincenal: días de la semana (Lunes-Domingo)
    - Mensual/Trimestral/Semestral/Anual: días del mes (1-31)
  * Toggle switch para activar/desactivar
  * JavaScript que actualiza opciones de día al cambiar frecuencia
  * Botón guardar (envía JSON a backend con alert_day incluido)
- Sección 2: Tipo de Notificaciones
  * Checkbox: Notificación en app (badge en topbar)
  * Checkbox: Notificación de escritorio (requiere permiso browser)
  * Checkbox: Email + input de correo
  * Explicación de cada opción
- Sección 3: Gestión de URLs
  * Formulario para añadir nueva URL (nombre + url)
  * Tabla con 173 URLs existentes
  * Botones: Editar, Activar/Desactivar, Eliminar
  * Modo edición inline (sin modal)
  * Validación de eliminación (no permite si hay tareas asociadas)
- JavaScript incluido para todas las interacciones
- Estilos CSS para toggle switches y notification-options

### Problemas resueltos

**Bug #1: Status-dot no cambiaba de color**
- **Síntoma**: El círculo de status no cambiaba de color al marcar tareas como OK o Problema
- **Causa**: Faltaba la lógica JavaScript para actualizar dinámicamente la clase CSS del status-dot
- **Solución**: Implementación de función que cuenta botones activos y aplica reglas de color según estado

**Bug #2: Página Pendientes solo mostraba 2 tareas**
- **Síntoma**: Contador mostraba 1376 pendientes pero la página solo listaba 2 tareas
- **Causa**: La consulta SQL solo buscaba registros con status='pending' en BD, ignorando tareas sin marcar
- **Solución**: Generar todas las combinaciones (sección × tipo) y excluir las marcadas como OK/Problema
- **Resultado**: Ahora muestra las 1376 tareas pendientes correctamente

---

### Archivos Modificados (Sesión anterior 2025-10-28)

**app.py** (líneas 63-122)
- Función `get_task_counts()` refactorizada completamente
- Nueva lógica: Pendientes = (Secciones × Tipos) - OK - Problemas
- Ahora cuenta correctamente tareas que no tienen registro en BD
- Contadores por periodo actual (excepto Realizadas que es histórico)

**templates/inicio.html** (líneas 43-55)
- Botones simplificados: solo iconos ✓ y ⚠
- Eliminado texto "Ok" y "Problema"
- Mantiene funcionalidad de toggle completa

**templates/pendientes.html** (líneas 9-14)
- Banner cambiado a color marrón oscuro (#78350f)
- Letras en amarillo claro (#fef3c7) para mejor contraste
- Mantiene identidad de "alerta" pero legible

**templates/problemas.html** (NUEVO)
- Nueva página para tareas con status='problem'
- Esquema de colores rojo/ámbar
- Muestra observaciones prominentemente
- Sin columna de estado (todas son problemas)

**templates/base.html** (líneas 26-45)
- Añadido link "Problemas" entre Pendientes y Realizadas
- Contadores agregados con clase `.nav-counter`
- Usa `{{ task_counts.pending }}`, `{{ task_counts.problems }}`, `{{ task_counts.completed }}`

**static/css/style.css** (líneas 89-116)
- Estilos para `.nav-counter`: badges azules con fondo semi-transparente
- `.nav a` ahora usa flexbox para alinear texto y contador
- Diseño consistente con tema oscuro

### Rutas Nuevas

**GET /problemas** (app.py líneas 242-293)
- Lista tareas con status='problem' desde octubre 2025 hasta periodo actual
- JOIN con sections y task_types
- Solo secciones activas

## Decisiones tomadas

### Separación de Pendientes vs Problemas
**Por qué:** Claridad conceptual
- **Pendientes** = Tareas no revisadas aún (sin marcar)
- **Problemas** = Tareas revisadas que tienen incidencias
- Antes todo se mezclaba en una sola vista

### Cálculo de contador de pendientes
**Problema detectado:** Solo contaba las 9 tareas en BD con status='pending'
**Solución:** Calcular total posible - OK - Problemas
- Total posible = Secciones activas × Tipos de tareas × 1 periodo
- Ahora refleja correctamente ~173 tareas pendientes

### Botones con solo iconos
**Por qué:** La página se hacía muy ancha con textos
**Solución:** Mantener solo ✓ (OK) y ⚠ (Problema)
- Más compacta la tabla
- Iconos universales, no necesitan traducción

### Banner oscuro en pendientes
**Problema:** Amarillo claro no se leía sobre fondo claro
**Solución:** Marrón oscuro (#78350f) con letras amarillo claro (#fef3c7)
- Consistente con tema oscuro de la app
- Contraste adecuado para accesibilidad

## Qué NO hicimos (aplazado)

### Filtros por periodo en Pendientes/Problemas
- Rango fijo: octubre 2025 hasta periodo actual
- Podría añadirse selector de periodo como en Inicio
- No era prioritario para hoy

### Buscar funcional en topbar
- Input de búsqueda existe pero no funciona
- Pendiente para futuras iteraciones

## 🚀 Estado actual del sistema (EN PRODUCCIÓN)

**✅ Funcionando en producción (Render + PostgreSQL):**
- ✅ Marcar/desmarcar tareas como OK o Problema (toggle buttons)
- ✅ Auto-guardado de observaciones
- ✅ Contadores en sidebar actualizados dinámicamente (Pendientes, Alertas, Problemas, Realizadas)
- ✅ Navegación entre Inicio, Pendientes, Alertas, Problemas, Realizadas
- ✅ Selector de periodo en Inicio
- ✅ Hiperlinks en nombres de URL/sección
- ✅ Status-dot cambia de color según estado de tareas (verde/naranja/rojo)
- ✅ Página Pendientes muestra TODAS las tareas sin marcar (no solo las de BD)
- ✅ Página Configuración completa con 3 secciones funcionales
- ✅ CRUD de URLs (añadir, editar, activar/desactivar, eliminar)
- ✅ Configuración de alertas por tipo de tarea (periodicidad + día específico)
- ✅ Configuración de preferencias de notificación
- ✅ Sistema de alertas automáticas completamente funcional
  - Generación de alertas según periodicidad configurada
  - Visualización de alertas pendientes con contador animado
  - Resolución/descarte de alertas individuales
  - Edge case handling para meses con menos días
- ✅ **PostgreSQL en desarrollo Y producción** (dev/prod parity)
- ✅ **Aplicación desplegada en Render** con PostgreSQL managed database

**⏸️ Pendiente para futuras iteraciones (Stage 2+):**
- ⏸️ Búsqueda funcional
- ⏸️ Sistema de autenticación multi-usuario (actualmente hardcoded)
- ⏸️ Filtros avanzados por fecha/tipo
- ⏸️ Exportación de reportes
- ⏸️ Sistema de envío real de notificaciones (email/desktop)
- ⏸️ Programación automática (cron job) para ejecutar generate_alerts() diariamente
- ⏸️ Notificaciones in-app cuando se generan nuevas alertas
- ⏸️ **Web scraper/crawler automático** (Stage 2)

## 🎯 Próxima sesión - Preparar Stage 2

**🎉 STAGE 1 COMPLETADO Y DESPLEGADO**

La aplicación está funcionando en producción. Todos los objetivos de Stage 1 cumplidos:
- ✅ Sistema manual de revisión de tareas
- ✅ Configuración de URLs (CRUD completo)
- ✅ Configuración de alertas con periodicidad
- ✅ Sistema de alertas automáticas
- ✅ PostgreSQL en desarrollo y producción
- ✅ Aplicación desplegada en Render

**Sugerencias para próxima sesión:**

### Opción A: Mejoras opcionales de Stage 1
1. **Autenticación multi-usuario**
   - Sistema de login/logout funcional
   - Gestión de usuarios (crear, editar, eliminar)
   - Permisos por rol (admin, revisor)

2. **Búsqueda funcional**
   - Filtrar secciones en tabla por nombre
   - JavaScript client-side simple

3. **Cron job para alertas**
   - Script para ejecutar `generate_alerts()` diariamente
   - Configuración en servidor o usar servicio como cron-job.org

### Opción B: Comenzar Stage 2 (Web Scraper)
1. **Definir arquitectura del scraper**
   - Evaluar herramientas: Playwright, BeautifulSoup, Scrapy
   - Decidir si scraper corre en Render o separado
   - Diseñar estructura de datos para guardar resultados

2. **Prototipo inicial**
   - Scraper básico para 1-2 URLs de prueba
   - Guardar resultados en nueva tabla `scan_results`
   - Endpoint para visualizar resultados

3. **Integración con sistema de alertas**
   - Scraper se ejecuta cuando hay alerta activa
   - Resultados aparecen en página de alerta
   - Sistema de comparación (cambios vs. última revisión)

**Recomendación: Opción B** - Stage 1 está completo y funcional. Es buen momento para empezar Stage 2.

## Bugs conocidos
- ✅ (RESUELTO) Status-dot no cambiaba de color (implementado 2025-10-29)
- ✅ (RESUELTO) Página Pendientes solo mostraba 2 tareas en vez de 1376 (implementado 2025-10-29)

## Notas técnicas

### Stack actual (Producción)
- **Base de datos**: PostgreSQL (Render managed database)
- **Servidor web**: Gunicorn (puerto configurado por Render)
- **Hosting**: Render (Frankfurt region)
- **Python**: 3.11.9
- **Framework**: Flask 3.0.0
- **Database driver**: psycopg2-binary 2.9.11

### Base de datos local (Desarrollo)
- **Base de datos**: PostgreSQL (localhost)
- **Connection string**: `postgresql://jesusramos:dev-password@localhost/agendaRenta4`
- **Migración**: 1267 filas desde SQLite

### Esquema de base de datos
- **Tablas**: sections, task_types, tasks, alert_settings, notification_preferences, notifications, pending_alerts, users
- **Task status**: 'pending', 'ok', 'problem'
- **Periodo actual**: 2025-10 (formato YYYY-MM)
- **Context processor**: Inyecta task_counts en todos los templates (incluyendo alerts)

### Deployment
- **Archivo de configuración**: render.yaml (Render Blueprint)
- **Build script**: build.sh
- **Runtime**: runtime.txt (Python 3.11.9)
- **Branch de producción**: master

### Sistema de Alertas Automáticas (IMPLEMENTADO ✅)

**Generación de alertas:**
- Función `generate_alerts(reference_date=None)` en app.py
- Se ejecuta manualmente mediante POST `/admin/generate-alerts`
- Consulta todas las configuraciones activas en `alert_settings`
- Para cada configuración, verifica si la fecha de referencia cumple los criterios
- **Crea UNA alerta por task_type** (máximo 8 alertas totales, no 173×8)
- Evita duplicados con constraint UNIQUE(task_type_id, due_date)
- Cada alerta recuerda revisar **todas las URLs** para ese tipo de tarea

**Lógica de periodicidad (`check_alert_day`):**
- **daily**: Siempre True
- **weekly**: Compara día de la semana (0=Monday, 6=Sunday)
- **biweekly**: Como weekly pero solo en semanas pares (week_number % 2 == 0)
- **monthly**: Compara día del mes (1-31)
- **quarterly**: Como monthly pero solo en meses 1, 4, 7, 10
- **semiannual**: Como monthly pero solo en meses 1, 7
- **annual**: Como monthly pero solo en mes 1

**Edge case - Días del mes que no existen:**
- Si se configura alerta para día 29, 30 o 31 en meses con menos días:
  * Se usa `min(target_day, calendar.monthrange(year, month)[1])`
  * Ejemplo: Alerta día 31 en febrero → se genera el día 28 (o 29 en bisiestos)
  * Ejemplo: Alerta día 31 en abril → se genera el día 30
- **Estado:** ✅ Implementado y probado
- **Validación:** 10 casos de prueba ejecutados correctamente

**Visualización:**
- Página `/alertas` muestra todas las alertas con dismissed=0
- Contador animado en sidebar (pulsa amarillo)
- Botón "Resolver" marca alerta como dismissed=1
- Botón admin "Generar Alertas" para testing manual

**Para producción (pendiente):**
- Configurar cron job o systemd timer para ejecutar generate_alerts() diariamente
- Ejemplo cron: `0 9 * * * cd /path/to/app && python3 -c "from app import generate_alerts; generate_alerts()"`

---

## 🎯 PREPARANDO STAGE 2 - Web Crawler Automático

**Fecha**: 2025-10-30
**Estado**: Stage 1 completado y en producción, bugs críticos corregidos, documentando Stage 2

### Sesión de Planning y Bug Fixes (2025-10-30)

#### ✅ Bugs Críticos Corregidos (4/4)

**Bug #1: INSERT OR IGNORE incompatible con PostgreSQL**
- **Archivo**: app.py:192-195
- **Problema**: Sintaxis SQLite `INSERT OR IGNORE` no funciona en PostgreSQL
- **Solución**: Cambiado a `INSERT ... ON CONFLICT (task_type_id, due_date) DO NOTHING`
- **Estado**: ✅ Corregido

**Bug #2: Helper scripts usando SQLite**
- **Archivos**: create_tasks_for_period.py, load_sections.py, seed_users.py
- **Problema**:
  - Importaban `sqlite3` y `DATABASE_PATH` (inexistentes tras migración)
  - Usaban placeholders `?` en lugar de `%s`
  - Capturaban `sqlite3.IntegrityError` en lugar de `psycopg2.IntegrityError`
  - Accedían a rows con índices en lugar de dict keys
- **Solución**: Migrados completamente a PostgreSQL con `db_cursor()` y psycopg2
- **Estado**: ✅ Corregido (3 scripts)

**Bug #3: add_notification_email.py mezclando sintaxis**
- **Archivo**: add_notification_email.py:9-44
- **Problema**: Mezclaba imports sqlite3, placeholders `?`, y acceso por índice
- **Solución**: Migrado a psycopg2 con placeholders `%s` y dict access
- **Estado**: ✅ Corregido

**Bug #4: send_email_notifications() depende de current_user**
- **Archivo**: app.py:305-323
- **Problema**: Función usaba `current_user.full_name`, fallará en cron jobs sin contexto Flask
- **Solución**: Añadido parámetro `user_name=None` con fallback graceful
- **Estado**: ✅ Corregido

#### ⏸️ Refactors Descartados (por ahora)

**Análisis de app.py realizado:**
- **Tamaño actual**: 1,222 líneas (manejable)
- **Organización**: Clara, fácil de navegar
- **Complejidad**: Aceptable para Stage 1
- **Veredicto**: 8/10 - No necesita refactoring urgente

**Refactors propuestos pero NO ejecutados:**
1. ❌ Break app.py into blueprints → Añade complejidad sin beneficio actual
2. ❌ Centralize database access patterns → Queries directos funcionan bien
3. ❌ Replace HTML string concatenation → Solo 1 caso (email template)
4. ❌ Consolidate configuration loading → load_dotenv() es suficiente

**Razón**: Evitar "spaghetti" y complejidad innecesaria. Stage 1 funciona bien.

**Cuándo reconsiderar**:
- app.py > 1,500 líneas
- Stage 2 añade mucho código
- 2+ desarrolladores en paralelo

#### 🚀 Stage 2 Confirmado: Web Crawler Automático

**Decisiones de diseño (sesión planning):**

**1. Objetivo Principal**
- Reemplazar lista hardcodeada de URLs (Excel + load_sections.py)
- Sistema de descubrimiento automático desde URL raíz
- **Opción elegida**: Crawler de descubrimiento (no solo validación)

**2. Tipo de Scraper**
- ✅ Crear árbol de páginas navegable
- ✅ Investigar enlaces rotos (404, 500, timeouts)
- ✅ Detectar enlaces incorrectos (malformados, loops, redirects)
- ❌ Comparación de contenido (Stage 3)
- ❌ Performance monitoring (Stage 3)

**3. Criterio de Éxito Mínimo Stage 2**
- Sistema end-to-end totalmente automatizado
- Crawler + alertas + emails sin intervención manual
- Reemplaza completamente el flujo manual del Excel

**4. Fuera de Scope Stage 2**
- ❌ Machine Learning / IA
- ❌ Scraping con JavaScript (Playwright/Selenium)
- ❌ Sistema de usuarios avanzado
- ⚠️ Refactorizar app.py → Solo si es necesario

**5. Arquitectura Propuesta**
- **Stack**: Requests + BeautifulSoup (simple y rápido)
- **Estructura**: Módulo `crawler/` separado
- **Tablas nuevas**: discovered_urls, crawl_runs, url_changes
- **Integración**: Nuevas rutas en app.py (<10 rutas)

**Próximos pasos:**
1. Crear `.claude/02-stage2-rules.md` con arquitectura completa
2. Crear `STAGE2_IMPLEMENTATION_PLAN.md` con fases de implementación
3. Actualizar `.claude/00-project-brief.md` con alcance Stage 2
4. Comenzar Fase 2.1: Crawler MVP (50 URLs de prueba)