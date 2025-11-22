# Plan de Refactor UI - Agenda Renta4

**Fecha inicio**: 2025-11-21
**Estado**: En progreso (Fase 2 completada)
**Objetivo**: Transformar la interfaz de tablas pesadas a un diseño moderno basado en cards con glassmorphism, gradientes y animaciones.

## 📋 Referencia Visual

Archivo: `docs/idea_for_UI.png`
- Diseño moderno con cards
- Glassmorphism effects
- Iconos SVG (Lucide)
- Gradientes sutiles
- Tipografía clara y jerarquizada

## 🎯 Alcance del Refactor

### Páginas a refactorizar (Gestor Manual de Tareas):
- ✅ `/configuracion` - Alertas de Tareas (COMPLETADO)
- ✅ `/inicio` - Dashboard principal (COMPLETADO)
- ⏳ `/alertas` - Alertas pendientes
- ⏳ `/pendientes` - Tareas pendientes
- ⏳ `/problemas` - Tareas con problemas
- ⏳ `/realizadas` - Tareas completadas

### Páginas NO incluidas:
- Módulo Crawler (ya tiene diseño funcional)
- Control de Calidad
- Configuración avanzada

## 🏗️ Fase 1: Design System Foundation ✅

**Archivos modificados**:
- `static/css/style.css` (líneas 24-577)
- `static/js/icons.js` (nuevo archivo)
- `templates/base.html` (líneas 219-224)

### 1.1 Design Tokens (style.css:24-114)

```css
/* Spacing Scale */
--space-xs: 4px;
--space-sm: 8px;
--space-md: 16px;
--space-lg: 24px;
--space-xl: 32px;
--space-2xl: 48px;

/* Typography Scale */
--text-xs: 11px;
--text-sm: 13px;
--text-base: 14px;
--text-lg: 16px;
--text-xl: 20px;
--text-2xl: 24px;
--text-3xl: 30px;

/* Font Weights */
--font-normal: 400;
--font-medium: 500;
--font-semibold: 600;
--font-bold: 700;
--font-extrabold: 800;

/* Shadows (Glassmorphism & Depth) */
--shadow-sm: 0 2px 8px rgba(0,0,0,.05);
--shadow-md: 0 4px 16px rgba(0,0,0,.08);
--shadow-lg: 0 8px 32px rgba(0,0,0,.12);
--shadow-xl: 0 12px 48px rgba(0,0,0,.16);
--shadow-glow: 0 0 24px rgba(193,83,99,.15);
--shadow-glow-strong: 0 0 32px rgba(193,83,99,.25);

/* Backdrop Blur */
--blur-sm: blur(5px);
--blur: blur(10px);
--blur-lg: blur(20px);

/* Border Radius Scale */
--radius-sm: 8px;
--radius-md: 12px;
--radius-lg: 16px;
--radius-xl: 20px;
--radius-full: 9999px;

/* Transitions */
--transition-fast: 0.15s ease;
--transition: 0.3s ease;
--transition-slow: 0.5s ease;

/* Z-index Scale */
--z-base: 1;
--z-dropdown: 1000;
--z-sticky: 1020;
--z-fixed: 1030;
--z-modal-backdrop: 1040;
--z-modal: 1050;
--z-popover: 1060;
--z-tooltip: 1070;
```

### 1.2 Sistema de Iconos Lucide (style.css:138-240)

**Integración**:
- CDN: `https://unpkg.com/lucide@latest`
- Helper: `static/js/icons.js`
- Auto-inicialización en DOM ready

**Utilidades CSS**:
```css
.icon          /* 16x16, base */
.icon-xs       /* 12x12 */
.icon-sm       /* 14x14 */
.icon-md       /* 18x18 */
.icon-lg       /* 20x20 */
.icon-xl       /* 24x24 */
.icon-2xl      /* 32x32 */

/* Colors */
.icon-primary
.icon-success
.icon-warning
.icon-danger
.icon-muted

/* Special */
.icon-btn      /* Botón solo con icono */
.icon-badge    /* Icono con notificación */
```

**IconMap en icons.js**:
```javascript
const IconMap = {
  success: 'check-circle',
  error: 'x-circle',
  warning: 'alert-triangle',
  info: 'info',
  pending: 'clock',
  task: 'check-square',
  calendar: 'calendar',
  alert: 'bell',
  // ... más de 30 iconos mapeados
};
```

### 1.3 Card Components (style.css:242-400)

