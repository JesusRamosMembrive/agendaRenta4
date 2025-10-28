# Plan de Proyecto: AgendaRenta4

**Fecha de creación**: 2025-10-28
**Estado**: Planificación
**Versión**: 1.0

---

## 📊 Resumen Ejecutivo

### ¿Qué problema resuelve?

Tu esposa trabaja en un banco y debe revisar secciones del sitio web periódicamente para control de calidad. Actualmente usa un Excel manual que consulta diariamente para saber qué revisar. Este proceso es:
- ❌ Manual y repetitivo
- ❌ Propenso a olvidos
- ❌ Difícil de compartir y colaborar
- ❌ No guarda historial estructurado de cambios

### ¿Qué vamos a construir?

Una **aplicación web de gestión de tareas** tipo agenda que:
- ✅ Gestiona **8 tipos de tareas** diferentes (enlaces rotos, erratas, información, etc.)
- ✅ Cada tipo tiene **periodicidad independiente** (semanal, mensual, trimestral, etc.)
- ✅ Activa automáticamente tareas según calendario por sección
- ✅ Muestra tareas pendientes y realizadas
- ✅ Guarda observaciones de qué se cambió en cada revisión
- ✅ Permite colaboración entre usuarios (tu esposa y José)
- ✅ Mantiene seguridad de datos bancarios
- ✅ Permite CRUD completo de secciones desde UI (crear/editar/desactivar)

### Factibilidad

| Aspecto | Evaluación | Justificación |
|---------|------------|---------------|
| **Factible** | ✅ SÍ | Es un task manager con tareas recurrentes (patrón conocido) |
| **Laborioso** | ⏱️ MODERADO | MVP en 2-3 días, versión completa en 1 semana |
| **Rollo** | ❌ NO | Problema real, alcance claro, beneficio inmediato |

---

## 🏗️ Arquitectura Técnica

### Stack Propuesto

#### Backend
- **Lenguaje**: Python 3.10+
- **Framework**: Flask (simple, rápido de prototipar)
- **Base de datos**: SQLite (archivo local, sin servidor)
- **Parseo Excel**: `openpyxl` o `pandas`
- **Scheduler**: `APScheduler` (activación automática de tareas)

#### Frontend
- **HTML5 + CSS3** (o Tailwind CSS para estilos rápidos)
- **JavaScript vanilla** o Alpine.js (interactividad mínima)
- **Sin framework pesado** en Stage 1 (no React/Vue/Angular)

#### Seguridad
- **Stage 1**: Web local (localhost:5000) sin exposición externa
- **Stage 2**: Autenticación básica + HTTPS local
- **Stage 3**: Deploy privado con VPN/túnel SSH si necesario

### Esquema de Base de Datos

**Diseño**: Soporta 8 tipos de tareas con periodicidades independientes por sección.

```sql
-- Secciones del sitio web a revisar (páginas)
CREATE TABLE sections (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,              -- Ej: "Renta Fija", "Fondos"
    url TEXT UNIQUE NOT NULL,        -- URL de la página
    description TEXT,
    active BOOLEAN DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tipos de tareas (los 8 tipos de revisiones)
CREATE TABLE task_types (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,       -- "enlaces_rotos", "informacion_actualizada", etc.
    display_name TEXT NOT NULL,      -- "Enlaces Rotos", "Información Actualizada", etc.
    display_order INTEGER DEFAULT 0
);

-- Configuración: periodicidad de cada tipo por sección
-- Esta tabla define QUÉ tipos de tareas se aplican a QUÉ secciones y con QUÉ frecuencia
CREATE TABLE section_task_config (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    section_id INTEGER NOT NULL,
    task_type_id INTEGER NOT NULL,
    frequency TEXT NOT NULL,         -- "weekly", "monthly", "quarterly", "biannual", "yearly"
    day_of_activation INTEGER DEFAULT 1,  -- Día del mes/semana para activar
    active BOOLEAN DEFAULT 1,
    FOREIGN KEY (section_id) REFERENCES sections(id),
    FOREIGN KEY (task_type_id) REFERENCES task_types(id),
    UNIQUE(section_id, task_type_id)
);

-- Tareas generadas (instancias concretas de revisión)
CREATE TABLE tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    section_id INTEGER NOT NULL,
    task_type_id INTEGER NOT NULL,
    status TEXT DEFAULT 'pending',   -- 'pending', 'in_progress', 'completed'
    activated_date DATE NOT NULL,    -- Cuándo se activó la tarea
    completed_date DATE,
    observations TEXT,               -- Notas de qué se cambió
    completed_by TEXT,               -- Nombre de quién completó (Stage 2: user_id)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (section_id) REFERENCES sections(id),
    FOREIGN KEY (task_type_id) REFERENCES task_types(id)
);

-- (Stage 2) Usuarios
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    display_name TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Ejemplo de Datos**:
```sql
-- Sección
INSERT INTO sections (name, url) VALUES ('Renta Fija', 'https://www.r4.com/renta-fija');

