# Estado Actual

**Fecha**: 2025-10-29
**Etapa**: 1 (Prototipado) - ✅ **COMPLETADO Y DESPLEGADO EN PRODUCCIÓN**
**Sesión Final**: Migración completa a PostgreSQL y despliegue en Render

## 🎉 STAGE 1 COMPLETADO Y EN PRODUCCIÓN

La aplicación está **desplegada y funcionando** en Render con PostgreSQL.

### Logros de la sesión final (2025-10-29 tarde)

✅ **Migración completa de SQLite a PostgreSQL**
- Migración exitosa de 1267 filas de datos
- Configuración de PostgreSQL local para desarrollo
- Actualización completa del código para PostgreSQL everywhere
- Eliminación de toda la lógica dual SQLite/PostgreSQL

✅ **Despliegue en producción (Render)**
- Aplicación desplegada y funcionando
- Base de datos PostgreSQL en Render
- Build exitoso con Python 3.11.9
- Todos los servicios comunicándose correctamente

---

## Progreso de la sesión final (2025-10-29 tarde)

### Migración PostgreSQL - Cambios Técnicos

**Archivos modificados:**

1. **utils.py** - Simplificación completa
   - ❌ Eliminado: `import sqlite3`
   - ❌ Eliminado: `DATABASE_PATH`
   - ❌ Eliminado: `adapt_query()` function
   - ❌ Eliminado: Lógica condicional SQLite/PostgreSQL
   - ✅ Solo PostgreSQL: `psycopg2` + `DATABASE_URL`
   - ✅ Context manager `db_cursor()` optimizado para PostgreSQL

2. **app.py** - 40+ queries actualizadas
   - Cambiados todos los placeholders `?` → `%s`
   - Eliminado import de `DATABASE_PATH` y `adapt_query`
   - Agregado `load_dotenv()` al inicio
   - Eliminada verificación de archivo de base de datos
   - Actualizado uso de booleanos (1/0 → TRUE/FALSE donde corresponde)

3. **manage_users.py** - Queries PostgreSQL
   - Cambiados 5 placeholders `?` → `%s`
   - `sqlite3.IntegrityError` → `psycopg2.IntegrityError`
   - Eliminado import de `DATABASE_PATH`

4. **.env** (local)
   - `DATABASE_URL=postgresql://jesusramos:dev-password@localhost/agendaRenta4`

**Migración de datos:**
- Script: `migrate_to_postgres.py`
- Datos migrados: 1267 filas
- Tablas: sections, task_types, tasks, alert_settings, notification_preferences, users, pending_alerts
- Conversión automática de booleanos SQLite (0/1) a PostgreSQL (FALSE/TRUE)
- Reset de sequences automático

**Commit:**
- Hash: `557a59b`
- Mensaje: "Migrate: Cambio completo de SQLite a PostgreSQL"
- Branch: `master`

### Problemas Resueltos en Migración

1. **Python version incompatibility**
   - Error: `psycopg2-binary` no compatible con Python 3.13.4
   - Solución: `runtime.txt` con Python 3.11.9 + psycopg2-binary 2.9.11

2. **Boolean type mismatch**
   - Error: PostgreSQL esperaba BOOLEAN pero recibía INTEGER
   - Solución: Actualización de migration script + 19 queries en código

3. **Database region mismatch**
   - Error: Web service y PostgreSQL en diferentes regiones
   - Solución: Recrear servicios en Frankfurt (misma región)

4. **SQL placeholder syntax**
   - Error: SQLite usa `?`, PostgreSQL usa `%s`
   - Solución: Cambio global de todos los placeholders (40+ queries)

5. **Import errors**
   - Error: Referencias a `DATABASE_PATH` y `adapt_query` inexistentes
   - Solución: Limpieza completa de imports obsoletos

---

## Sesión Anterior (2025-10-29 mañana)
**Objetivo**: Sistema de Alertas Automáticas