```css
.card              /* Card base con hover effect */
.card-glass        /* Glassmorphism effect */
.card-sm           /* Padding reducido */
.card-lg           /* Padding amplio */
.card-gradient     /* Borde con gradiente */
.card-interactive  /* Clickeable con scale */

/* Estructura */
.card-header       /* Header con border-bottom */
.card-title        /* Título principal */
.card-subtitle     /* Subtítulo muted */
.card-body         /* Contenido */
.card-footer       /* Footer con border-top */

/* Status indicator (borde lateral) */
.card-status
.card-status.status-success
.card-status.status-warning
.card-status.status-danger
.card-status.status-primary

/* Layouts */
.card-grid         /* Grid responsive 300px */
.card-grid-sm      /* Grid 250px */
.card-grid-lg      /* Grid 350px */
```

### 1.4 Badge & Status Components (style.css:402-577)

```css
/* Badges */
.badge             /* Badge base */
.badge-primary
.badge-success
.badge-warning
.badge-danger
.badge-muted

.badge-sm          /* Tamaño pequeño */
.badge-lg          /* Tamaño grande */
.badge-dot         /* Con punto indicator */

/* Status indicators */
.status            /* Texto + dot */
.status-dot        /* Dot con shadow glow */
.status-pulse      /* Animación pulse */

/* Tags (badges grandes) */
.tag               /* Tag con hover */
.tag-removable     /* Con botón X */
.tag-remove        /* Botón eliminar */
```

## 🎨 Fase 2: Refactor /configuracion ✅

**Archivo**: `templates/configuracion.html`
**Líneas modificadas**: 1-387
**Completado**: 2025-11-21

### Cambios implementados:

#### 1. Guía Rápida (líneas 8-44)
**Antes**: Panel con emoji y fondo azul
**Después**:
```html
<div class="card card-glass" style="background: linear-gradient(...)">
  <div style="...">
    <i data-lucide="compass" class="icon-2xl"></i>
  </div>
  <ul style="list-style: none">
    <li><i data-lucide="check" class="icon-sm"></i> Texto</li>
  </ul>
  <a class="btn"><i data-lucide="bell"></i> Ver alertas</a>
</div>
```

**Iconos usados**:
- `compass` - Icono principal de guía
- `check` - Items de lista
- `bell` - Ver alertas
- `clipboard-list` - Ir a tareas

#### 2. Alertas de Tareas (líneas 49-168)
**Antes**: Tabla HTML tradicional
**Después**: Grid de cards individuales

**Estructura por alerta**:
```html
<div class="card card-sm card-status status-success">
  <div style="display: flex; justify-content: space-between">
    <div>
      <h3>{{ task_type.display_name }}</h3>
      <span class="badge badge-muted badge-sm">
        <i data-lucide="calendar"></i>
        {{ task_type.periodicity }}
      </span>
    </div>
    <label class="toggle-switch">...</label>
  </div>
  <div>
    <!-- Selectores de frecuencia y día -->
  </div>
</div>
```

**Iconos usados**:
- `bell-ring` - Título de sección
- `lightbulb` - Nota informativa
- `calendar` - Badge de periodicidad
- `save` - Botón guardar

**Features**:
- Indicador de estado (borde lateral verde/gris)
- Toggle switch en esquina superior
- Selectores con labels uppercase
- Grid responsive (min 300px)

#### 3. Tipo de Notificaciones (líneas 173-273)
**Antes**: Checkboxes con texto
**Después**: 3 cards individuales clickeables

**Estructura por notificación**:
```html
<div class="card card-sm card-interactive">
  <label style="display: flex">
    <input type="checkbox">
    <div>
      <div><i data-lucide="smartphone"></i> Título</div>
      <p>Descripción</p>
      <!-- Email input si aplica -->
    </div>
  </label>
</div>
```

**Iconos usados**:
- `bell` - Título de sección
- `smartphone` - Notificación en app
- `monitor` - Notificación de escritorio
- `mail` - Correo electrónico
- `save` - Botón guardar

#### 4. Alertas Personalizadas (líneas 278-387)
**Antes**: Formulario + tabla
**Después**: Formulario grid + lista de cards

**Formulario de creación**:
```html
<form id="form-custom-alert">
  <div style="display: grid; gap: var(--space-md)">
    <div>
      <label style="text-transform: uppercase">Título *</label>
      <input class="input">
    </div>
    <!-- Más campos -->
    <button class="btn primary">
      <i data-lucide="plus"></i> Crear
    </button>
  </div>
</form>
```

