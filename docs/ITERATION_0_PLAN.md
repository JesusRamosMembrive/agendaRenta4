# Plan de Iteración 0 - MVP

**Fecha inicio**: 2025-10-28
**Duración estimada**: 2-3 días
**Objetivo**: Sistema funcional con UI completa para UN tipo de tarea ("Enlaces Rotos")

---

## 🎯 Alcance de Iteración 0

### ✅ Qué SÍ incluye

**Frontend (UI)**:
- ✅ Página principal con lista de tareas pendientes
- ✅ Formulario para completar tarea (marcar done + observaciones)
- ✅ Página de administración de secciones (lista básica)
- ✅ Diseño responsive con Tailwind CSS

**Backend**:
- ✅ Base de datos SQLite con 4 tablas (sections, task_types, section_task_config, tasks)
- ✅ Importación de ~30-50 secciones desde Excel
- ✅ Flask app con 3 endpoints básicos
- ✅ Solo tipo de tarea "Enlaces Rotos"
- ✅ Periodicidad mensual simplificada (día 1)

**Funcionalidad**:
- ✅ Ver lista de tareas pendientes ordenadas por fecha
- ✅ Marcar tarea como completada
- ✅ Agregar observaciones a tarea completada
- ✅ Ver lista de secciones importadas

### ❌ Qué NO incluye (Futuras iteraciones)

**Aplazado para Iteración 0.5+**:
- ❌ Scheduler automático (tareas creadas manualmente)
- ❌ Autenticación/login
- ❌ Multi-usuario
- ❌ Los otros 7 tipos de tareas
- ❌ Editar/crear/eliminar secciones (CRUD completo)
- ❌ Filtros avanzados
- ❌ Estadísticas/reportes
- ❌ Deployment (solo localhost)

---

## 📅 Timeline Día por Día

### 📆 Día 1 - Diseño UI + Setup Backend

**Objetivo**: Wireframes completos + estructura de proyecto lista

#### Mañana (3-4 horas)

**1.1. Wireframes (1.5-2 horas)** ⭐ CRÍTICO
- [ ] Crear `docs/wireframes.md`
- [ ] Diseñar 3 pantallas principales:
  - Pantalla 1: Lista de tareas pendientes
  - Pantalla 2: Detalle de tarea (completar + observaciones)
  - Pantalla 3: Lista de secciones (admin)
- [ ] Definir flujo de navegación
- [ ] Identificar elementos de UI necesarios

**Output**: Mockups ASCII/texto de cada pantalla

**1.2. Setup de Proyecto (1-1.5 horas)**
- [ ] Crear estructura de directorios:
  ```
  agendaRenta4/
  ├── app.py              # Flask app principal
  ├── database.py         # Schema + inicialización
  ├── load_sections.py    # Import desde Excel
  ├── templates/          # Jinja2 templates
  │   ├── base.html
  │   ├── tasks.html
  │   ├── task_detail.html
  │   └── sections.html
  ├── static/
  │   ├── css/           # (vacío, usamos Tailwind CDN)
  │   └── js/
  │       └── main.js    # JS vanilla para interactividad
  ├── original-data/     # (ya existe)
  ├── agendaRenta4.db    # SQLite database (generado)
  └── requirements.txt
  ```
- [ ] Crear `requirements.txt` con dependencias:
  ```
  Flask==3.0.0
  openpyxl==3.1.2
  python-dateutil==2.8.2
  ```
- [ ] Instalar dependencias: `pip install -r requirements.txt`

**1.3. Validación de wireframes (0.5 horas)**
- [ ] Revisar wireframes con usuario
- [ ] Ajustar si necesario
- [ ] Aprobar diseño antes de implementar

#### Tarde (3-4 horas)

**1.4. Database Schema (1.5 horas)**
- [ ] Crear `database.py` con schema completo:
  ```python
  # 4 tablas:
  # - sections (id, name, url, active)
  # - task_types (id, name, display_name, display_order)
  # - section_task_config (id, section_id, task_type_id, frequency)
  # - tasks (id, section_id, task_type_id, status, activated_date, completed_date, observations)
  ```
