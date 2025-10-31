# Maintenance Log

## 2025-10-31 - BASELINE Before Stage 3

### 📊 Métricas Iniciales

**Archivos Python más grandes:**
- ✅ `app.py`: **1,647 líneas** - ⚠️ CRÍTICO (debe reducirse a <1,000)
- ✅ `generate_excel_report.py`: 486 líneas
- ✅ `crawler/crawler.py`: 362 líneas
- ✅ `sync_postgres_to_postgres.py`: 320 líneas
- ✅ `crawler/scheduler.py`: 312 líneas
- Total: 6,942 líneas de código Python

**Complejidad ciclomática (funciones ≥C):**
- ⚠️ `generate_excel_report.py:create_excel_report()` - **E** (muy compleja)
- ⚠️ `export_broken_links.py:export_broken_links_txt()` - **D** (compleja)
- ⚠️ 12 funciones con complejidad **C** (moderada):
  - `app.py:check_alert_day()` - C
  - `app.py:send_email_notifications()` - C
  - `crawler/crawler.py:Crawler.crawl()` - C
  - `sync_postgres_to_postgres.py:get_table_schema()` - C
  - `sync_postgres_to_postgres.py:main()` - C
  - `create_tasks_for_period.py:create_tasks_for_period()` - C
  - `manage_users.py:main()` - C
  - `analyze_typos.py:generate_report()` - C
  - `explore_excel.py:explore_excel()` - C
  - `full_crawl_and_compare.py:compare_urls()` - C
  - `load_sections.py:load_sections_from_excel()` - C
  - `load_sections.py:generate_section_name()` - C

**Imports no usados:**
- ✅ **NINGUNO** - Código limpio

**Código muerto (dead code):**
- ⚠️ `app.py:23` - Import no usado: `PERIODICITIES` (90% confidence)
- ⚠️ `generate_excel_report.py:12` - Import no usado: `get_column_letter` (90% confidence)
- ⚠️ `sync_postgres_to_postgres.py:214` - Import no usado: `subprocess` (90% confidence)

**Errores de estilo (flake8 en app.py):**
- 19 errores de indentación (E128)
- 2 errores de espaciado (E302)
- 2 imports no al principio (E402)
- 4 imports no usados de werkzeug (F401)
- 1 variable indefinida: `logger` (F821)
- 1 falta newline al final (W292)
- **Total: 29 issues**

---

### ✅ Qué Funciona Bien

1. **Sin imports no usados** (autoflake clean)
2. **Código Python en general limpio** (solo 3 dead code warnings)
3. **Estructura modular** - crawler/, templates/, migrations/ bien organizados
4. **Stage 2 completo y funcional** en producción
5. **Testing scripts** - test_scheduler.py, test_email.py funcionando

---

### ⚠️ Qué Debe Mejorar

#### 🔴 CRÍTICO - Debe hacerse en Phase 3.0

1. **app.py tiene 1,647 líneas** (debe reducirse a <1,000)
   - **Acción**: Mover lógica del crawler a `crawler/engine.py`
   - **Acción**: Extraer rutas de configuración a blueprint separado
   - **Meta**: Reducir a ~1,000 líneas (reducción de 647 líneas)

2. **Complejidad ciclomática alta en funciones clave**
   - `generate_excel_report.py:create_excel_report()` - **E** (muy compleja)
   - **Acción**: Dividir en subfunciones (create_sheet_X, format_sheet_X)
   - `export_broken_links.py:export_broken_links_txt()` - **D**
   - **Acción**: Extraer lógica de formateo a funciones separadas

3. **Errores de estilo en app.py** (29 issues)
   - **Acción**: Ejecutar `black app.py --line-length=120`
   - **Acción**: Corregir variable indefinida `logger`
   - **Acción**: Eliminar imports no usados de werkzeug

#### 🟡 MEDIO - Puede hacerse durante Phase 3.0

4. **Dead code warnings** (3 imports no usados)
   - `app.py:23` - `PERIODICITIES`
   - `generate_excel_report.py:12` - `get_column_letter`
   - `sync_postgres_to_postgres.py:214` - `subprocess`
   - **Acción**: Eliminar o usar estos imports

5. **Funciones con complejidad C** (12 funciones)
   - **Decisión**: Evaluar caso por caso durante refactoring
   - **Prioridad**: Solo refactorizar si se modifican en Stage 3

---

### 📋 Plan de Acción para Phase 3.0 (1 semana)

**Objetivo**: Preparar arquitectura modular antes de añadir 8 checkers de calidad

**Tareas obligatorias:**

