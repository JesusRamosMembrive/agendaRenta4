# Guía de Validación de CTAs - Stage 5

## 📋 Resumen

Se ha implementado un sistema completo de validación de CTAs (Call-To-Action) que permite:
- Definir qué CTAs deben aparecer en cada tipo de página
- Validar automáticamente que los CTAs estén presentes y apunten a las URLs correctas
- Detectar errores en textos y URLs de los CTAs
- Generar reportes detallados de validación

## 🏗️ Arquitectura

### Base de Datos (3 tablas nuevas)

1. **`cta_page_types`** - Tipos de página (homepage, fondos, clientes, etc.)
2. **`cta_validation_rules`** - Reglas de validación (qué CTAs debe tener cada tipo)
3. **`cta_url_assignments`** - Asignación de URLs a tipos de página

### Código

- **`calidad/ctas.py`** - Clase `CTAChecker` que valida CTAs
- **`calidad/post_crawl_runner.py`** - Integración con el sistema de quality checks
- **`crawler/routes.py`** - Rutas `/cta-config` y `/cta-results`
- **Templates**:
  - `templates/crawler/cta_config.html` - Configuración de CTAs
  - `templates/crawler/cta_results.html` - Resultados de validación

## 🚀 Cómo Usar

### 1. Ver Configuración Actual

```bash
# Acceder en el navegador
http://localhost:5000/crawler/cta-config
```

Aquí verás:
- 8 tipos de página configurados (global, homepage, planes_pensiones, clientes, etc.)
- 9 reglas de validación (4 globales + 5 específicas)
- 0 URLs asignadas (por ahora)

### 2. Ejecutar Validación Manual

Desde el **Dashboard de Calidad** (`/crawler/quality`):

1. Selecciona "🎯 Validación de CTAs" en los checks disponibles
2. Elige el scope:
   - **priority**: Solo URLs prioritarias (~117 URLs)
   - **all**: Todas las URLs descubiertas (~2,800 URLs)
3. Haz clic en "Ejecutar Checks Seleccionados"

### 3. Ver Resultados

```bash
# Acceder en el navegador
http://localhost:5000/crawler/cta-results
```

Aquí verás:
- Resumen de validaciones (OK, warnings, errors)
- Lista de URLs validadas con detalles
- CTAs faltantes o incorrectos

## 📝 Reglas Configuradas (Seeding Inicial)

### Reglas Globales (aplican a TODAS las páginas)

| Texto Esperado | URL Esperada | Match Type | Prioridad | Opcional |
|----------------|--------------|------------|-----------|----------|
| Contratar | `https://www.r4.com/portal?TX=goto&FWD=CONT_LND&PAG=0` | exact | Crítico | No |
| Abre una cuenta | `https://www.r4.com/abrir-cuenta` | exact | Crítico | No |
| abrir cuenta | `https://www.r4.com/new?TX=goto&FWD=APERTURA-CUENTA` | contains | Alto | Sí |
| Área cliente | `https://www.r4.com/portal` | contains | Normal | Sí |

### Reglas Específicas por Tipo

**Homepage:**
- "Descubrir carteras Easy" → `https://www.r4.com/soluciones-easy/carteras-easy`
- "Ver promoción" → `https://www.r4.com/serviciosr4/` (contains)
- "Contactar con nosotros" → `https://www.r4.com/contacto`

**Fondos:**
- "Ver fondo" → `https://www.r4.com/fondos-de-inversion/fondos/` (contains)

**Contacto:**
- "contacta con un asesor" → `/contacto` (contains)

## 🧪 Pruebas

### Test Manual

```bash
# Ejecutar script de prueba
python test_cta_checker.py
```

Este script prueba el checker con las primeras 3 URLs de la tabla `sections`.

### Ejemplo de Resultado

```
✅ Check completed!
Status: ok
Score: 100/100
Message: All 2 required CTAs found and valid
Issues found: 0

📊 Details:
  Total rules: 4
  Required rules: 2
  Optional rules: 2
  CTAs found: 3

  ✅ Matched CTAs:
    - 'Abre una cuenta' → https://www.r4.com/abrir-cuenta
    - 'Contratar' → https://www.r4.com/portal?TX=goto&FWD=CONT_LND&PAG...
```

## 🔧 Cómo Añadir Nuevas Reglas

### Opción A: Manual (SQL)

```sql
-- 1. Crear nuevo tipo de página (si no existe)
INSERT INTO cta_page_types (name, description, url_pattern)
VALUES ('broker', 'Páginas de broker', '^https://www.r4.com/broker-online/');

-- 2. Añadir regla específica
INSERT INTO cta_validation_rules (
    page_type_id,
    is_global,
    expected_text,
    expected_url_pattern,
    url_match_type,
    is_optional,
    priority
)
SELECT
    id,
    FALSE,
    'Abrir cuenta de broker',
    'https://www.r4.com/broker-online/abrir-cuenta',
    'exact',
    FALSE,
    1
FROM cta_page_types WHERE name = 'broker';

-- 3. Asignar URLs al tipo
INSERT INTO cta_url_assignments (url_id, page_type_id, assigned_by)
SELECT
    du.id,
    pt.id,
    'manual'
FROM discovered_urls du
CROSS JOIN cta_page_types pt
WHERE du.url LIKE 'https://www.r4.com/broker-online/%'
  AND pt.name = 'broker';
```