- [ ] Función `init_db()` para crear tablas
- [ ] Función `seed_task_types()` para insertar los 8 tipos fijos
- [ ] Ejecutar y verificar que `agendaRenta4.db` se crea correctamente

**1.5. Script de Importación (1.5-2 horas)**
- [ ] Crear `load_sections.py` basado en `explore_excel.py`
- [ ] Lógica:
  - Leer pestaña "Actualización y calidad"
  - Extraer todas las filas con URL válida (Col 7)
  - Generar nombre descriptivo desde URL
  - Insertar en tabla `sections`
  - Configurar "Enlaces Rotos" (task_type_id=1) con frecuencia mensual para todas
- [ ] Ejecutar y verificar que se importan ~30-50 secciones
- [ ] Ejecutar y verificar que `section_task_config` tiene ~30-50 filas

**Output Día 1**:
- ✅ Wireframes aprobados
- ✅ Estructura de proyecto creada
- ✅ Base de datos poblada con secciones
- ✅ 8 tipos de tareas insertados
- ✅ Configuración inicial de "Enlaces Rotos" para todas las secciones

**Checkpoint Día 1**:
```bash
# Verificar que BD está correcta:
sqlite3 agendaRenta4.db "SELECT COUNT(*) FROM sections;"  # Debe ser ~30-50
sqlite3 agendaRenta4.db "SELECT COUNT(*) FROM task_types;"  # Debe ser 8
sqlite3 agendaRenta4.db "SELECT COUNT(*) FROM section_task_config;"  # Debe ser ~30-50
```

---

### 📆 Día 2 - Implementación Backend + Templates

**Objetivo**: Flask app funcional + HTML templates renderizando

#### Mañana (3-4 horas)

**2.1. Flask App Base (1 hora)**
- [ ] Crear `app.py` con:
  - Imports (Flask, sqlite3, datetime)
  - App initialization
  - Database connection helper
  - Template filters (fechas, etc.)
  - Error handlers (404, 500)
- [ ] Endpoint de prueba: `GET /` → "Hello World"
- [ ] Ejecutar `flask run` y verificar que funciona

**2.2. Endpoint: Lista de Tareas (1.5 horas)**
- [ ] Crear endpoint `GET /tasks` (o `/`)
- [ ] Query SQL:
  ```sql
  SELECT
    tasks.id,
    tasks.activated_date,
    sections.name AS section_name,
    sections.url AS section_url,
    task_types.display_name AS task_type
  FROM tasks
  JOIN sections ON tasks.section_id = sections.id
  JOIN task_types ON tasks.task_type_id = task_types.id
  WHERE tasks.status = 'pending'
  ORDER BY tasks.activated_date ASC
  ```
- [ ] Renderizar `templates/tasks.html` con lista de tareas
- [ ] Manejar caso de "no hay tareas pendientes"

**2.3. Endpoint: Completar Tarea (1 hora)**
- [ ] Crear endpoint `POST /tasks/<id>/complete`
- [ ] Recibir parámetros:
  - `observations` (textarea)
  - `completed_by` (text input)
- [ ] Actualizar BD:
  ```sql
  UPDATE tasks
  SET status = 'completed',
      completed_date = CURRENT_DATE,
      observations = ?,
      completed_by = ?
  WHERE id = ?
  ```
- [ ] Redirect a `/tasks` después de completar
- [ ] Agregar mensaje de éxito (flash message)

**2.4. Endpoint: Lista de Secciones (0.5 horas)**
- [ ] Crear endpoint `GET /sections`
- [ ] Query SQL simple:
  ```sql
  SELECT id, name, url, active
  FROM sections
  ORDER BY name ASC
  ```
- [ ] Renderizar `templates/sections.html` con tabla

#### Tarde (3-4 horas)