1. **Refactorizar app.py** (Día 1-2)
   - [ ] Mover crawler routes a `crawler/routes.py` blueprint
   - [ ] Mover lógica de crawler a `crawler/engine.py`
   - [ ] Extraer configuración routes a `config/routes.py` blueprint
   - [ ] **Verificar**: app.py <1,000 líneas

2. **Crear módulo calidad/** (Día 3)
   - [ ] Crear `calidad/__init__.py`
   - [ ] Crear `calidad/base.py` con clase `QualityCheck`
   - [ ] Crear `calidad/enlaces.py` migrando lógica existente del crawler

3. **Base de datos** (Día 4)
   - [ ] Crear `migrations/006_add_quality_checks_table.sql`
   - [ ] Ejecutar migración en local
   - [ ] Verificar con queries de prueba

4. **Limpieza de código** (Día 5)
   - [ ] Ejecutar `black . --line-length=120`
   - [ ] Eliminar 3 imports no usados (dead code)
   - [ ] Corregir variable `logger` indefinida
   - [ ] Simplificar `generate_excel_report.py:create_excel_report()` (E→C)

5. **Testing** (Día 5-6)
   - [ ] Verificar que toda la funcionalidad existente sigue funcionando
   - [ ] Ejecutar test_scheduler.py
   - [ ] Probar todas las rutas del crawler
   - [ ] Confirmar que no hay regresiones

6. **Documentación** (Día 7)
   - [ ] Actualizar README.md con nueva estructura
   - [ ] Crear DECISIONS.md con decisiones de arquitectura
   - [ ] Actualizar .claude/01-current-phase.md

---

### 🎯 Metas de Phase 3.0

**Código:**
- ✅ app.py <1,000 líneas (actualmente 1,647)
- ✅ Complejidad máxima C (eliminar E y D)
- ✅ Zero dead code warnings
- ✅ Zero errores de flake8 (actualmente 29)

**Arquitectura:**
- ✅ Módulo `calidad/` creado con estructura modular
- ✅ Módulo `crawler/` refactorizado (crawler.py → engine.py)
- ✅ Blueprints para routes (crawler, config)
- ✅ Tabla `quality_checks` en base de datos

**Testing:**
- ✅ Toda funcionalidad existente sigue funcionando
- ✅ Zero regresiones

---

### 📈 Comparación con Thresholds del MAINTENANCE_CHECKLIST.md

| Métrica | Actual | Threshold | Estado |
|---------|--------|-----------|--------|
| app.py líneas | **1,647** | <1,000 | ❌ CRÍTICO |
| Archivo más grande | 1,647 líneas | <500 | ❌ CRÍTICO |
| Complejidad máxima | **E** | ≤B | ❌ CRÍTICO |
| Dead code warnings | 3 | 0 | ⚠️ MEDIO |
| Errores flake8 | 29 | 0 | ⚠️ MEDIO |
| Imports no usados | 0 | 0 | ✅ OK |

**Veredicto**: 🔴 **REFACTORING OBLIGATORIO antes de continuar**

---

### 💡 Decisiones Tomadas

**Decisión #1: ¿Refactorizar ahora o después?**
- **Opción elegida**: AHORA (Phase 3.0)
- **Razón**: app.py con 1,647 líneas es inmanejable para añadir 6 fases más de código
- **Trade-off**: Dedicar 1 semana a refactoring retrasa features, pero evita "spaghetti code"

**Decisión #2: ¿Blueprints de Flask o mantener app.py monolítico?**
- **Opción elegida**: Blueprints para crawler y config
- **Razón**: Separación de responsabilidades, más fácil de mantener
- **Trade-off**: Añade complejidad de imports, pero mejora organización

**Decisión #3: ¿Refactorizar generate_excel_report.py (E complexity)?**
- **Opción elegida**: SÍ, durante Phase 3.0
- **Razón**: Función con complejidad E es inaceptable, difícil de mantener
- **Trade-off**: Tiempo extra, pero necesario para salud del código

**Decisión #4: ¿Ejecutar black y autoflake automáticamente?**
- **Opción elegida**: SÍ, formatear todo el código en Phase 3.0
- **Razón**: Consistencia de estilo, elimina 29 errores de flake8
- **Trade-off**: Cambios masivos en git diff, pero mejora legibilidad

---

### 🔄 Próximo Maintenance Check

**Fecha estimada**: 2025-11-08 (después de completar Phase 3.0)
**Expectativa**:
- app.py <1,000 líneas
- Zero complejidad E o D
- Zero errores flake8
- Estructura modular lista para añadir checkers

---

**Documento creado**: 2025-10-31
**Autor**: Claude Code + Jesús Ramos
**Estado**: BASELINE - Pre Stage 3
