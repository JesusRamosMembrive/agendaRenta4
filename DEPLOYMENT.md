# Guía de Deployment - Render + PostgreSQL

Esta guía te ayudará a desplegar **agendaRenta4** en Render con PostgreSQL en ~15-20 minutos.

## ¿Por qué Render + PostgreSQL?

- ✅ **PostgreSQL gratis** - Base de datos robusta incluida en free tier
- ✅ **Deployment automático** - Desde GitHub, cada push autodeploys
- ✅ **Archivos estáticos funcionan** - CSS/JS se sirven correctamente
- ✅ **HTTPS incluido** - Certificado SSL automático
- ✅ **Stage 1 compatible** - Configuración simple con render.yaml

---

## Requisitos Previos

1. ✅ Cuenta en GitHub (tu código ya está en GitHub)
2. ✅ Cuenta en Render (gratis): https://render.com
3. ✅ Base de datos SQLite local con tus datos

---

## Paso 1: Subir código a GitHub

```bash
# En tu máquina local, asegúrate de que todo esté commiteado
git status

# Si hay cambios pendientes:
git add .
git commit -m "Preparar deployment para Render"
git push origin master  # o develop
```

**Tiempo:** 1 minuto

---

## Paso 2: Crear cuenta en Render

1. Ve a https://render.com
2. Haz clic en **"Get Started for Free"**
3. Regístrate con tu cuenta de GitHub (recomendado)
4. Autoriza a Render para acceder a tus repositorios

**Tiempo:** 2 minutos

---

## Paso 3: Crear servicios desde render.yaml

Render detectará automáticamente el archivo `render.yaml` y creará:
- Web Service (Flask app)
- PostgreSQL Database

### Opción A: Blueprint (Automático - Recomendado)

1. En el dashboard de Render, haz clic en **"New +"** → **"Blueprint"**

2. Conecta tu repositorio:
   - Selecciona **"agendaRenta4"** de la lista
   - Haz clic en **"Connect"**

3. Render leerá `render.yaml` y te mostrará:
   - ✅ Web Service: agendarenta4
   - ✅ PostgreSQL: agendarenta4-db

4. Configura variables de entorno sensibles:
   - `MAIL_USERNAME`: tu-email@gmail.com
   - `MAIL_PASSWORD`: tu-app-password-de-gmail
   - `MAIL_DEFAULT_SENDER`: tu-email@gmail.com

5. Haz clic en **"Apply"**

Render creará ambos servicios automáticamente y comenzará el deployment.

### Opción B: Manual

Si prefieres crear los servicios manualmente:

#### 3.1. Crear PostgreSQL Database

1. Dashboard → **"New +"** → **"PostgreSQL"**
2. Configuración:
   - Name: `agendarenta4-db`
   - Database: `agendarenta4`
   - User: `agendarenta4`
   - Region: Frankfurt (o la más cercana)
   - Plan: **Free**
3. Haz clic en **"Create Database"**
4. **IMPORTANTE:** Guarda la **Internal Database URL** (la necesitarás)

#### 3.2. Crear Web Service

1. Dashboard → **"New +"** → **"Web Service"**
2. Conecta tu repositorio de GitHub
3. Configuración:
   - Name: `agendarenta4`
   - Region: Frankfurt (misma que la base de datos)
   - Branch: `master` (o `develop`)
   - Root Directory: (dejar vacío)
   - Environment: **Python 3**
   - Build Command: `./build.sh`
   - Start Command: `gunicorn --bind 0.0.0.0:$PORT app:app`
   - Plan: **Free**

4. Variables de entorno (Add Environment Variable):
   ```
   DATABASE_URL = [pegar Internal Database URL de PostgreSQL]
   SECRET_KEY = [generar aleatorio, ej: ejecuta en terminal: python3 -c "import secrets; print(secrets.token_hex(32))"]
   MAIL_SERVER = smtp.gmail.com
   MAIL_PORT = 587
   MAIL_USE_TLS = True
   MAIL_USE_SSL = False
   MAIL_USERNAME = tu-email@gmail.com
   MAIL_PASSWORD = tu-app-password-de-gmail
   MAIL_DEFAULT_SENDER = tu-email@gmail.com
   MAIL_DEBUG = False
   ```