**Lista de alertas activas**:
```html
<div class="card card-sm card-status status-success">
  <h4>{{ r.title }}</h4>
  <span class="badge badge-primary">
    <i data-lucide="repeat"></i> {{ r.alert_frequency }}
  </span>
  <span class="badge badge-muted">
    <i data-lucide="calendar-days"></i> Día {{ r.alert_day }}
  </span>
  <p>{{ r.notes }}</p>
  <div>
    <label class="toggle-switch">...</label>
    <button class="icon-btn">
      <i data-lucide="trash-2"></i>
    </button>
  </div>
</div>
```

**Iconos usados**:
- `puzzle` - Título de sección
- `plus` - Crear alerta
- `repeat` - Badge de frecuencia
- `calendar-days` - Badge de día
- `trash-2` - Eliminar alerta

### Mejoras técnicas aplicadas:

✅ **Sin emojis** - 100% iconos Lucide SVG
✅ **Design tokens** - Variables CSS en todo el template
✅ **Glassmorphism** - Guía rápida con efecto cristal
✅ **Status indicators** - Bordes laterales de color
✅ **Grid responsive** - Auto-fit con minmax
✅ **Hover effects** - Transiciones suaves (var(--transition))
✅ **Tipografía consistente** - Jerarquía clara con font-weights
✅ **Spacing consistente** - Variables de espaciado
✅ **Accesibilidad** - Labels descriptivos, aria attributes implícitos

## 🚀 Fase 3: Refactor /inicio (PENDIENTE)

**Archivo**: `templates/inicio.html`
**Prioridad**: Alta
**Estimado**: 2-3 horas

### Cambios planificados:

#### 1. Stats Cards (Dashboard summary)
**Actual**: Texto simple o tabla
**Nuevo**: Grid de 4 cards con iconos y stats

```html
<div class="card-grid" style="grid-template-columns: repeat(4, 1fr)">
  <div class="card card-sm">
    <i data-lucide="clipboard-list" class="icon-xl icon-primary"></i>
    <h3>24</h3>
    <p>Tareas Pendientes</p>
  </div>
  <!-- 3 más -->
</div>
```

**Iconos sugeridos**:
- `clipboard-list` - Tareas pendientes
- `alert-triangle` - Problemas
- `check-circle` - Completadas hoy
- `bell-ring` - Alertas activas

#### 2. Tabla de tareas principal
**Actual**: Tabla HTML tradicional
**Nuevo**: Tabla mejorada con badges y estados visuales

```html
<div class="card">
  <div class="card-header">
    <h2 class="card-title">
      <i data-lucide="list"></i>
      Tareas Recientes
    </h2>
    <div class="card-actions">
      <button class="btn ghost">
        <i data-lucide="filter"></i> Filtrar
      </button>
    </div>
  </div>
  <div class="table">
    <table>
      <!-- Mejorar con badges de estado -->
    </table>
  </div>
</div>
```

#### 3. Timeline o actividad reciente
**Opcional**: Card con últimas acciones

## 📝 Fase 4: Refactor /alertas (PENDIENTE)

**Archivo**: `templates/alertas.html`
**Prioridad**: Media
**Estimado**: 1-2 horas

### Cambios planificados:

#### Lista de alertas pendientes
**Actual**: Tabla o lista simple
**Nuevo**: Cards con estado, fecha y acciones

```html
<div class="card-grid">
  <div class="card card-status status-warning">
    <div class="card-header">
      <h3>{{ alert.title }}</h3>
      <span class="badge badge-warning">Pendiente</span>
    </div>
    <div class="card-body">
      <p><i data-lucide="calendar"></i> {{ alert.due_date }}</p>
      <p><i data-lucide="link"></i> {{ alert.url }}</p>
    </div>
    <div class="card-footer">
      <button class="btn primary">
        <i data-lucide="check"></i> Marcar como hecha
      </button>
    </div>
  </div>
</div>
```

**Iconos sugeridos**:
- `bell-ring` - Título de página
- `calendar` - Fecha de vencimiento
- `link` - URL asociada
- `check` - Marcar como hecha
- `x` - Descartar

## 📝 Fase 5: Refactor /pendientes, /problemas, /realizadas (PENDIENTE)

**Archivos**:
- `templates/pendientes.html`
- `templates/problemas.html`
- `templates/realizadas.html`

