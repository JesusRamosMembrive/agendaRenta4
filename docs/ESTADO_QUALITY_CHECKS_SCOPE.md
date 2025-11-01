# Estado del Proyecto: Sistema de Quality Checks con Scopes

**Fecha**: 2025-11-01
**Fase**: Stage 3 - Implementación de sistema de calidad con scopes

---

## 🎯 Cambio de Paradigma

### Antes (Sistema Antiguo)
- Los quality checks dependían de la tabla `sections`
- No había forma de controlar el alcance de los tests
- Los tests se ejecutaban manualmente sobre secciones específicas
- Separación entre páginas descubiertas por el crawler y páginas testeadas

### Ahora (Nuevo Sistema)
- Los quality checks trabajan directamente con `discovered_urls` (tabla poblada por el crawler)
- **Dos modos de ejecución por tipo de test**:
  - **"Priority URLs"**: Solo URLs marcadas con `is_priority = TRUE` (~117 URLs)
  - **"Todas las URLs"**: Todas las URLs descubiertas (~2,839 URLs)
- Los tests se ejecutan **automáticamente después de cada crawl**
- Suite de tests configurable: enlaces rotos, imágenes, SEO, performance, accesibilidad
- Total desacoplamiento entre tests y secciones

---

## ✅ Implementado (Completado)

### 1. Base de Datos
- **Migración 009** (`migrations/009_add_discovered_url_to_quality_checks.sql`)
  - Añadida columna `discovered_url_id` a `quality_checks` (nullable, FK a `discovered_urls`)
  - Columna `section_id` ahora nullable (compatibilidad hacia atrás)
  - Constraint `check_url_source`: al menos uno de `section_id` o `discovered_url_id` debe existir
  - Añadida columna `scope` a `quality_check_config` (valores: 'all' | 'priority', default: 'priority')
  - Índices y constraints aplicados correctamente
  - ✅ **Migración aplicada a la base de datos**

### 2. Backend - `calidad/post_crawl_runner.py`
- **Método `get_configured_checks()`**: Retorna lista de checks con `check_type` y `scope`
- **Método `run_selected_checks_with_scope()`**: Ejecuta checks respetando el scope configurado
- **Método `_run_broken_links_check(scope)`**:
  - Query dinámico: añade `AND is_priority = TRUE` si scope='priority'
  - Filtra por `crawl_run_id`, `active = TRUE`
- **Método `_run_image_quality_check(scope)`**:
  - Query dinámico con filtro de scope
  - Guarda resultados con `discovered_url_id` (no `section_id`)
  - Filtra por `is_broken = FALSE` para evitar chequear URLs rotas
- **Función `update_user_check_config()`**: Acepta y guarda parámetro `scope`
- **Función `get_user_check_config()`**: Incluye `scope` en los resultados

### 3. Frontend - `templates/configuracion.html`
- **Radio buttons para scope** por cada tipo de check:
  - "Solo URLs Priority (117)"
  - "Todas las URLs (~2,800)"
- **Función `toggleCheckEnabled()`**: Habilita/deshabilita radio buttons según estado del toggle
- **Función `saveQualityChecksConfig()`**: Recopila valores de scope y envía al backend
- Diseño visual coherente con el resto de la UI

### 4. API - `crawler/routes.py`
- **Endpoint `/crawler/config/checks` (POST)**:
  - Acepta parámetro `scope` en el JSON
  - Llama a `update_user_check_config()` con scope
  - Documentación actualizada
- **Endpoint `/crawler/quality` (GET)**:
  - Query modificado con `LEFT JOIN` para `sections` y `discovered_urls`
  - Usa `COALESCE` para obtener URL de cualquier fuente
  - Soporta resultados tanto del sistema antiguo como del nuevo

### 5. Crawler - `crawler/crawler.py`
- **Bug fix en `save_discovered_url()` (líneas 201-211)**:
  - **PROBLEMA ENCONTRADO**: El `ON CONFLICT (url) DO UPDATE` solo actualizaba `last_checked`
  - **CONSECUENCIA**: URLs re-crawleadas mantenían `crawl_run_id` antiguo
  - **SOLUCIÓN**: Ahora también actualiza `crawl_run_id`, `depth`, y `parent_url_id`
  - Esto permite que cada crawl asocie las URLs con el nuevo `crawl_run_id`

---

## ❌ Problema Actual (Bloqueante)

### Los quality checks no se ejecutan después del crawl

**Síntoma**:
- Página `/crawler/quality` muestra "0 total checks"
- Post-crawl runner se ejecuta pero no procesa URLs

