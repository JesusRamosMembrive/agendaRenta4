# 🧪 Guía de Testing Local - Phase 2.4

## Prerequisitos

✅ Base de datos PostgreSQL corriendo (localhost)
✅ Migración 004 ejecutada (tabla `health_snapshots` creada)
✅ APScheduler instalado (`pip install APScheduler==3.10.4`)
✅ 2,839 URLs descubiertas en la base de datos

## Paso 1: Iniciar la Aplicación Flask

```bash
python app.py
```

Deberías ver:
```
 * Serving Flask app 'app'
 * Debug mode: on
WARNING: This is a development server. Do not use it in a production deployment.
 * Running on http://127.0.0.1:5000
```

✅ **La aplicación está corriendo** si ves este mensaje.

---

## Paso 2: Acceder a la Aplicación

1. **Abrir navegador**: http://127.0.0.1:5000

2. **Login**:
   - Usuario: `admin` (o el usuario que tengas configurado)
   - Contraseña: tu contraseña

✅ **Login exitoso** si ves el dashboard principal de Inicio.

---

## Paso 3: Testing del Módulo Crawler

### 3.1 Dashboard Principal del Crawler

**URL**: http://127.0.0.1:5000/crawler

**Qué verificar:**
- ✅ Stats cards muestran números correctos
  - Total URLs descubiertas
  - URLs rotas
  - Último crawl
- ✅ Historial de crawls visible
- ✅ Botón "Iniciar Nuevo Crawl"

**Screenshot sugerido**: `screenshots/01-crawler-dashboard.png`

---

### 3.2 URLs Descubiertas

**URL**: http://127.0.0.1:5000/crawler/results

**Qué verificar:**
- ✅ Tabla muestra las 2,839 URLs descubiertas
- ✅ Paginación funciona (si hay más de 100 URLs)
- ✅ Columna "Profundidad" tiene badge azul con texto legible
- ✅ Enlaces rotos tienen fondo rosa con texto rojo oscuro (legible)
- ✅ Al hacer click en URL se abre en nueva pestaña

**Screenshot sugerido**: `screenshots/02-urls-descubiertas.png`

---

### 3.3 Validación - Enlaces Rotos ⚠️ (BUG FIX VISUAL)

**URL**: http://127.0.0.1:5000/crawler/broken

**Qué verificar:**
- ✅ Stats cards muestran:
  - Total enlaces rotos (debería ser ~46)
  - Enlaces prioritarios rotos (debería ser 0)
  - Nuevos rotos
- ✅ Tabla de enlaces rotos visible
- ✅ **VERIFICAR BUG FIX**: Texto en enlaces rotos es legible (rojo oscuro sobre rosa)
- ✅ Badges de status code visibles (404, 500, etc.)

**Screenshot sugerido**: `screenshots/03-enlaces-rotos.png`

---

### 3.4 🆕 Health Dashboard (NUEVO - Phase 2.4)

**URL**: http://127.0.0.1:5000/crawler/health

**Qué verificar:**

#### Stats Cards
- ✅ **HEALTH SCORE**: Muestra porcentaje (debería ser ~98.4%)
  - Fondo verde si >95%
  - Fondo amarillo si 80-95%
  - Fondo rojo si <80%
- ✅ **TOTAL URLs**: Muestra número (2,839)
- ✅ **URLs OK**: Muestra número y porcentaje
- ✅ **ENLACES ROTOS**: Muestra número y porcentaje

#### Mensaje si no hay datos
Si es la primera vez que accedes:
- ⚠️ Banner amarillo: "No hay datos de salud disponibles"
- ✅ Link a "Ejecuta una revalidación"

#### Cambios Recientes (si existen)
- ✅ Cards con conteo de cambios (🆕 Nuevas, ❌ Rotas, ✅ Corregidas, 🔄 Cambios)

#### Gráfico Histórico (si hay >1 snapshot)
- ✅ Gráfico de líneas con Chart.js
- ✅ Eje izquierdo: Health Score (%)
- ✅ Eje derecho: Enlaces Rotos
- ✅ Leyenda visible
- ✅ Tooltip al hacer hover

#### Botones de acción
- ✅ "⚙️ Configurar Scheduler"
- ✅ "🔍 Ver Enlaces Rotos"
- ✅ "← Volver al Dashboard"

**Screenshot sugerido**: `screenshots/04-health-dashboard.png`

---

### 3.5 🆕 Configuración del Scheduler (NUEVO - Phase 2.4)

**URL**: http://127.0.0.1:5000/crawler/scheduler

**Qué verificar:**

#### Estado Actual
Si el scheduler está inactivo:
- ✅ Fondo gris con "⚪ Scheduler inactivo"
- ✅ Mensaje explicativo

Si el scheduler está activo:
- ✅ Fondo verde con "🟢 Activo"
- ✅ Próxima ejecución visible (ej: "01/11/2025 03:00:00")
- ✅ Configuración visible (ej: "cron[hour='3', minute='0']")
- ✅ Botón "🛑 Detener Scheduler" (rojo)