## Progreso sesión de alertas (2025-10-29 mañana)
- [x] Crear tabla `pending_alerts` en base de datos
- [x] Implementar función `generate_alerts()` para crear alertas según periodicidad
- [x] Implementar función `check_alert_day()` con lógica para todas las frecuencias
- [x] Crear rutas de alertas en app.py:
  - [x] POST `/admin/generate-alerts` - Generar alertas manualmente
  - [x] GET `/alertas` - Visualizar alertas pendientes (TODAS, no solo activas)
  - [x] POST `/alertas/dismiss/<id>` - Toggle alerta (activa ↔ resuelta)
- [x] Actualizar `get_task_counts()` para incluir contador de alertas
- [x] Agregar link y contador de alertas en sidebar (templates/base.html)
- [x] Crear template `alertas.html` con visualización completa
- [x] Agregar estilos CSS para `.alert-counter` con animación pulse
- [x] Probar generación de alertas: 8 alertas máximo (1 por tipo de tarea)
- [x] Probar toggle de alertas: funcionamiento correcto en ambas direcciones
- [x] Validar lógica de `check_alert_day()` con 10 casos de prueba (todos ✓)
- [x] **Corrección - Cambiar sistema de alertas:**
  - [x] Eliminar section_id de tabla pending_alerts
  - [x] Modificar generate_alerts() para crear solo 1 alerta por task_type
  - [x] Actualizar template para mostrar tipos de tarea en lugar de URLs
- [x] **Corrección - Implementar toggle de alertas:**
  - [x] Modificar endpoint dismiss para hacer toggle en lugar de solo resolver
  - [x] Actualizar template para mostrar TODAS las alertas (activas y resueltas)
  - [x] Diferenciar visualmente alertas resueltas (opacidad 50%, fondo verde)
  - [x] Cambiar botón dinámicamente: "✓ Resolver" ↔ "↻ Reactivar"
  - [x] Mostrar checkmark verde en alertas resueltas

## Progreso sesiones anteriores
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

### Archivos Modificados/Creados (Sesión actual - Sistema de Alertas)

**agendaRenta4.db** - Nueva tabla
- `pending_alerts` - Alertas pendientes generadas automáticamente
  * id, task_type_id, due_date, generated_at, dismissed, dismissed_at
  * UNIQUE constraint en (task_type_id, due_date) para evitar duplicados
  * **NOTA:** NO tiene section_id - una alerta por tipo de tarea, no por URL
  * Máximo 8 alertas simultáneas (una por cada tipo de tarea)

**app.py** - Nuevas funciones y rutas (líneas ~64-132, ~950-1048)
- Función `get_task_counts()` actualizada para incluir contador de alertas
- Función `generate_alerts(reference_date=None)` (líneas ~135-199)
  * Genera alertas según configuración de alert_settings
  * **Crea una alerta por task_type, NO por sección**
  * Verifica periodicidad con check_alert_day()
  * Crea registros en pending_alerts evitando duplicados
  * Retorna estadísticas: {generated, skipped, errors}
  * Máximo 8 alertas por ejecución (una por tipo de tarea)
- Función `check_alert_day(reference_date, frequency, alert_day)` (líneas ~214-285)
  * Valida si una fecha cumple criterios de alerta
  * Lógica para: daily, weekly, biweekly, monthly, quarterly, semiannual, annual
  * Edge case: usa min(target_day, last_day_of_month) para meses cortos
- POST `/admin/generate-alerts` - Endpoint para generar alertas manualmente
- GET `/alertas` - Página de visualización de alertas pendientes (sin JOIN a sections)
- POST `/alertas/dismiss/<id>` - Marcar alerta como resuelta

**templates/alertas.html** (NUEVO - ~172 líneas)
- Tabla con alertas pendientes mostrando:
  * Fecha de aviso, **tipo de tarea**, periodicidad, fecha de generación
  * Texto: "Revisar todas las URLs para esta tarea"
  * Botón "Resolver" para cada alerta
  * **SIN columna de URL/sección** - las alertas son genéricas por tipo
- Panel informativo sobre el sistema de alertas
- Panel de administración con botón para generar alertas manualmente
- JavaScript para:
  * Función `dismissAlert(id)` - Resolver alerta con confirmación
  * Función `generateAlerts()` - Generar alertas manualmente
  * Animación de fade-out al resolver
  * Recarga de página si no quedan alertas

