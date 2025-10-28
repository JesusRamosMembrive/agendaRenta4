# Análisis del Excel Original

**Fecha**: 2025-10-28
**Archivo**: `original-data/251028_Árbol web - control calidad.xlsx`
**Estado**: Fase 0 - Exploración completada

---

## 📊 Resumen Ejecutivo

El Excel contiene **dos pestañas** con información sobre el control de calidad del sitio web del banco:

1. **"Actualización y calidad"** - Pestaña principal con tracking detallado de revisiones
2. **"Tráfico y SEO"** - Pestaña secundaria con métricas de tráfico y decisiones de eliminación

**Hallazgo clave**: El sistema actual ya trackea **periodicidad de revisiones** (Mensual, Semanal, Trimestral, Semestral, Anual) en la columna **"Tiempo revisión contenido"**.

**⚠️ ACTUALIZACIÓN IMPORTANTE**: Después de validación con usuario:
- No son 2 tipos de revisiones → Son **8 tipos de tareas únicas y separadas**
- Cada tipo puede tener **periodicidad independiente** por sección
- Ejemplo: "Enlaces Rotos" semanal, "Información Actualizada" mensual para misma sección

---

## 📋 Pestaña 1: "Actualización y calidad"

### Dimensiones
- **Filas**: 1,048,526 (probablemente muchas vacías - Excel tiene límite de 1M+ filas)
- **Columnas**: 25
- **Filas con datos reales**: ~50-100 (estimado, basado en muestra)

### Estructura de Columnas

#### 🌳 Jerarquía de Navegación (Cols 1-6)
```
Col 1: Nº - Número de fila
Col 2: NIVELES DE NAVEGACIÓN - Nivel 1 (ej: "R4")
Col 3: [Vacía_3] - Nivel 2 (ej: "ANÁLISIS E IDEAS")
Col 4: [Vacía_4] - Nivel 3 (ej: "CATEGORÍAS")
Col 5: [Vacía_5] - Nivel 4 (ej: "BOLSAS")
Col 6: [Vacía_6] - Nivel 5 (ej: "QUÉ SON CFDS")
```

**Interpretación**: El sitio tiene hasta 5 niveles de jerarquía. Cada fila representa una página del sitio.

**Ejemplo de jerarquía**:
```
R4 → BRÓKER → BOLSAS → DIVIDENDO → QUÉ SON ETFS
```

---

#### 🔗 Identificación de Página (Cols 7-10)

```
Col 7: URL - https://www.r4.com/...
Col 8: Tráfico - Número de visitas o "-" si no hay datos
Col 9: Clics - Número de clics o "-"
Col 10: CTR - Fórmula =I2/H2 (Click Through Rate)
```

**Observación**: La URL es el identificador único de cada página.

---

#### ✅ Revisión de Erratas/Enlaces (Cols 11-14)

```
Col 11: Revisión de erratas/enlaces - Boolean (True/False)
Col 12: Última revisión - Fecha (2025-07-30, 2025-08-05, etc.)
Col 13: Actualizado por - Nombre ("Jose Ruiz")
Col 14: Revisado por - Nombre ("Jose Ruiz")
```

**Significado**:
- `True` en Col 11 → Esta página necesita revisión de erratas/enlaces
- Cols 12-14 → Tracking de cuándo y quién hizo la última revisión

**Uso en el task manager**:
- Esto podría ser un **tipo de tarea**: "Revisar erratas/enlaces"
- Las páginas marcadas `True` son candidatas para tareas

---

#### 📝 Revisión de Contenidos (Cols 15-20)

```
Col 15: Necesidad actualización contenido - Boolean (True/False)
Col 16: Tiempo revisión contenido - ⭐ PERIODICIDAD: "Mensual", "Semanal", "Trimestral", "Semestral", "Anual"
Col 17: Revisión contenidos - Boolean (True/False)
Col 18: Última revisión - Fecha
Col 19: Actualizado por - Nombre
Col 20: Revisado por - Nombre
```

**⭐ Columna clave: "Tiempo revisión contenido" (Col 16)**

Valores encontrados (primeras 50 filas):
- **"Mensual"** - Revisar cada mes
- **"Semanal"** - Revisar cada semana
- **"Trimestral"** - Revisar cada 3 meses
- **"Semestral"** - Revisar cada 6 meses
- **"Anual"** - Revisar cada año

**Uso en el task manager**:
- Esta columna define la **frecuencia de activación** de tareas
- Ejemplo: Si "Renta Fija" tiene "Mensual" → crear tarea cada mes

---

#### 🗂️ Metadata (Cols 21-25)