#### Formulario de Configuración
- ✅ Select de frecuencia: "Diaria", "Semanal (Lunes)"
- ✅ Input de hora (0-23)
- ✅ Input de minuto (0-59)
- ✅ Botón "▶️ Iniciar Scheduler" (verde)

#### Panel de Ejecución Manual
- ✅ Fondo amarillo
- ✅ Advertencia visible
- ✅ Botón "▶️ Ejecutar Revalidación Ahora" (naranja)
- ✅ Confirmación JavaScript al hacer click

#### Panel Informativo
- ✅ Fondo azul claro
- ✅ Lista de características del scheduler
- ✅ Tiempo estimado calculado (~24 minutos para 2,839 URLs)

**Screenshot sugerido**: `screenshots/05-scheduler-config.png`

---

## Paso 4: Testing Funcional

### 4.1 Ejecutar Revalidación Manual

**Pasos:**
1. Ir a: http://127.0.0.1:5000/crawler/scheduler
2. Scroll a "Ejecución Manual"
3. Click en "▶️ Ejecutar Revalidación Ahora"
4. Confirmar en el diálogo JavaScript
5. **ESPERAR**: La página puede tardar ~20-30 minutos (2,839 URLs × 0.5 seg/URL)

**Qué esperar:**
- ⏳ La página quedará "cargando" mientras ejecuta
- ✅ Al finalizar: mensaje "✓ Revalidación manual ejecutada"
- ✅ Redirige a /crawler/scheduler

**Verificar en consola del servidor:**
```bash
# En la terminal donde corre Flask, deberías ver:
INFO - Validating URLs...
INFO - Progress: 10/2839 URLs validated
INFO - Progress: 20/2839 URLs validated
...
INFO - Validation complete
INFO - Health snapshot saved
```

**Después de completar:**
1. Ir a: http://127.0.0.1:5000/crawler/health
2. ✅ Verificar que ahora aparece el Health Score
3. ✅ Verificar que hay un snapshot en la lista

**⚠️ NOTA**: Este proceso es LENTO. Es normal. Puedes cancelar y continuar con otros tests.

---

### 4.2 Iniciar Scheduler Automático

**Pasos:**
1. Ir a: http://127.0.0.1:5000/crawler/scheduler
2. En "Configurar Nueva Programación":
   - Frecuencia: Diaria
   - Hora: 3
   - Minuto: 0
3. Click en "▶️ Iniciar Scheduler"

**Qué esperar:**
- ✅ Mensaje flash: "✓ Scheduler iniciado: daily a las 03:00"
- ✅ El panel "Estado Actual" ahora muestra:
  - 🟢 Activo
  - Próxima ejecución: mañana a las 03:00
- ✅ Aparece botón "🛑 Detener Scheduler"

**Screenshot sugerido**: `screenshots/06-scheduler-activo.png`

---

### 4.3 Detener Scheduler

**Pasos:**
1. En la misma página (/crawler/scheduler)
2. Click en "🛑 Detener Scheduler" (botón rojo arriba)

**Qué esperar:**
- ✅ Mensaje flash: "✓ Scheduler detenido"
- ✅ El panel "Estado Actual" vuelve a "⚪ Scheduler inactivo"

---

### 4.4 Verificar Base de Datos

**Comando:**
```bash
psql postgresql://jesusramos:dev-password@localhost/agendaRenta4
```

**Queries de verificación:**

```sql
-- ¿Cuántos snapshots de salud hay?
SELECT COUNT(*) FROM health_snapshots;

-- Ver último snapshot
SELECT
    snapshot_date,
    health_score,
    total_urls,
    ok_urls,
    broken_urls
FROM health_snapshots
ORDER BY snapshot_date DESC
LIMIT 1;

-- Ver cambios recientes (últimos 7 días)
SELECT
    change_type,
    COUNT(*) as count
FROM url_changes
WHERE detected_at >= NOW() - INTERVAL '7 days'
GROUP BY change_type;
```

**Qué esperar:**
- ✅ Si ejecutaste revalidación manual: 1+ snapshots
- ✅ Si no: 0 snapshots (normal)
- ✅ Health score entre 0-100

---

## Paso 5: Testing de Email (Opcional)

⚠️ **Requiere configurar SMTP en .env**

### 5.1 Configurar SMTP

Editar `.env`:
```bash
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USE_TLS=True
MAIL_USERNAME=tu-email@gmail.com
MAIL_PASSWORD=tu-app-password  # App password, no contraseña normal
MAIL_DEFAULT_SENDER=Agenda Renta4 <noreply@renta4.com>
```

**Cómo obtener App Password de Gmail:**
1. Google Account → Security
2. 2-Step Verification (activar si no está)
3. App Passwords → Generate
4. Copiar el código de 16 caracteres

### 5.2 Configurar Email en la App

1. Ir a: http://127.0.0.1:5000/configuracion
2. Scroll a "Tipo de Notificaciones"
3. ✅ Check "Email"
4. Ingresar tu email
5. Guardar