**templates/base.html** (líneas 34-39)
- Nuevo link "Alertas" en navegación (entre Pendientes y Problemas)
- Contador `.nav-counter.alert-counter` solo visible si hay alertas > 0
- Recibe `task_counts.alerts` del context processor

**static/css/style.css** (líneas 118-131)
- `.nav-counter.alert-counter` - Estilo especial para contador de alertas
  * Color amarillo/warning (#f6c445)
  * Fondo semi-transparente rgba(246, 196, 69, 0.2)
  * Animación `pulse-alert` de 2s que pulsa la opacidad
- `.btn.btn-sm` - Botones pequeños (padding: 6px 10px, font-size: 13px)

### Archivos Modificados (Sesiones anteriores)

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

## 🚀 Estado actual del sistema (EN PRODUCCIÓN)

**✅ Funcionando en producción (Render + PostgreSQL):**
- ✅ Marcar/desmarcar tareas como OK o Problema (toggle buttons)
- ✅ Auto-guardado de observaciones
- ✅ Contadores en sidebar actualizados dinámicamente (Pendientes, Alertas, Problemas, Realizadas)
- ✅ Navegación entre Inicio, Pendientes, Alertas, Problemas, Realizadas
- ✅ Selector de periodo en Inicio
- ✅ Hiperlinks en nombres de URL/sección
- ✅ Status-dot cambia de color según estado de tareas (verde/naranja/rojo)
- ✅ Página Pendientes muestra TODAS las tareas sin marcar (no solo las de BD)
- ✅ Página Configuración completa con 3 secciones funcionales
- ✅ CRUD de URLs (añadir, editar, activar/desactivar, eliminar)
- ✅ Configuración de alertas por tipo de tarea (periodicidad + día específico)
- ✅ Configuración de preferencias de notificación
- ✅ Sistema de alertas automáticas completamente funcional
  - Generación de alertas según periodicidad configurada
  - Visualización de alertas pendientes con contador animado
  - Resolución/descarte de alertas individuales
  - Edge case handling para meses con menos días
- ✅ **PostgreSQL en desarrollo Y producción** (dev/prod parity)
- ✅ **Aplicación desplegada en Render** con PostgreSQL managed database

**⏸️ Pendiente para futuras iteraciones (Stage 2+):**
- ⏸️ Búsqueda funcional
- ⏸️ Sistema de autenticación multi-usuario (actualmente hardcoded)
- ⏸️ Filtros avanzados por fecha/tipo
- ⏸️ Exportación de reportes
- ⏸️ Sistema de envío real de notificaciones (email/desktop)
- ⏸️ Programación automática (cron job) para ejecutar generate_alerts() diariamente
- ⏸️ Notificaciones in-app cuando se generan nuevas alertas
- ⏸️ **Web scraper/crawler automático** (Stage 2)

## 🎯 Próxima sesión - Preparar Stage 2

**🎉 STAGE 1 COMPLETADO Y DESPLEGADO**

La aplicación está funcionando en producción. Todos los objetivos de Stage 1 cumplidos:
- ✅ Sistema manual de revisión de tareas
- ✅ Configuración de URLs (CRUD completo)
- ✅ Configuración de alertas con periodicidad
- ✅ Sistema de alertas automáticas
- ✅ PostgreSQL en desarrollo y producción
- ✅ Aplicación desplegada en Render

**Sugerencias para próxima sesión:**

### Opción A: Mejoras opcionales de Stage 1
1. **Autenticación multi-usuario**
   - Sistema de login/logout funcional
   - Gestión de usuarios (crear, editar, eliminar)
   - Permisos por rol (admin, revisor)

2. **Búsqueda funcional**
   - Filtrar secciones en tabla por nombre
   - JavaScript client-side simple

3. **Cron job para alertas**
   - Script para ejecutar `generate_alerts()` diariamente
   - Configuración en servidor o usar servicio como cron-job.org

### Opción B: Comenzar Stage 2 (Web Scraper)
1. **Definir arquitectura del scraper**
   - Evaluar herramientas: Playwright, BeautifulSoup, Scrapy
   - Decidir si scraper corre en Render o separado
   - Diseñar estructura de datos para guardar resultados

2. **Prototipo inicial**
   - Scraper básico para 1-2 URLs de prueba
   - Guardar resultados en nueva tabla `scan_results`
   - Endpoint para visualizar resultados

3. **Integración con sistema de alertas**
   - Scraper se ejecuta cuando hay alerta activa
   - Resultados aparecen en página de alerta
   - Sistema de comparación (cambios vs. última revisión)

**Recomendación: Opción B** - Stage 1 está completo y funcional. Es buen momento para empezar Stage 2.

## Bugs conocidos
- ✅ (RESUELTO) Status-dot no cambiaba de color (implementado 2025-10-29)
- ✅ (RESUELTO) Página Pendientes solo mostraba 2 tareas en vez de 1376 (implementado 2025-10-29)

## Notas técnicas

### Stack actual (Producción)
- **Base de datos**: PostgreSQL (Render managed database)
- **Servidor web**: Gunicorn (puerto configurado por Render)
- **Hosting**: Render (Frankfurt region)
- **Python**: 3.11.9
- **Framework**: Flask 3.0.0
- **Database driver**: psycopg2-binary 2.9.11

### Base de datos local (Desarrollo)
- **Base de datos**: PostgreSQL (localhost)
- **Connection string**: `postgresql://jesusramos:dev-password@localhost/agendaRenta4`
- **Migración**: 1267 filas desde SQLite

### Esquema de base de datos
- **Tablas**: sections, task_types, tasks, alert_settings, notification_preferences, notifications, pending_alerts, users
- **Task status**: 'pending', 'ok', 'problem'
- **Periodo actual**: 2025-10 (formato YYYY-MM)
- **Context processor**: Inyecta task_counts en todos los templates (incluyendo alerts)

### Deployment
- **Archivo de configuración**: render.yaml (Render Blueprint)
- **Build script**: build.sh
- **Runtime**: runtime.txt (Python 3.11.9)
- **Branch de producción**: master

### Sistema de Alertas Automáticas (IMPLEMENTADO ✅)

**Generación de alertas:**
- Función `generate_alerts(reference_date=None)` en app.py
- Se ejecuta manualmente mediante POST `/admin/generate-alerts`
- Consulta todas las configuraciones activas en `alert_settings`
- Para cada configuración, verifica si la fecha de referencia cumple los criterios
- **Crea UNA alerta por task_type** (máximo 8 alertas totales, no 173×8)
- Evita duplicados con constraint UNIQUE(task_type_id, due_date)
- Cada alerta recuerda revisar **todas las URLs** para ese tipo de tarea

**Lógica de periodicidad (`check_alert_day`):**
- **daily**: Siempre True
- **weekly**: Compara día de la semana (0=Monday, 6=Sunday)
- **biweekly**: Como weekly pero solo en semanas pares (week_number % 2 == 0)
- **monthly**: Compara día del mes (1-31)
- **quarterly**: Como monthly pero solo en meses 1, 4, 7, 10
- **semiannual**: Como monthly pero solo en meses 1, 7
- **annual**: Como monthly pero solo en mes 1

**Edge case - Días del mes que no existen:**
- Si se configura alerta para día 29, 30 o 31 en meses con menos días:
  * Se usa `min(target_day, calendar.monthrange(year, month)[1])`
  * Ejemplo: Alerta día 31 en febrero → se genera el día 28 (o 29 en bisiestos)
  * Ejemplo: Alerta día 31 en abril → se genera el día 30
- **Estado:** ✅ Implementado y probado
- **Validación:** 10 casos de prueba ejecutados correctamente

**Visualización:**
- Página `/alertas` muestra todas las alertas con dismissed=0
- Contador animado en sidebar (pulsa amarillo)
- Botón "Resolver" marca alerta como dismissed=1
- Botón admin "Generar Alertas" para testing manual

**Para producción (pendiente):**
- Configurar cron job o systemd timer para ejecutar generate_alerts() diariamente
- Ejemplo cron: `0 9 * * * cd /path/to/app && python3 -c "from app import generate_alerts; generate_alerts()"`