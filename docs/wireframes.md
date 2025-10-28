# Wireframes - Agenda Renta4

**Fecha**: 2025-10-28
**Iteración**: 0 (MVP)
**Pantallas**: 3 principales

---

## 🎨 Guía de Diseño

### Colores

**Palette principal** (Tailwind CSS):
- **Primary**: `blue-600` (#2563eb) - Enlaces, botones principales
- **Success**: `green-600` (#16a34a) - Confirmaciones, badges "completada"
- **Warning**: `yellow-500` (#eab308) - Badges "pendiente"
- **Neutral**: `gray-100` a `gray-900` - Texto, fondos
- **Background**: `white` (#ffffff) - Fondo principal
- **Background Alt**: `gray-50` (#f9fafb) - Cards, secciones

### Tipografía

**Font**: System fonts (Tailwind default)
```css
font-family: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, ...
```

**Tamaños**:
- **Heading 1**: `text-3xl` (30px) - Títulos de página
- **Heading 2**: `text-2xl` (24px) - Subtítulos
- **Body**: `text-base` (16px) - Texto normal
- **Small**: `text-sm` (14px) - Metadatos, badges

### Espaciado

**Container**: `max-w-6xl mx-auto px-4` (máximo 1152px, centrado)
**Padding**: `p-4` (16px) o `p-6` (24px)
**Gap**: `gap-4` (16px) entre elementos

---

## 📱 Pantalla 1: Lista de Tareas Pendientes

**Ruta**: `/tasks` (o `/`)
**Usuario**: María (esposa, revisora principal)
**Objetivo**: Ver qué tengo que revisar hoy

### Layout Desktop (>768px)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │  🏠 Agenda Renta4           [Tareas] [Secciones]      👤 María   │ │
│  └───────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │  Tareas Pendientes                                      10 tareas │ │
│  └───────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │  📅 28 Oct 2025                                [Enlaces Rotos]    │ │
│  │  Planes de Pensiones - Categorías                                 │ │
│  │  🔗 https://www.r4.com/planes-de-pensiones/categorias            │ │
│  │                                         [Completar →]              │ │
│  └───────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │  📅 28 Oct 2025                                [Enlaces Rotos]    │ │
│  │  Bolsas - CFDs                                                     │ │
│  │  🔗 https://www.r4.com/bolsas/cfds                               │ │
│  │                                         [Completar →]              │ │
│  └───────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │  📅 28 Oct 2025                                [Enlaces Rotos]    │ │
│  │  Fondos - Categorías                                               │ │
│  │  🔗 https://www.r4.com/fondos/categorias                         │ │
│  │                                         [Completar →]              │ │
│  └───────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│  ... (más tareas) ...                                                  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Layout Mobile (<768px)

```
┌───────────────────────────────┐
│  ☰  Agenda Renta4      👤 María│
├───────────────────────────────┤
│  Tareas Pendientes            │
│  10 tareas                    │
├───────────────────────────────┤
│                               │
│  ┌─────────────────────────┐ │
│  │ 📅 28/10/2025          │ │
│  │ Enlaces Rotos           │ │
│  │                         │ │
│  │ Planes de Pensiones -   │ │
│  │ Categorías              │ │
│  │                         │ │
│  │ 🔗 Ver página           │ │
│  │                         │ │
│  │     [Completar →]       │ │
│  └─────────────────────────┘ │
│                               │
│  ┌─────────────────────────┐ │
│  │ 📅 28/10/2025          │ │
│  │ Enlaces Rotos           │ │
│  │                         │ │
│  │ Bolsas - CFDs           │ │
│  │                         │ │
│  │ 🔗 Ver página           │ │
│  │                         │ │
│  │     [Completar →]       │ │
│  └─────────────────────────┘ │
│                               │
│  ... (más tareas) ...         │
│                               │
└───────────────────────────────┘
```

### Componentes y Estados

#### Card de Tarea (Componente reutilizable)

**Estado: Pendiente**
```html
<div class="bg-white border border-gray-200 rounded-lg p-6 hover:shadow-md transition">
  <!-- Header -->
  <div class="flex justify-between items-start mb-3">
    <div class="flex items-center text-sm text-gray-500">
      <svg>📅</svg>
      <span>28 Oct 2025</span>
    </div>
    <span class="bg-yellow-100 text-yellow-800 text-xs px-2 py-1 rounded-full">
      Enlaces Rotos
    </span>
  </div>

  <!-- Título -->
  <h3 class="text-lg font-semibold text-gray-900 mb-2">
    Planes de Pensiones - Categorías
  </h3>

  <!-- URL -->
  <a href="https://www.r4.com/..." target="_blank"
     class="text-sm text-blue-600 hover:underline flex items-center mb-4">
    🔗 https://www.r4.com/planes-de-pensiones/categorias
  </a>

  <!-- Acción -->
  <div class="flex justify-end">
    <a href="/tasks/123/complete"
       class="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700">
      Completar →
    </a>
  </div>
</div>
```

#### Estado: Sin tareas

```
┌─────────────────────────────────────────────┐
│  Tareas Pendientes                   0 tareas│
├─────────────────────────────────────────────┤
│                                             │
│           ✅                                │
│                                             │
│     ¡No hay tareas pendientes!              │
│                                             │
│  Todas las revisiones están al día.         │
│                                             │
│           [Ver Secciones]                   │
│                                             │
└─────────────────────────────────────────────┘
```

### Interacciones

**Hover en Card**:
- Border cambia a `border-blue-200`
- Shadow aumenta: `shadow-md` → `shadow-lg`
- Cursor: `cursor-pointer`

**Click en "Completar"**:
- Navega a `/tasks/<id>/complete`

**Click en URL**:
- Abre en nueva pestaña: `target="_blank"`

---

## 📝 Pantalla 2: Completar Tarea

**Ruta**: `/tasks/<id>/complete`
**Usuario**: María (revisora)
**Objetivo**: Marcar tarea como completada y agregar observaciones

### Layout Desktop

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │  🏠 Agenda Renta4           [Tareas] [Secciones]      👤 María   │ │
│  └───────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │  ← Volver a Tareas                                                 │ │
│  └───────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │  Completar Tarea                                                   │ │
│  └───────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │  Información de la Tarea                                           │ │
│  ├───────────────────────────────────────────────────────────────────┤ │
│  │                                                                     │ │
│  │  Sección:                                                           │ │
│  │  Planes de Pensiones - Categorías                                  │ │
│  │                                                                     │ │
│  │  Tipo de Tarea:                                                     │ │
│  │  Enlaces Rotos                                                      │ │
│  │                                                                     │ │
│  │  URL:                                                               │ │
│  │  🔗 https://www.r4.com/planes-de-pensiones/categorias              │ │
│  │  [Abrir en nueva pestaña ↗]                                        │ │
│  │                                                                     │ │
│  │  Fecha de Activación:                                               │ │
│  │  28 de Octubre de 2025                                             │ │
│  │                                                                     │ │
│  └───────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │  Completar Revisión                                                │ │
│  ├───────────────────────────────────────────────────────────────────┤ │
│  │                                                                     │ │
│  │  Observaciones: *                                                   │ │
│  │  ┌─────────────────────────────────────────────────────────────┐  │ │
│  │  │                                                             │  │ │
│  │  │  Describe qué revisaste y qué cambios hiciste...           │  │ │
│  │  │                                                             │  │ │
│  │  │                                                             │  │ │
│  │  └─────────────────────────────────────────────────────────────┘  │ │
│  │                                                                     │ │
│  │  Completado por: *                                                  │ │
│  │  ┌─────────────────────────────────────────────────────────────┐  │ │
│  │  │  María García                                               │  │ │
│  │  └─────────────────────────────────────────────────────────────┘  │ │
│  │                                                                     │ │
│  │  * Campo obligatorio                                                │ │
│  │                                                                     │ │
│  │                                                                     │ │
│  │     [Cancelar]                    [✓ Marcar como Completada]       │ │
│  │                                                                     │ │
│  └───────────────────────────────────────────────────────────────────┘ │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Layout Mobile

```
┌───────────────────────────────┐
│  ← Volver  Completar Tarea    │
├───────────────────────────────┤
│                               │
│  Información                  │
│  ─────────────────────────    │
│                               │
│  Sección:                     │
│  Planes de Pensiones -        │
│  Categorías                   │
│                               │
│  Tipo:                        │
│  Enlaces Rotos                │
│                               │
│  URL:                         │
│  🔗 Ver página ↗              │
│                               │
│  Fecha: 28/10/2025            │
│                               │
├───────────────────────────────┤
│                               │
│  Observaciones: *             │
│  ┌─────────────────────────┐ │
│  │                         │ │
│  │ Escribe aquí...         │ │
│  │                         │ │
│  │                         │ │
│  └─────────────────────────┘ │
│                               │
│  Completado por: *            │
│  ┌─────────────────────────┐ │
│  │ María García            │ │
│  └─────────────────────────┘ │
│                               │
│  * Campo obligatorio          │
│                               │
├───────────────────────────────┤
│                               │
│  [Cancelar]                   │
│                               │
│  [✓ Marcar como Completada]   │
│                               │
└───────────────────────────────┘
```

### Formulario HTML

```html
<form method="POST" action="/tasks/123/complete" onsubmit="return confirmComplete()">

  <!-- Observaciones -->
  <div class="mb-6">
    <label for="observations" class="block text-sm font-medium text-gray-700 mb-2">
      Observaciones: <span class="text-red-600">*</span>
    </label>
    <textarea
      id="observations"
      name="observations"
      rows="5"
      required
      placeholder="Describe qué revisaste y qué cambios hiciste..."
      class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
    ></textarea>
    <p class="text-xs text-gray-500 mt-1">
      Ejemplo: "Enlaces funcionan correctamente. Actualizado banner principal."
    </p>
  </div>

  <!-- Completado por -->
  <div class="mb-6">
    <label for="completed_by" class="block text-sm font-medium text-gray-700 mb-2">
      Completado por: <span class="text-red-600">*</span>
    </label>
    <input
      type="text"
      id="completed_by"
      name="completed_by"
      required
      value="María García"
      class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
    />
  </div>

  <!-- Nota sobre campo obligatorio -->
  <p class="text-sm text-gray-500 mb-6">* Campo obligatorio</p>

  <!-- Botones de acción -->
  <div class="flex flex-col sm:flex-row gap-3 sm:justify-end">
    <a href="/tasks"
       class="px-6 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50 text-center">
      Cancelar
    </a>
    <button
      type="submit"
      class="px-6 py-2 bg-green-600 text-white rounded-md hover:bg-green-700">
      ✓ Marcar como Completada
    </button>
  </div>

</form>
```

### Validación JavaScript

```javascript
// static/js/main.js

function confirmComplete() {
  const observations = document.getElementById('observations').value.trim();
  const completedBy = document.getElementById('completed_by').value.trim();

  // Validación adicional
  if (observations.length < 10) {
    alert('Por favor, escribe observaciones más detalladas (mínimo 10 caracteres).');
    return false;
  }

  if (!completedBy) {
    alert('Por favor, ingresa quién completó la tarea.');
    return false;
  }

  // Confirmación final
  return confirm('¿Confirmas que quieres marcar esta tarea como completada?');
}
```

### Estados y Mensajes

**Éxito (después de submit)**:
```
┌─────────────────────────────────────────────┐
│  ✅ Tarea completada correctamente          │
└─────────────────────────────────────────────┘
```

**Error (si falla submit)**:
```
┌─────────────────────────────────────────────┐
│  ❌ Error al completar tarea. Inténtalo    │
│     de nuevo.                               │
└─────────────────────────────────────────────┘
```

---

## 📚 Pantalla 3: Lista de Secciones (Admin)

**Ruta**: `/sections`
**Usuario**: José o María (administrador)
**Objetivo**: Ver qué secciones están siendo monitoreadas

### Layout Desktop

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │  🏠 Agenda Renta4           [Tareas] [Secciones]      👤 José    │ │
│  └───────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │  Secciones                                              43 secciones│ │
│  └───────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │  ID  │  Nombre                        │  URL                │ ✓   │ │
│  ├──────┼────────────────────────────────┼─────────────────────┼─────┤ │
│  │  1   │  Planes de Pensiones -         │  🔗 Ver página ↗   │ ✅  │ │
│  │      │  Categorías                    │                     │     │ │
│  ├──────┼────────────────────────────────┼─────────────────────┼─────┤ │
│  │  2   │  Bolsas - CFDs                 │  🔗 Ver página ↗   │ ✅  │ │
│  ├──────┼────────────────────────────────┼─────────────────────┼─────┤ │
│  │  3   │  Fondos - Categorías           │  🔗 Ver página ↗   │ ✅  │ │
│  ├──────┼────────────────────────────────┼─────────────────────┼─────┤ │
│  │  4   │  Renta Fija - Bonos            │  🔗 Ver página ↗   │ ✅  │ │
│  ├──────┼────────────────────────────────┼─────────────────────┼─────┤ │
│  │  5   │  Análisis - Dividendos         │  🔗 Ver página ↗   │ ✅  │ │
│  ├──────┼────────────────────────────────┼─────────────────────┼─────┤ │
│  │ ...  │  ...                           │  ...                │ ... │ │
│  └──────┴────────────────────────────────┴─────────────────────┴─────┘ │
│                                                                         │
│  ℹ️ Futuras iteraciones: Podrás editar, agregar y eliminar secciones   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Layout Mobile

```
┌───────────────────────────────┐
│  ☰  Secciones          👤 José│
├───────────────────────────────┤
│  43 secciones                 │
├───────────────────────────────┤
│                               │
│  ┌─────────────────────────┐ │
│  │ #1  ✅                  │ │
│  │                         │ │
│  │ Planes de Pensiones -   │ │
│  │ Categorías              │ │
│  │                         │ │
│  │ 🔗 Ver página ↗         │ │
│  └─────────────────────────┘ │
│                               │
│  ┌─────────────────────────┐ │
│  │ #2  ✅                  │ │
│  │                         │ │
│  │ Bolsas - CFDs           │ │
│  │                         │ │
│  │ 🔗 Ver página ↗         │ │
│  └─────────────────────────┘ │
│                               │
│  ┌─────────────────────────┐ │
│  │ #3  ✅                  │ │
│  │                         │ │
│  │ Fondos - Categorías     │ │
│  │                         │ │
│  │ 🔗 Ver página ↗         │ │
│  └─────────────────────────┘ │
│                               │
│  ... (más secciones) ...      │
│                               │
├───────────────────────────────┤
│  ℹ️ Futuras iteraciones:     │
│  Podrás editar secciones      │
└───────────────────────────────┘
```

### Tabla HTML

```html
<div class="overflow-x-auto">
  <table class="w-full border-collapse">
    <thead>
      <tr class="bg-gray-100 border-b">
        <th class="text-left p-3 text-sm font-semibold">ID</th>
        <th class="text-left p-3 text-sm font-semibold">Nombre</th>
        <th class="text-left p-3 text-sm font-semibold">URL</th>
        <th class="text-center p-3 text-sm font-semibold">Estado</th>
      </tr>
    </thead>
    <tbody>
      {% for section in sections %}
      <tr class="border-b hover:bg-gray-50">
        <td class="p-3 text-sm text-gray-500">{{ section.id }}</td>
        <td class="p-3 text-sm font-medium text-gray-900">{{ section.name }}</td>
        <td class="p-3 text-sm">
          <a href="{{ section.url }}" target="_blank"
             class="text-blue-600 hover:underline flex items-center">
            🔗 Ver página ↗
          </a>
        </td>
        <td class="p-3 text-center">
          {% if section.active %}
            <span class="text-green-600 text-xl">✅</span>
          {% else %}
            <span class="text-gray-400 text-xl">⭕</span>
          {% endif %}
        </td>
      </tr>
      {% endfor %}
    </tbody>
  </table>
</div>

<!-- Info sobre futuras funcionalidades -->
<div class="mt-6 p-4 bg-blue-50 border border-blue-200 rounded-md">
  <p class="text-sm text-blue-800">
    ℹ️ <strong>Próximas iteraciones:</strong>
    Podrás editar, agregar y eliminar secciones desde esta página.
  </p>
</div>
```

### Vista de Card (Mobile alternativo)

```html
<!-- Para mobile, usar cards en lugar de tabla -->
<div class="space-y-4">
  {% for section in sections %}
  <div class="bg-white border border-gray-200 rounded-lg p-4">
    <div class="flex justify-between items-start mb-2">
      <span class="text-sm text-gray-500">#{{ section.id }}</span>
      {% if section.active %}
        <span class="text-green-600 text-xl">✅</span>
      {% else %}
        <span class="text-gray-400 text-xl">⭕</span>
      {% endif %}
    </div>

    <h3 class="text-base font-semibold text-gray-900 mb-2">
      {{ section.name }}
    </h3>

    <a href="{{ section.url }}" target="_blank"
       class="text-sm text-blue-600 hover:underline flex items-center">
      🔗 Ver página ↗
    </a>
  </div>
  {% endfor %}
</div>
```

---

## 🧭 Navegación Global

### Navbar (Desktop)

```
┌─────────────────────────────────────────────────────────────────────┐
│  🏠 Agenda Renta4           [Tareas] [Secciones]      👤 María     │
└─────────────────────────────────────────────────────────────────────┘
```

**HTML**:
```html
<nav class="bg-white border-b border-gray-200">
  <div class="max-w-6xl mx-auto px-4">
    <div class="flex justify-between items-center h-16">

      <!-- Logo/Brand -->
      <a href="/" class="flex items-center text-xl font-bold text-gray-900">
        🏠 Agenda Renta4
      </a>

      <!-- Navigation Links -->
      <div class="flex items-center space-x-6">
        <a href="/tasks"
           class="text-gray-700 hover:text-blue-600 font-medium">
          Tareas
        </a>
        <a href="/sections"
           class="text-gray-700 hover:text-blue-600 font-medium">
          Secciones
        </a>
      </div>

      <!-- User Info -->
      <div class="flex items-center text-gray-700">
        <span class="mr-2">👤</span>
        <span class="font-medium">María</span>
      </div>

    </div>
  </div>
</nav>
```

### Navbar (Mobile)

```
┌───────────────────────────────┐
│  ☰  Agenda Renta4      👤 María│
└───────────────────────────────┘
```

**HTML**:
```html
<nav class="bg-white border-b border-gray-200">
  <div class="px-4">
    <div class="flex justify-between items-center h-14">

      <!-- Hamburger Menu + Brand -->
      <div class="flex items-center space-x-3">
        <button id="mobile-menu-toggle" class="text-gray-700">
          <svg class="w-6 h-6">☰</svg>
        </button>
        <a href="/" class="font-bold text-gray-900">
          Agenda Renta4
        </a>
      </div>

      <!-- User -->
      <div class="flex items-center text-gray-700 text-sm">
        <span class="mr-1">👤</span>
        <span>María</span>
      </div>

    </div>
  </div>

  <!-- Mobile Menu (hidden by default) -->
  <div id="mobile-menu" class="hidden border-t border-gray-200">
    <a href="/tasks" class="block px-4 py-3 text-gray-700 hover:bg-gray-50">
      Tareas
    </a>
    <a href="/sections" class="block px-4 py-3 text-gray-700 hover:bg-gray-50">
      Secciones
    </a>
  </div>
</nav>
```

**JavaScript para mobile menu**:
```javascript
// static/js/main.js

document.addEventListener('DOMContentLoaded', function() {
  const menuToggle = document.getElementById('mobile-menu-toggle');
  const mobileMenu = document.getElementById('mobile-menu');

  if (menuToggle && mobileMenu) {
    menuToggle.addEventListener('click', function() {
      mobileMenu.classList.toggle('hidden');
    });
  }
});
```

---

## 🎨 Componentes Reutilizables

### Badge de Estado

```html
<!-- Pendiente -->
<span class="bg-yellow-100 text-yellow-800 text-xs px-2 py-1 rounded-full">
  Pendiente
</span>

<!-- Completada -->
<span class="bg-green-100 text-green-800 text-xs px-2 py-1 rounded-full">
  Completada
</span>

<!-- Tipo de Tarea -->
<span class="bg-blue-100 text-blue-800 text-xs px-2 py-1 rounded-full">
  Enlaces Rotos
</span>
```

### Flash Messages

```html
<!-- Éxito -->
<div class="max-w-6xl mx-auto px-4 mt-4">
  <div class="bg-green-50 border border-green-200 text-green-800 px-4 py-3 rounded-md flex items-center">
    <svg class="w-5 h-5 mr-2">✓</svg>
    <span>Tarea completada correctamente</span>
  </div>
</div>

<!-- Error -->
<div class="max-w-6xl mx-auto px-4 mt-4">
  <div class="bg-red-50 border border-red-200 text-red-800 px-4 py-3 rounded-md flex items-center">
    <svg class="w-5 h-5 mr-2">✕</svg>
    <span>Error al completar tarea. Inténtalo de nuevo.</span>
  </div>
</div>

<!-- Info -->
<div class="max-w-6xl mx-auto px-4 mt-4">
  <div class="bg-blue-50 border border-blue-200 text-blue-800 px-4 py-3 rounded-md flex items-center">
    <svg class="w-5 h-5 mr-2">ℹ</svg>
    <span>Las secciones se importaron correctamente</span>
  </div>
</div>
```

**Flask + Jinja2**:
```python
# app.py
from flask import flash

@app.route('/tasks/<int:task_id>/complete', methods=['POST'])
def complete_task(task_id):
    # ... lógica de completar tarea ...
    flash('Tarea completada correctamente', 'success')
    return redirect(url_for('tasks'))
```

```html
<!-- base.html -->
{% with messages = get_flashed_messages(with_categories=true) %}
  {% if messages %}
    <div class="max-w-6xl mx-auto px-4 mt-4">
      {% for category, message in messages %}
        <div class="bg-{{ 'green' if category == 'success' else 'red' }}-50 ...">
          {{ message }}
        </div>
      {% endfor %}
    </div>
  {% endif %}
{% endwith %}
```

### Botones

```html
<!-- Botón Primario -->
<button class="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 transition">
  Acción Principal
</button>

<!-- Botón Secundario -->
<button class="bg-white border border-gray-300 text-gray-700 px-4 py-2 rounded-md hover:bg-gray-50 transition">
  Acción Secundaria
</button>

<!-- Botón Éxito -->
<button class="bg-green-600 text-white px-4 py-2 rounded-md hover:bg-green-700 transition">
  ✓ Confirmar
</button>

<!-- Botón Peligro -->
<button class="bg-red-600 text-white px-4 py-2 rounded-md hover:bg-red-700 transition">
  ✕ Eliminar
</button>

<!-- Botón Link -->
<a href="/..." class="text-blue-600 hover:underline">
  Ver más →
</a>
```

### Empty State

```html
<div class="text-center py-12">
  <div class="text-6xl mb-4">📋</div>
  <h3 class="text-xl font-semibold text-gray-900 mb-2">
    No hay tareas pendientes
  </h3>
  <p class="text-gray-600 mb-6">
    Todas las revisiones están al día
  </p>
  <a href="/sections" class="inline-block bg-blue-600 text-white px-6 py-2 rounded-md hover:bg-blue-700">
    Ver Secciones
  </a>
</div>
```

---

## 📱 Responsiveness

### Breakpoints (Tailwind)

```css
/* Mobile-first approach */
.container {
  padding: 1rem;  /* Default: mobile */
}

@media (min-width: 768px) {  /* md: tablet */
  .container {
    padding: 1.5rem;
  }
}

@media (min-width: 1024px) {  /* lg: desktop */
  .container {
    padding: 2rem;
  }
}
```

### Clases Tailwind Responsive

```html
<!-- Ocultar en mobile, mostrar en desktop -->
<div class="hidden md:block">
  Desktop only
</div>

<!-- Mostrar en mobile, ocultar en desktop -->
<div class="block md:hidden">
  Mobile only
</div>

<!-- Columnas responsivas -->
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
  <!-- Cards -->
</div>

<!-- Padding/Margin responsivo -->
<div class="p-4 md:p-6 lg:p-8">
  Content
</div>

<!-- Texto responsivo -->
<h1 class="text-2xl md:text-3xl lg:text-4xl">
  Título
</h1>
```

---

## 🔄 Flujo de Usuario

### Happy Path: Completar una tarea

```
1. Usuario abre app
   ↓
2. Ve lista de tareas pendientes (Pantalla 1)
   ↓
3. Click en "Completar" de una tarea
   ↓
4. Navega a formulario de completar (Pantalla 2)
   ↓
5. Lee info de la tarea (sección, URL, tipo)
   ↓
6. Opcionalmente: Click en "Abrir página" → Revisa página real
   ↓
7. Vuelve a formulario
   ↓
8. Escribe observaciones (ej: "Enlaces OK, actualicé banner")
   ↓
9. Verifica nombre en "Completado por"
   ↓
10. Click en "Marcar como Completada"
    ↓
11. JS: Confirmación "¿Confirmas...?"
    ↓
12. Usuario: "Aceptar"
    ↓
13. POST a /tasks/<id>/complete
    ↓
14. Backend: Actualiza BD, marca status='completed'
    ↓
15. Redirect a /tasks con mensaje "✅ Tarea completada"
    ↓
16. Usuario ve lista actualizada (tarea ya NO aparece)
    ↓
17. Usuario continúa con siguiente tarea
```

### Alternate Path: Cancelar

```
1-9. (Mismo proceso hasta formulario)
    ↓
10. Usuario: Click en "Cancelar"
    ↓
11. Navega de vuelta a /tasks
    ↓
12. Tarea sigue en lista de pendientes (no se completó)
```

### Error Path: Validación falla

```
1-9. (Mismo proceso hasta formulario)
    ↓
10. Usuario: Deja observaciones vacías
    ↓
11. Click en "Marcar como Completada"
    ↓
12. HTML5 validation: "Por favor, rellena este campo"
    ↓
13. Formulario NO se envía
    ↓
14. Usuario completa el campo
    ↓
15. (Vuelve al happy path)
```

---

## ✅ Checklist de Implementación

### Pantalla 1: Lista de Tareas

- [ ] Navbar responsive
- [ ] Título de página + contador
- [ ] Card de tarea con todos los elementos
- [ ] Hover states
- [ ] Empty state (sin tareas)
- [ ] Link a detalle de tarea
- [ ] Link a abrir URL en nueva pestaña
- [ ] Badge con tipo de tarea
- [ ] Fecha formateada (dd/mm/yyyy)
- [ ] Mobile: Cards en columna
- [ ] Desktop: Cards en grid (opcional)

### Pantalla 2: Completar Tarea

- [ ] Navbar responsive
- [ ] Link "Volver a Tareas"
- [ ] Card con info de tarea (read-only)
- [ ] Botón "Abrir página" en nueva pestaña
- [ ] Textarea para observaciones (required)
- [ ] Input para "Completado por" (required, pre-filled)
- [ ] Validación HTML5
- [ ] Validación JS adicional
- [ ] Confirmación antes de submit
- [ ] Botón "Cancelar" (link a /tasks)
- [ ] Botón "Completar" (submit)
- [ ] Flash message después de submit

### Pantalla 3: Lista de Secciones

- [ ] Navbar responsive
- [ ] Título + contador
- [ ] Tabla HTML (desktop)
- [ ] Cards (mobile)
- [ ] Columnas: ID, Nombre, URL, Estado
- [ ] Badge "✅" para activa, "⭕" para inactiva
- [ ] Link a URL externa
- [ ] Mensaje info sobre funcionalidades futuras
- [ ] Responsive (tabla → cards)

### Componentes Globales

- [ ] Template base con Tailwind CDN
- [ ] Navbar con logo + links + usuario
- [ ] Mobile menu (hamburger)
- [ ] Flash messages (success, error, info)
- [ ] Footer (opcional)
- [ ] Favicon (opcional)

---

## 🎨 Assets y Recursos

### Tailwind CSS CDN

```html
<!-- En base.html <head> -->
<script src="https://cdn.tailwindcss.com"></script>
```

### Iconos

**Opción 1: Emojis (MVP)**
- ✅ Simple, sin dependencias
- ✅ Funciona en todos los navegadores
- ❌ Menos consistentes entre plataformas

```html
📅 Fecha
🔗 Link
✅ Completada
👤 Usuario
🏠 Home
☰ Menu
```

**Opción 2: Heroicons (Futuro)**
```html
<!-- Agregar en <head> -->
<script src="https://unpkg.com/heroicons@2.0.0/24/outline/index.js"></script>
```

### Fuentes

**System Fonts (Default Tailwind)**
```css
font-family: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont,
             "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
```

---

## 📝 Notas de Implementación

### Prioridades

**Día 1 (wireframes):**
- ✅ Diseñar las 3 pantallas completas
- ✅ Definir flujo de navegación
- ✅ Identificar componentes reutilizables
- ✅ Validar con usuario

**Día 2 (implementación):**
1. Navbar + base.html
2. Pantalla 1 (Lista de Tareas) - **Crítica**
3. Pantalla 2 (Completar Tarea) - **Crítica**
4. Pantalla 3 (Secciones) - **Secundaria**
5. Flash messages
6. Mobile menu

**Día 3 (polish):**
- Responsive testing
- UX improvements
- Edge cases

### Simplificaciones para MVP

✅ **Incluido**:
- Emojis como iconos
- Tailwind CDN (no build)
- HTML5 validation
- JS vanilla (no frameworks)
- Flash messages básicos

❌ **NO incluido (futuro)**:
- Login/autenticación
- Editar/crear/eliminar secciones (CRUD)
- Filtros avanzados
- Paginación
- Búsqueda
- Estadísticas
- Dark mode
- Export a PDF/Excel

---

**Última actualización**: 2025-10-28
**Estado**: ✅ Wireframes completos - Listos para implementar
**Próximo paso**: Validar wireframes con usuario → Empezar Día 1 de implementación