### Opción B: Script Python

```python
from utils import get_db_connection

conn = get_db_connection()
cursor = conn.cursor()

# Añadir regla global
cursor.execute("""
    INSERT INTO cta_validation_rules (
        page_type_id,
        is_global,
        expected_text,
        expected_url_pattern,
        url_match_type,
        priority
    )
    SELECT id, TRUE, 'Nuevo CTA Global', 'https://example.com', 'exact', 1
    FROM cta_page_types WHERE name = 'global'
""")

conn.commit()
cursor.close()
conn.close()
```

## 🎯 Match Types Explicados

- **`exact`**: La URL debe coincidir exactamente
- **`contains`**: La URL esperada debe estar contenida en la URL encontrada
- **`regex`**: La URL se valida con expresión regular
- **`domain`**: Solo valida que el dominio coincida

## 📊 Casos de Uso

### 1. Validar que homepage tiene botón "Abrir cuenta"

Ya configurado como regla global con prioridad crítica.

### 2. Validar que páginas de fondos tienen botón "Ver fondo"

Ya configurado como regla específica para tipo `fondos`.

### 3. Detectar si CTA apunta a URL incorrecta

El checker detecta automáticamente si:
- El texto del CTA está presente
- Pero la URL no coincide con el patrón esperado

Reporta como "incorrect_urls" en los detalles.

## 🔄 Integración con Workflow Existente

El CTA checker se integra con el sistema de quality checks:

1. **Ejecución Automática**: Después de cada crawl (si está configurado)
2. **Ejecución Manual**: Desde el dashboard de calidad
3. **Scope**: priority (117 URLs) o all (~2,800 URLs)
4. **Resultados**: Se guardan en tabla `quality_checks`

## 📈 Próximos Pasos (Evolución a Opción B)

Para evolucionar a clasificación automática:

1. **Auto-clasificación por URL pattern**: Script que asigne URLs a tipos basándose en `url_pattern`
2. **ML-based detection**: Análisis de contenido para detectar tipo de página
3. **UI de gestión**: CRUD completo para page types, rules y assignments
4. **Aprendizaje**: Sugerir nuevos CTAs basándose en los encontrados frecuentemente

## 🐛 Troubleshooting

### No se encuentran CTAs

**Problema**: El checker reporta "No CTA validation rules configured for this URL"

**Solución**:
1. La URL no está en `discovered_urls` o
2. La URL no está asignada a ningún tipo de página

Para asignar:
```sql
INSERT INTO cta_url_assignments (url_id, page_type_id, assigned_by)
SELECT du.id, pt.id, 'manual'
FROM discovered_urls du
CROSS JOIN cta_page_types pt
WHERE du.url = 'https://www.r4.com/tu-url'
  AND pt.name = 'tu_tipo';
```

### CTAs no coinciden

**Problema**: El checker no encuentra un CTA que visualmente existe

**Causas posibles**:
1. El texto esperado no coincide exactamente (es case-insensitive y usa `contains`)
2. El CTA se carga dinámicamente con JavaScript (el checker solo analiza HTML estático)
3. El CTA usa clases CSS diferentes a las esperadas

**Solución**: Inspeccionar con `inspect_ctas.py` para ver cómo se estructura el CTA.

## 📁 Archivos Creados/Modificados

### Nuevos Archivos
```
migrations/001_create_cta_tables.sql          # Migración de tablas
scripts/seed_cta_rules.py                     # Script de seeding
calidad/ctas.py                               # CTAChecker class
inspect_ctas.py                               # Script de inspección
test_cta_checker.py                           # Script de pruebas
templates/crawler/cta_config.html             # Template configuración
templates/crawler/cta_results.html            # Template resultados
CTA_VALIDATION_GUIDE.md                       # Esta guía
```

### Archivos Modificados
```
calidad/post_crawl_runner.py                  # +180 líneas (integración)
crawler/routes.py                             # +115 líneas (rutas)
```

## ✅ Checklist de Implementación Completada

- [x] Diseño de base de datos (3 tablas)
- [x] Migraciones ejecutadas
- [x] Script de seeding con reglas globales
- [x] Implementación de CTAChecker
- [x] Integración con post_crawl_runner
- [x] Rutas en crawler blueprint
- [x] Templates de UI
- [x] Scripts de testing
- [x] Documentación

---

**Última actualización**: 2025-11-08
**Stage**: 5 - CTA Validation (MVP)
**Estado**: ✅ Implementación completa (Opción A)