### 5.3 Forzar Envío de Email

**Opción A**: Hacer que una URL se rompa
1. En discovered_urls, cambiar manualmente un status_code de 200 a 404
2. Ejecutar revalidación
3. Al detectar cambio, enviará email

**Opción B**: Ejecutar función directamente (no recomendado para testing)

---

## Paso 6: Testing de Menú Sidebar

**Verificar que el menú lateral tiene:**

### Sección "Gestión de Tareas"
- ✅ 🏠 Inicio
- ✅ 📋 Pendientes (con contador)
- ✅ 🔔 Alertas (con contador animado)
- ✅ ⚠️ Problemas (con contador)
- ✅ ✅ Realizadas (con contador)
- ✅ ⚙️ Configuración

### Sección "Crawler"
- ✅ 📊 Dashboard
- ✅ 🌐 URLs Descubiertas
- ✅ 🔍 Validación (con contador de enlaces rotos)
- ✅ 💚 Health (NUEVO)
- ✅ ⚙️ Scheduler (NUEVO)

**Screenshot sugerido**: `screenshots/07-menu-completo.png`

---

## Checklist Final

### Features Phase 2.4
- [ ] Health Dashboard accesible y funcional
- [ ] Stats cards muestran datos correctos
- [ ] Gráfico histórico se renderiza (Chart.js)
- [ ] Scheduler configuration UI funciona
- [ ] Formulario de scheduler tiene valores por defecto
- [ ] Botón "Iniciar Scheduler" funciona
- [ ] Botón "Detener Scheduler" funciona
- [ ] Botón "Ejecutar Revalidación Ahora" funciona (puede tardar)
- [ ] Estado del scheduler es visible y correcto
- [ ] Menú sidebar actualizado con nuevos enlaces

### Bug Fixes
- [ ] Enlaces rotos en /crawler/results tienen texto legible
- [ ] Badge de profundidad tiene texto legible

### Base de Datos
- [ ] Tabla health_snapshots existe
- [ ] Se pueden insertar snapshots correctamente
- [ ] Queries históricas funcionan

---

## Troubleshooting

### Error: "health_snapshots table does not exist"
**Solución**:
```bash
psql postgresql://jesusramos:dev-password@localhost/agendaRenta4 < migrations/004_add_health_snapshots.sql
```

### Error: "Module APScheduler not found"
**Solución**:
```bash
pip install APScheduler==3.10.4
```

### Error: "Port 5000 already in use"
**Solución**:
```bash
# Opción 1: Matar proceso en puerto 5000
lsof -ti:5000 | xargs kill -9

# Opción 2: Usar otro puerto
export PORT=5001
python app.py
```

### Scheduler no ejecuta automáticamente
**Verificar**:
- ✅ Scheduler está iniciado (🟢 Activo)
- ✅ Próxima ejecución es futura
- ✅ Flask app sigue corriendo
- ⚠️ **NOTA**: En desarrollo, si reinicias Flask, el scheduler se detiene

### Gráfico no se muestra
**Verificar**:
- ✅ Hay al menos 2 snapshots en health_snapshots
- ✅ Chart.js se carga desde CDN (requiere internet)
- ✅ Console del navegador no muestra errores JS

### Email no se envía
**Verificar**:
- ✅ Variables MAIL_* configuradas en .env
- ✅ App Password de Gmail correcto (no contraseña normal)
- ✅ Hay URLs que cambiaron de OK a broken
- ✅ notification_preferences tiene enable_email=TRUE

---

## Notas Adicionales

### Tiempo de Ejecución Esperado
- **Revalidación manual**: ~20-30 minutos (2,839 URLs × 0.5 seg)
- **Health dashboard**: <1 segundo
- **Scheduler config**: <1 segundo

### Seguridad
- ⚠️ Este es un servidor de DESARROLLO
- ⚠️ NO usar en producción con `debug=True`
- ⚠️ Cambiar `SECRET_KEY` en producción

### Logs Útiles
```bash
# Ver logs del scheduler en tiempo real
tail -f /ruta/logs/crawler.log  # Si configuraste logging a archivo

# Ver output de Flask
# (ya lo ves en la terminal donde ejecutaste python app.py)
```

---

## Screenshots Sugeridos para Documentación

Crear carpeta `screenshots/`:
```bash
mkdir -p screenshots
```

Capturas sugeridas:
1. `01-crawler-dashboard.png` - Dashboard principal
2. `02-urls-descubiertas.png` - Tabla de URLs con bug fix
3. `03-enlaces-rotos.png` - Validación con bug fix
4. `04-health-dashboard.png` - Health con gráfico
5. `05-scheduler-config.png` - Configuración scheduler
6. `06-scheduler-activo.png` - Scheduler corriendo
7. `07-menu-completo.png` - Sidebar con nuevas secciones

---

**¡Listo para testing!** 🚀

Si encuentras algún bug, anótalo con:
- URL donde ocurre
- Qué esperabas
- Qué pasó realmente
- Screenshot (si es visual)