**2.5. Template Base (1 hora)**
- [ ] Crear `templates/base.html` con:
  - DOCTYPE + HTML5 structure
  - Tailwind CSS CDN en `<head>`
  - Navbar con links (Tareas, Secciones)
  - Container responsivo
  - Block `{% block content %}{% endblock %}`
  - Block `{% block scripts %}{% endblock %}`
- [ ] Estilos básicos con Tailwind

**2.6. Template: Lista de Tareas (1.5 horas)**
- [ ] Crear `templates/tasks.html` extendiendo `base.html`
- [ ] Estructura según wireframe (Día 1):
  - Título "Tareas Pendientes"
  - Lista de tareas (cards o tabla)
  - Cada tarea muestra:
    - Fecha de activación
    - Nombre de sección
    - Tipo de tarea (siempre "Enlaces Rotos" por ahora)
    - Botón "Completar" (link a detalle)
- [ ] Mensaje si no hay tareas pendientes
- [ ] Responsive design (mobile-first)

**2.7. Template: Completar Tarea (1 hora)**
- [ ] Crear `templates/task_detail.html` extendiendo `base.html`
- [ ] Estructura:
  - Info de la tarea (read-only):
    - Sección
    - Tipo
    - URL (clickeable)
    - Fecha de activación
  - Formulario:
    - Campo "Observaciones" (textarea, 5 filas)
    - Campo "Completado por" (text input)
    - Botón "Marcar como Completada" (submit)
    - Botón "Cancelar" (back)
- [ ] Validación básica con HTML5 (required)

**2.8. Template: Lista de Secciones (0.5 horas)**
- [ ] Crear `templates/sections.html` extendiendo `base.html`
- [ ] Tabla HTML simple con columnas:
  - ID
  - Nombre
  - URL (link externo)
  - Activa (badge)
- [ ] Sin botones de edición/borrado (futuro)

**Output Día 2**:
- ✅ Flask app con 3 endpoints funcionando
- ✅ 4 templates HTML completos
- ✅ UI renderizando correctamente
- ✅ Tailwind CSS aplicado

**Checkpoint Día 2**:
```bash
# Verificar endpoints:
curl http://localhost:5000/tasks  # Debe renderizar HTML
curl http://localhost:5000/sections  # Debe renderizar HTML
```

---

### 📆 Día 3 - Testing + Interactividad + Validación

**Objetivo**: Sistema completamente funcional y validado con usuario

#### Mañana (2-3 horas)

**3.1. Crear Tareas de Prueba (0.5 horas)**
- [ ] Script para crear 10 tareas de prueba manualmente:
  ```python
  # create_test_tasks.py
  import sqlite3
  from datetime import date

  conn = sqlite3.connect('agendaRenta4.db')
  cursor = conn.cursor()

  # Obtener primeras 10 secciones
  cursor.execute("SELECT id FROM sections LIMIT 10")
  sections = cursor.fetchall()

  # Crear una tarea "Enlaces Rotos" para cada una
  for (section_id,) in sections:
      cursor.execute("""
          INSERT INTO tasks (section_id, task_type_id, status, activated_date)
          VALUES (?, 1, 'pending', ?)
      """, (section_id, date.today()))

  conn.commit()
  conn.close()
  ```
- [ ] Ejecutar script
- [ ] Verificar que tareas aparecen en `/tasks`

**3.2. Testing Manual - Flujo Completo (1 hora)**
- [ ] Abrir `http://localhost:5000/tasks`
- [ ] Verificar que aparecen 10 tareas pendientes
- [ ] Click en "Completar" de una tarea
- [ ] Llenar formulario:
  - Observaciones: "Enlaces funcionan correctamente. Actualizado banner principal."
  - Completado por: "María García"
- [ ] Submit
- [ ] Verificar que:
  - Redirige a `/tasks`
  - La tarea completada ya NO aparece en lista
  - Aparece mensaje de éxito
- [ ] Verificar en BD:
  ```sql
  SELECT * FROM tasks WHERE status = 'completed';
  ```
- [ ] Repetir con 2-3 tareas más

**3.3. Mejoras de UX (1 hora)**
- [ ] Flash messages para feedback:
  - "Tarea completada correctamente" (verde)
  - Errores de validación (rojo)
