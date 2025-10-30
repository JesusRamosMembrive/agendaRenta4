# Project Brief - Agenda Renta4

## ¿Qué estoy construyendo?

Un sistema de control de calidad web para revisar y monitorear el estado de las URLs de un sitio web corporativo. El sistema ayuda a un equipo a revisar manualmente múltiples tipos de tareas (autenticación, velocidad, navegación, etc.) en 173 URLs diferentes, y genera alertas automáticas basadas en periodicidad configurada.

**Problema que resuelve:**
- Gestión manual con Excel es propensa a errores
- No hay sistema de alertas automáticas
- Difícil trackear qué URLs fueron revisadas y cuáles tienen problemas

## ¿Cuál es el caso de uso mínimo?

Un usuario puede:
1. **Ver una lista de tareas pendientes** por periodo (ej: octubre 2025)
2. **Marcar tareas como OK o Problema** con un click
3. **Agregar observaciones** cuando detecta un problema
4. **Ver alertas automáticas** cuando es momento de revisar algo
5. **Configurar periodicidad** de cada tipo de tarea (semanal, mensual, etc)

---

## STAGE 1: Sistema Manual ✅ COMPLETADO

### Qué SÍ hice en Stage 1
- ✅ CRUD de tareas (marcar OK/Problema, observaciones)
- ✅ Páginas: Inicio, Pendientes, Problemas, Realizadas, Configuración, Alertas
- ✅ Sistema de alertas automáticas con periodicidad configurable
- ✅ Gestión manual de URLs (CRUD completo)
- ✅ Contadores en sidebar (Pendientes, Alertas, Problemas, Realizadas)
- ✅ Configuración de notificaciones (email, browser, in-app)
- ✅ **Migración completa a PostgreSQL**
- ✅ **Desplegado en producción en Render**

### Qué NO hice en Stage 1
- ❌ Web scraper automático
- ❌ Comparación de contenido entre versiones
- ❌ Detección automática de problemas
- ❌ Envío real de emails (solo UI configurada)
- ❌ Cron jobs automatizados
- ❌ Multi-usuario avanzado (solo login simple)
- ❌ Tests unitarios extensivos
- ❌ Documentación completa de API

### Criterio de éxito de Stage 1
- [x] Puedo ejecutar el programa básico
- [x] El caso de uso mínimo funciona
- [x] Puedo ver el resultado en menos de 5 minutos
- [x] Si algo falla, el error es claro
- [x] Aplicación en producción funcionando

**Estado**: ✅ **Stage 1 completado y en producción**

---

## STAGE 2: Web Crawler Automático (En Preparación)

### Objetivo Principal
**Reemplazar la gestión manual de URLs con un sistema automático de descubrimiento y validación.**

### Qué VOY a hacer en Stage 2

#### Core Features
- ✅ **Crawler de descubrimiento**: Descubrir URLs automáticamente desde raíz
- ✅ **Detección de enlaces rotos**: Identificar 404, 500, timeouts
- ✅ **Árbol navegable de URLs**: Visualizar jerarquía de páginas
- ✅ **Automatización completa**: Cron jobs + alertas + emails
- ✅ **Validación de enlaces**: Detectar enlaces incorrectos, loops, redirects

#### Fases de Implementación
1. **Fase 2.1 - Crawler MVP** (2-3 sesiones)
   - Crawler básico que descubre 50 URLs de prueba
   - UI simple para ver URLs descubiertas

2. **Fase 2.2 - Validación** (2 sesiones)
   - Detectar enlaces rotos (404, 500)
   - Histórico de cambios
   - Badge "Enlaces rotos" en sidebar

3. **Fase 2.3 - Automatización** (2 sesiones)
   - Quitar límite de 50 URLs → crawl completo
   - Cron job diario
   - Envío automático de emails con resumen
   - Sistema de alertas integrado

4. **Fase 2.4 - UI Árbol** (1-2 sesiones)
   - Árbol navegable con expand/collapse
   - Filtros (solo rotos, por depth, por dominio)
   - Botón "Re-crawl Now"

### Qué NO voy a hacer en Stage 2
- ❌ Refactorizar app.py en blueprints (solo si >1,500 líneas)
- ❌ Machine Learning / detección inteligente
- ❌ Navegador headless (Playwright/Selenium)
- ❌ Comparación de contenido HTML (Stage 3)
- ❌ Performance monitoring avanzado (Stage 3)
- ❌ Sistema de usuarios/permisos avanzado
- ❌ Multi-tenancy / múltiples clientes

### Criterio de éxito de Stage 2
- [ ] Crawler descubre URLs desde raíz automáticamente
- [ ] Detecta y reporta enlaces rotos/incorrectos
- [ ] Construye árbol de páginas navegable en UI
- [ ] Se ejecuta automáticamente (cron/scheduler)
- [ ] Envía alertas por email cuando encuentra problemas
- [ ] Reemplaza completamente el flujo manual de Excel