**Prioridad**: Baja (similar estructura)
**Estimado**: 2-3 horas para las 3

### Cambios planificados:

Todas comparten estructura similar de tabla de tareas:

#### Header con filtros
```html
<div class="card">
  <div class="card-header">
    <h2 class="card-title">
      <i data-lucide="clock"></i> <!-- o alert-triangle, check-circle -->
      Tareas Pendientes
    </h2>
    <div class="card-actions">
      <button class="btn ghost">
        <i data-lucide="filter"></i> Filtrar
      </button>
      <button class="btn ghost">
        <i data-lucide="download"></i> Exportar
      </button>
    </div>
  </div>
</div>
```

#### Tabla mejorada
- Badges de estado
- Iconos en columnas
- Hover effects
- Acciones inline con iconos

## 🎨 Patrones de Diseño Establecidos

### Pattern 1: Card Grid para Listas
Usar cuando: Mostrar colección de items similares

```html
<div class="card-grid">
  <div class="card card-sm card-status status-{color}">
    <h3>Título</h3>
    <div><span class="badge">Info</span></div>
    <p>Descripción</p>
    <div class="card-actions">
      <button class="icon-btn">
        <i data-lucide="edit"></i>
      </button>
    </div>
  </div>
</div>
```

### Pattern 2: Card con Header para Secciones
Usar cuando: Agrupar contenido relacionado

```html
<div class="card">
  <div class="card-header">
    <div>
      <h2 class="card-title">
        <i data-lucide="icon"></i>
        Título
      </h2>
      <p class="card-subtitle">Descripción</p>
    </div>
    <div class="card-actions">
      <button class="btn">Acción</button>
    </div>
  </div>
  <div class="card-body">
    <!-- Contenido -->
  </div>
</div>
```

### Pattern 3: Glassmorphism Card para Destacados
Usar cuando: Información importante o guías

```html
<div class="card card-glass" style="background: linear-gradient(...)">
  <i data-lucide="icon" class="icon-2xl"></i>
  <h3>Título</h3>
  <p>Contenido</p>
</div>
```

### Pattern 4: Badge con Icono
Usar cuando: Mostrar metadata o estado

```html
<span class="badge badge-{variant} badge-{size}">
  <i data-lucide="icon" class="icon-xs"></i>
  Texto
</span>
```

### Pattern 5: Card Status Indicator
Usar cuando: Mostrar estado con color visual

```html
<div class="card card-status status-success">
  <!-- Borde lateral verde -->
</div>
```

## 🔧 Guía de Uso de Iconos

### Mapeo de Contexto a Iconos

| Contexto | Icono Lucide | Uso |
|----------|--------------|-----|
| **Tareas** | `check-square`, `clipboard-list` | Listas de tareas |
| **Alertas** | `bell`, `bell-ring` | Notificaciones |
| **Calendario** | `calendar`, `calendar-days` | Fechas, periodicidad |
| **Estados OK** | `check-circle`, `check-circle-2` | Completado, éxito |
| **Estados KO** | `x-circle`, `alert-triangle` | Error, advertencia |
| **Acciones** | `save`, `edit-3`, `trash-2`, `plus` | Botones de acción |
| **Info** | `lightbulb`, `info`, `help-circle` | Ayuda, notas |
| **Navegación** | `home`, `settings`, `user` | Menú principal |
| **Repetición** | `repeat`, `refresh-cw` | Recurrencia |
| **Email** | `mail`, `send` | Correo electrónico |
| **Dispositivos** | `smartphone`, `monitor` | Notificaciones |

### Tamaños por Contexto

| Contexto | Clase | Tamaño |
|----------|-------|--------|
| Icono en badge | `icon-xs` | 12px |
| Icono inline con texto | `icon-sm` | 14px |
| Icono en botón | `icon-sm` o `icon` | 14-16px |
| Icono en título | `icon-lg` | 20px |
| Icono destacado | `icon-xl` o `icon-2xl` | 24-32px |

## 📋 Checklist por Página

### ✅ /configuracion
- [x] Guía rápida con glassmorphism
- [x] Grid de cards para alertas de tareas (3 columnas - optimizado)
- [x] Cards individuales para notificaciones (layout horizontal 3 columnas)
- [x] Formulario de alertas personalizadas (layout 4 columnas: 2fr 1fr 1fr 2fr)
- [x] Lista de alertas activas con cards
- [x] Todos los emojis reemplazados por iconos
- [x] Design tokens aplicados
- [x] Status indicators funcionando
- [x] Botones de guardar centrados
- [x] Optimización de espacio horizontal