-- Tipos de tareas (los 8)
INSERT INTO task_types (name, display_name, display_order) VALUES
  ('enlaces_rotos', 'Enlaces Rotos', 1),
  ('enlaces_incorrectos', 'Enlaces Incorrectos', 2),
  ('textos_erratas', 'Textos - Erratas', 3),
  ('informacion_actualizada', 'Información Actualizada', 4),
  ('preguntas_frecuentes', 'Preguntas Frecuentes', 5),
  ('ctas', 'CTAs', 6),
  ('imagenes', 'Imágenes', 7),
  ('diseno', 'Diseño', 8);

-- Configuración: "Renta Fija" tiene "Enlaces Rotos" semanal e "Información" mensual
INSERT INTO section_task_config (section_id, task_type_id, frequency) VALUES
  (1, 1, 'weekly'),   -- Enlaces Rotos cada semana
  (1, 4, 'monthly');  -- Información cada mes

-- Scheduler genera tareas automáticamente según configuración
INSERT INTO tasks (section_id, task_type_id, activated_date) VALUES
  (1, 1, '2025-11-01'),  -- Tarea "Enlaces Rotos" para "Renta Fija"
  (1, 4, '2025-11-01');  -- Tarea "Información" para "Renta Fija"
```

### 8 Tipos de Tareas

**Importante**: No son items de checklist, son **tipos de tareas separadas** con periodicidad independiente.

1. **Enlaces rotos** - Verificar links funcionan (automatizable en futuro)
2. **Enlaces incorrectos** - Verificar links apuntan a destino correcto
3. **Textos - erratas** - Revisar ortografía y gramática (spell check automatizable)
4. **Información actualizada** - Verificar datos están al día (manual)
5. **Preguntas frecuentes** - Revisar FAQs son relevantes (manual)
6. **CTAs** - Verificar calls-to-action funcionan (parcialmente automatizable)
7. **Imágenes** - Verificar imágenes cargan y son apropiadas (automatizable)
8. **Diseño** - Verificar layout y responsive (visual regression testing en futuro)

**Ejemplo de uso**:
- Sección "Renta Fija" puede tener:
  - "Enlaces Rotos" cada semana
  - "Información Actualizada" cada mes
  - "Diseño" cada trimestre
- Sección "Fondos" puede tener:
  - "Enlaces Rotos" cada dos semanas
  - "Información Actualizada" cada 15 días
  - "Imágenes" cada mes

---

## 🎯 Enfoque Iterativo UI-First

### Iteración 0: MVP Ultra-Simple (2-3 días) ⭐ INICIO

**Filosofía**: Empezar con 1 tipo de tarea, validar el workflow completo, luego añadir tipos uno por uno.

**Alcance Iteración 0**:
- ✅ Solo **1 tipo de tarea**: "Enlaces Rotos"
- ✅ UI completa y usable desde día 1
- ✅ ~30-50 secciones cargadas desde Excel
- ✅ Periodicidad simplificada: todas las secciones día 1 del mes

#### Features Incluidas

✅ **Parseo del Excel inicial**
- Leer pestaña "Actualización y calidad"
- Extraer secciones (URLs) del sitio
- Poblar tabla `sections`
- Configurar periodicidad "Enlaces Rotos" para todas

✅ **Vista "Tareas Pendientes"** (UI principal)
- Lista de tareas activadas tipo "Enlaces Rotos"
- Card por tarea: Sección + URL + Fecha activación
- Textarea para observaciones con auto-save
- Botón "Marcar como Realizada"

✅ **Vista "Tareas Realizadas"** (historial)
- Lista de tareas completadas
- Muestra observaciones guardadas
- Fecha de completado

✅ **Scheduler básico**
- Script manual `python scheduler.py` genera tareas
- Verifica periodicidad según `section_task_config`
- Crea tasks para tipo "Enlaces Rotos" cuando toca

✅ **Backend API REST**
- GET /api/tasks/pending - Lista pendientes
- GET /api/tasks/completed - Lista completadas
- PUT /api/tasks/:id/observations - Guardar observaciones
- POST /api/tasks/:id/complete - Marcar realizada

#### Features NO Incluidas (Iteración 0)

❌ Los otros 7 tipos de tareas (se añaden después)
❌ Multi-usuario con autenticación
❌ CRUD de secciones desde UI
❌ Scheduler automático (cron)
❌ Reportes o estadísticas
❌ Filtros o búsqueda
❌ Deploy en servidor

#### Criterios de Éxito (Iteración 0)

- [ ] Tu esposa abre navegador → ve tareas pendientes "Enlaces Rotos"
- [ ] Escribe observaciones de qué encontró/cambió
- [ ] Marca tarea como realizada
- [ ] Ve historial de tareas realizadas
- [ ] Todo funciona sin errores ni confusión

**Validación**: 3-7 días de uso. Si workflow es útil → Iteración 1 (añadir 2do tipo).

---

### Iteración 1-7: Añadir Tipos Restantes (medio día c/u)

**Una vez Iteración 0 validada**, añadir los demás tipos uno por uno:

**Iteración 1**: Añadir "Textos - Erratas"
- Insertar en task_types
- Configurar periodicidad para secciones
- Generar tareas en scheduler
- UI muestra ambos tipos mezclados

**Iteración 2**: Añadir "Información Actualizada"
**Iteración 3**: Añadir "Enlaces Incorrectos"
**Iteración 4**: Añadir "Imágenes"
**Iteración 5**: Añadir "CTAs"
**Iteración 6**: Añadir "Preguntas Frecuentes"
**Iteración 7**: Añadir "Diseño"

**Ventaja**: Cada tipo se añade rápido (~medio día) porque arquitectura ya existe.

---

### Iteración N: CRUD Secciones (cuando se necesite)

**Trigger**: Cuando tu esposa quiera añadir/editar secciones sin tocar código.

**Features**:
- ✅ Crear nuevas secciones desde UI
- ✅ Editar URL y nombre de secciones existentes
- ✅ Configurar periodicidad de cada tipo por sección
- ✅ Desactivar secciones (dejan de generar tareas)
- ✅ Vista lista de todas las secciones

**Tiempo**: 1-2 días

---

### Stage 2: Colaboración y Seguridad (si se necesita)

**Trigger**: Cuando José también necesite usar la app.

**Features**:
- ✅ Autenticación básica (2 usuarios)
- ✅ Registrar quién completó cada tarea
- ✅ Mejor UX/diseño
- ✅ Acceso desde red local (no solo localhost)

**Tiempo**: 3-5 días

---

### Stage 3: Producción (si se necesita largo plazo)

**Trigger**: Necesitan acceso remoto o herramienta de producción.

**Features**:
- ✅ Deploy seguro (Docker + VPN)
- ✅ Backups automáticos
- ✅ Tests automatizados
- ✅ Monitoreo y alertas

**Tiempo**: 1-2 semanas

---

### Stage 2: Estructura (3-5 días)

**Solo implementar si Stage 1 es exitoso y hay dolor claro.**

#### Posibles Features

✅ **Autenticación básica**
- 2 usuarios: tu esposa + José
- Login simple (username/password)
- Registrar quién completó cada tarea

✅ **Edición de secciones**
- CRUD de secciones desde UI
- Cambiar periodicidad sin tocar BD directamente

✅ **Mejor UX/diseño**
- Refinar estilos
- Animaciones/transiciones
- Responsive para tablet/móvil

✅ **Filtros y búsqueda**
- Filtrar tareas por sección
- Buscar en observaciones

✅ **Dashboard simple**
- Cuántas tareas pendientes
- Cuántas completadas este mes
- Próximas activaciones

#### Seguridad Mejorada

- Autenticación con contraseñas hasheadas (bcrypt)
- HTTPS local (certificado self-signed)
- Acceso solo desde red local (192.168.x.x)

---

### Stage 3: Producción (1-2 semanas)

**Solo si necesitan acceso remoto o quieren herramienta de largo plazo.**

#### Posibles Features

✅ **Deploy seguro**
- Docker containerization
- Reverse proxy con auth (nginx + basic auth)
- VPN o túnel SSH para acceso remoto

✅ **Backups automáticos**
- SQLite backup diario
- Export periódico a JSON/Excel
- Restore procedure documentado

✅ **Tests**
- Tests de endpoints críticos
- Tests de scheduler
- Tests de parseo Excel

✅ **Monitoreo**
- Logs estructurados
- Alertas si scheduler falla
- Health check endpoint

✅ **Features avanzadas**
- Notificaciones por email
- Reportes mensuales automáticos
- Export personalizado

---

## 📅 Plan de Implementación

### Fase 0: Exploración (medio día)

**Objetivo**: Entender estructura real del Excel antes de implementar.

**Tareas**:
1. Escribir script Python para parsear Excel
2. Imprimir estructura de ambas pestañas
3. Identificar columnas relevantes
4. Determinar cómo se codifica la periodicidad
5. **Validar con esposa** antes de continuar

**Output**: Documento con estructura del Excel + decisiones de mapeo a BD.

---

### Fase 1: Backend Core (1 día)

**Objetivo**: API funcional que gestiona tareas.

**Tareas**:
1. Setup proyecto Flask
2. Crear schema SQLite (4 tablas)
3. Poblar `checklist_items` con 8 items fijos
4. Script de parseo Excel → poblar `sections`
5. Implementar endpoints REST:
   - `GET /api/tasks/pending` - Lista tareas pendientes
   - `GET /api/tasks/completed` - Lista tareas completadas
   - `GET /api/tasks/:id` - Detalle de tarea
   - `PUT /api/tasks/:id/checklist` - Actualizar checklist
   - `PUT /api/tasks/:id/observations` - Guardar observaciones
   - `POST /api/tasks/:id/complete` - Marcar como realizada
6. Implementar scheduler:
   - Script que revisa si toca activar secciones
   - Crea nuevas tasks según periodicidad
   - Ejecutable como `python scheduler.py` (luego cron)

**Output**: API funcional + tests manuales con curl.

---

### Fase 2: Frontend (1 día)

**Objetivo**: UI simple para usar la aplicación.

**Tareas**:
1. HTML estructura:
   - Header con título
   - 2 tabs: "Pendientes" / "Realizadas"
   - Cards de tareas
2. CSS estilos:
   - Usar Tailwind CDN o CSS custom simple
   - Responsive básico
3. JavaScript:
   - Fetch de tareas desde API
   - Render de cards
   - Checklist interactivo (toggle checkboxes)
   - Textarea observaciones con auto-save
   - Botón "Marcar como realizada"
4. Integración:
   - Flask sirve index.html en `/`
   - API en `/api/*`

**Output**: Web app funcional en localhost:5000.

---

### Fase 3: Testing y Documentación (medio día)

**Objetivo**: Validar que todo funciona end-to-end.

**Tareas**:
1. **Test workflow completo**:
   - Ejecutar scheduler → verifica task se crea
   - Ver tarea en "Pendientes"
   - Marcar checklist
   - Agregar observaciones
   - Marcar como realizada
   - Ver en "Realizadas"
2. **Documentación**:
   - README.md con instrucciones de setup
   - Cómo ejecutar app
   - Cómo ejecutar scheduler
   - Cómo hacer backup de BD
3. **Refinar UX**:
   - Ajustar según feedback inicial
   - Mejorar mensajes de error
   - Añadir loading states

**Output**: App lista para uso real + documentación clara.

---

### Fase 4: Validación (1 semana)

**Objetivo**: Uso real para identificar qué funciona y qué no.

**Tareas**:
1. Tu esposa usa app por 1 semana
2. Recopilar feedback:
   - ¿Es útil? ¿Ahorra tiempo?
   - ¿Qué falta? ¿Qué sobra?
   - ¿Qué es confuso o tedioso?
3. Decidir:
   - ✅ Si es útil → continuar a Stage 2
   - ❌ Si no → ajustar o descartar

---

## 🔒 Seguridad y Consideraciones

### Datos Bancarios Sensibles

**Problema**: La información sobre el sitio web del banco es confidencial y no puede estar en internet público.

**Solución por Stage**:

**Stage 1 (MVP)**:
- ✅ Web app corre en `localhost:5000` (solo accesible desde mismo PC)
- ✅ SQLite archivo local (no se sale de la máquina)
- ✅ Sin conexión a internet necesaria
- ✅ Ambos usuarios acceden desde mismo PC o red local

**Stage 2 (si necesitan acceso desde red local)**:
- Flask escucha en `0.0.0.0:5000` (accesible desde LAN)
- Autenticación con usuario/contraseña
- Acceso limitado a IPs de red local (192.168.x.x)
- HTTPS con certificado self-signed

**Stage 3 (si necesitan acceso remoto)**:
- Deploy en servidor privado (no cloud público)
- VPN obligatoria para acceder
- O túnel SSH inverso (cloudflare tunnel, ngrok con auth)
- Backups encriptados

### Pérdida de Datos

**Problema**: SQLite puede corromperse, eliminación accidental.

**Solución**:
- Backup automático diario (copia de archivo .db)
- Script de export a JSON periódico
- Procedure de restore documentado
- Stage 3: Backups automáticos a ubicación segura

### Concurrencia

**Problema**: 2 usuarios editando misma tarea simultáneamente.

**Solución**:
- Stage 1: Ignorar (poco probable con 2 usuarios)
- Stage 2: Optimistic locking (last write wins)
- Stage 3: Websockets para updates en tiempo real

---

## 🎨 Wireframes Conceptuales

### Vista "Tareas Pendientes"

```
╔═══════════════════════════════════════════════════════╗
║  AgendaRenta4                                [José ▾] ║
╠═══════════════════════════════════════════════════════╣
║  [Pendientes] [Realizadas]                            ║
╠═══════════════════════════════════════════════════════╣
║                                                        ║
║  ┌────────────────────────────────────────────────┐  ║
║  │ Revisión: Renta Fija                           │  ║
║  │ Activada: 01/10/2025                           │  ║
║  │                                                 │  ║
║  │ Checklist:                                      │  ║
║  │ ☑ Enlaces rotos                                 │  ║
║  │ ☑ Enlaces incorrectos                           │  ║
║  │ ☐ Textos - erratas                              │  ║
║  │ ☐ Información actualizada                       │  ║
║  │ ☐ Preguntas frecuentes                          │  ║
║  │ ☐ CTAs                                          │  ║
║  │ ☐ Imágenes                                      │  ║
║  │ ☐ Diseño                                        │  ║
║  │                                                 │  ║
║  │ Observaciones:                                  │  ║
║  │ ┌─────────────────────────────────────────┐    │  ║
║  │ │ Se corrigieron 3 enlaces rotos en la   │    │  ║
║  │ │ sección de bonos corporativos...       │    │  ║
║  │ └─────────────────────────────────────────┘    │  ║
║  │                                                 │  ║
║  │                      [Marcar como Realizada]   │  ║
║  └────────────────────────────────────────────────┘  ║
║                                                        ║
║  ┌────────────────────────────────────────────────┐  ║
║  │ Revisión: Fondos de Inversión                  │  ║
║  │ Activada: 28/10/2025                           │  ║
║  │ ...                                             │  ║
║  └────────────────────────────────────────────────┘  ║
╚═══════════════════════════════════════════════════════╝
```

### Vista "Tareas Realizadas"

```
╔═══════════════════════════════════════════════════════╗
║  AgendaRenta4                                [José ▾] ║
╠═══════════════════════════════════════════════════════╣
║  [Pendientes] [Realizadas]                            ║
╠═══════════════════════════════════════════════════════╣
║                                                        ║
║  ┌────────────────────────────────────────────────┐  ║
║  │ ✓ Revisión: Depósitos                          │  ║
║  │ Completada: 25/10/2025 por María               │  ║
║  │                                                 │  ║
║  │ Checklist: ✓ 8/8 completados                   │  ║
║  │                                                 │  ║
║  │ Observaciones:                                  │  ║
║  │ Se actualizaron las tasas de interés y se     │  ║
║  │ corrigió error en calculadora de intereses.   │  ║
║  │                                                 │  ║
║  │                        [Ver detalles]          │  ║
║  └────────────────────────────────────────────────┘  ║
║                                                        ║
║  ┌────────────────────────────────────────────────┐  ║
║  │ ✓ Revisión: Renta Fija                         │  ║
║  │ Completada: 20/10/2025 por José                │  ║
║  │ ...                                             │  ║
║  └────────────────────────────────────────────────┘  ║
╚═══════════════════════════════════════════════════════╝
```

---

## 🚀 Próximos Pasos

### Inmediatos (Esta Semana)

1. **Revisar y discutir este plan** con tu esposa
   - ¿El checklist de 8 items es completo?
   - ¿La periodicidad del Excel es mensual, semanal, mixta?
   - ¿Hay algo crítico que falta?

2. **Explorar estructura del Excel**
   - Escribir script de parseo
   - Ver qué columnas tiene cada pestaña
   - Entender cómo se codifica la periodicidad

3. **Validar mapeo a BD**
   - Mostrar a tu esposa cómo se va a representar la info
   - Confirmar que no se pierde información importante

### Desarrollo (Próximas 2 Semanas)

4. **Implementar MVP (Stage 1)**
   - Seguir plan de 4 fases
   - 2-3 días de desarrollo concentrado

5. **Validación con uso real**
   - 1 semana de uso diario
   - Recopilar feedback honesto

6. **Decidir evolución**
   - Si es útil → Stage 2 (features adicionales)
   - Si no → ajustar o replantear

---

## 📊 Métricas de Éxito

### MVP (Stage 1)

- [ ] App instalada y corriendo en localhost
- [ ] Tu esposa puede usarla sin ayuda después de 5 minutos de explicación
- [ ] Scheduler activa tareas automáticamente
- [ ] Historial de al menos 5 tareas completadas después de 1 semana
- [ ] Tu esposa dice "esto es más útil que el Excel"

### Stage 2

- [ ] José también usa la app regularmente
- [ ] Autenticación funciona sin problemas
- [ ] Ambos pueden ver quién hizo qué revisión
- [ ] UI es lo suficientemente clara/bonita para uso diario

### Stage 3

- [ ] App corre en servidor/deploy
- [ ] Backups automáticos funcionando
- [ ] No ha habido pérdida de datos en 3 meses
- [ ] Tu esposa NO quiere volver al Excel nunca más

---

## ❓ Preguntas Abiertas

**Para resolver antes de empezar desarrollo**:

1. **¿Cómo se define la periodicidad en el Excel actual?**
   - ¿Hay columna que diga "mensual", "semanal"?
   - ¿O es implícito (siempre el día 1 del mes)?
   - ¿Varía por sección?

2. **¿Cuántas secciones del sitio hay que revisar?**
   - ¿5? ¿10? ¿50?
   - Esto afecta diseño de UI

3. **¿El checklist de 8 items aplica a TODAS las secciones?**
   - ¿O algunas secciones tienen checklist diferente?

4. **¿Qué pasa con la pestaña "Tráfico y SEO"?**
   - ¿Es parte de la misma revisión?
   - ¿O es proceso separado?

5. **¿Hay deadlines?**
   - Si tarea se activa día 1, ¿cuándo "expira"?
   - ¿O puede quedar pendiente indefinidamente?

6. **¿Necesitan poder RE-revisar secciones ya completadas?**
   - ¿O cada revisión es one-time?

**Estas preguntas se responden en Fase 0 (Exploración).**

---

## 🎓 Lecciones del Framework Stage-Aware

Este proyecto sigue la metodología Stage-Aware:

### Stage 1: Prototipar
- **Objetivo**: ¿Funciona? ¿Es útil?
- **Regla**: Mínimo viable, sin sobre-ingeniería
- **Output**: MVP en 2-3 días

### Stage 2: Estructurar
- **Objetivo**: Hacerlo usable y mantenible
- **Regla**: Solo añadir lo que duele NO tener
- **Output**: App robusta para uso diario

### Stage 3: Producir
- **Objetivo**: Confiable para largo plazo
- **Regla**: Testing, deploy, monitoreo
- **Output**: Herramienta productiva

**IMPORTANTE**: No saltar stages. Validar utilidad antes de añadir complejidad.

---

## 📝 Notas Finales

- Este es un **documento vivo** - actualizar según aprendamos
- Priorizar **feedback temprano** sobre features especulativas
- Mantener **simplicidad** - resist the urge to over-engineer
- **Seguridad primero** - datos bancarios requieren cuidado

**¿Listo para empezar? → Siguiente paso: Fase 0 (Explorar Excel)**