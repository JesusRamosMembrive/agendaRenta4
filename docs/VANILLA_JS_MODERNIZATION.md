# Guía de Modernización de Vanilla JavaScript

**Fecha**: 2025-11-04
**Estado**: Propuesta / Referencia futura
**Esfuerzo estimado**: 3-4 semanas
**Objetivo**: Obtener 80% de los beneficios de React con 20% de la complejidad

---

## Índice

1. [Visión General](#visión-general)
2. [Estado Actual](#estado-actual)
3. [Propuesta de Estructura](#propuesta-de-estructura)
4. [Mejoras por Área](#mejoras-por-área)
5. [Plan de Implementación Incremental](#plan-de-implementación-incremental)
6. [Patrones y Buenas Prácticas](#patrones-y-buenas-prácticas)
7. [Testing Strategy](#testing-strategy)
8. [Beneficios Esperados](#beneficios-esperados)
9. [Decisiones de Diseño](#decisiones-de-diseño)
10. [Recursos y Referencias](#recursos-y-referencias)

---

## Visión General

### Por Qué NO React, Sino Vanilla JS Mejorado

**Razones**:
- ✅ Mantiene simplicidad del stack actual (Stage 3 philosophy)
- ✅ Cero dependencias de runtime (solo dev dependencies)
- ✅ Sin proceso de build obligatorio (opcional para producción)
- ✅ Compatibilidad perfecta con Flask + Jinja2
- ✅ Progressive enhancement preservado
- ✅ Curva de aprendizaje mínima para el equipo
- ✅ Deploy sigue siendo "git push" sin complicaciones

### Qué Ganamos

- 🎯 **Mantenibilidad**: Código organizado y documentado
- 🎯 **Type Safety**: JSDoc + TypeScript checking sin compilación
- 🎯 **Reusabilidad**: Componentes y utilidades compartidas
- 🎯 **Testabilidad**: Arquitectura que facilita testing
- 🎯 **Developer Experience**: Autocomplete, error detection, refactoring tools
- 🎯 **Escalabilidad**: Fácil añadir nuevas features sin enredarse

### Qué NO Perdemos

- ✅ Simplicidad del deployment
- ✅ Server-side rendering (Jinja2)
- ✅ Flask flash messages
- ✅ Progressive enhancement
- ✅ Cero build step (opcional, no obligatorio)

---

## Estado Actual

### Inventario de JavaScript Existente

```
Archivos JavaScript actuales:
├── static/main.js                    # 278 líneas - Lógica principal
│   ├── Desmarcable radio buttons
│   ├── Auto-save con debouncing
│   ├── Row status calculation
│   ├── Search/filter
│   └── Theme toggle
├── static/modal-utils.js             # 229 líneas - Modales reutilizables
│   ├── QualityCheckModal class
│   ├── Progress tracking
│   └── API integration
└── Inline scripts en templates       # ~1,500 líneas distribuidas
    ├── templates/crawler/dashboard.html    (~100 líneas - Polling)
    ├── templates/crawler/test_runner.html  (~350 líneas - Orquestación)
    ├── templates/crawler/quality.html      (~125 líneas - Quality checks)
    ├── templates/inicio.html               (~150 líneas - Form handling)
    └── templates/crawler/tree.html         (~50 líneas - Tree toggling)

Total: ~2,000 líneas de JavaScript
```

### Análisis de Patrones Actuales

**Fortalezas** ✅:
- Vanilla JS moderno (ES6+, no jQuery)
- Fetch API para AJAX
- CSS Variables para theming
- Clases ES6 (modal-utils.js)
- LocalStorage para persistencia
- Debouncing implementado

**Áreas de Mejora** 🔧:
- Código disperso en templates (difícil mantener)
- Inline event handlers (`onclick="..."`)
- No hay separación de concerns clara
- Sin type safety (propenso a errores)
- Testing difícil (acoplado al DOM)
- Duplicación de lógica (fetch patterns, error handling)

### Métricas de Complejidad

```javascript
// Complejidad ciclomática estimada
main.js:                 ~15 (medio-alto)
modal-utils.js:          ~12 (medio)
Inline scripts:          ~25 (alto, difícil de testear)

// Acoplamiento
Templates ↔ JS:          Alto (inline handlers, global functions)
JS ↔ Backend API:        Medio (fetch disperso, sin capa consistente)
JS ↔ DOM:                Alto (querySelector everywhere, difícil mock)
```

---

## Propuesta de Estructura

### Nueva Organización de Carpetas

```
static/
├── js/
│   ├── lib/                          # Librerías internas (0 dependencias)
│   │   ├── state-manager.js          # State management simple
│   │   ├── api-client.js             # Wrapper de Fetch API
│   │   ├── dom-utils.js              # Utilidades DOM comunes
│   │   ├── event-bus.js              # Pub/sub para desacoplar
│   │   └── storage.js                # LocalStorage wrapper con types
│   │
│   ├── components/                   # Componentes reutilizables
│   │   ├── base-component.js         # Base class para componentes
│   │   ├── task-row.js               # Lógica de fila de tarea
│   │   ├── progress-tracker.js       # Progress bar + polling
│   │   ├── quality-modal.js          # Modal de calidad (refactor actual)
│   │   ├── search-filter.js          # Búsqueda/filtrado genérico
│   │   ├── theme-toggle.js           # Dark/light mode
│   │   ├── tree-node.js              # Árbol expandible
│   │   └── auto-save-form.js         # Form con auto-save
│   │
│   ├── pages/                        # Scripts específicos por página
│   │   ├── inicio.js                 # Lógica de página de inicio
│   │   ├── pendientes.js             # Página de tareas pendientes
│   │   ├── crawler-dashboard.js      # Crawler dashboard
│   │   ├── crawler-test-runner.js    # Test runner UI
│   │   ├── quality-checks.js         # Quality checks page
│   │   └── tree-view.js              # Tree view page
│   │
│   ├── services/                     # Lógica de negocio
│   │   ├── task-service.js           # CRUD de tareas
│   │   ├── crawler-service.js        # Crawler operations
│   │   ├── quality-service.js        # Quality checks operations
│   │   └── alert-service.js          # Gestión de alertas
│   │
│   ├── utils/                        # Utilidades genéricas
│   │   ├── debounce.js               # Debouncing function
│   │   ├── date-utils.js             # Formateo de fechas
│   │   ├── validators.js             # Validación de inputs
│   │   └── formatters.js             # Formateo de strings, números
│   │
│   ├── types/                        # JSDoc type definitions
│   │   ├── task.types.js             # @typedef para Task
│   │   ├── crawler.types.js          # @typedef para Crawler
│   │   └── api.types.js              # @typedef para API responses
│   │
│   └── main.js                       # Entry point (initialization)
│
├── css/
│   └── main.css                      # (sin cambios por ahora)
│
└── (archivos actuales quedan igual temporalmente)
```

### Filosofía de Carpetas

**`lib/`**: Código de infraestructura, reutilizable en cualquier proyecto
**`components/`**: UI components con comportamiento, específicos del proyecto
**`pages/`**: Lógica específica de cada página, orquesta components + services
**`services/`**: Business logic, comunicación con backend
**`utils/`**: Funciones puras, helpers sin estado
**`types/`**: Definiciones de tipos para JSDoc

---

## Mejoras por Área

### 1. Type Safety con JSDoc + TypeScript

**Sin compilación, solo type checking en desarrollo**

#### Setup (5 minutos)

```bash
# Instalar TypeScript solo como dev dependency
npm init -y
npm install --save-dev typescript

# Crear tsconfig.json
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "allowJs": true,
    "checkJs": false,  // No forzar checking en todos los .js
    "noEmit": true,     // SOLO type checking, sin compilación
    "target": "ES2020",
    "module": "ES2020",
    "moduleResolution": "node",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true
  },
  "include": ["static/js/**/*.js"],
  "exclude": ["node_modules"]
}
EOF

# Script en package.json
cat > package.json << 'EOF'
{
  "name": "agendarenta4-frontend",
  "version": "1.0.0",
  "scripts": {
    "typecheck": "tsc",
    "typecheck:watch": "tsc --watch"
  },
  "devDependencies": {
    "typescript": "^5.3.0"
  }
}
EOF
```

#### Ejemplo de Uso

**Antes** (sin types):
```javascript
// static/main.js
function updateTask(taskId, status) {
    fetch(`/tasks/update`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({task_id: taskId, status: status})
    })
    .then(r => r.json())
    .then(data => console.log(data));
}
```

**Después** (con JSDoc types):
```javascript
// static/js/types/task.types.js
/**
 * @typedef {Object} Task
 * @property {number} id
 * @property {number} url_id
 * @property {number} task_type_id
 * @property {'ok'|'problem'|'pending'} status
 * @property {string|null} observations
 * @property {string} period
 */

/**
 * @typedef {Object} TaskUpdateRequest
 * @property {number} task_id
 * @property {'ok'|'problem'|'pending'} status
 */

/**
 * @typedef {Object} TaskUpdateResponse
 * @property {boolean} success
 * @property {string} [error]
 */

// static/js/services/task-service.js
import { apiClient } from '../lib/api-client.js';

/**
 * Actualiza el estado de una tarea
 * @param {number} taskId - ID de la tarea
 * @param {'ok'|'problem'|'pending'} status - Nuevo estado
 * @returns {Promise<TaskUpdateResponse>}
 */
export async function updateTask(taskId, status) {
    return apiClient.post('/tasks/update', {
        task_id: taskId,
        status: status
    });
}
```

**Beneficios inmediatos**:
- ✅ VS Code autocomplete funciona perfectamente
- ✅ Detecta typos: `updateTask(123, 'okk')` → error
- ✅ Verifica tipos: `updateTask('abc', 'ok')` → error
- ✅ Documentación inline (hover muestra JSDoc)
- ✅ Refactoring seguro (rename, find references)

#### Type Definitions para API Responses

```javascript
// static/js/types/api.types.js

/**
 * @typedef {Object} ApiError
 * @property {boolean} success - false
 * @property {string} error - Mensaje de error
 */

/**
 * @template T
 * @typedef {Object} ApiSuccess
 * @property {boolean} success - true
 * @property {T} data - Datos de respuesta
 */

/**
 * @template T
 * @typedef {ApiSuccess<T> | ApiError} ApiResponse
 */

/**
 * @typedef {Object} CrawlerProgress
 * @property {boolean} is_running
 * @property {number} urls_discovered
 * @property {string|null} last_url
 * @property {number} elapsed_time
 * @property {number} estimated_remaining
 */

// Uso:
/**
 * @returns {Promise<ApiResponse<CrawlerProgress>>}
 */
export async function getCrawlerProgress() {
    return apiClient.get('/crawler/progress');
}
```

---

### 2. API Client Unificado

**Centralizar todos los fetch calls**

```javascript
// static/js/lib/api-client.js

/**
 * Cliente HTTP unificado para todas las peticiones
 */
class ApiClient {
    constructor(baseURL = '') {
        this.baseURL = baseURL;
        this.defaultHeaders = {
            'Content-Type': 'application/json'
        };
    }

    /**
     * @private
     * @param {string} url
     * @param {RequestInit} options
     * @returns {Promise<any>}
     */
    async _request(url, options) {
        const fullURL = this.baseURL + url;

        try {
            const response = await fetch(fullURL, {
                ...options,
                headers: {
                    ...this.defaultHeaders,
                    ...options.headers
                }
            });

            // Manejar errores HTTP
            if (!response.ok) {
                const errorData = await response.json().catch(() => ({}));
                throw new ApiError(
                    errorData.error || `HTTP ${response.status}`,
                    response.status,
                    errorData
                );
            }

            return await response.json();
        } catch (error) {
            if (error instanceof ApiError) throw error;

            // Network errors, timeout, etc.
            throw new ApiError(
                'Error de conexión',
                0,
                { originalError: error.message }
            );
        }
    }

    /**
     * GET request
     * @param {string} url
     * @param {Object} [params] - Query parameters
     * @returns {Promise<any>}
     */
    async get(url, params = {}) {
        const queryString = new URLSearchParams(params).toString();
        const fullURL = queryString ? `${url}?${queryString}` : url;

        return this._request(fullURL, {
            method: 'GET'
        });
    }

    /**
     * POST request
     * @param {string} url
     * @param {Object} data - Request body
     * @returns {Promise<any>}
     */
    async post(url, data) {
        return this._request(url, {
            method: 'POST',
            body: JSON.stringify(data)
        });
    }

    /**
     * PUT request
     * @param {string} url
     * @param {Object} data - Request body
     * @returns {Promise<any>}
     */
    async put(url, data) {
        return this._request(url, {
            method: 'PUT',
            body: JSON.stringify(data)
        });
    }

    /**
     * DELETE request
     * @param {string} url
     * @returns {Promise<any>}
     */
    async delete(url) {
        return this._request(url, {
            method: 'DELETE'
        });
    }
}

/**
 * Custom error class para errores de API
 */
class ApiError extends Error {
    /**
     * @param {string} message
     * @param {number} status
     * @param {Object} data
     */
    constructor(message, status, data) {
        super(message);
        this.name = 'ApiError';
        this.status = status;
        this.data = data;
    }
}

// Singleton instance
export const apiClient = new ApiClient();
export { ApiError };
```

**Uso**:

```javascript
// Antes (disperso en templates):
fetch('/tasks/update', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({task_id: 123, status: 'ok'})
})
.then(r => r.json())
.then(data => {
    if (data.success) {
        alert('Guardado');
    } else {
        alert('Error: ' + data.error);
    }
})
.catch(err => alert('Error de conexión'));

// Después (centralizado):
import { apiClient, ApiError } from '../lib/api-client.js';
import { updateTask } from '../services/task-service.js';

try {
    const result = await updateTask(123, 'ok');
    showSuccessMessage('Tarea actualizada');
} catch (error) {
    if (error instanceof ApiError) {
        showErrorMessage(`Error: ${error.message}`);
    } else {
        showErrorMessage('Error inesperado');
    }
}
```

---

### 3. State Management Simple

**No Redux, solo un EventBus + State Store ligero**

```javascript
// static/js/lib/event-bus.js

/**
 * Event Bus para comunicación desacoplada entre componentes
 * Patrón Pub/Sub simple
 */
class EventBus {
    constructor() {
        /** @type {Map<string, Set<Function>>} */
        this.listeners = new Map();
    }

    /**
     * Suscribirse a un evento
     * @param {string} event - Nombre del evento
     * @param {Function} callback - Función a ejecutar
     * @returns {Function} Unsubscribe function
     */
    on(event, callback) {
        if (!this.listeners.has(event)) {
            this.listeners.set(event, new Set());
        }
        this.listeners.get(event).add(callback);

        // Return unsubscribe function
        return () => this.off(event, callback);
    }

    /**
     * Desuscribirse de un evento
     * @param {string} event
     * @param {Function} callback
     */
    off(event, callback) {
        if (!this.listeners.has(event)) return;
        this.listeners.get(event).delete(callback);
    }

    /**
     * Emitir un evento
     * @param {string} event
     * @param {any} data
     */
    emit(event, data) {
        if (!this.listeners.has(event)) return;

        this.listeners.get(event).forEach(callback => {
            try {
                callback(data);
            } catch (error) {
                console.error(`Error in event listener for "${event}":`, error);
            }
        });
    }

    /**
     * Suscribirse solo una vez
     * @param {string} event
     * @param {Function} callback
     */
    once(event, callback) {
        const unsubscribe = this.on(event, (data) => {
            unsubscribe();
            callback(data);
        });
    }
}

// Singleton
export const eventBus = new EventBus();
```

```javascript
// static/js/lib/state-manager.js

import { eventBus } from './event-bus.js';

/**
 * Simple state manager con reactividad
 * Similar a Vue's reactive() pero más simple
 */
class StateManager {
    constructor() {
        /** @type {Map<string, any>} */
        this.stores = new Map();
    }

    /**
     * Crear o obtener un store
     * @template T
     * @param {string} storeName
     * @param {T} initialState
     * @returns {T & {subscribe: Function, update: Function}}
     */
    createStore(storeName, initialState) {
        if (this.stores.has(storeName)) {
            return this.stores.get(storeName);
        }

        const state = { ...initialState };

        const store = {
            /**
             * Get current state
             */
            get: () => ({ ...state }),

            /**
             * Update state and notify subscribers
             * @param {Partial<T>} updates
             */
            update: (updates) => {
                Object.assign(state, updates);
                eventBus.emit(`state:${storeName}`, state);
            },

            /**
             * Subscribe to state changes
             * @param {Function} callback
             * @returns {Function} unsubscribe
             */
            subscribe: (callback) => {
                return eventBus.on(`state:${storeName}`, callback);
            },

            /**
             * Reset to initial state
             */
            reset: () => {
                Object.assign(state, initialState);
                eventBus.emit(`state:${storeName}`, state);
            }
        };

        this.stores.set(storeName, store);
        return store;
    }

    /**
     * Get existing store
     * @param {string} storeName
     * @returns {any}
     */
    getStore(storeName) {
        return this.stores.get(storeName);
    }
}

// Singleton
export const stateManager = new StateManager();
```

**Ejemplo de Uso**:

```javascript
// static/js/pages/crawler-dashboard.js

import { stateManager } from '../lib/state-manager.js';

// Crear store para crawler progress
const crawlerStore = stateManager.createStore('crawler', {
    isRunning: false,
    urlsDiscovered: 0,
    lastUrl: null,
    elapsedTime: 0,
    estimatedRemaining: 0
});

// Component A: Actualiza el estado
async function pollProgress() {
    const progress = await apiClient.get('/crawler/progress');
    crawlerStore.update(progress);
}

// Component B: Reacciona a cambios (sin conocer Component A)
crawlerStore.subscribe((state) => {
    document.getElementById('urls-count').textContent = state.urlsDiscovered;
    document.getElementById('last-url').textContent = state.lastUrl || 'N/A';
});

// Component C: También reacciona
crawlerStore.subscribe((state) => {
    const progressBar = document.getElementById('progress-bar');
    if (state.isRunning) {
        progressBar.classList.add('active');
    } else {
        progressBar.classList.remove('active');
    }
});
```

---

### 4. Componentes Reutilizables

**Base Component Class**

```javascript
// static/js/components/base-component.js

/**
 * Base class para todos los componentes
 * Maneja lifecycle, eventos, y cleanup
 */
export class BaseComponent {
    /**
     * @param {HTMLElement} element - Elemento raíz del componente
     */
    constructor(element) {
        this.element = element;
        this.listeners = [];
        this.mounted = false;
    }

    /**
     * Lifecycle: Montar componente
     * Override en subclasses
     */
    mount() {
        if (this.mounted) return;
        this.mounted = true;
        this.onMount();
    }

    /**
     * Lifecycle: Desmontar componente
     * Limpia event listeners automáticamente
     */
    unmount() {
        if (!this.mounted) return;
        this.mounted = false;
        this.cleanup();
        this.onUnmount();
    }

    /**
     * Override: Lógica al montar
     */
    onMount() {}

    /**
     * Override: Lógica al desmontar
     */
    onUnmount() {}

    /**
     * Añadir event listener con cleanup automático
     * @param {EventTarget} target
     * @param {string} event
     * @param {Function} handler
     * @param {Object} [options]
     */
    addEventListener(target, event, handler, options) {
        target.addEventListener(event, handler, options);
        this.listeners.push({ target, event, handler, options });
    }

    /**
     * Cleanup: Remover todos los event listeners
     */
    cleanup() {
        this.listeners.forEach(({ target, event, handler, options }) => {
            target.removeEventListener(event, handler, options);
        });
        this.listeners = [];
    }

    /**
     * Query selector dentro del componente
     * @param {string} selector
     * @returns {HTMLElement|null}
     */
    $(selector) {
        return this.element.querySelector(selector);
    }

    /**
     * Query selector all dentro del componente
     * @param {string} selector
     * @returns {NodeListOf<HTMLElement>}
     */
    $$(selector) {
        return this.element.querySelectorAll(selector);
    }
}
```

**Ejemplo: Progress Tracker Component**

```javascript
// static/js/components/progress-tracker.js

import { BaseComponent } from './base-component.js';
import { apiClient } from '../lib/api-client.js';
import { stateManager } from '../lib/state-manager.js';

/**
 * Componente para tracking de progreso con polling
 */
export class ProgressTracker extends BaseComponent {
    /**
     * @param {HTMLElement} element
     * @param {Object} options
     * @param {string} options.endpoint - URL del endpoint de progreso
     * @param {number} [options.interval=2000] - Intervalo de polling (ms)
     * @param {Function} [options.onComplete] - Callback al completar
     */
    constructor(element, options) {
        super(element);
        this.options = options;
        this.intervalId = null;
        this.store = stateManager.createStore('progress-tracker', {
            isRunning: false,
            progress: 0,
            message: ''
        });
    }

    onMount() {
        // Bind UI elements
        this.progressBar = this.$('.progress-bar');
        this.progressText = this.$('.progress-text');
        this.startButton = this.$('.start-button');
        this.stopButton = this.$('.stop-button');

        // Event listeners con cleanup automático
        this.addEventListener(this.startButton, 'click', () => this.start());
        this.addEventListener(this.stopButton, 'click', () => this.stop());

        // Subscribe a cambios de estado
        this.unsubscribe = this.store.subscribe((state) => {
            this.render(state);
        });
    }

    onUnmount() {
        this.stop();
        if (this.unsubscribe) this.unsubscribe();
    }

    async start() {
        if (this.store.get().isRunning) return;

        this.store.update({ isRunning: true, progress: 0 });
        this.intervalId = setInterval(() => this.poll(), this.options.interval);
    }

    stop() {
        if (this.intervalId) {
            clearInterval(this.intervalId);
            this.intervalId = null;
        }
        this.store.update({ isRunning: false });
    }

    async poll() {
        try {
            const data = await apiClient.get(this.options.endpoint);

            this.store.update({
                progress: data.progress || 0,
                message: data.message || ''
            });

            // Check si completó
            if (data.is_complete) {
                this.stop();
                if (this.options.onComplete) {
                    this.options.onComplete(data);
                }
            }
        } catch (error) {
            console.error('Error polling progress:', error);
            this.stop();
        }
    }

    render(state) {
        if (this.progressBar) {
            this.progressBar.style.width = `${state.progress}%`;
        }
        if (this.progressText) {
            this.progressText.textContent = state.message;
        }

        // Toggle buttons
        if (this.startButton && this.stopButton) {
            this.startButton.disabled = state.isRunning;
            this.stopButton.disabled = !state.isRunning;
        }
    }
}
```

**Uso en HTML**:

```html
<!-- templates/crawler/dashboard.html -->
<div id="progress-tracker" class="progress-tracker">
    <div class="progress-bar-container">
        <div class="progress-bar"></div>
    </div>
    <div class="progress-text">Esperando inicio...</div>
    <button class="start-button">Iniciar Crawl</button>
    <button class="stop-button" disabled>Detener</button>
</div>

<script type="module">
    import { ProgressTracker } from '/static/js/components/progress-tracker.js';

    const tracker = new ProgressTracker(
        document.getElementById('progress-tracker'),
        {
            endpoint: '/crawler/progress',
            interval: 2000,
            onComplete: (data) => {
                alert('Crawl completado!');
                window.location.reload();
            }
        }
    );

    tracker.mount();

    // Cleanup al salir de la página
    window.addEventListener('beforeunload', () => tracker.unmount());
</script>
```

---

### 5. Event Delegation (No más inline handlers)

**Antes** (inline onclick):
```html
<button onclick="updateTask(123, 'ok')">Marcar OK</button>
<button onclick="updateTask(123, 'problem')">Marcar Problema</button>
```

**Después** (event delegation):

```javascript
// static/js/pages/inicio.js

import { updateTask } from '../services/task-service.js';

/**
 * Inicializar página de inicio
 */
export function initInicioPage() {
    const tasksContainer = document.getElementById('tasks-container');

    // Event delegation: un solo listener para todos los botones
    tasksContainer.addEventListener('click', async (e) => {
        const button = e.target.closest('[data-action]');
        if (!button) return;

        const action = button.dataset.action;
        const taskId = parseInt(button.dataset.taskId);

        switch (action) {
            case 'update-status':
                const status = button.dataset.status;
                await handleUpdateStatus(taskId, status);
                break;
            case 'view-details':
                await handleViewDetails(taskId);
                break;
            case 'delete':
                await handleDelete(taskId);
                break;
        }
    });
}

async function handleUpdateStatus(taskId, status) {
    try {
        await updateTask(taskId, status);
        // Actualizar UI
        const row = document.querySelector(`[data-task-id="${taskId}"]`);
        row.dataset.status = status;
        row.classList.remove('ok', 'problem', 'pending');
        row.classList.add(status);
    } catch (error) {
        showErrorMessage('Error al actualizar tarea');
    }
}
```

```html
<!-- HTML actualizado -->
<div id="tasks-container">
    <div class="task-row" data-task-id="123" data-status="pending">
        <span class="task-name">Tarea ejemplo</span>
        <button data-action="update-status" data-task-id="123" data-status="ok">
            OK
        </button>
        <button data-action="update-status" data-task-id="123" data-status="problem">
            Problema
        </button>
        <button data-action="view-details" data-task-id="123">
            Ver Detalles
        </button>
    </div>
</div>
```

**Beneficios**:
- ✅ Menos event listeners (mejor performance)
- ✅ Funciona con elementos añadidos dinámicamente
- ✅ JavaScript desacoplado del HTML
- ✅ Más fácil de testear

---

### 6. Servicios de Negocio

**Separar lógica de negocio de UI**

```javascript
// static/js/services/task-service.js

import { apiClient } from '../lib/api-client.js';

/**
 * @typedef {import('../types/task.types.js').Task} Task
 * @typedef {import('../types/task.types.js').TaskUpdateResponse} TaskUpdateResponse
 */

/**
 * Servicio para gestión de tareas
 */
export const taskService = {
    /**
     * Obtener tareas por período
     * @param {string} period - Período en formato YYYY-MM
     * @returns {Promise<Task[]>}
     */
    async getTasksByPeriod(period) {
        const response = await apiClient.get('/api/tasks', { period });
        return response.data;
    },

    /**
     * Obtener tareas pendientes
     * @returns {Promise<Task[]>}
     */
    async getPendingTasks() {
        const response = await apiClient.get('/api/tasks', { status: 'pending' });
        return response.data;
    },

    /**
     * Actualizar estado de tarea
     * @param {number} taskId
     * @param {'ok'|'problem'|'pending'} status
     * @returns {Promise<TaskUpdateResponse>}
     */
    async updateTask(taskId, status) {
        return apiClient.post('/tasks/update', {
            task_id: taskId,
            status: status
        });
    },

    /**
     * Guardar observaciones
     * @param {number} taskId
     * @param {string} observations
     * @returns {Promise<TaskUpdateResponse>}
     */
    async saveObservations(taskId, observations) {
        return apiClient.post('/save_observations', {
            task_id: taskId,
            observations: observations
        });
    },

    /**
     * Calcular estado agregado de URL
     * @param {Task[]} tasks - Tareas de una URL
     * @returns {'ok'|'problem'|'pending'|'mixed'}
     */
    calculateAggregateStatus(tasks) {
        if (tasks.length === 0) return 'pending';

        const statuses = tasks.map(t => t.status);
        const uniqueStatuses = [...new Set(statuses)];

        if (uniqueStatuses.length === 1) return uniqueStatuses[0];
        if (statuses.includes('problem')) return 'problem';
        if (statuses.includes('pending')) return 'pending';
        return 'mixed';
    }
};
```

```javascript
// static/js/services/crawler-service.js

import { apiClient } from '../lib/api-client.js';

/**
 * Servicio para operaciones del crawler
 */
export const crawlerService = {
    /**
     * Iniciar crawl
     * @param {Object} options
     * @param {string} options.start_url
     * @param {number} [options.max_depth]
     * @returns {Promise<{crawl_run_id: number}>}
     */
    async startCrawl(options) {
        return apiClient.post('/crawler/start', options);
    },

    /**
     * Obtener progreso del crawl
     * @returns {Promise<import('../types/crawler.types.js').CrawlerProgress>}
     */
    async getProgress() {
        return apiClient.get('/crawler/progress');
    },

    /**
     * Obtener resultados del último crawl
     * @returns {Promise<Object>}
     */
    async getResults() {
        const response = await apiClient.get('/crawler/results');
        return response.data;
    },

    /**
     * Ejecutar quality checks
     * @param {Object} options
     * @param {string[]} options.check_types
     * @param {'priority'|'all'} options.scope
     * @returns {Promise<{batch_id: number}>}
     */
    async runQualityChecks(options) {
        return apiClient.post('/crawler/quality/run', options);
    }
};
```

---

### 7. Utilidades y Helpers

```javascript
// static/js/utils/debounce.js

/**
 * Debounce function execution
 * @param {Function} func - Function to debounce
 * @param {number} wait - Wait time in ms
 * @returns {Function}
 */
export function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

/**
 * Throttle function execution
 * @param {Function} func - Function to throttle
 * @param {number} limit - Limit time in ms
 * @returns {Function}
 */
export function throttle(func, limit) {
    let inThrottle;
    return function(...args) {
        if (!inThrottle) {
            func.apply(this, args);
            inThrottle = true;
            setTimeout(() => inThrottle = false, limit);
        }
    };
}
```

```javascript
// static/js/utils/dom-utils.js

/**
 * Crear elemento DOM con atributos
 * @param {string} tag
 * @param {Object} [attrs]
 * @param {string|HTMLElement[]} [children]
 * @returns {HTMLElement}
 */
export function createElement(tag, attrs = {}, children = []) {
    const element = document.createElement(tag);

    Object.entries(attrs).forEach(([key, value]) => {
        if (key === 'className') {
            element.className = value;
        } else if (key === 'dataset') {
            Object.assign(element.dataset, value);
        } else if (key.startsWith('on')) {
            element.addEventListener(key.slice(2).toLowerCase(), value);
        } else {
            element.setAttribute(key, value);
        }
    });

    if (typeof children === 'string') {
        element.textContent = children;
    } else {
        children.forEach(child => {
            if (typeof child === 'string') {
                element.appendChild(document.createTextNode(child));
            } else {
                element.appendChild(child);
            }
        });
    }

    return element;
}

/**
 * Show/hide element
 * @param {HTMLElement} element
 * @param {boolean} show
 */
export function toggleVisibility(element, show) {
    element.style.display = show ? '' : 'none';
}

/**
 * Disable/enable element
 * @param {HTMLElement} element
 * @param {boolean} disabled
 */
export function setDisabled(element, disabled) {
    if (disabled) {
        element.setAttribute('disabled', '');
    } else {
        element.removeAttribute('disabled');
    }
}

/**
 * Add/remove loading state
 * @param {HTMLElement} element
 * @param {boolean} loading
 */
export function setLoading(element, loading) {
    if (loading) {
        element.classList.add('loading');
        element.setAttribute('aria-busy', 'true');
    } else {
        element.classList.remove('loading');
        element.removeAttribute('aria-busy');
    }
}
```

```javascript
// static/js/utils/validators.js

/**
 * Validar URL
 * @param {string} url
 * @returns {boolean}
 */
export function isValidURL(url) {
    try {
        new URL(url);
        return true;
    } catch {
        return false;
    }
}

/**
 * Validar email
 * @param {string} email
 * @returns {boolean}
 */
export function isValidEmail(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email);
}

/**
 * Validar que no esté vacío
 * @param {string} value
 * @returns {boolean}
 */
export function isNotEmpty(value) {
    return value != null && value.trim().length > 0;
}

/**
 * Validar número en rango
 * @param {number} value
 * @param {number} min
 * @param {number} max
 * @returns {boolean}
 */
export function isInRange(value, min, max) {
    return typeof value === 'number' && value >= min && value <= max;
}
```

---

## Plan de Implementación Incremental

### Fase 0: Setup (1 día)

**No romper nada existente**

```bash
# 1. Crear estructura de carpetas
mkdir -p static/js/{lib,components,pages,services,utils,types}

# 2. Setup TypeScript checking (opcional, recomendado)
npm init -y
npm install --save-dev typescript
# Crear tsconfig.json (ver sección Type Safety)

# 3. Añadir scripts a package.json
npm pkg set scripts.typecheck="tsc"
npm pkg set scripts.typecheck:watch="tsc --watch"

# 4. Git: No commitear node_modules
echo "node_modules/" >> .gitignore
```

### Fase 1: Infraestructura (3-4 días)

**Crear librerías base sin tocar código existente**

1. ✅ Implementar `lib/api-client.js`
2. ✅ Implementar `lib/event-bus.js`
3. ✅ Implementar `lib/state-manager.js`
4. ✅ Implementar `lib/dom-utils.js`
5. ✅ Implementar `lib/storage.js`
6. ✅ Crear type definitions en `types/`
7. ✅ Escribir tests unitarios para libs

**Testing**:
```bash
# Instalar Jest
npm install --save-dev jest @types/jest

# Crear jest.config.js
cat > jest.config.js << 'EOF'
export default {
    testEnvironment: 'jsdom',
    transform: {},
    moduleNameMapper: {
        '^@/(.*)$': '<rootDir>/static/js/$1'
    }
};
EOF

# Ejecutar tests
npm test
```

### Fase 2: Servicios (2-3 días)

**Encapsular llamadas API existentes**

1. ✅ Implementar `services/task-service.js`
2. ✅ Implementar `services/crawler-service.js`
3. ✅ Implementar `services/quality-service.js`
4. ✅ Implementar `services/alert-service.js`
5. ✅ Tests de integración (mock fetch)

**Todavía no cambiar templates, solo crear servicios**

### Fase 3: Utilidades (2 días)

**Extraer lógica repetida**

1. ✅ `utils/debounce.js` (ya existe lógica en main.js)
2. ✅ `utils/validators.js`
3. ✅ `utils/formatters.js`
4. ✅ `utils/date-utils.js`

### Fase 4: Componente Base (1 día)

1. ✅ Implementar `components/base-component.js`
2. ✅ Documentar API del componente
3. ✅ Crear ejemplo funcional

### Fase 5: Migrar Primer Componente (2-3 días)

**Elegir el más simple: Theme Toggle**

1. ✅ Crear `components/theme-toggle.js`
2. ✅ Migrar lógica de main.js
3. ✅ Actualizar template para usar el componente
4. ✅ Testear que todo funcione igual
5. ✅ **PUNTO DE DECISIÓN**: Si funciona bien, continuar. Si hay problemas, revisar approach.

**Ejemplo**:

```javascript
// static/js/components/theme-toggle.js

import { BaseComponent } from './base-component.js';
import { storage } from '../lib/storage.js';

export class ThemeToggle extends BaseComponent {
    onMount() {
        this.button = this.element;
        this.currentTheme = storage.get('theme') || 'light';

        // Apply theme immediately
        this.applyTheme(this.currentTheme);

        // Event listener
        this.addEventListener(this.button, 'click', () => this.toggle());
    }

    toggle() {
        this.currentTheme = this.currentTheme === 'light' ? 'dark' : 'light';
        this.applyTheme(this.currentTheme);
        storage.set('theme', this.currentTheme);
    }

    applyTheme(theme) {
        document.documentElement.setAttribute('data-theme', theme);
        this.button.textContent = theme === 'light' ? '🌙' : '☀️';
    }
}
```

### Fase 6: Migrar Componentes Complejos (1-2 semanas)

**Uno por uno, testeando cada cambio**

1. ✅ `components/progress-tracker.js` (crawler progress)
2. ✅ `components/quality-modal.js` (refactor de modal-utils.js)
3. ✅ `components/task-row.js` (lógica de filas en inicio.html)
4. ✅ `components/auto-save-form.js` (auto-save con debouncing)
5. ✅ `components/search-filter.js` (búsqueda en tablas)
6. ✅ `components/tree-node.js` (árbol expandible)

**Después de cada componente**:
- Testear en desarrollo
- Testear en producción (staging)
- Recolectar feedback
- Iterar si es necesario

### Fase 7: Migrar Páginas (1 semana)

**Convertir scripts inline a page modules**

1. ✅ `pages/inicio.js` (orquestar task-row + auto-save)
2. ✅ `pages/crawler-dashboard.js` (orquestar progress-tracker)
3. ✅ `pages/crawler-test-runner.js` (orquestar quality checks)
4. ✅ `pages/quality-checks.js`
5. ✅ `pages/tree-view.js`

**Actualizar templates**:

```html
<!-- Antes: inline script -->
<script>
    function startCrawl() {
        // 100 líneas de código inline...
    }
</script>

<!-- Después: import module -->
<script type="module">
    import { initCrawlerDashboard } from '/static/js/pages/crawler-dashboard.js';

    document.addEventListener('DOMContentLoaded', () => {
        initCrawlerDashboard();
    });
</script>
```

### Fase 8: Refactoring y Optimización (3-5 días)

1. ✅ Eliminar código duplicado
2. ✅ Mejorar cobertura de tests
3. ✅ Performance audit (bundle size, load time)
4. ✅ Accessibility audit
5. ✅ Documentación completa (README en cada carpeta)

### Fase 9: Build Tooling (Opcional, 2-3 días)

**Solo si queremos optimización adicional**

```bash
# Instalar Vite (build tool moderno, zero-config)
npm install --save-dev vite

# vite.config.js
export default {
    root: 'static',
    build: {
        outDir: '../dist/static',
        rollupOptions: {
            input: {
                main: 'static/js/main.js'
            }
        }
    }
};

# Scripts
npm pkg set scripts.dev="vite"
npm pkg set scripts.build="vite build"
```

**Beneficios del build**:
- Minificación (~50% menos tamaño)
- Tree-shaking (eliminar código no usado)
- Bundling (menos HTTP requests)
- Source maps para debugging

**Trade-off**:
- Añade complejidad
- Deploy más complejo
- Solo vale la pena si el bundle crece mucho

### Cronograma Total

```
Semana 1:
- Día 1: Setup + infraestructura (event bus, state manager)
- Día 2: API client + types
- Día 3: Servicios (task, crawler)
- Día 4: Utilidades + componente base
- Día 5: Primer componente (theme toggle) + testing

Semana 2:
- Día 1-2: Progress tracker component
- Día 3-4: Quality modal component
- Día 5: Task row component + auto-save

Semana 3:
- Día 1-2: Migrar página inicio.html
- Día 3-4: Migrar crawler dashboard
- Día 5: Migrar test runner

Semana 4 (opcional):
- Día 1-2: Tree view + quality checks pages
- Día 3: Refactoring
- Día 4: Tests + documentación
- Día 5: Build tooling (si se necesita)
```

---

## Patrones y Buenas Prácticas

### 1. Naming Conventions

```javascript
// Variables y funciones: camelCase
const userName = 'John';
function getUserData() {}

// Clases y Componentes: PascalCase
class TaskService {}
class ProgressTracker extends BaseComponent {}

// Constantes: SCREAMING_SNAKE_CASE
const API_BASE_URL = '/api';
const MAX_RETRY_ATTEMPTS = 3;

// Archivos: kebab-case
// task-service.js, progress-tracker.js, api-client.js

// Componentes DOM: data-attributes kebab-case
<button data-action="update-task" data-task-id="123">
```

### 2. Module Organization

```javascript
// Cada archivo: una responsabilidad clara
// ✅ Bueno: task-service.js exporta taskService
// ❌ Malo: utils.js exporta 50 funciones random

// Imports ordenados:
// 1. Node modules (si hubiera)
// 2. Libs internas
// 3. Components
// 4. Services
// 5. Utils
// 6. Types

import { apiClient } from '../lib/api-client.js';
import { ProgressTracker } from '../components/progress-tracker.js';
import { taskService } from '../services/task-service.js';
import { debounce } from '../utils/debounce.js';
/**
 * @typedef {import('../types/task.types.js').Task} Task
 */
```

### 3. Error Handling

```javascript
// SIEMPRE manejar errores en llamadas async
// ✅ Bueno:
try {
    const result = await taskService.updateTask(id, status);
    showSuccessMessage('Tarea actualizada');
} catch (error) {
    if (error instanceof ApiError) {
        showErrorMessage(`Error: ${error.message}`);
    } else {
        console.error('Unexpected error:', error);
        showErrorMessage('Error inesperado');
    }
}

// ❌ Malo:
taskService.updateTask(id, status); // Sin await, sin catch
```

### 4. Evitar Memory Leaks

```javascript
// SIEMPRE limpiar event listeners
// ✅ Bueno: Usar BaseComponent que limpia automáticamente
class MyComponent extends BaseComponent {
    onMount() {
        this.addEventListener(window, 'resize', this.handleResize);
    }
    // onUnmount limpia automáticamente
}

// ✅ Bueno: Cleanup manual si no usas BaseComponent
function initPage() {
    const handler = () => console.log('resize');
    window.addEventListener('resize', handler);

    // Cleanup al salir
    window.addEventListener('beforeunload', () => {
        window.removeEventListener('resize', handler);
    });
}

// ❌ Malo: Añadir listeners sin cleanup
window.addEventListener('resize', () => console.log('resize'));
```

### 5. Progressive Enhancement

```javascript
// El HTML base debe funcionar sin JavaScript
// JavaScript solo mejora la UX

// ✅ Bueno: Form tradicional + AJAX enhancement
<form action="/tasks/update" method="POST" id="task-form">
    <input name="task_id" value="123">
    <button type="submit">Guardar</button>
</form>

<script type="module">
    // Enhance con AJAX solo si JS disponible
    document.getElementById('task-form').addEventListener('submit', async (e) => {
        e.preventDefault(); // Prevent traditional submit
        // AJAX submission...
    });
</script>
```

### 6. Accessibility

```javascript
// SIEMPRE considerar accesibilidad
// - Keyboard navigation
// - Screen readers (ARIA)
// - Focus management

function showModal(modal) {
    modal.style.display = 'block';
    modal.setAttribute('aria-hidden', 'false');

    // Focus management
    const firstFocusable = modal.querySelector('button, input, a');
    if (firstFocusable) firstFocusable.focus();

    // Trap focus dentro del modal
    modal.addEventListener('keydown', trapFocus);
}

function setLoading(button, loading) {
    button.disabled = loading;
    button.setAttribute('aria-busy', loading ? 'true' : 'false');
    button.textContent = loading ? 'Cargando...' : 'Guardar';
}
```

---

## Testing Strategy

### Test Structure

```
tests/
├── unit/                           # Tests unitarios (sin DOM, sin network)
│   ├── lib/
│   │   ├── api-client.test.js
│   │   ├── event-bus.test.js
│   │   └── state-manager.test.js
│   ├── services/
│   │   ├── task-service.test.js
│   │   └── crawler-service.test.js
│   └── utils/
│       ├── debounce.test.js
│       └── validators.test.js
│
├── integration/                    # Tests con DOM (jsdom)
│   ├── components/
│   │   ├── progress-tracker.test.js
│   │   └── quality-modal.test.js
│   └── pages/
│       └── inicio.test.js
│
└── e2e/                            # Tests end-to-end (Playwright)
    ├── task-workflow.spec.js
    └── crawler-workflow.spec.js
```

### Ejemplo de Test Unitario

```javascript
// tests/unit/lib/event-bus.test.js

import { EventBus } from '../../../static/js/lib/event-bus.js';

describe('EventBus', () => {
    let eventBus;

    beforeEach(() => {
        eventBus = new EventBus();
    });

    test('should emit events to subscribers', () => {
        const callback = jest.fn();
        eventBus.on('test-event', callback);

        eventBus.emit('test-event', { data: 'hello' });

        expect(callback).toHaveBeenCalledWith({ data: 'hello' });
        expect(callback).toHaveBeenCalledTimes(1);
    });

    test('should unsubscribe correctly', () => {
        const callback = jest.fn();
        const unsubscribe = eventBus.on('test-event', callback);

        unsubscribe();
        eventBus.emit('test-event', {});

        expect(callback).not.toHaveBeenCalled();
    });

    test('should handle multiple subscribers', () => {
        const callback1 = jest.fn();
        const callback2 = jest.fn();

        eventBus.on('test-event', callback1);
        eventBus.on('test-event', callback2);

        eventBus.emit('test-event', {});

        expect(callback1).toHaveBeenCalled();
        expect(callback2).toHaveBeenCalled();
    });
});
```

### Ejemplo de Test de Componente

```javascript
// tests/integration/components/progress-tracker.test.js

import { ProgressTracker } from '../../../static/js/components/progress-tracker.js';

describe('ProgressTracker', () => {
    let container, tracker;

    beforeEach(() => {
        // Setup DOM
        container = document.createElement('div');
        container.innerHTML = `
            <div class="progress-bar-container">
                <div class="progress-bar"></div>
            </div>
            <div class="progress-text"></div>
            <button class="start-button">Start</button>
            <button class="stop-button">Stop</button>
        `;
        document.body.appendChild(container);

        // Mock fetch
        global.fetch = jest.fn(() =>
            Promise.resolve({
                ok: true,
                json: () => Promise.resolve({
                    is_complete: false,
                    progress: 50,
                    message: 'Processing...'
                })
            })
        );

        tracker = new ProgressTracker(container, {
            endpoint: '/test/progress',
            interval: 100
        });
        tracker.mount();
    });

    afterEach(() => {
        tracker.unmount();
        document.body.removeChild(container);
        jest.clearAllMocks();
    });

    test('should render progress correctly', async () => {
        await tracker.poll();

        const progressBar = container.querySelector('.progress-bar');
        const progressText = container.querySelector('.progress-text');

        expect(progressBar.style.width).toBe('50%');
        expect(progressText.textContent).toBe('Processing...');
    });

    test('should stop polling when complete', async () => {
        global.fetch.mockResolvedValueOnce({
            ok: true,
            json: () => Promise.resolve({
                is_complete: true,
                progress: 100,
                message: 'Done'
            })
        });

        const onComplete = jest.fn();
        tracker.options.onComplete = onComplete;

        await tracker.poll();

        expect(onComplete).toHaveBeenCalled();
        expect(tracker.store.get().isRunning).toBe(false);
    });
});
```

### E2E Testing con Playwright

```javascript
// tests/e2e/task-workflow.spec.js

import { test, expect } from '@playwright/test';

test.describe('Task Management Workflow', () => {
    test.beforeEach(async ({ page }) => {
        await page.goto('http://localhost:5000/login');
        await page.fill('input[name="username"]', 'test-user');
        await page.fill('input[name="password"]', 'test-pass');
        await page.click('button[type="submit"]');
        await page.waitForURL('**/inicio');
    });

    test('should update task status', async ({ page }) => {
        // Find first pending task
        const taskRow = page.locator('.task-row[data-status="pending"]').first();
        const taskId = await taskRow.getAttribute('data-task-id');

        // Click OK button
        await taskRow.locator('button[data-status="ok"]').click();

        // Wait for update
        await page.waitForTimeout(500);

        // Verify status changed
        const updatedRow = page.locator(`.task-row[data-task-id="${taskId}"]`);
        await expect(updatedRow).toHaveAttribute('data-status', 'ok');
        await expect(updatedRow).toHaveClass(/ok/);
    });

    test('should auto-save observations', async ({ page }) => {
        const textarea = page.locator('textarea[data-task-id="123"]');

        // Type observation
        await textarea.fill('Esta es una observación de prueba');

        // Wait for debounced auto-save (1 second)
        await page.waitForTimeout(1500);

        // Verify saved indicator appears
        await expect(page.locator('.save-indicator')).toHaveText('Guardado');
    });
});
```

---

## Beneficios Esperados

### Métricas de Éxito

**Mantenibilidad**:
- ✅ Reducir tiempo de onboarding de nuevos devs: 2 días → 4 horas
- ✅ Encontrar código relevante: 10 minutos → 2 minutos (estructura clara)
- ✅ Añadir nueva feature: 50% menos tiempo (componentes reutilizables)

**Calidad del Código**:
- ✅ Type safety: 0% → 90% (JSDoc + TypeScript checking)
- ✅ Test coverage: 0% → 70%+ (tests unitarios + integración)
- ✅ Bugs en producción: -80% (type checking + tests catch errors)

**Developer Experience**:
- ✅ Autocomplete: ❌ → ✅ (JSDoc types)
- ✅ Refactoring: Manual → Automated (rename, find references)
- ✅ Debugging: console.log → Source maps + DevTools

**Performance**:
- ✅ Event listeners: 100+ → 10-20 (event delegation)
- ✅ Memory leaks: Frecuentes → Raros (cleanup automático)
- ✅ Bundle size: 20 KB → 25 KB (solo +25%, con mucha más funcionalidad)

**Sin perder**:
- ✅ Deploy simplicity: Igual (build opcional)
- ✅ Progressive enhancement: Preservado
- ✅ Server-side rendering: Intacto
- ✅ Flask integration: Sin cambios

---

## Decisiones de Diseño

### 1. Por Qué NO Web Components

**Considerado pero descartado**:
- ✅ Pros: Estándar web, encapsulación real, shadow DOM
- ❌ Cons: Complejo para casos simples, Shadow DOM limita estilos globales
- ❌ Cons: IE no soportado (aunque ya no es relevante)
- ❌ Cons: Curva de aprendizaje más alta

**Decisión**: Clases ES6 con BaseComponent es más simple y suficiente

### 2. Por Qué NO Build Tool Obligatorio

**Razones**:
- ES Modules nativos funcionan en todos los browsers modernos (>95%)
- HTTP/2 hace que múltiples requests pequeños sean eficientes
- Source maps no necesarios si el código es legible
- Compilación añade complejidad al deploy

**Compromiso**: Build tool OPCIONAL para producción (minificación)

### 3. Por Qué JSDoc en vez de TypeScript puro

**Razones**:
- ✅ Cero build step (TS requiere compilación)
- ✅ Debugging más fácil (código fuente = código ejecutado)
- ✅ Deploy sin cambios (sigue siendo vanilla JS)
- ✅ Type checking funciona igual de bien en desarrollo
- ✅ Menor curva de aprendizaje

**Trade-off**: Sintaxis más verbosa, pero vale la pena por la simplicidad

### 4. Por Qué State Manager Simple vs Redux

**Razones**:
- ✅ Redux es overkill para este proyecto (1-5 usuarios, no hay estado global complejo)
- ✅ EventBus + Store simple cubre 90% de casos de uso
- ✅ Menos de 100 líneas de código vs 500+ KB de Redux
- ✅ Más fácil entender y debuggear

**Cuándo reconsiderar**: Si el estado global se vuelve muy complejo (time-travel debugging, etc.)

### 5. Por Qué NO SPA (Single Page Application)

**Razones**:
- ✅ Flask routing + Jinja2 funcionan perfecto
- ✅ SEO sin complicaciones (SSR gratis)
- ✅ Progressive enhancement preservado
- ✅ Flash messages y sesiones de Flask siguen funcionando
- ✅ Deploy sin API refactor completo

**Compromiso**: Páginas individuales pueden tener comportamiento SPA-like (pushState)

---

## Recursos y Referencias

### Documentación Oficial

- [MDN Web Docs - JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript)
- [MDN - ES Modules](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Modules)
- [TypeScript JSDoc Reference](https://www.typescriptlang.org/docs/handbook/jsdoc-supported-types.html)
- [Web.dev - Performance Best Practices](https://web.dev/performance/)

### Tutoriales y Guías

- [JavaScript Design Patterns](https://www.patterns.dev/posts/classic-design-patterns/)
- [Event Delegation Explained](https://javascript.info/event-delegation)
- [JavaScript Testing Best Practices](https://github.com/goldbergyoni/javascript-testing-best-practices)

### Tools

- [TypeScript Playground](https://www.typescriptlang.org/play) - Testear JSDoc
- [Jest Documentation](https://jestjs.io/docs/getting-started)
- [Playwright Documentation](https://playwright.dev/)
- [VS Code Extensions](https://code.visualstudio.com/docs/languages/javascript):
  - JavaScript and TypeScript Nightly
  - ESLint
  - Prettier

### Ejemplos de Referencia

Proyectos que usan vanilla JS moderno sin frameworks:
- [Stimulus](https://stimulus.hotwired.dev/) - Modest JavaScript framework
- [Alpine.js](https://alpinejs.dev/) - Minimal reactive framework
- [htmx](https://htmx.org/) - High Power Tools for HTML

---

## Resumen Ejecutivo

### TL;DR

**Objetivo**: Mejorar la arquitectura JavaScript actual sin migrar a React.

**Approach**:
- Vanilla JS moderno con ES Modules
- JSDoc para type safety (sin compilación)
- Estructura clara (lib/, components/, pages/, services/)
- Testing completo (Jest + Playwright)
- Build tool opcional

**Beneficios**:
- 80% beneficios de React, 20% complejidad
- Mantiene simplicidad de deploy
- Type safety sin build step
- Código organizado y testeable

**Esfuerzo**: 3-4 semanas implementación incremental

**Riesgo**: BAJO (cambios graduales, no breaking changes)

**Decisión**: Implementar cuando:
- Se termine Stage 3 actual
- Haya tiempo para refactoring sin presión
- Equipo esté de acuerdo con el approach

---

**Documento creado**: 2025-11-04
**Última actualización**: 2025-11-04
**Autor**: Claude Code + Análisis del proyecto
**Estado**: Propuesta / Referencia futura
**Versión**: 1.0
