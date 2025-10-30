# Stage 2: Implementation Plan - Web Crawler Automático

## TL;DR

**Objetivo**: Reemplazar la gestión manual de URLs (Excel) con un sistema automático de descubrimiento y validación.

**Duración estimada**: 7-9 sesiones (~10-15 horas)

**Stack**: Requests + BeautifulSoup + APScheduler + PostgreSQL

---

## Fases de Implementación

### Fase 2.1: Crawler MVP (2-3 sesiones) 🎯
**Objetivo**: Probar concepto con 50 URLs

**Entregables:**
- ✅ Crawler básico que descubre URLs desde raíz
- ✅ Tabla `discovered_urls` con relaciones parent/child
- ✅ UI simple: lista de URLs descubiertas
- ✅ Rate limiting: 1 request/segundo
- ✅ Timeout: 10 segundos

**Criterio de éxito:**
- Descubre 50 URLs de prueba
- No crashea con enlaces malformados
- Respeta rate limiting

**NO hacer:**
- ❌ Detección de enlaces rotos
- ❌ Árbol navegable
- ❌ Automatización

---

### Fase 2.2: Validación (2 sesiones) 🔍
**Objetivo**: Detectar enlaces rotos

**Entregables:**
- ✅ `validator.py`: detectar 404, 500, timeouts
- ✅ Actualizar `discovered_urls`: status_code, is_broken
- ✅ Tabla `url_changes`: histórico de cambios
- ✅ Ruta `/crawler/broken`: filtro de enlaces rotos
- ✅ Badge sidebar: "Enlaces rotos: X"

**Criterio de éxito:**
- Identifica enlaces rotos correctamente
- Guarda histórico de cambios
- Badge actualizado en tiempo real

---

### Fase 2.3: Automatización (2 sesiones) 🤖
**Objetivo**: Crawl completo + cron + emails

**Entregables:**
- ✅ Quitar límite de 50 URLs
- ✅ `run_crawler.py`: script standalone para cron
- ✅ APScheduler: ejecutar 1x/día automáticamente
- ✅ Sistema de alertas: >10 enlaces rotos → alerta
- ✅ Template `emails/crawler_report.html`
- ✅ Envío automático de email con resumen

**Criterio de éxito:**
- Crawler corre 1x/día sin intervención
- Email enviado correctamente
- Alertas generadas cuando hay problemas

---

### Fase 2.4: UI Árbol (1-2 sesiones) 🌳
**Objetivo**: Dashboard visual atractivo

**Entregables:**
- ✅ Template `crawler/dashboard.html`: árbol navegable
- ✅ JavaScript: expand/collapse, resaltar rotos
- ✅ Filtros: solo rotos, por depth, por dominio
- ✅ Búsqueda: encontrar URL en árbol
- ✅ Botón "Re-crawl Now"
- ✅ Exportar árbol a JSON/CSV

**Criterio de éxito:**
- Árbol visualmente atractivo
- Fácil encontrar enlaces rotos
- Filtros funcionan correctamente

---

## Arquitectura Simplificada

### Nuevas Tablas BD
```sql
-- URLs descubiertas por crawler
discovered_urls (id, url, parent_url_id, depth, status_code, is_broken, ...)

-- Histórico de ejecuciones
crawl_runs (id, started_at, finished_at, urls_discovered, urls_broken, ...)

-- Cambios detectados
url_changes (id, url_id, change_type, detected_at, ...)
```

### Nuevos Archivos (~10 archivos)
```
crawler/
├── crawler.py      # Lógica de crawling (queue, visited, fetch)
├── validator.py    # Validación (status codes, timeouts)
├── scheduler.py    # APScheduler config
└── config.py       # Settings (root_url, max_depth, rate limit)

templates/crawler/
├── dashboard.html  # UI árbol navegable
└── results.html    # Lista simple de resultados

templates/emails/
└── crawler_report.html  # Email resumen

scripts/
└── run_crawler.py  # Script para cron job

migrations/
└── 002_add_crawler_tables.sql  # CREATE TABLE statements
```

---

## Principios Stage 2

### ✅ PERMITIDO
- Módulo `crawler/` separado (responsabilidad clara)
- Clases con estado (ej: Crawler con queue/visited)
- Nuevas dependencias: requests, beautifulsoup4, apscheduler
- <10 rutas nuevas en app.py

### ❌ PROHIBIDO
- Refactorizar app.py (solo si >1,500 líneas)
- Navegador headless (Playwright/Selenium)
- Machine Learning / IA
- Comparación de contenido HTML (Stage 3)
- Optimizaciones prematuras (async, cache)

---

## Métricas de Éxito

**Fase 2.1:**
- [ ] 50 URLs descubiertas desde raíz

**Fase 2.2:**
- [ ] Enlaces rotos identificados correctamente

**Fase 2.3:**
- [ ] Crawler corre automáticamente 1x/día
- [ ] Email enviado sin fallos

**Fase 2.4:**
- [ ] Árbol navegable fácil de usar
- [ ] Filtros funcionan

**Stage 2 Completo:**
- [ ] Reemplaza flujo manual del Excel
- [ ] Stage 1 sigue funcionando sin cambios
- [ ] 0 crashes en producción durante 1 semana

---

## Siguiente Paso

**Leer antes de empezar Fase 2.1:**
- `.claude/02-stage2-rules.md` - Arquitectura detallada y reglas
- `.claude/00-project-brief.md` - Contexto del proyecto

**Comando inicial:**
```bash
# Crear estructura básica
mkdir -p crawler templates/crawler templates/emails scripts migrations
touch crawler/__init__.py crawler/crawler.py crawler/config.py
```

---

## Recursos

**Documentación:**
- [Requests Docs](https://requests.readthedocs.io/)
- [BeautifulSoup Docs](https://www.crummy.com/software/BeautifulSoup/bs4/doc/)
- [APScheduler Docs](https://apscheduler.readthedocs.io/)

**Anti-Patterns a Evitar:**
- ❌ Crawler recursivo infinito → usar queue + visited set
- ❌ Requests sin timeout → siempre timeout=10
- ❌ Ignorar rate limiting → sleep(1) entre requests
- ❌ Crawlear sitios externos → validar dominio siempre
- ❌ Procesar todo en memoria → usar BD como queue

---

**Última actualización**: 2025-10-30
**Próximo paso**: Fase 2.1 - Crawler MVP con límite de 50 URLs