- [ ] Confirmación antes de marcar completa (JS):
  ```javascript
  // static/js/main.js
  function confirmComplete() {
      return confirm('¿Marcar esta tarea como completada?');
  }
  ```
- [ ] Loading states (opcional)
- [ ] Timestamps legibles (formato español):
  ```python
  # Template filter
  @app.template_filter('format_date')
  def format_date(value):
      return value.strftime('%d/%m/%Y')
  ```

#### Tarde (2-3 horas)

**3.4. Edge Cases y Bugs (1 hora)**
- [ ] Probar casos extremos:
  - ¿Qué pasa si no hay tareas pendientes?
  - ¿Qué pasa si observaciones están vacías?
  - ¿Qué pasa si sección no existe? (404)
  - ¿Qué pasa si task_id no existe?
- [ ] Corregir bugs encontrados
- [ ] Agregar validación server-side si necesario

**3.5. Documentación de Uso (0.5 horas)**
- [ ] Crear `README.md` en root del proyecto:
  ```markdown
  # Agenda Renta4 - Iteración 0

  ## Setup
  1. pip install -r requirements.txt
  2. python database.py  # Crear DB
  3. python load_sections.py  # Importar secciones
  4. python create_test_tasks.py  # Crear tareas de prueba

  ## Ejecutar
  flask run

  ## Uso
  - Ver tareas: http://localhost:5000/tasks
  - Ver secciones: http://localhost:5000/sections
  ```

**3.6. Validación con Usuario Final (1-1.5 horas)** ⭐ CRÍTICO
- [ ] Demo con esposa (usuario final):
  - Mostrar lista de tareas
  - Completar 1-2 tareas juntos
  - Explicar flujo
- [ ] Recoger feedback:
  - ¿UI es clara?
  - ¿Falta algo importante?
  - ¿Hay algo confuso?
- [ ] Priorizar ajustes si los hay
- [ ] Implementar ajustes críticos (si los hay)

**Output Día 3**:
- ✅ Sistema completamente funcional
- ✅ 10 tareas de prueba creadas y probadas
- ✅ Flujo completo validado
- ✅ Feedback de usuario recopilado
- ✅ README con instrucciones de uso

**Checkpoint Día 3**:
- ✅ Usuario puede usar el sistema sin ayuda
- ✅ No hay bugs críticos
- ✅ UI es clara y usable

---

## 📊 Criterios de Éxito (Iteración 0)

### Funcionales ✅

- [ ] Usuario puede ver lista de tareas pendientes
- [ ] Usuario puede completar una tarea
- [ ] Usuario puede agregar observaciones al completar
- [ ] Tareas completadas desaparecen de la lista
- [ ] Usuario puede ver lista de secciones importadas
- [ ] ~30-50 secciones importadas correctamente desde Excel

### No Funcionales ✅

- [ ] UI es clara y usable (validado con usuario final)
- [ ] Responsive en mobile y desktop
- [ ] No hay bugs críticos
- [ ] Código limpio y legible
- [ ] README con instrucciones de setup

### Performance (Nice to have) 🔮

- [ ] Página de tareas carga en <1 segundo
- [ ] Completar tarea tarda <500ms
- [ ] BD responde rápido (SQLite es suficiente)

---

## 🚀 Próximos Pasos Post-Iteración 0

### Iteración 0.5 - Scheduler Automático (1-2 días)

**Objetivo**: Tareas se crean automáticamente cada mes (día 1)

**Implementación**:
- [ ] Script `scheduler.py` que corre daily (cron)
- [ ] Lógica:
  ```python
  # Si hoy es día 1 del mes:
  # - Para cada config en section_task_config donde frequency='monthly'
  # - Crear tarea si no existe ya para este mes
  ```
- [ ] Testing: Simular día 1 del mes, verificar que se crean tareas

**Validación**: Dejar correr 1 mes y verificar que se auto-generan tareas

---

### Iteración 1 - Segundo Tipo de Tarea (1 día)