**Diagnóstico realizado**:
1. ✅ Migración aplicada correctamente
2. ✅ Configuración guardada (broken_links y image_quality habilitados con auto=True)
3. ✅ Crawl se ejecuta exitosamente (50 URLs descubiertas)
4. ✅ Post-crawl runner se invoca automáticamente
5. ❌ **URLs no se asocian correctamente al crawl_run_id actual**

**Evidencia en logs**:
```
2025-11-01 07:01:40,726 - Running 2 automatic checks: ['broken_links', 'image_quality']
2025-11-01 07:01:40,762 - broken_links: completed - No URLs to validate
2025-11-01 07:01:40,762 - image_quality: completed - No sections to check
```

**Estado de la BD**:
```sql
-- Crawl runs recientes existen
SELECT id, status, urls_discovered FROM crawl_runs ORDER BY id DESC LIMIT 3;
-- id | status    | urls_discovered
-- 7  | completed | 50
-- 6  | completed | 50
-- 5  | completed | 50

-- Pero discovered_urls no tiene registros para estos crawl_run_id
SELECT crawl_run_id, COUNT(*) FROM discovered_urls
WHERE crawl_run_id IN (5,6,7) GROUP BY crawl_run_id;
-- (0 rows)

-- URLs antiguas siguen con crawl_run_id viejos
SELECT crawl_run_id, COUNT(*) FROM discovered_urls GROUP BY crawl_run_id;
-- crawl_run_id | total
-- 1            | 50
-- 2            | 2789
```

**Causa raíz identificada**:
- El bug en `crawler.py:205` (ON CONFLICT) ya fue corregido
- Pero los crawls 5, 6, 7 se ejecutaron ANTES del fix
- Necesitamos un nuevo crawl DESPUÉS del fix para verificar que funciona

---

## 🔧 Solución Aplicada

**Archivo**: `crawler/crawler.py:201-211`

**Antes**:
```python
INSERT INTO discovered_urls (url, parent_url_id, depth, crawl_run_id, discovered_at)
VALUES (%s, %s, %s, %s, NOW())
ON CONFLICT (url) DO UPDATE
SET last_checked = NOW()
```

**Después**:
```python
INSERT INTO discovered_urls (url, parent_url_id, depth, crawl_run_id, discovered_at)
VALUES (%s, %s, %s, %s, NOW())
ON CONFLICT (url) DO UPDATE
SET
    last_checked = NOW(),
    crawl_run_id = EXCLUDED.crawl_run_id,
    depth = EXCLUDED.depth,
    parent_url_id = EXCLUDED.parent_url_id
```

**Efecto**: Ahora cada crawl actualiza el `crawl_run_id` de las URLs re-descubiertas, permitiendo que los quality checks encuentren las URLs del crawl actual.

---

## 📋 Tareas Pendientes

### INMEDIATO (Próxima sesión)
1. **Ejecutar un crawl completo DESPUÉS del fix**
   - Verificar que `discovered_urls` se actualiza con el nuevo `crawl_run_id`
   - Comprobar que quality checks encuentran URLs: `SELECT crawl_run_id, COUNT(*) FROM discovered_urls WHERE crawl_run_id = [nuevo_id]`

2. **Verificar ejecución de quality checks**
   - Confirmar que broken_links y image_quality se ejecutan
   - Revisar logs para mensajes de éxito (no "No URLs to validate")
   - Verificar que la tabla `quality_checks` se popula con `discovered_url_id`

3. **Probar resultados en UI**
   - Abrir `/crawler/quality` y verificar que muestra checks
   - Confirmar que estadísticas se calculan correctamente
   - Probar filtros por estado (OK, Warning, Error)

### MEDIO PLAZO
4. **Implementar sistema de Priority URLs**
   - Decidir cómo marcar URLs como `is_priority = TRUE`
   - Crear UI para seleccionar/deseleccionar priority URLs
   - Probar scope 'priority' vs 'all' en quality checks

5. **Optimización y batch processing**
   - Los checks de imagen pueden ser lentos en 2,839 URLs
   - Considerar procesamiento en background o por lotes
   - Añadir barra de progreso en UI

6. **Tests unitarios e integración**
   - Test para `PostCrawlQualityRunner` con ambos scopes
   - Test para crawler con ON CONFLICT actualizado
   - Test end-to-end: crawl → quality checks → resultados

### FUTURO
7. **Checks adicionales** (actualmente marcados como `available: False`)
   - SEO: meta tags, títulos, estructura
   - Performance: tiempos de carga, optimización
   - Accessibility: estándares WCAG

---

## 🔍 Comandos Útiles para Debugging