```
Col 21: Acceso a este contenido - Cómo se accede ("Menú", "Footer", "Login", etc.)
Col 22: ¿Eliminar? - Boolean (True/False)
Col 23: Comentarios - Texto libre (ej: "Actualizar el boletín de renta fija")
Col 24: Categoria - (Vacía en muestra)
Col 25: Subcategoría - (Vacía en muestra)
```

**Observación**: Los comentarios pueden ser útiles para pre-popular el campo de observaciones.

---

### Ejemplos de Filas Reales

**Fila 2:**
```
CATEGORÍAS
https://www.r4.com/planes-de-pensiones/categorias
Revisión de erratas/enlaces: False
Revisión contenidos: False
Tiempo revisión contenido: (vacío)
```

**Fila con periodicidad:**
```
Página: X
URL: https://www.r4.com/...
Revisión de erratas/enlaces: True
Tiempo revisión contenido: Mensual  ← Esto define que se revisa cada mes
Última revisión: 2025-08-05
```

---

## 📋 Pestaña 2: "Tráfico y SEO"

### Dimensiones
- **Filas**: 272
- **Columnas**: 11

### Estructura de Columnas

```
Col 1: NIVELES DE NAVEGACIÓN - Nivel 1
Col 2-5: [Vacías] - Niveles 2-5 de jerarquía
Col 6: URL - https://www.r4.com/...
Col 7: Tráfico - Número de visitas
Col 8: Posicionamiento - (Vacía en muestra)
Col 9: ¿Eliminar? - Boolean
Col 10-11: Categoria, Subcategoría - (Vacías)
```

**Propósito**: Esta pestaña parece ser más para **métricas de SEO** y **decisiones de eliminación** de páginas con poco tráfico.

**Relación con task manager**: Probablemente no es prioritaria para el MVP. Podría ser útil en Stage 2 para priorizar revisiones (revisar primero páginas con más tráfico).

---

## 🔑 Hallazgos Clave

### 1. Periodicidad de Revisiones ✅

**Columna**: "Tiempo revisión contenido" (Col 16 de pestaña 1)

**Valores**:
- Semanal
- Mensual
- Trimestral
- Semestral
- Anual

**Implicación**: Ya existe un sistema de periodicidad. No hay que inventarlo.

---

### 2. Ocho Tipos de Tareas Únicas ✅ VALIDADO

**⚠️ Actualización después de validación con usuario**:

**NO son 2 tipos de revisiones** → Son **8 tipos de tareas separadas**:

1. **Enlaces rotos** - Verificar links funcionan
2. **Enlaces incorrectos** - Verificar links apuntan a destino correcto
3. **Textos - erratas** - Revisar ortografía y gramática
4. **Información actualizada** - Verificar datos están al día
5. **Preguntas frecuentes** - Revisar FAQs son relevantes
6. **CTAs** - Verificar calls-to-action funcionan
7. **Imágenes** - Verificar imágenes cargan correctamente
8. **Diseño** - Verificar layout y responsive

**Clave**: Cada tipo puede tener **periodicidad independiente** por sección.

**Ejemplo real**:
- Sección "Renta Fija":
  - "Enlaces Rotos" → Semanal (cada lunes)
  - "Información Actualizada" → Mensual (día 1)
  - "Diseño" → Trimestral (día 1 de enero/abril/julio/octubre)

**Implicación para BD**: Necesitamos tabla `task_types` + `section_task_config` para mapear qué tipos aplican a qué secciones con qué frecuencia.

---

### 3. Identificación de Secciones

**Cada fila del Excel = Una página del sitio web**

**Identificador único**: URL (Col 7)

**Nombre de sección**: Podemos usar el nivel más profundo de la jerarquía o la URL

Ejemplo:
```
Jerarquía: FONDOS Y PLANES R4 → CATEGORÍAS
URL: https://www.r4.com/planes-de-pensiones/categorias
Nombre sugerido: "Planes de Pensiones - Categorías"
```

---

### 4. Tracking de Quién y Cuándo

El Excel ya trackea:
- **Última revisión** (fecha)
- **Actualizado por** (nombre)
- **Revisado por** (nombre)

**Implicación**: El task manager debe preservar esta información. En Stage 2, añadir multi-usuario.

---

## 💾 Mapeo a Base de Datos (Actualizado)

**⚠️ Arquitectura actualizada**: Soporta 8 tipos de tareas con periodicidades independientes.

### Tabla 1: `sections`

Cada fila del Excel (con URL) se mapea a una sección:

```sql
CREATE TABLE sections (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,                    -- Nombre descriptivo
    url TEXT UNIQUE NOT NULL,              -- URL de la página
    description TEXT,
    active BOOLEAN DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Tabla 2: `task_types`

Los 8 tipos de tareas (fijos, no cambian):

```sql
CREATE TABLE task_types (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,             -- "enlaces_rotos", "informacion_actualizada", etc.
    display_name TEXT NOT NULL,            -- "Enlaces Rotos", "Información Actualizada", etc.
    display_order INTEGER DEFAULT 0
);

-- Poblado al inicio:
INSERT INTO task_types (name, display_name, display_order) VALUES
  ('enlaces_rotos', 'Enlaces Rotos', 1),
  ('enlaces_incorrectos', 'Enlaces Incorrectos', 2),
  ('textos_erratas', 'Textos - Erratas', 3),
  ('informacion_actualizada', 'Información Actualizada', 4),
  ('preguntas_frecuentes', 'Preguntas Frecuentes', 5),
  ('ctas', 'CTAs', 6),
  ('imagenes', 'Imágenes', 7),
  ('diseno', 'Diseño', 8);
```

### Tabla 3: `section_task_config`

Define QUÉ tipos de tareas aplican a QUÉ secciones y con QUÉ frecuencia:

```sql
CREATE TABLE section_task_config (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    section_id INTEGER NOT NULL,
    task_type_id INTEGER NOT NULL,
    frequency TEXT NOT NULL,               -- "weekly", "monthly", "quarterly", "biannual", "yearly"
    day_of_activation INTEGER DEFAULT 1,   -- Día del mes/semana
    active BOOLEAN DEFAULT 1,
    FOREIGN KEY (section_id) REFERENCES sections(id),
    FOREIGN KEY (task_type_id) REFERENCES task_types(id),
    UNIQUE(section_id, task_type_id)       -- Una config por (sección, tipo)
);
```

**Ejemplo de datos**:
```sql
-- Sección "Renta Fija" (id=1) tiene 3 tipos de tareas configuradas:
INSERT INTO section_task_config (section_id, task_type_id, frequency) VALUES
  (1, 1, 'weekly'),    -- Enlaces Rotos cada semana
  (1, 4, 'monthly'),   -- Información Actualizada cada mes
  (1, 8, 'quarterly'); -- Diseño cada trimestre
```

### Tabla 4: `tasks`

Tareas generadas automáticamente por scheduler:

```sql
CREATE TABLE tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    section_id INTEGER NOT NULL,
    task_type_id INTEGER NOT NULL,
    status TEXT DEFAULT 'pending',         -- 'pending', 'in_progress', 'completed'
    activated_date DATE NOT NULL,          -- Cuándo se activó la tarea
    completed_date DATE,
    observations TEXT,                     -- Lo que el usuario escribe
    completed_by TEXT,                     -- Nombre de quién completó
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (section_id) REFERENCES sections(id),
    FOREIGN KEY (task_type_id) REFERENCES task_types(id)
);
```

---

## 📝 Parseo del Excel (Actualizado)

**Paso 1**: Parsear secciones (URLs)

```python
import openpyxl

def load_sections_from_excel(excel_path, db_path):
    wb = openpyxl.load_workbook(excel_path)
    sheet = wb["Actualización y calidad"]

    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    for row in sheet.iter_rows(min_row=2, values_only=True):
        url = row[6]  # Col 7: URL
        if url and url.startswith('http'):
            # Extraer nombre de la URL o jerarquía
            name = extract_name_from_url(url) or row[3] or row[4]

            cursor.execute("""
                INSERT OR IGNORE INTO sections (name, url)
                VALUES (?, ?)
            """, (name, url))

    conn.commit()
    conn.close()
```

**Paso 2**: Configurar periodicidades (simplificado para Iteración 0)

Para Iteración 0 (solo "Enlaces Rotos"), configurar todas las secciones con periodicidad mensual:

```python
def configure_initial_task_types(db_path):
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # Get all sections
    cursor.execute("SELECT id FROM sections WHERE active = 1")
    sections = cursor.fetchall()

    # Get "Enlaces Rotos" task type (id = 1)
    enlaces_rotos_id = 1

    # Configure all sections with "Enlaces Rotos" monthly
    for (section_id,) in sections:
        cursor.execute("""
            INSERT OR IGNORE INTO section_task_config
            (section_id, task_type_id, frequency, day_of_activation)
            VALUES (?, ?, 'monthly', 1)
        """, (section_id, enlaces_rotos_id))

    conn.commit()
    conn.close()