### Lo que reemplaza Stage 2
- ❌ Excel "251028_Árbol web - control calidad.xlsx"
- ❌ Script manual `load_sections.py`
- ❌ Lista hardcodeada de 173 URLs
- ✅ Sistema de descubrimiento automático

### Arquitectura Stage 2

**Nuevas tablas:**
- `discovered_urls` - URLs descubiertas por el crawler
- `crawl_runs` - Histórico de ejecuciones
- `url_changes` - Cambios detectados entre crawls

**Nuevos archivos:**
- `crawler/crawler.py` - Lógica de crawling
- `crawler/validator.py` - Validación de enlaces
- `crawler/scheduler.py` - Automatización
- `crawler/config.py` - Configuración
- `templates/crawler/dashboard.html` - UI árbol
- `templates/emails/crawler_report.html` - Email resumen
- `scripts/run_crawler.py` - Script para cron

**Stack tecnológico:**
- Requests + BeautifulSoup (simple, rápido)
- APScheduler (cron jobs)
- PostgreSQL existente (no BD separada)

**Total archivos nuevos**: ~10 archivos
**Total proyecto**: 25-30 archivos (manejable)

---

## STAGE 3: Tentativo (Después de Stage 2)

**Definir basado en feedback de Stage 2. Posibles features:**
- Comparación de contenido HTML entre versiones
- Detección de cambios en elementos específicos
- Performance monitoring (tiempos de carga)
- Migración completa: deprecar tabla `sections`
- Sistema de usuarios avanzado (si necesario)

**Criterio para empezar Stage 3:**
- Stage 2 funciona 100% en producción durante 2+ semanas
- Feedback real de usuarios sobre qué mejorar
- Stage 1 y Stage 2 conviven estable

---

## Tipo de proyecto
**Web Application - Sistema de Control de Calidad Web**

- **Categoría**: Internal tool / Quality Assurance
- **Usuarios**: Equipo interno (1-5 personas)
- **Deployment**: Cloud (Render + PostgreSQL)
- **Arquitectura**: Monolito (Flask app)

---

## Stack Tecnológico

### Stage 1 (Actual)
- **Backend**: Python 3.11, Flask 3.0.0
- **Database**: PostgreSQL (Render managed)
- **ORM**: None (raw SQL con psycopg2-binary 2.9.11)
- **Frontend**: HTML, CSS, JavaScript vanilla
- **Server**: Gunicorn
- **Hosting**: Render (Frankfurt region)
- **Auth**: Flask-Login (simple)
- **Email**: Flask-Mail (configurado, no usado aún)

### Stage 2 (Planeado)
- **Todo lo de Stage 1** +
- **Crawler**: Requests + BeautifulSoup4
- **Scheduler**: APScheduler
- **Tree UI**: JavaScript vanilla o d3.js/jsTree

### Dependencias Clave
```
Flask==3.0.0
Flask-Login==0.6.3
Flask-Mail==0.9.1
psycopg2-binary==2.9.11
python-dotenv==1.0.0
gunicorn==21.2.0

# Stage 2 (añadir)
requests==2.31.0
beautifulsoup4==4.12.2
apscheduler==3.10.4
```

---

## Arquitectura Actual

### Estructura de Archivos (Stage 1)
```
agendaRenta4/
├── app.py                       # 1,222 líneas - Flask app principal
├── utils.py                     # 140 líneas - DB + utilidades
├── constants.py                 # 80 líneas - Constantes
├── templates/                   # HTML templates
│   ├── base.html
│   ├── inicio.html
│   ├── pendientes.html
│   ├── problemas.html
│   ├── realizadas.html
│   ├── configuracion.html
│   ├── alertas.html
│   └── login.html
├── static/
│   └── css/
│       └── style.css
├── scripts/
│   ├── create_tasks_for_period.py
│   ├── load_sections.py
│   ├── seed_users.py
│   └── add_notification_email.py
├── migrations/
│   └── 001_sqlite_to_postgres.py
├── .env                         # Variables de entorno
├── requirements.txt
├── runtime.txt                  # Python 3.11.9
├── build.sh                     # Render build script
└── render.yaml                  # Render blueprint
```

**Total archivos core**: 3 (app.py, utils.py, constants.py)
**Líneas de código producción**: ~1,442 líneas

### Base de Datos (Stage 1)

**Tablas actuales:**
- `sections` - URLs a revisar (173 URLs)
- `task_types` - Tipos de tareas (8 tipos)
- `tasks` - Tareas realizadas
- `alert_settings` - Configuración de alertas
- `notification_preferences` - Preferencias de notificación
- `notifications` - Notificaciones in-app (futuro)
- `pending_alerts` - Alertas pendientes
- `users` - Usuarios del sistema