5. Haz clic en **"Create Web Service"**

**Tiempo:** 5-7 minutos

---

## Paso 4: Esperar el primer deploy

Render comenzará a:
1. Clonar tu repositorio
2. Ejecutar `build.sh` (instalar dependencias)
3. Iniciar la aplicación con gunicorn

Verás los logs en tiempo real. El primer deploy tarda ~3-5 minutos.

**Indicador de éxito:** Status cambia a **"Live"** (verde)

**Tiempo:** 3-5 minutos

---

## Paso 5: Migrar datos de SQLite a PostgreSQL

⚠️ **IMPORTANTE:** La base de datos PostgreSQL está vacía. Necesitas migrar tus datos.

### 5.1. Obtener DATABASE_URL de producción

1. Ve a tu PostgreSQL database en Render
2. En la pestaña **"Info"**, copia la **External Database URL**
   - Formato: `postgresql://user:pass@hostname:port/database`

### 5.2. Ejecutar migración desde tu máquina local

```bash
# En tu máquina local (donde está agendaRenta4.db)
cd /ruta/a/agendaRenta4

# Instalar psycopg2 localmente (solo una vez)
pip install psycopg2-binary

# Ejecutar migración
python3 migrate_to_postgres.py "postgresql://user:pass@hostname:port/database"

# Ejemplo real:
# python3 migrate_to_postgres.py "postgresql://agendarenta4_user:abc123@dpg-xyz.frankfurt-postgres.render.com:5432/agendarenta4"
```

El script:
- ✅ Creará todas las tablas en PostgreSQL
- ✅ Copiará todos los datos de SQLite
- ✅ Ajustará sequences/autoincrement
- ✅ Validará la migración

**Tiempo:** 2-3 minutos

---

## Paso 6: Verificar la aplicación

1. Ve a la URL de tu Web Service en Render
   - Formato: `https://agendarenta4.onrender.com`

2. Haz login con tus credenciales

3. Verifica que:
   - ✅ CSS y estilos se cargan correctamente
   - ✅ Puedes ver tus secciones/URLs
   - ✅ Puedes marcar tareas como OK/Problema
   - ✅ Los datos migrados están presentes

🎉 **¡Tu aplicación está en producción!**

**Tiempo:** 2 minutos

---

## Configuración adicional (Opcional)

### Custom Domain

1. En tu Web Service → **"Settings"** → **"Custom Domains"**
2. Agrega tu dominio (ej: `agenda.tudominio.com`)
3. Configura el CNAME en tu proveedor de DNS
4. Render proveerá HTTPS automáticamente

### Configurar Email (Gmail App Password)

Si aún no tienes App Password de Gmail:

1. Ve a https://myaccount.google.com/apppasswords
2. Genera una nueva contraseña de aplicación
3. Usa esa contraseña en `MAIL_PASSWORD` (NO tu contraseña normal)

### Auto-deploys

Por defecto, Render hace auto-deploy en cada `git push`. Para desactivar:

1. Web Service → **"Settings"**
2. Desactiva **"Auto-Deploy"**

---

## Troubleshooting

### Error: "Application failed to start"

**Solución:**
1. Revisa los logs en Render
2. Busca errores de importación o dependencias faltantes
3. Verifica que `DATABASE_URL` esté configurada correctamente

```bash
# Probar localmente con PostgreSQL:
export DATABASE_URL="postgresql://..."
python3 app.py
```

### Error: "No module named psycopg2"

**Solución:**
- Verifica que `psycopg2-binary==2.9.9` esté en `requirements.txt`
- Haz push y redeploy

### CSS no se carga

