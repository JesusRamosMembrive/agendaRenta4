# Stage 5 - CTA Validation: Progreso y Roadmap

**Fecha de inicio**: 2025-11-08
**Estado actual**: ✅ MVP Completado (Opción A - Manual)
**Próximo paso**: Asignación de URLs y validación inicial

---

## 📋 Tabla de Contenidos

1. [Resumen del Stage 5](#resumen-del-stage-5)
2. [Lo que Hemos Hecho](#lo-que-hemos-hecho)
3. [Estado Actual](#estado-actual)
4. [Lo que Falta por Hacer](#lo-que-falta-por-hacer)
5. [Roadmap de Evolución](#roadmap-de-evolución)
6. [Decisiones Técnicas](#decisiones-técnicas)

---

## Resumen del Stage 5

### Objetivo

Automatizar la validación de CTAs (Call-To-Action) que actualmente hace tu mujer manualmente. El sistema debe:

1. **Verificar presencia**: ¿Está el CTA en la página?
2. **Validar texto**: ¿El texto del CTA es el correcto?
3. **Validar URL**: ¿El CTA apunta a la URL correcta?
4. **Reportar errores**: ¿Qué CTAs faltan o están mal?

### Enfoque Implementado

**Opción A (MVP)**: Sistema basado en reglas configuradas manualmente en base de datos.

- ✅ **Ventaja**: Simple, funcional, extensible
- ⚠️ **Limitación**: Requiere configuración manual de reglas y asignaciones
- 🔄 **Evolución**: Puede migrar a Opción B (auto-clasificación) sin reescribir

---

## Lo que Hemos Hecho

### 1. ✅ Análisis e Investigación (2025-11-08)

**Script de Inspección**: `inspect_ctas.py`

Analizamos las primeras 5 URLs del sitio para entender la estructura de CTAs:

```
📊 Resultados del Análisis:
- URLs analizadas: 5
- CTAs encontrados: 46
- Promedio: 9.2 CTAs por página
- Clases CSS más comunes: btn, button, cta, r4-button, button-red
```

**Hallazgos clave**:
- CTAs globales (aparecen en todas): "Contratar", "Abre una cuenta"
- CTAs específicos por tipo: "Ver fondo", "Descubrir carteras Easy"
- Estructura HTML: Enlaces (`<a>`) con clases específicas
- URLs pueden ser relativas o absolutas

### 2. ✅ Base de Datos (2025-11-08)

**Migración**: `migrations/001_create_cta_tables.sql`

Creamos 3 tablas nuevas:

#### Tabla `cta_page_types` (Tipos de Página)
```sql
CREATE TABLE cta_page_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    url_pattern VARCHAR(255),  -- Para auto-clasificación futura
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Datos seeded**: 8 tipos de página
- `global` - CTAs que deben aparecer en todas las páginas
- `homepage` - Página principal
- `planes_pensiones` - Planes de pensiones
- `clientes` - Área de clientes
- `fondos` - Fondos de inversión
- `broker` - Plataforma broker
- `academia` - Formación y cursos
- `contacto` - Páginas de contacto

#### Tabla `cta_validation_rules` (Reglas de Validación)
```sql
CREATE TABLE cta_validation_rules (
    id SERIAL PRIMARY KEY,
    page_type_id INTEGER REFERENCES cta_page_types(id),
    is_global BOOLEAN DEFAULT FALSE,
    expected_text VARCHAR(255) NOT NULL,
    expected_url_pattern VARCHAR(500),
    url_match_type VARCHAR(20) DEFAULT 'exact',
    is_optional BOOLEAN DEFAULT FALSE,
    priority INTEGER DEFAULT 0,  -- 0=normal, 1=alto, 2=crítico
    ...
);
```

**Datos seeded**: 9 reglas de validación

**Reglas Globales (4)**:
| Texto | URL | Match | Opcional | Prioridad |
|-------|-----|-------|----------|-----------|
| Contratar | `portal?TX=goto&FWD=CONT_LND&PAG=0` | exact | No | Crítico |
| Abre una cuenta | `abrir-cuenta` | exact | No | Crítico |
| abrir cuenta | `APERTURA-CUENTA` | contains | Sí | Alto |
| Área cliente | `portal` | contains | Sí | Normal |

**Reglas Específicas (5)**:
- Homepage: "Descubrir carteras Easy", "Ver promoción", "Contactar con nosotros"
- Fondos: "Ver fondo"
- Contacto: "contacta con un asesor"

#### Tabla `cta_url_assignments` (Asignaciones)
```sql
CREATE TABLE cta_url_assignments (
    id SERIAL PRIMARY KEY,
    url_id INTEGER REFERENCES discovered_urls(id),
    page_type_id INTEGER REFERENCES cta_page_types(id),
    assigned_by VARCHAR(50) DEFAULT 'manual',
    confidence FLOAT DEFAULT 1.0,
    ...
);
```

**Estado actual**: 0 asignaciones (pendiente de hacer)

### 3. ✅ Backend - Quality Checker (2025-11-08)

**Archivo**: `calidad/ctas.py` (376 líneas)

Implementamos `CTAChecker` que hereda de `QualityCheck`:

**Características**:
- ✅ Extrae CTAs del HTML usando BeautifulSoup
- ✅ Compara contra reglas esperadas (globales + específicas del tipo)
- ✅ Valida presencia, texto y URL
- ✅ Soporta 4 tipos de match: exact, contains, regex, domain
- ✅ Genera score 0-100 según CTAs encontrados vs esperados
- ✅ Reporta: missing_required, missing_optional, incorrect_urls, matched_ctas

**Estrategias de detección**:
1. Por clases CSS comunes (`btn`, `button`, `cta`)
2. Por roles ARIA (`role="button"`)
3. Por keywords en texto (configurable)

### 4. ✅ Integración con Sistema de Quality Checks (2025-11-08)

**Archivo modificado**: `calidad/post_crawl_runner.py` (+180 líneas)

**Añadido**:
- `cta_validation` a `AVAILABLE_CHECKS`
- Método `_run_cta_validation_check(scope)` con:
  - Fetching concurrente de HTML
  - Ejecución paralela de checks (ThreadPoolExecutor)
  - Guardado batch de resultados
  - Logging de progreso

**Performance**:
- Soporta scope `priority` (117 URLs) o `all` (~2,800 URLs)
- Concurrencia configurable (`max_workers=10` por defecto)
- Reutiliza HTML cache entre checkers

### 5. ✅ Backend - Rutas (2025-11-08)

**Archivo modificado**: `crawler/routes.py` (+115 líneas)

**Rutas nuevas**:

#### `/crawler/cta-config` (GET)
- Muestra configuración de CTAs
- Lista page types, rules y assignment counts
- Template: `cta_config.html`

#### `/crawler/cta-results` (GET)
- Muestra resultados de validaciones
- Stats de últimos 7 días
- Últimas 100 validaciones con detalles
- Template: `cta_results.html`

### 6. ✅ Frontend - Templates (2025-11-08)

**Archivos creados**:

#### `templates/crawler/cta_config.html`
- Cards con resumen: page types, reglas, URLs asignadas
- Tabla de page types con descripción y patrón
- Tabla de reglas globales
- Accordion con reglas específicas por tipo
- Links rápidos a resultados y quality dashboard

#### `templates/crawler/cta_results.html`
- Cards con stats: total checks, OK, warnings, errors, avg score, issues
- Tabla con últimas 100 validaciones
- Botón "Ver Detalles" expandible para cada check
- Detalles muestran:
  - Estadísticas (total reglas, found CTAs, etc.)
  - CTAs faltantes (missing_required)
  - CTAs con URL incorrecta (incorrect_urls)
  - CTAs correctos (matched_ctas)

### 7. ✅ Scripts y Utilidades (2025-11-08)

#### `scripts/seed_cta_rules.py`
- Puebla las 3 tablas con datos iniciales
- 8 page types, 9 rules, 3 example assignments (no funcionaron porque URLs no están en discovered_urls)
- Ejecutado exitosamente

#### `inspect_ctas.py`
- Analiza estructura de CTAs en páginas web
- Genera `cta_analysis_results.json`
- Útil para debugging y descubrir nuevos CTAs

#### `test_cta_checker.py`
- Prueba el CTAChecker con URLs reales
- **Test exitoso**:
  - URL: `https://www.r4.com/planes-de-pensiones/categorias`
  - Status: `ok`, Score: `100/100`
  - Message: "All 2 required CTAs found and valid"

### 8. ✅ Documentación (2025-11-08)

**Archivos creados**:

#### `CTA_VALIDATION_GUIDE.md`
- Guía completa de uso
- Cómo ejecutar validaciones
- Cómo añadir reglas (SQL y Python)
- Match types explicados
- Troubleshooting
- Checklist de implementación

#### `docs/STAGE5_PROGRESS.md` (este archivo)
- Progreso detallado
- Roadmap
- Decisiones técnicas

---

## Estado Actual

### ✅ Completado (MVP Funcional)

- [x] Análisis de estructura de CTAs en sitio web
- [x] Diseño de base de datos (3 tablas)
- [x] Migraciones ejecutadas en PostgreSQL
- [x] Script de seeding con reglas globales y específicas
- [x] Implementación de `CTAChecker` class
- [x] Integración con `PostCrawlQualityRunner`
- [x] Rutas en crawler blueprint
- [x] Templates de UI (config y results)
- [x] Scripts de testing y utilidades
- [x] Documentación completa

### 🔧 Estado de Datos

| Tabla | Registros | Estado |
|-------|-----------|--------|
| `cta_page_types` | 8 | ✅ Seeded |
| `cta_validation_rules` | 9 | ✅ Seeded |
| `cta_url_assignments` | 0 | ⚠️ Pendiente |
| `quality_checks` (cta_validation) | 0 | ⚠️ Pendiente ejecutar |

### 🎯 Capabilities Actuales

El sistema YA PUEDE:
- ✅ Validar URLs individuales contra reglas configuradas
- ✅ Detectar CTAs faltantes
- ✅ Detectar CTAs con texto incorrecto
- ✅ Detectar CTAs con URL incorrecta
- ✅ Generar score de calidad (0-100)
- ✅ Ejecutarse manual o automáticamente post-crawl
- ✅ Soportar scope priority o all
- ✅ Mostrar configuración en UI
- ✅ Mostrar resultados en UI

### ⚠️ Limitaciones Actuales

El sistema NO PUEDE (aún):
- ❌ Asignar automáticamente URLs a page types (todo manual)
- ❌ Sugerir nuevos CTAs basándose en patrones
- ❌ Aprender de validaciones anteriores
- ❌ Editar reglas desde UI (requiere SQL)
- ❌ Gestionar page types desde UI

---

## Lo que Falta por Hacer

### 📋 Fase 1: Puesta en Marcha (Próximos Pasos Inmediatos)

#### 1. Asignar URLs a Page Types (CRÍTICO)

**Problema**: Tenemos 0 URLs asignadas → validaciones retornan "No rules configured"

**Solución**: Script para asignar las 117 URLs prioritarias a sus tipos correspondientes

**Script sugerido**: `scripts/assign_priority_urls_to_types.py`

```python
# Asignar automáticamente basándose en url_pattern
# Ejemplo:
# - URLs que contengan "/planes-de-pensiones/" → tipo 'planes_pensiones'
# - URLs que contengan "/fondos-de-inversion/" → tipo 'fondos'
# - URL exacta "https://www.r4.com/" → tipo 'homepage'
# - etc.
```

**Estimación**: 30 minutos de desarrollo + testing

#### 2. Ejecutar Validación Inicial en URLs Prioritarias

**Objetivo**: Obtener baseline de CTAs en las 117 URLs críticas

**Pasos**:
1. Asignar URLs a tipos (paso 1)
2. Ejecutar validación desde UI: `/crawler/quality` → CTA Validation → scope=priority
3. Revisar resultados en `/crawler/cta-results`
4. Documentar hallazgos (CTAs faltantes más comunes, etc.)

**Estimación**: 15 minutos de ejecución + 30 minutos de análisis

#### 3. Refinar Reglas Basándose en Resultados

**Objetivo**: Ajustar reglas para reducir falsos positivos/negativos

**Posibles ajustes**:
- Cambiar match type (exact → contains)
- Marcar CTAs como opcionales si fallan en muchas páginas legítimamente
- Añadir variaciones de texto ("Abre una cuenta" vs "Abrir cuenta")
- Ajustar patrones de URL

**Estimación**: 1-2 horas de ajustes iterativos

#### 4. Documentar Workflow para tu Mujer

**Objetivo**: Guía paso a paso de cómo usar el sistema

**Contenido**:
- Cómo ver resultados de validación
- Cómo interpretar errores
- Qué hacer cuando falta un CTA
- Cómo reportar falsos positivos

**Estimación**: 1 hora

### 📋 Fase 2: Mejoras de UX (Corto Plazo)

#### 5. Añadir CTA Validation al Dashboard de Calidad

**Archivo**: `templates/crawler/quality.html`

**Añadir**:
- Card de "🎯 Validación de CTAs" junto a otros checks
- Checkbox para habilitar/deshabilitar
- Selector de scope (priority/all)

**Estimación**: 30 minutos

#### 6. Mejorar Visualización de Resultados

**Mejoras sugeridas**:
- Filtros por status (OK/Warning/Error)
- Filtros por page type
- Ordenar por score, fecha, URL
- Export a Excel de CTAs faltantes
- Gráfico de tendencia (score promedio en el tiempo)

**Estimación**: 2-3 horas

#### 7. Añadir Links en Navegación Principal

**Archivo**: `templates/base.html`

**Añadir** en sección "🧪 Control de Calidad":
- Link a "Validación de CTAs" (`/crawler/cta-results`)
- Link a "Configuración CTAs" (`/crawler/cta-config`)

**Estimación**: 15 minutos

### 📋 Fase 3: Automatización (Medio Plazo)

#### 8. Auto-asignación de URLs a Page Types

**Objetivo**: Eliminar asignación manual

**Enfoque**:
1. Crear script que use `url_pattern` de cada page type
2. Hacer match con regex contra URLs en `discovered_urls`
3. Asignar automáticamente con `confidence < 1.0`
4. Permitir revisión manual de asignaciones con baja confidence

**Script**: `scripts/auto_assign_urls_to_types.py`

**Estimación**: 2-3 horas

#### 9. UI CRUD para Page Types

**Objetivo**: Gestionar tipos de página desde UI sin SQL

**Rutas nuevas**:
- `GET /crawler/cta-config/page-types` - Listar
- `POST /crawler/cta-config/page-types` - Crear
- `PUT /crawler/cta-config/page-types/<id>` - Editar
- `DELETE /crawler/cta-config/page-types/<id>` - Eliminar

**Template**: Formularios modales en `cta_config.html`

**Estimación**: 4-5 horas

#### 10. UI CRUD para Validation Rules

**Objetivo**: Gestionar reglas desde UI sin SQL

**Rutas nuevas**:
- `GET /crawler/cta-config/rules` - Listar
- `POST /crawler/cta-config/rules` - Crear
- `PUT /crawler/cta-config/rules/<id>` - Editar
- `DELETE /crawler/cta-config/rules/<id>` - Eliminar

**Template**: Formularios modales en `cta_config.html`

**Estimación**: 4-5 horas

#### 11. Ejecutar CTA Validation Automáticamente Post-Crawl

**Objetivo**: Validar CTAs después de cada crawl sin intervención manual

**Implementación**:
1. Ya está integrado en `PostCrawlQualityRunner`
2. Solo falta habilitarlo en configuración de usuario

**Pasos**:
```sql
-- Habilitar para user_id=1
INSERT INTO quality_check_config (user_id, check_type, enabled, run_after_crawl, scope)
VALUES (1, 'cta_validation', TRUE, TRUE, 'priority')
ON CONFLICT (user_id, check_type) DO UPDATE SET
    enabled = TRUE,
    run_after_crawl = TRUE;
```

**Estimación**: 5 minutos

### 📋 Fase 4: Inteligencia (Largo Plazo)

#### 12. Sistema de Sugerencias de CTAs

**Objetivo**: Sugerir nuevos CTAs basándose en patrones

**Enfoque**:
- Analizar CTAs encontrados en múltiples páginas del mismo tipo
- Si un CTA aparece en >80% de páginas de un tipo, sugerirlo como regla
- UI para revisar y aprobar sugerencias

**Estimación**: 1-2 días

#### 13. Aprendizaje de Variaciones de Texto

**Objetivo**: Detectar variaciones legítimas de CTAs

**Ejemplo**:
- "Abre una cuenta" ≈ "Abrir cuenta" ≈ "Apertura de cuenta"
- Usar fuzzy matching o embeddings

**Estimación**: 2-3 días

#### 14. Detección de CTAs Dinámicos (JavaScript)

**Objetivo**: Validar CTAs que se cargan con JavaScript

**Enfoque**:
- Integrar Playwright/Selenium
- Esperar a que página cargue completamente
- Extraer CTAs del DOM renderizado

**Limitación**: Más lento, más recursos

**Estimación**: 3-4 días

---

## Roadmap de Evolución

### Versión 1.0 - MVP Manual (ACTUAL ✅)
**Completado**: 2025-11-08
- Validación básica con reglas manuales
- Asignación manual de URLs
- UI de visualización

### Versión 1.1 - Operacional (Próximos 1-2 días)
**Objetivo**: Sistema usable por tu mujer
- Asignar 117 URLs prioritarias a tipos
- Ejecutar validación inicial
- Refinar reglas basándose en resultados
- Documentar workflow de usuario

### Versión 1.5 - Semi-automático (Próximas 1-2 semanas)
**Objetivo**: Reducir trabajo manual
- Auto-asignación de URLs basada en patrones
- CRUD UI para page types y rules
- Ejecución automática post-crawl
- Mejoras de UX en resultados

### Versión 2.0 - Inteligente (Futuro)
**Objetivo**: Sistema que aprende y sugiere
- Sugerencias de nuevos CTAs
- Detección de variaciones de texto
- Soporte para CTAs dinámicos (JavaScript)
- Analytics y tendencias

---

## Decisiones Técnicas

### Decisión 1: Base de Datos vs Archivos de Configuración

**Elegido**: Base de datos (PostgreSQL)

**Razones**:
- ✅ Más flexible para añadir/editar reglas
- ✅ Permite UI CRUD en el futuro
- ✅ Integración natural con sistema existente
- ✅ Soporta queries complejas (reglas globales + específicas)
- ✅ Facilita auto-asignación con SQL

**Alternativa descartada**: JSON/YAML
- ❌ Requiere editar archivos manualmente
- ❌ No escalable para muchas reglas
- ❌ Difícil de consultar programáticamente

### Decisión 2: Opción A (Manual) vs Opción B (Auto)

**Elegido**: Empezar con Opción A, evolucionar a B

**Razones**:
- ✅ MVP más rápido (1 día vs 1 semana)
- ✅ Validar concepto antes de invertir en ML
- ✅ Arquitectura permite evolución sin reescribir
- ✅ Más control inicial sobre reglas

**Plan de migración a B**: Fase 3 y 4 del roadmap

### Decisión 3: Match Types Soportados

**Elegidos**: exact, contains, regex, domain

**Razones**:
- `exact`: Para URLs fijas ("https://www.r4.com/abrir-cuenta")
- `contains`: Para URLs con parámetros ("portal?TX=goto&...")
- `regex`: Para patrones complejos ("fondos/[A-Z0-9]+")
- `domain`: Para validar solo dominio (útil para links externos)

**Flexibilidad**: Cubre 95% de casos de uso

### Decisión 4: HTML Estático vs JavaScript Rendering

**Elegido**: HTML estático (BeautifulSoup)

**Razones**:
- ✅ Más rápido (no requiere browser headless)
- ✅ Menos recursos (CPU, memoria)
- ✅ Suficiente para la mayoría de CTAs en r4.com
- ✅ Puede ejecutarse en paralelo fácilmente

**Plan futuro**: Añadir soporte Playwright en Versión 2.0 para casos específicos

### Decisión 5: Scope Priority vs All

**Elegido**: Soportar ambos, default a priority

**Razones**:
- `priority` (117 URLs): Rápido (~5 min), cubre URLs críticas
- `all` (~2,800 URLs): Completo pero lento (~30 min)
- Usuario elige según necesidad

**Uso recomendado**:
- Daily: priority
- Weekly: all

### Decisión 6: Integración con Quality Checks vs Módulo Separado

**Elegido**: Integrar con sistema de quality checks existente

**Razones**:
- ✅ Reutiliza infraestructura (HTML fetching, concurrencia, DB schema)
- ✅ UI consistente con otros checks
- ✅ Configuración unificada (scope, auto-run)
- ✅ Reportes centralizados en `quality_checks` table

**Alternativa descartada**: Módulo separado
- ❌ Duplicaría código
- ❌ UI fragmentada
- ❌ Más complejo de mantener

---

## Métricas de Éxito

### KPIs para Versión 1.1 (Operacional)

- [ ] 100% de URLs prioritarias asignadas a page types
- [ ] Primera validación ejecutada sin errores técnicos
- [ ] Score promedio de validación documentado (baseline)
- [ ] Tu mujer puede interpretar resultados sin ayuda

### KPIs para Versión 1.5 (Semi-automático)

- [ ] >90% de URLs auto-asignadas correctamente
- [ ] Tiempo de configuración <10 min para nuevo page type
- [ ] Validaciones post-crawl ejecutándose automáticamente
- [ ] Reducción 50% de tiempo manual de validación de CTAs

### KPIs para Versión 2.0 (Inteligente)

- [ ] Sistema sugiere 3+ nuevos CTAs relevantes por semana
- [ ] <5% falsos positivos en detección
- [ ] Soporte para CTAs JavaScript en páginas críticas
- [ ] Reducción 80% de tiempo manual de validación de CTAs

---

## Archivos Clave para Referencia

### Base de Datos
```
migrations/001_create_cta_tables.sql        # Esquema de tablas
scripts/seed_cta_rules.py                   # Datos iniciales
```

### Backend
```
calidad/ctas.py                             # CTAChecker class
calidad/post_crawl_runner.py                # Integración (líneas 67-106, 271, 650-815)
crawler/routes.py                           # Rutas (líneas 1205-1315)
```

### Frontend
```
templates/crawler/cta_config.html           # Configuración UI
templates/crawler/cta_results.html          # Resultados UI
```

### Utilidades
```
inspect_ctas.py                             # Analizar CTAs en páginas
test_cta_checker.py                         # Probar checker
```

### Documentación
```
CTA_VALIDATION_GUIDE.md                     # Guía de uso completa
docs/STAGE5_PROGRESS.md                     # Este archivo
```

---

## Comandos Útiles

### Base de Datos

```bash
# Ver page types configurados
PGPASSWORD=dev-password psql -h localhost -U jesusramos -d agendarenta4 \
  -c "SELECT * FROM cta_page_types ORDER BY name;"

# Ver reglas de validación
PGPASSWORD=dev-password psql -h localhost -U jesusramos -d agendarenta4 \
  -c "SELECT expected_text, is_global, is_optional FROM cta_validation_rules;"

# Ver asignaciones de URLs
PGPASSWORD=dev-password psql -h localhost -U jesusramos -d agendarenta4 \
  -c "SELECT COUNT(*) FROM cta_url_assignments;"

# Ver resultados de validaciones
PGPASSWORD=dev-password psql -h localhost -U jesusramos -d agendarenta4 \
  -c "SELECT status, COUNT(*) FROM quality_checks WHERE check_type='cta_validation' GROUP BY status;"
```

### Testing

```bash
# Probar checker con URLs de ejemplo
python test_cta_checker.py

# Inspeccionar CTAs en página específica
# (modificar URLs en inspect_ctas.py primero)
python inspect_ctas.py

# Re-seed reglas (si se modificaron)
python scripts/seed_cta_rules.py
```

### Ejecución

```bash
# Iniciar aplicación
python app.py

# Acceder a configuración
# http://localhost:5000/crawler/cta-config

# Acceder a resultados
# http://localhost:5000/crawler/cta-results

# Ejecutar validación desde UI
# http://localhost:5000/crawler/quality
```

---

## Próximas Sesiones de Desarrollo

### Sesión 1: Asignación de URLs (Estimación: 1 hora)

**Objetivos**:
1. Crear `scripts/assign_priority_urls_to_types.py`
2. Ejecutar script para asignar 117 URLs
3. Verificar asignaciones en DB

**Output**: 117 registros en `cta_url_assignments`

### Sesión 2: Primera Validación (Estimación: 1 hora)

**Objetivos**:
1. Ejecutar validación desde UI (scope=priority)
2. Revisar resultados en `/crawler/cta-results`
3. Documentar problemas encontrados
4. Crear lista de ajustes necesarios

**Output**: Baseline de CTAs + lista de TODOs

### Sesión 3: Refinamiento de Reglas (Estimación: 2 horas)

**Objetivos**:
1. Ajustar reglas basándose en resultados
2. Añadir variaciones de texto si necesario
3. Marcar CTAs opcionales donde corresponda
4. Re-ejecutar validación

**Output**: Score promedio >80/100 en URLs prioritarias

### Sesión 4: UX y Automatización (Estimación: 3 horas)

**Objetivos**:
1. Añadir CTA validation a quality dashboard
2. Habilitar ejecución automática post-crawl
3. Mejorar visualización de resultados (filtros, ordenamiento)
4. Documentar workflow para usuario final

**Output**: Sistema listo para uso productivo

---

## Notas Finales

### Por qué este Enfoque Funciona

1. **Incremental**: MVP funcional en 1 día, mejoras graduales
2. **Extensible**: Arquitectura permite evolución sin reescribir
3. **Pragmático**: Resuelve problema real con mínima complejidad
4. **Integrado**: Aprovecha sistema existente (quality checks)
5. **Documentado**: Guías y roadmap para futuras iteraciones

### Compatibilidad con Filosofía del Proyecto

- ✅ **Simplicity > Completeness**: MVP manual antes que sistema complejo
- ✅ **Stage-based Evolution**: Opción A → B según necesidad real
- ✅ **Pain-driven Development**: Solo automatizar cuando trabajo manual sea evidente
- ✅ **No premature optimization**: BeautifulSoup suficiente, Playwright solo si necesario

### Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Falsos positivos (CTAs marcados como faltantes cuando existen) | Media | Alto | Refinar reglas iterativamente, usar fuzzy matching |
| CTAs dinámicos no detectados | Media | Medio | Documentar limitación, añadir Playwright en v2.0 |
| Asignaciones incorrectas de URLs a tipos | Media | Medio | Review manual de auto-asignaciones con baja confidence |
| Reglas obsoletas (sitio cambia) | Baja | Medio | Monitorear tendencias en validaciones, alertar si score baja |

---

**Última actualización**: 2025-11-08
**Autor**: Claude Code
**Review**: Pendiente
**Próxima revisión**: Después de Sesión 1 (asignación URLs)