**Total**: 8 tablas

### Rutas Actuales (Stage 1)

**Páginas** (10 rutas):
- `/` - Redirect a inicio
- `/login` - Autenticación
- `/logout` - Cerrar sesión
- `/inicio` - Dashboard principal
- `/pendientes` - Tareas sin revisar
- `/problemas` - Tareas con incidencias
- `/realizadas` - Histórico completado
- `/configuracion` - Settings
- `/alertas` - Alertas pendientes
- Error handlers (404, 500)

**API** (10 rutas):
- `/tasks/update` - Actualizar estado de tarea
- `/save_observations` - Guardar observaciones
- `/configuracion/alertas` - Configurar alertas
- `/configuracion/notificaciones` - Configurar notificaciones
- `/configuracion/url/*` - CRUD de URLs (add, edit, toggle, delete)
- `/admin/generate-alerts` - Generar alertas manualmente
- `/alertas/dismiss/<id>` - Marcar alerta como resuelta

**Total**: 20 rutas

---

## Principios de Desarrollo

### Filosofía General
1. **Simplicidad > Perfección**
2. **Funciona > Elegante**
3. **Evidencia > Teoría** (solo añadir complejidad si hay dolor real)
4. **Iteración rápida** sobre arquitectura perfecta

### Stage 1 Rules (Seguidos ✅)
- ✅ TODO en 1-3 archivos principales
- ✅ Funciones simples > Clases
- ✅ Hardcodear está OK si acelera
- ✅ Zero configuración externa (todo en .env)
- ✅ Resultados en <5 minutos

### Stage 2 Rules (A seguir)
- ✅ Estructura SOLO si resuelve dolor real
- ✅ Módulo `crawler/` separado (justificado: responsabilidad clara)
- ✅ Clases permitidas si hay estado complejo (ej: Crawler con queue/visited)
- ❌ NO patrones sin justificación
- ❌ NO "preparar para el futuro" sin evidencia

---

## Métricas de Éxito

### Stage 1 (Actual) ✅
- ✅ Aplicación en producción en Render
- ✅ 100% migrado a PostgreSQL
- ✅ 0 bugs críticos conocidos
- ✅ Usuario puede revisar 173 URLs × 8 tareas = 1,384 combinaciones
- ✅ Sistema de alertas funcionando
- ✅ Configuración de URLs/alertas/notificaciones completa

### Stage 2 (Objetivos)
- [ ] Crawler descubre >100 URLs automáticamente
- [ ] Detecta enlaces rotos en <10 minutos
- [ ] Cron job corre 1x/día sin fallar
- [ ] Email de resumen enviado correctamente
- [ ] UI de árbol fácil de navegar
- [ ] Stage 1 sigue funcionando sin cambios

### Stage 3 (TBD)
- Definir basado en feedback Stage 2

---

## Historial de Decisiones

### Decisión 1: SQLite → PostgreSQL (2025-10-29)
**Razón**: Dev/prod parity, escalabilidad, deployment en Render
**Resultado**: ✅ Migración exitosa, 1,267 filas migradas

### Decisión 2: NO refactorizar app.py a blueprints (2025-10-30)
**Razón**: 1,222 líneas es manejable, evitar complejidad innecesaria
**Reconsiderar si**: app.py > 1,500 líneas o 2+ desarrolladores

### Decisión 3: Requests + BeautifulSoup para Stage 2 (2025-10-30)
**Razón**: Simple, rápido, suficiente para HTML estático
**Alternativas descartadas**: Scrapy (overkill), Playwright (pesado)
**Reconsiderar si**: Sitio requiere JavaScript

### Decisión 4: Convivencia temporal sections + discovered_urls (2025-10-30)
**Razón**: No romper Stage 1, transición gradual
**Migración completa**: Evaluar en Stage 3

---

## Contacto y Recursos

### Documentación
- `.claude/00-project-brief.md` - Este archivo
- `.claude/01-current-phase.md` - Estado actual y progreso
- `.claude/02-stage1-rules.md` - Reglas de Stage 1
- `.claude/02-stage2-rules.md` - Reglas de Stage 2 (crawler)
- `STAGE2_IMPLEMENTATION_PLAN.md` - Resumen ejecutivo Stage 2

### Referencias
- [Flask Docs](https://flask.palletsprojects.com/)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)
- [BeautifulSoup Docs](https://www.crummy.com/software/BeautifulSoup/bs4/doc/)
- [Render Docs](https://render.com/docs)

---

**Última actualización**: 2025-10-30
**Próximo paso**: Comenzar Fase 2.1 - Crawler MVP