**Solución:**
- En Render, los archivos estáticos se sirven correctamente con Flask
- Verifica que `static/` esté en tu repositorio
- Hard refresh en el navegador: Ctrl+F5

### Base de datos vacía después de deploy

**Solución:**
- Ejecuta el script de migración (`migrate_to_postgres.py`)
- Verifica que usaste la **External Database URL** correcta

### Conexión a base de datos falla

**Solución:**
1. Verifica que Web Service y PostgreSQL estén en la misma región
2. Usa **Internal Database URL** en variables de entorno del Web Service
3. Revisa que la base de datos esté en estado "Available"

---

## Desarrollo local vs Producción

### Desarrollo Local (SQLite)

```bash
# .env local
DATABASE_PATH=agendaRenta4.db
# DATABASE_URL comentado o sin definir

python3 app.py
```

La aplicación detecta que no hay `DATABASE_URL` y usa SQLite.

### Producción (PostgreSQL)

```bash
# Variables de entorno en Render
DATABASE_URL=postgresql://...

gunicorn app:app
```

La aplicación detecta `DATABASE_URL` y usa PostgreSQL.

**Mismo código, diferentes bases de datos** ✨

---

## Limitaciones del Free Tier de Render

### Web Service:
- ❌ Se duerme después de 15 minutos de inactividad
- ⚠️ Primer request después de dormir tarda ~30 segundos (cold start)
- ✅ 750 horas/mes incluidas (suficiente para Stage 1)
- ✅ HTTPS automático
- ✅ Custom domain

### PostgreSQL:
- ⚠️ 90 días de free tier, después $7/mes
- ✅ 1GB almacenamiento
- ✅ Backups automáticos
- ❌ Puede ser eliminado si no lo actualizas a plan pago

**Tip:** Para Stage 1 es perfecto. Para Stage 2/3 considera upgrade.

---

## Backups de Base de Datos

### Backup automático (incluido en free tier):

Render hace backups diarios automáticos.

### Backup manual:

```bash
# Desde tu máquina local
pg_dump -d "postgresql://user:pass@host:port/database" > backup.sql

# Restaurar
psql -d "postgresql://user:pass@host:port/database" < backup.sql
```

---

## Actualizar la aplicación

### Cambios en el código:

```bash
# En tu máquina local
git add .
git commit -m "Actualizar feature X"
git push

# Render detectará el push y hará redeploy automático
```

### Cambios en variables de entorno:

1. Web Service → **"Environment"**
2. Edita la variable
3. Guarda → Render reinicia automáticamente

---

## Monitoring y Logs

### Ver logs en tiempo real:

1. Web Service → **"Logs"**
2. Verás stdout/stderr de tu aplicación
3. Útil para debugging

### Métricas:

1. Web Service → **"Metrics"**
2. CPU, memoria, requests, etc.

---

## Migrar a otro proveedor (futuro)

Si en el futuro quieres migrar (Fly.io, Railway, VPS):

1. **Backup de PostgreSQL:**
   ```bash
   pg_dump -d "$DATABASE_URL" > full_backup.sql
   ```

2. **Usar render.yaml como referencia** para configurar en nueva plataforma

3. **Actualizar DATABASE_URL** en variables de entorno

Todo lo demás es estándar (Flask + PostgreSQL + gunicorn).

---

## Recursos

- **Dashboard Render:** https://dashboard.render.com
- **Docs Render:** https://render.com/docs
- **PostgreSQL Docs:** https://www.postgresql.org/docs/
- **Gunicorn Docs:** https://docs.gunicorn.org/

---

## Siguiente paso (Stage 2)

Tu Stage 1 está **completo y en producción** 🚀

Para Stage 2, considera:
- Implementar scraping/crawling automático
- Mejorar sistema de alertas
- Añadir más tipos de notificaciones

¡Felicidades por completar Stage 1!

---

**¿Problemas?** Revisa los logs en Render o consulta la documentación oficial.