```bash
# Verificar estado de discovered_urls después de un crawl
PGPASSWORD=dev-password psql -h localhost -U jesusramos -d agendaRenta4 -c \
  "SELECT crawl_run_id, COUNT(*) as total,
          COUNT(CASE WHEN is_priority = TRUE THEN 1 END) as priority
   FROM discovered_urls
   GROUP BY crawl_run_id ORDER BY crawl_run_id DESC LIMIT 5;"

# Ver últimos crawl runs
PGPASSWORD=dev-password psql -h localhost -U jesusramos -d agendaRenta4 -c \
  "SELECT id, root_url, status, urls_discovered, started_at
   FROM crawl_runs ORDER BY id DESC LIMIT 5;"

# Ver quality checks guardados
PGPASSWORD=dev-password psql -h localhost -U jesusramos -d agendaRenta4 -c \
  "SELECT qc.id, qc.check_type, qc.status, qc.score,
          du.url, du.crawl_run_id
   FROM quality_checks qc
   LEFT JOIN discovered_urls du ON qc.discovered_url_id = du.id
   ORDER BY qc.id DESC LIMIT 10;"

# Ver configuración de usuario
PGPASSWORD=dev-password psql -h localhost -U jesusramos -d agendaRenta4 -c \
  "SELECT * FROM quality_check_config WHERE user_id = 1;"
```

---

## 📊 Arquitectura del Sistema

```
┌─────────────────────────────────────────────────────────────┐
│                      USUARIO CONFIGURA                       │
│  [Configuración] → Selecciona checks + scope (all/priority) │
└────────────────────────────┬────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                       CRAWLER EJECUTA                        │
│  [Crawler] → Descubre URLs → Guarda en discovered_urls     │
│              con crawl_run_id actual                         │
└────────────────────────────┬────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                  POST-CRAWL RUNNER (Auto)                    │
│  [PostCrawlQualityRunner] → Lee config de usuario          │
│                          → Filtra URLs por scope            │
│                          → Ejecuta checks                   │
└────────────────────────────┬────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                     QUALITY CHECKERS                         │
│  [ImagenesChecker] → Analiza imágenes → Guarda resultado   │
│  [URLValidator]    → Valida enlaces   → quality_checks     │
│                         (con discovered_url_id)             │
└────────────────────────────┬────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                    RESULTADOS EN UI                          │
│  [/crawler/quality] → Lee quality_checks                    │
│                    → JOIN con discovered_urls               │
│                    → Muestra estadísticas                   │
└─────────────────────────────────────────────────────────────┘
```

---

## 🗂️ Archivos Modificados

### Migración
- `migrations/009_add_discovered_url_to_quality_checks.sql` (NUEVO)

### Backend
- `calidad/post_crawl_runner.py` (MODIFICADO - múltiples métodos)
- `crawler/crawler.py` (BUG FIX - líneas 201-211)

### Frontend
- `templates/configuracion.html` (MODIFICADO - añadidos radio buttons y lógica JS)

### API
- `crawler/routes.py` (MODIFICADO - endpoints /config/checks y /quality)

---

## 💡 Notas Técnicas

### Por qué ON CONFLICT era problemático
La tabla `discovered_urls` tiene un UNIQUE constraint en `url`. Cuando el crawler re-descubre una URL:
- **Sin el fix**: Solo actualiza `last_checked`, manteniendo el `crawl_run_id` antiguo
- **Con el fix**: Actualiza `crawl_run_id`, `depth`, `parent_url_id` y `last_checked`

Esto es crucial porque los quality checks filtran por:
```sql
WHERE crawl_run_id = %s AND active = TRUE AND is_priority = TRUE/FALSE
```

Si las URLs mantienen `crawl_run_id` antiguos, los checks no encuentran nada.

### Compatibilidad hacia atrás
El sistema soporta tanto `section_id` (antiguo) como `discovered_url_id` (nuevo):
- CHECK constraint: `(section_id IS NOT NULL) OR (discovered_url_id IS NOT NULL)`
- Query con LEFT JOIN y COALESCE para ambas fuentes
- Migración sin pérdida de datos antiguos

---

## 📞 Próximos Pasos Sugeridos

1. **Ejecutar un crawl fresco** con el fix aplicado
2. **Monitorear logs** para confirmar que quality checks encuentran URLs
3. **Verificar tabla quality_checks** para ver registros con `discovered_url_id`
4. **Probar UI** en `/crawler/quality` para confirmar visualización
5. **Definir estrategia de Priority URLs** (¿cómo marcar is_priority=TRUE?)

---

**Estado**: ⏸️ En pausa - Pendiente de testing completo
**Confianza en el fix**: 🟢 Alta (bug identificado y corregido)
**Próxima acción**: Ejecutar crawl manual y verificar resultados