```

**Mapeo de Frecuencia**:
```python
FREQUENCY_MAP = {
    'Semanal': 'weekly',
    'Mensual': 'monthly',
    'Trimestral': 'quarterly',
    'Semestral': 'biannual',
    'Anual': 'yearly'
}
```

---

## ✅ Validación Completada

### 1. Periodicidad ✅ RESUELTO
- ✅ Confirmado: Ya existe en Excel ("Tiempo revisión contenido")
- ✅ **Respuesta**: Día 1 fijo para todas las tareas mensuales (simplificación MVP)
- ✅ Las tareas NO desaparecen hasta completarlas (quedan pendientes indefinidamente)

### 2. Tipos de Tareas ✅ RESUELTO
- ✅ **Respuesta**: Son **8 tipos de tareas separadas** (no checklist)
- ✅ Cada tipo puede tener periodicidad independiente por sección
- ✅ Tipos:
  1. Enlaces rotos
  2. Enlaces incorrectos
  3. Textos - erratas
  4. Información actualizada
  5. Preguntas frecuentes
  6. CTAs
  7. Imágenes
  8. Diseño

### 3. Alcance ✅ RESUELTO
- ✅ **Respuesta**: ~30-50 páginas/secciones (todas las URLs del Excel)
- ✅ Todas las páginas con URL válida se importan
- ✅ Se revisan todas iterando por todas las webs

### 4. Aplicación Universal ✅ RESUELTO
- ✅ **Respuesta**: Los 8 tipos aplican a TODAS las páginas
- ✅ Se pueden ir quitando tipos con el tiempo si no son relevantes
- ✅ Todas tienen imágenes y textos (mínimo común)

### 5. CRUD Secciones ✅ RESUELTO
- ✅ **Respuesta**: Necesitan CRUD completo desde UI
- ✅ Crear nuevas secciones
- ✅ Editar secciones existentes (nombre, URL, periodicidades)
- ✅ Eliminar/desactivar secciones
- ✅ Ver lista de todas las secciones

### 6. Datos Históricos ✅ DECIDIDO
- ✅ **Decisión**: Empezar desde cero (no importar historial)
- ✅ Razón: Más simple para MVP, menos riesgo de errores

---

## 📝 Decisiones de Diseño (Validadas)

### ✅ Decisión 1: Parseo Inicial del Excel

**Objetivo**: Poblar tabla `sections` desde Excel

**Script**: `load_sections.py` (a crear)

**Lógica**:
1. Leer pestaña "Actualización y calidad"
2. Extraer todas las filas con URL válida (Col 7)
3. Generar nombre descriptivo desde jerarquía o URL
4. Insertar en tabla `sections`

**Output esperado**: ~30-50 secciones activas

---

### ✅ Decisión 2: Generación de Tareas

**¿Cómo se determina cuándo activar una tarea?**

**Implementación MVP (Opción A - Simple)**:
- ✅ Día fijo para todas las tareas: día 1 del período
- ✅ Mensual: día 1 del mes
- ✅ Semanal: lunes (día 1 de semana)
- ✅ Trimestral: día 1 del trimestre (ene/abr/jul/oct)

**Stage 2 (Opción B - Configurable)**:
- Cada configuración (`section_task_config`) tiene su propio `day_of_activation`
- Permite diferentes días para diferentes combinaciones sección/tipo

**Decisión**: Opción A para Iteración 0 (validado con usuario)

---

### ✅ Decisión 3: Enfoque Iterativo - Un Tipo a la Vez

**⚠️ DECISIÓN CRÍTICA: No implementar todos los 8 tipos a la vez**

**Iteración 0 (MVP)**:
- ✅ Solo implementar **"Enlaces Rotos"**
- ✅ Todas las ~30-50 secciones tienen este tipo
- ✅ Periodicidad: Mensual (simplificado)
- ✅ UI completa y funcional desde día 1

**Razón**: Validar workflow completo antes de agregar complejidad.

**Próximas iteraciones**:
- Iteración 1: Agregar "Enlaces Incorrectos"
- Iteración 2: Agregar "Textos - Erratas"
- ... y así sucesivamente

**Ventaja**: Cada iteración agrega UNA tabla nueva a `section_task_config`, validamos con usuario real.

---

### ✅ Decisión 4: Nombre de Secciones

**¿Cómo generar nombre legible para cada sección?**

**Opción elegida**: **Opción C** (extraer de URL) + fallback a jerarquía

```python
def generate_section_name(url, hierarchy_levels):
    """
    Extrae nombre descriptivo de URL.

    URL: https://www.r4.com/planes-de-pensiones/categorias
    → "Planes de Pensiones - Categorías"
    """
    path_parts = url.split('/')[-2:]  # Últimos 2 segmentos
    name = ' - '.join([p.replace('-', ' ').title() for p in path_parts])

    # Fallback si URL no es descriptiva
    if not name or len(name) < 5:
        name = ' - '.join([h for h in hierarchy_levels if h])

    return name