**Objetivo**: Agregar "Enlaces Incorrectos" como segundo tipo

**Implementación**:
- [ ] Configurar "Enlaces Incorrectos" en `section_task_config` para todas las secciones
- [ ] Ya no hace falta cambiar UI (muestra el tipo dinámicamente)
- [ ] Crear 5 tareas de prueba del nuevo tipo
- [ ] Validar que ambos tipos coexisten correctamente

**Validación**: Usuario ve tareas de ambos tipos mezcladas, puede completarlas independientemente

---

### Iteraciones 2-7 - Agregar Tipos Restantes (1 día c/u)

**Tipos a agregar**:
3. Textos - Erratas
4. Información Actualizada
5. Preguntas Frecuentes
6. CTAs
7. Imágenes
8. Diseño

**Proceso**: Igual que Iteración 1 (configurar + testing)

---

### Iteración 8 - Periodicidades Diferenciadas (2-3 días)

**Objetivo**: Permitir diferentes periodicidades por (sección, tipo)

**Implementación**:
- [ ] UI para configurar periodicidades (página admin)
- [ ] Scheduler lee `frequency` de `section_task_config`
- [ ] Soportar: weekly, monthly, quarterly, biannual, yearly

**Validación**: Usuario configura "Enlaces Rotos" semanal para una sección, mensual para otra

---

## 📋 Checklist Pre-Launch Iteración 0

### Setup ✅

- [ ] Python 3.10+ instalado
- [ ] `requirements.txt` creado e instalado
- [ ] Estructura de directorios completa
- [ ] `agendaRenta4.db` creado
- [ ] Excel en `original-data/` accesible

### Base de Datos ✅

- [ ] 4 tablas creadas (sections, task_types, section_task_config, tasks)
- [ ] 8 tipos de tareas insertados
- [ ] ~30-50 secciones importadas
- [ ] ~30-50 configuraciones en `section_task_config` (todas "Enlaces Rotos" + mensual)
- [ ] 10 tareas de prueba creadas

### Backend ✅

- [ ] `app.py` con Flask funcionando
- [ ] 3 endpoints implementados y probados:
  - `GET /tasks` o `/`
  - `POST /tasks/<id>/complete`
  - `GET /sections`
- [ ] Error handling (404, 500)
- [ ] Flash messages para feedback

### Frontend ✅

- [ ] 4 templates HTML completos y funcionales
- [ ] Tailwind CSS aplicado
- [ ] Responsive design (mobile + desktop)
- [ ] JS vanilla para interactividad básica
- [ ] Formularios con validación HTML5

### Testing ✅

- [ ] Flujo completo probado manualmente
- [ ] Edge cases cubiertos
- [ ] Bugs críticos corregidos
- [ ] Usuario final validó usabilidad

### Documentación ✅

- [ ] `README.md` con instrucciones de setup
- [ ] Wireframes documentados en `docs/wireframes.md`
- [ ] Este plan (`ITERATION_0_PLAN.md`) actualizado

---

## 🎯 Métricas de Éxito

**Objetivo cuantitativo**:
- ✅ 30-50 secciones importadas
- ✅ 0 bugs críticos
- ✅ <1 segundo de carga en página principal
- ✅ Usuario completa 1 tarea sin ayuda

**Objetivo cualitativo**:
- ✅ Usuario: "Esto es más fácil que el Excel"
- ✅ Usuario puede usar el sistema sin leer documentación
- ✅ UI es clara y no genera confusión

---

## 💡 Lecciones Aprendidas (Post-Iteración 0)

_A completar después de Iteración 0_

**¿Qué funcionó bien?**
- (a completar)

**¿Qué NO funcionó?**
- (a completar)

**¿Qué ajustaremos para Iteración 1?**
- (a completar)

**Feedback del usuario**:
- (a completar)

---

**Última actualización**: 2025-10-28
**Estado**: 📝 Documentación completa - Listo para ejecutar
**Próximo paso**: Crear `wireframes.md` y empezar Día 1
