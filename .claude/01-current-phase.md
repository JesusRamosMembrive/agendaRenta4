# Estado Actual

**Fecha**: 2025-10-29
**Etapa**: 1 (Prototipado)
**Sesión**: Corrección de bug - Status dot no cambiaba de color

## Objetivo de hoy
✅ COMPLETADO: Implementación de lógica JavaScript para actualizar el color del status-dot

---

## Sesión Anterior (2025-10-28)
**Objetivo**: Mejoras de interfaz, nueva sección Problemas, y contadores en sidebar

## Progreso de hoy
- [x] Implementar función JavaScript `updateRowStatus()` para calcular color del status-dot
- [x] Integrar llamada automática después de cada cambio de estado
- [x] Inicializar status-dots al cargar la página
- [x] Corregir página /pendientes para mostrar TODAS las tareas pendientes (no solo las de BD)
- [x] Implementar página de Configuración completa:
  - [x] Sección de Alertas de Tareas (8 tipos con periodicidad y toggle)
  - [x] Sección de Tipo de Notificaciones (email, escritorio, in-app)
  - [x] Sección de Gestión de URLs (CRUD completo)
- [x] Crear 3 nuevas tablas en BD: alert_settings, notification_preferences, notifications
- [x] Implementar 6 nuevas rutas POST para guardar configuraciones
- [x] Agregar selector de día específico para alertas:
  - [x] Columna alert_day en tabla alert_settings
  - [x] Selector dinámico: días de la semana (semanal/quincenal) o días del mes (mensual/trimestral/etc)
  - [x] JavaScript para actualizar opciones según frecuencia elegida

## Progreso sesión anterior (2025-10-28)
- [x] Cambiar botones a solo iconos (✓ y ⚠)
- [x] Separar Pendientes (no revisadas) de Problemas (con incidencias)
- [x] Crear nueva ruta /problemas
- [x] Crear template problemas.html
- [x] Agregar contadores al sidebar (Pendientes, Problemas, Realizadas)
- [x] Corregir lógica de contador de pendientes (no contaba tareas sin registro en BD)
- [x] Mejorar contraste del banner de pendientes (amarillo claro → marrón oscuro)

## Implementación

### Archivos Modificados (Sesión actual 2025-10-29)

**templates/inicio.html** (líneas 115-269)
- Nueva función JavaScript `updateRowStatus(row)` (líneas 233-267)
- Calcula el color del status-dot basándose en botones activos:
  * Verde (sd-green): Todos los botones OK marcados (0 problemas, OK = total)
  * Rojo (sd-red): Más de 4 problemas
  * Naranja (sd-orange): Entre 1 y 4 problemas
  * Neutral (sd-neutral): Cualquier otro caso
- Llamada automática después de cada click en botones (línea 153)
- Inicialización al cargar página (líneas 227-229)
- Logs en consola para debugging

**app.py** - Ruta /pendientes (líneas 262-324)
- Cambiado de consulta SQL a generación de combinaciones
- Obtiene todas las secciones activas y tipos de tareas
- Genera todas las combinaciones posibles (173 secciones × 8 tipos = 1384)
- Excluye las que ya están marcadas como OK o Problema
- Muestra las restantes como pendientes (1376 en el ejemplo)
- Solución simple y directa siguiendo Stage 1

**agendaRenta4.db** - Nuevas tablas
- `alert_settings` - Configuración de alertas por tipo de tarea
  * task_type_id, alert_frequency (daily/weekly/biweekly/monthly/quarterly/semiannual/annual), alert_day (día específico), enabled
  * alert_day: NULL para daily, día de la semana (monday-sunday) para weekly/biweekly, día del mes (1-31) para monthly/quarterly/semiannual/annual
- `notification_preferences` - Preferencias de notificación del usuario
  * user_name, email, enable_email, enable_desktop, enable_in_app
- `notifications` - Notificaciones en app (para futuro)
  * user_name, task_type_id, message, created_at, read

**app.py** - Ruta GET /configuracion (líneas 430-496)
- Carga todos los task_types con sus alert_settings
- Carga notification_preferences del usuario actual
- Carga todas las sections (URLs)
- Renderiza template con todos los datos

**app.py** - Nuevas rutas POST (líneas 585-770)
- `/configuracion/alertas` - Guardar config de alertas (JSON batch update)
- `/configuracion/notificaciones` - Guardar preferencias de notificación
- `/configuracion/url/add` - Añadir nueva URL/sección
- `/configuracion/url/edit/<id>` - Editar URL existente
- `/configuracion/url/toggle/<id>` - Activar/desactivar URL
- `/configuracion/url/delete/<id>` - Eliminar URL (solo si no tiene tareas)