```

**Razón**: Nombres más descriptivos y únicos.

---

## 🚀 Próximos Pasos (Iteración 0)

### ✅ Paso 1: Documentación Completa

**Estado**: ✅ COMPLETADO
- ✅ EXCEL_ANALYSIS.md - Estructura del Excel documentada
- ✅ PROJECT_PLAN.md - Arquitectura y plan iterativo
- ⏳ ITERATION_0_PLAN.md - Plan día-por-día (próximo)
- ⏳ wireframes.md - Mockups de UI (próximo)

---

### ⏳ Paso 2: Wireframes y Diseño UI

**Objetivo**: Diseñar mockups de las 3 pantallas principales antes de codificar

**Pantallas a diseñar**:
1. **Lista de tareas pendientes** - Vista principal tipo agenda
2. **Detalle de tarea** - Formulario para marcar completa + observaciones
3. **Lista de secciones** - Vista CRUD de secciones (admin)

**Output**: `docs/wireframes.md` con mockups ASCII/texto de cada pantalla

**⚠️ Crítico**: UI primero, backend después (lección aprendida)

---

### ⏳ Paso 3: Implementación Backend Mínimo

**Objetivo**: Backend que soporte SOLO la funcionalidad de UI

**Orden de implementación**:
1. `database.py` - Schema + inicialización
2. `load_sections.py` - Importar ~30-50 secciones desde Excel
3. `models.py` - SQLAlchemy models (si necesario, o usar raw SQL)
4. `app.py` - Flask app con 3 endpoints:
   - `GET /tasks` - Lista de tareas pendientes
   - `POST /tasks/<id>/complete` - Marcar completa
   - `GET /sections` - Lista de secciones (básico)

**Sin scheduler todavía** - Crear tareas manualmente para testing

---

### ⏳ Paso 4: Implementación Frontend (Templates)

**Objetivo**: HTML + Tailwind para las 3 pantallas

**Templates a crear**:
1. `templates/base.html` - Layout base con Tailwind CDN
2. `templates/tasks.html` - Lista de tareas (página principal)
3. `templates/task_detail.html` - Formulario de completar tarea
4. `templates/sections.html` - Lista de secciones (admin)

**JS vanilla** para interactividad básica (marcar completa, etc.)

---

### ⏳ Paso 5: Testing Manual + Validación

**Objetivo**: Validar workflow completo con usuario real

**Pruebas a realizar**:
1. Crear 5-10 tareas manualmente en BD
2. Ver lista de pendientes en UI
3. Completar una tarea con observaciones
4. Verificar que desaparece de pendientes
5. Ver lista de secciones

**Criterios de éxito Iteración 0**:
- ✅ Esposa puede ver tareas pendientes
- ✅ Esposa puede marcar completa + agregar observaciones
- ✅ UI es clara y usable
- ✅ No hay bugs críticos

---

### 🔮 Paso 6: Próximas Iteraciones (Post-MVP)

**Una vez validado Iteración 0**:

**Iteración 0.5**: Agregar scheduler para auto-generar tareas mensuales
**Iteración 1**: Agregar segundo tipo de tarea ("Enlaces Incorrectos")
**Iteración 2**: Agregar tercer tipo ("Textos - Erratas")
... (6 iteraciones más para completar los 8 tipos)

---

## 📊 Resumen del Excel

**Hallazgos validados**:
- ✅ Periodicidad: Semanal, Mensual, Trimestral, Semestral, Anual
- ✅ ~30-50 secciones (URLs) para importar
- ✅ 8 tipos de tareas separadas (no checklist)
- ✅ Cada tipo tiene periodicidad independiente por sección
- ✅ Tracking de quién y cuándo (preservar en BD)

**Decisiones tomadas**:
- ✅ Día de activación fijo (día 1 del período)
- ✅ Empezar con 1 tipo (Enlaces Rotos)
- ✅ Periodicidad mensual simplificada para MVP
- ✅ UI-first approach (diseño antes que backend)

**Estado**:
- ✅ Fase 0 completada - Excel explorado y documentado
- ⏳ Fase 1 (Iteración 0) - Siguiente paso: wireframes

---

**Última actualización**: 2025-10-28
**Próximo paso**: Crear `ITERATION_0_PLAN.md` con timeline día-por-día