### ✅ /inicio
- [x] Quick Stats Cards (3 cards horizontales con métricas)
- [x] Guía rápida con glassmorphism y numbered steps
- [x] Cards para URLs individuales (reemplazo de tabla)
- [x] Task buttons con iconos (OK / Problema)
- [x] Status indicators por URL
- [x] Observaciones inline expandibles
- [x] Empty state elegante
- [x] Instrucciones en card al final
- [x] Hover effects en cards
- [x] Auto-guardado funcional
- [x] JavaScript actualizado para nueva estructura

**Ajustes finales aplicados a /configuracion (2025-11-21)**:
- Alertas de Tareas: Grid 3 columnas (`grid-template-columns: 1fr 1fr 1fr`) - Optimización de espacio horizontal
- Tipo de Notificaciones: Flexbox horizontal 3 items con separadores verticales (ahorra altura)
- Alertas Personalizadas: Layout `2fr 1fr 1fr 2fr` (Título | Frecuencia | Día | Notas)
- Todos los botones "Guardar" centrados respecto a la card padre
- Uso de `!important` en grid para evitar conflictos de estilos

---

## 🏗️ Fase 3: Página /inicio - Dashboard Principal ✅

**Archivo modificado**: `templates/inicio.html` (495 líneas)
**Completado**: 2025-11-21

### Estructura Nueva

#### 1. Quick Stats Cards (líneas 19-70)
Grid de 3 cards horizontales con métricas principales:

```html
<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: var(--space-md);">
  <!-- Card 1: Pendientes -->
  <a href="/pendientes" class="card card-interactive">
    <div style="display: flex; align-items: center; gap: var(--space-md);">
      <div style="width: 48px; height: 48px; border-radius: var(--radius-md);
                  background: linear-gradient(135deg, var(--warning) 0%, var(--warning-hover) 100%);">
        <i data-lucide="clock" class="icon-lg" style="color: white;"></i>
      </div>
      <div>
        <div style="font-size: var(--text-xs); color: var(--muted); text-transform: uppercase;">
          Pendientes
        </div>
        <div style="font-size: 32px; font-weight: var(--font-bold);">
          {{ task_counts.pending }}
        </div>
      </div>
    </div>
  </a>
  <!-- Problemas y Realizadas con estructura similar -->
</div>
```

**Características**:
- Cards clickeables que navegan a las páginas correspondientes
- Iconos con gradientes de color según el tipo
- Números grandes y legibles
- Hover effect con sutil elevación

#### 2. Guía Rápida Card (líneas 75-125)
Card con glassmorphism y pasos numerados:

```html
<div class="card card-glass" style="border-left: 4px solid var(--primary);">
  <div style="display: flex; align-items: flex-start; gap: var(--space-lg);">
    <div style="font-size: 42px;">👩‍💻</div>

    <div style="flex: 1;">
      <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: var(--space-sm);">
        <!-- Step 1 -->
        <div style="display: flex; align-items: flex-start; gap: var(--space-xs);">
          <div style="width: 20px; height: 20px; border-radius: 50%;
                      background: var(--primary); color: white;
                      display: flex; align-items: center; justify-content: center;">
            1
          </div>
          <div>
            <div style="font-weight: var(--font-semibold);">Elige el periodo</div>
            <div style="color: var(--muted); font-size: var(--text-xs);">
              Selecciona en la barra superior
            </div>
          </div>
        </div>
        <!-- Steps 2 y 3 con estructura similar -->
      </div>
    </div>

    <div style="display: flex; flex-direction: column; gap: var(--space-sm);">
      <a href="/configuracion" class="btn ghost">
        <i data-lucide="settings" class="icon-sm"></i>
        <span>Configurar</span>
      </a>
      <a href="/alertas" class="btn ghost">
        <i data-lucide="bell" class="icon-sm"></i>
        <span>Alertas</span>
      </a>
    </div>
  </div>
</div>
```

**Mejoras respecto a diseño anterior**:
- Pasos numerados con círculos de color
- Layout en grid para mejor alineación
- Botones de acciones rápidas a la derecha
- Más compacto y visual

#### 3. URL Cards (líneas 130-223)
Reemplazo completo de la tabla por cards individuales:

```html
{% for section in sections %}
<div class="card card-interactive url-card" data-section-id="{{ section.id }}">
  <!-- Header: URL y Status -->
  <div style="display: flex; align-items: center; gap: var(--space-md);
              border-bottom: 1px solid var(--border);">
    <div style="flex: 1;">
      <div style="display: flex; align-items: center; gap: var(--space-sm);">
        <i data-lucide="link" class="icon-sm icon-muted"></i>
        <a href="{{ section.url }}" class="url-link">{{ section.name }}</a>
        <i data-lucide="external-link" class="icon-xs icon-muted"></i>
      </div>
      <div style="color: var(--muted); font-size: var(--text-xs); font-family: 'Courier New';">
        {{ section.url }}
      </div>
    </div>

    <!-- Status Dot -->
    <span class="status-dot sd-neutral url-status-dot"></span>
  </div>

  <!-- Task Types Grid (4 columnas) -->
  <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: var(--space-sm);">
    {% for task_type in task_types %}
    <div class="task-type-card">
      <div style="font-size: var(--text-xs); text-transform: uppercase;">
        {{ task_type.display_name }}
      </div>

      <div style="display: flex; gap: var(--space-xs);">
        <button class="task-btn task-btn-ok" data-status="ok">
          <i data-lucide="check" class="icon-xs"></i>
          <span>OK</span>
        </button>

        <button class="task-btn task-btn-problem" data-status="problem">
          <i data-lucide="alert-triangle" class="icon-xs"></i>
          <span>Problema</span>
        </button>
      </div>
    </div>
    {% endfor %}
  </div>

  <!-- Observaciones (hidden by default) -->
  <div class="observations-section" style="display: none; border-top: 1px solid var(--border);">
    <label>
      <i data-lucide="file-text" class="icon-xs"></i>
      <span>Observaciones para {{ section.name }}</span>
    </label>
    <form>
      <textarea class="textarea obs-textarea"></textarea>
      <button type="submit" class="btn primary btn-sm">
        <i data-lucide="save" class="icon-xs"></i>
        <span>Guardar observaciones</span>
      </button>
    </form>
  </div>
</div>
{% endfor %}
```

**Ventajas del nuevo diseño**:
- Cada URL es una card independiente (más fácil de escanear visualmente)
- Task types en grid de 4 columnas (balance entre compacto y legible)
- Botones con iconos y texto (más claros que ✓ y ⚠)
- Observaciones aparecen inline solo cuando hay problemas (ahorra espacio)
- Status dot muestra resumen visual del estado general de la URL
- Hover effect en toda la card

#### 4. Botones de Tarea Mejorados (líneas 265-310)

```css
/* Task Button Styles */
.task-btn {
  transition: all 0.2s ease;
}

.task-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.task-btn-ok.active {
  background: linear-gradient(135deg, var(--success) 0%, var(--success-hover) 100%) !important;
  border-color: var(--success) !important;
  color: white !important;
}

.task-btn-problem.active {
  background: linear-gradient(135deg, var(--danger) 0%, var(--danger-hover) 100%) !important;
  border-color: var(--danger) !important;
  color: white !important;
}
```

**Mejoras**:
- Gradientes en estado activo (más visuales)
- Hover con elevación sutil
- Transiciones suaves

#### 5. JavaScript Actualizado (líneas 312-493)

**Función principal**: `updateCardStatus(card)`
- Calcula OKs y Problemas de cada URL card
- Actualiza el status dot según las reglas:
  - Verde: Todos los tasks en OK
  - Naranja: 1-4 problemas
  - Rojo: >4 problemas
  - Gris: Estado mixto o incompleto

**Función auxiliar**: `updateObservationsVisibility(card)`
- Muestra la sección de observaciones solo si hay al menos un problema marcado
- Oculta automáticamente si se desmarca el último problema

**Auto-guardado**: Mantiene el mismo comportamiento que la versión anterior
- Guarda al hacer clic en botones de estado
- Auto-guarda observaciones con debounce de 1 segundo

#### 6. Empty State (líneas 244-260)

```html
<div class="card" style="text-align: center; padding: var(--space-2xl);">
  <div style="width: 64px; height: 64px; margin: 0 auto var(--space-lg);
              border-radius: 50%;
              background: linear-gradient(135deg, var(--muted-light) 0%, var(--border) 100%);
              display: flex; align-items: center; justify-content: center;">
    <i data-lucide="inbox" class="icon-xl icon-muted"></i>
  </div>
  <h3>No hay secciones disponibles</h3>
  <p style="color: var(--muted);">No se encontraron URLs para revisar en este periodo.</p>
  <a href="/configuracion" class="btn primary">
    <i data-lucide="settings" class="icon-sm"></i>
    <span>Ir a Configuración</span>
  </a>
</div>
```

