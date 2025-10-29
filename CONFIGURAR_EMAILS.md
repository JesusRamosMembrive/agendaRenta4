# Configuración del Sistema de Notificaciones por Email

## 📧 Paso 1: Configurar SMTP

Copia el archivo `.env.example` a `.env` y configura tus credenciales SMTP:

```bash
cp .env.example .env
```

Edita `.env` con tus credenciales:

```env
# Para Gmail
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USE_TLS=True
MAIL_USERNAME=tu-email@gmail.com
MAIL_PASSWORD=tu-app-password-aqui
MAIL_DEFAULT_SENDER=Agenda Renta4 <tu-email@gmail.com>
```

### Obtener App Password para Gmail:
1. Ve a https://myaccount.google.com/apppasswords
2. Selecciona "App" → "Other" → "Agenda Renta4"
3. Copia la contraseña de 16 caracteres generada
4. Úsala en MAIL_PASSWORD (sin espacios)

### Alternativas a Gmail:
- **Outlook**: smtp-mail.outlook.com:587
- **Office365**: smtp.office365.com:587
- **SendGrid**: smtp.sendgrid.net:587

## 📋 Paso 2: Gestionar Emails de Notificación

### Desde la Página de Configuración:

1. Ve a la sección "Tipo de Notificaciones"
2. Activa "📧 Notificación por Email"
3. En la nueva sección "Emails de Notificación":
   - Añade emails uno por uno
   - Cada email puede tener un nombre descriptivo
   - Puedes activar/desactivar emails individuales
   - Puedes eliminar emails que ya no necesites

### Desde la Base de Datos (si prefieres):

```sql
INSERT INTO notification_emails (email, name, active) 
VALUES ('ejemplo@empresa.com', 'Juan Pérez', 1);
```

## 🔔 Paso 3: Activar Notificaciones

En Configuración → Tipo de Notificaciones:
- ✅ Marca "Notificación por Email"
- ✅ Añade al menos un email en la lista

## 🧪 Paso 4: Probar

1. Ve a la página de Alertas
2. Haz clic en "🔄 Generar Alertas de Hoy"
3. Si todo está configurado correctamente:
   - Se generarán las alertas
   - Se enviará un email a todos los destinatarios activos
   - Verás un mensaje de éxito con estadísticas de envío

## ❌ Solución de Problemas

### "SMTP not configured"
- Verifica que MAIL_USERNAME y MAIL_PASSWORD estén en .env
- Asegúrate de que .env esté en la raíz del proyecto
- Reinicia el servidor Flask después de modificar .env

### "Failed to send email: Authentication failed"
- Para Gmail, usa App Password no tu contraseña normal
- Verifica que la autenticación en dos pasos esté activada en Gmail

### "No active email recipients configured"
- Añade al menos un email en Configuración
- Verifica que el email esté marcado como activo

### "Email notifications not enabled"
- En Configuración, marca la casilla "Notificación por Email"
- Haz clic en "Guardar"

## 📝 Notas Importantes

- Los emails se envían cuando se generan alertas nuevas
- Si ya existe una alerta para ese día y tipo, no se envía email duplicado
- Puedes tener múltiples destinatarios (equipo, jefes, etc.)
- El sistema usa HTML para emails bonitos y legibles
- Los emails incluyen un link directo a la página de alertas