**templates/configuracion.html** (NUEVO - ~730 líneas)
- Sección 1: Alertas de Tareas
  * Tabla con 8 task_types
  * Select de periodicidad (7 opciones: diario, semanal, quincenal, mensual, trimestral, semestral, anual)
  * Select de día de aviso (dinámico según frecuencia):
    - Diario: deshabilitado ("Todos los días")
    - Semanal/Quincenal: días de la semana (Lunes-Domingo)
    - Mensual/Trimestral/Semestral/Anual: días del mes (1-31)
  * Toggle switch para activar/desactivar
  * JavaScript que actualiza opciones de día al cambiar frecuencia
  * Botón guardar (envía JSON a backend con alert_day incluido)
- Sección 2: Tipo de Notificaciones
  * Checkbox: Notificación en app (badge en topbar)
  * Checkbox: Notificación de escritorio (requiere permiso browser)
  * Checkbox: Email + input de correo
  * Explicación de cada opción
- Sección 3: Gestión de URLs
  * Formulario para añadir nueva URL (nombre + url)
  * Tabla con 173 URLs existentes
  * Botones: Editar, Activar/Desactivar, Eliminar
  * Modo edición inline (sin modal)
  * Validación de eliminación (no permite si hay tareas asociadas)
- JavaScript incluido para todas las interacciones
- Estilos CSS para toggle switches y notification-options

### Problemas resueltos

**Bug #1: Status-dot no cambiaba de color**
- **Síntoma**: El círculo de status no cambiaba de color al marcar tareas como OK o Problema
- **Causa**: Faltaba la lógica JavaScript para actualizar dinámicamente la clase CSS del status-dot
- **Solución**: Implementación de función que cuenta botones activos y aplica reglas de color según estado

**Bug #2: Página Pendientes solo mostraba 2 tareas**
- **Síntoma**: Contador mostraba 1376 pendientes pero la página solo listaba 2 tareas
- **Causa**: La consulta SQL solo buscaba registros con status='pending' en BD, ignorando tareas sin marcar
- **Solución**: Generar todas las combinaciones (sección × tipo) y excluir las marcadas como OK/Problema
- **Resultado**: Ahora muestra las 1376 tareas pendientes correctamente

---

### Archivos Modificados (Sesión anterior 2025-10-28)

**app.py** (líneas 63-122)
- Función `get_task_counts()` refactorizada completamente
- Nueva lógica: Pendientes = (Secciones × Tipos) - OK - Problemas
- Ahora cuenta correctamente tareas que no tienen registro en BD
- Contadores por periodo actual (excepto Realizadas que es histórico)

**templates/inicio.html** (líneas 43-55)
- Botones simplificados: solo iconos ✓ y ⚠
- Eliminado texto "Ok" y "Problema"
- Mantiene funcionalidad de toggle completa