**Características**:
- Icono grande en círculo con gradiente
- Mensaje claro y acción sugerida
- Diseño centrado y equilibrado

#### 7. Instructions Card (líneas 225-242)

Card informativa al final de la página con:
- Icono de información
- Lista de instrucciones de uso
- Status dots inline como referencia visual
- Tipografía pequeña y color muted para no distraer

### Comparación: Antes vs Después

| Aspecto | Antes (Tabla) | Después (Cards) |
|---------|---------------|-----------------|
| **Estructura** | Tabla HTML rígida | Cards flexibles |
| **Escaneo visual** | Horizontal, difícil | Vertical, agrupado por URL |
| **Espacio** | Compacto pero denso | Espacioso pero organizado |
| **Interacción** | Botones pequeños (✓ ⚠) | Botones con texto + icono |
| **Estado** | Dot en columna separada | Dot integrado en header de card |
| **Observaciones** | Fila expandible debajo | Sección inline en la misma card |
| **Responsividad** | Scroll horizontal en móvil | Cards se adaptan al ancho |
| **Accesibilidad** | ARIA roles en tabla | Semántica clara con iconos + texto |

### ⏳ /alertas

### ⏳ /alertas
- [ ] Grid de cards para alertas
- [ ] Badges de estado
- [ ] Iconos de fecha y URL
- [ ] Botones de acción con iconos

### ⏳ /pendientes
- [ ] Header con filtros
- [ ] Tabla mejorada con badges
- [ ] Iconos en columnas
- [ ] Acciones inline

### ⏳ /problemas
- [ ] Similar a /pendientes
- [ ] Énfasis en estado de error

### ⏳ /realizadas
- [ ] Similar a /pendientes
- [ ] Énfasis en estado completado

## 🚨 Notas Importantes

### Conservar Funcionalidad
- **JavaScript**: No tocar lógica de negocio
- **Formularios**: Mantener names y IDs exactos
- **Event listeners**: Mantener clases usadas en JS (js-*, data-*)
- **URLs**: No cambiar href en enlaces

### Testing Requerido
Después de cada página refactorizada:
1. ✅ Verificar que formularios envían correctamente
2. ✅ Verificar que botones ejecutan acciones
3. ✅ Probar toggle switches
4. ✅ Verificar responsive (mobile, tablet, desktop)
5. ✅ Probar modo oscuro
6. ✅ Verificar iconos se renderizan

### Consistencia Visual
- Usar `var(--space-*)` para todos los espaciados
- Usar `var(--text-*)` para tamaños de fuente
- Usar `var(--font-*)` para font-weights
- Usar `var(--radius-*)` para border-radius
- Usar `.card`, `.badge`, `.icon` de forma consistente

## 📅 Cronograma Estimado

| Fase | Página | Tiempo Estimado | Estado |
|------|--------|-----------------|--------|
| 1 | Design System | 2-3h | ✅ Completado |
| 2 | /configuracion | 2-3h | ✅ Completado |
| 3 | /inicio | 2-3h | ⏳ Pendiente |
| 4 | /alertas | 1-2h | ⏳ Pendiente |
| 5 | /pendientes /problemas /realizadas | 2-3h | ⏳ Pendiente |

**Total estimado**: 10-15 horas
**Progreso actual**: ~40% (5h completadas)

## 🔄 Continuación de Sesión

### Para retomar el trabajo:

1. **Leer este documento** completo
2. **Verificar Fase 1** está intacta:
   - `static/css/style.css` (design tokens)
   - `static/js/icons.js` (helper de iconos)
   - `templates/base.html` (CDN Lucide)
3. **Revisar /configuracion** como referencia
4. **Continuar con /inicio** siguiendo los patrones establecidos

### Archivos clave:
- `docs/idea_for_UI.png` - Referencia visual
- `static/css/style.css` - Design system
- `static/js/icons.js` - Helper de iconos
- `templates/configuracion.html` - Ejemplo completo

---

**Última actualización**: 2025-11-21
**Próxima sesión**: Continuar con Fase 3 (/inicio)