**templates/pendientes.html** (líneas 9-14)
- Banner cambiado a color marrón oscuro (#78350f)
- Letras en amarillo claro (#fef3c7) para mejor contraste
- Mantiene identidad de "alerta" pero legible

**templates/problemas.html** (NUEVO)
- Nueva página para tareas con status='problem'
- Esquema de colores rojo/ámbar
- Muestra observaciones prominentemente
- Sin columna de estado (todas son problemas)

**templates/base.html** (líneas 26-45)
- Añadido link "Problemas" entre Pendientes y Realizadas
- Contadores agregados con clase `.nav-counter`
- Usa `{{ task_counts.pending }}`, `{{ task_counts.problems }}`, `{{ task_counts.completed }}`

**static/css/style.css** (líneas 89-116)
- Estilos para `.nav-counter`: badges azules con fondo semi-transparente
- `.nav a` ahora usa flexbox para alinear texto y contador
- Diseño consistente con tema oscuro

### Rutas Nuevas

**GET /problemas** (app.py líneas 242-293)
- Lista tareas con status='problem' desde octubre 2025 hasta periodo actual
- JOIN con sections y task_types
- Solo secciones activas

## Decisiones tomadas

### Separación de Pendientes vs Problemas
**Por qué:** Claridad conceptual
- **Pendientes** = Tareas no revisadas aún (sin marcar)
- **Problemas** = Tareas revisadas que tienen incidencias
- Antes todo se mezclaba en una sola vista

### Cálculo de contador de pendientes
**Problema detectado:** Solo contaba las 9 tareas en BD con status='pending'
**Solución:** Calcular total posible - OK - Problemas
- Total posible = Secciones activas × Tipos de tareas × 1 periodo
- Ahora refleja correctamente ~173 tareas pendientes

### Botones con solo iconos
**Por qué:** La página se hacía muy ancha con textos
**Solución:** Mantener solo ✓ (OK) y ⚠ (Problema)
- Más compacta la tabla
- Iconos universales, no necesitan traducción

### Banner oscuro en pendientes
**Problema:** Amarillo claro no se leía sobre fondo claro
**Solución:** Marrón oscuro (#78350f) con letras amarillo claro (#fef3c7)
- Consistente con tema oscuro de la app
- Contraste adecuado para accesibilidad

## Qué NO hicimos (aplazado)

### Filtros por periodo en Pendientes/Problemas
- Rango fijo: octubre 2025 hasta periodo actual
- Podría añadirse selector de periodo como en Inicio
- No era prioritario para hoy

### Buscar funcional en topbar
- Input de búsqueda existe pero no funciona
- Pendiente para futuras iteraciones

## Estado actual del sistema

**Funcionando correctamente:**
- ✅ Marcar/desmarcar tareas como OK o Problema (toggle buttons)
- ✅ Auto-guardado de observaciones
- ✅ Contadores en sidebar actualizados dinámicamente
- ✅ Navegación entre Inicio, Pendientes, Problemas, Realizadas
- ✅ Selector de periodo en Inicio
- ✅ Hiperlinks en nombres de URL/sección
- ✅ Status-dot cambia de color según estado de tareas (verde/naranja/rojo)
- ✅ Página Pendientes muestra TODAS las tareas sin marcar (no solo las de BD)
- ✅ Página Configuración completa con 3 secciones funcionales
- ✅ CRUD de URLs (añadir, editar, activar/desactivar, eliminar)
- ✅ Configuración de alertas por tipo de tarea
- ✅ Configuración de preferencias de notificación

**Pendiente/No implementado:**
- ⏸️ Búsqueda funcional
- ⏸️ Autenticación de usuarios (hardcoded 'José Ramos')
- ⏸️ Filtros avanzados por fecha/tipo
- ⏸️ Exportación de reportes
- ⏸️ Sistema de envío real de notificaciones (email/desktop) - Por ahora solo configuración
- ⏸️ Programación de alertas automáticas basadas en periodicidad
- ⏸️ Contador de notificaciones en topbar

## Próxima sesión

**Prioridades sugeridas:**

1. ✅ **Página Configuración** - COMPLETADO
   - Implementación completa de CRUD de URLs
   - Configuración de alertas y notificaciones
   - Todo funcional y siguiendo Stage 1

2. **Mejorar página Pendientes** (si es necesario)
   - Generar todas las combinaciones pendientes sin registro en BD
   - O simplemente documentar que es así por diseño

3. **Implementar búsqueda**
   - Filtrar por nombre de sección en tabla
   - JavaScript simple client-side

4. **Validaciones y errores**
   - Manejo de errores en AJAX calls
   - Feedback visual cuando falla guardado

**Siguiente objetivo realista para Stage 1:**
✅ COMPLETADO - Página de Configuración implementada

**Nuevos objetivos sugeridos:**
- Implementar sistema básico de alertas automáticas
- Agregar contador de notificaciones en topbar
- Mejorar búsqueda y filtros

## Bugs conocidos
- ✅ (RESUELTO) Status-dot no cambiaba de color (implementado 2025-10-29)
- ✅ (RESUELTO) Página Pendientes solo mostraba 2 tareas en vez de 1376 (implementado 2025-10-29)

## Notas técnicas

- Base de datos: SQLite (agendaRenta4.db)
- Tablas: sections, task_types, tasks, alert_settings, notification_preferences, notifications
- Task status: 'pending', 'ok', 'problem'
- Periodo actual: 2025-10 (formato YYYY-MM)
- Context processor inyecta task_counts en todos los templates

### Lógica de alertas (para implementación futura)
**Edge case - Días del mes que no existen:**
- Si se configura alerta para día 29, 30 o 31 en meses con menos días:
  * Se usará el **último día del mes**
  * Ejemplo: Alerta día 31 en febrero → se genera el día 28 (o 29 en bisiestos)
  * Ejemplo: Alerta día 31 en abril → se genera el día 30
- Decisión tomada: 2025-10-29
- Estado: Configuración guardada en BD, lógica de generación pendiente para Stage 2