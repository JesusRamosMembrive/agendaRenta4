#!/usr/bin/env python3
"""
Script para probar el envío de emails
Uso: python3 test_email.py [email_destino]
"""

import sys
import os
from dotenv import load_dotenv
from flask import Flask
from flask_mail import Mail, Message

# Load environment variables
load_dotenv()

# Create Flask app
app = Flask(__name__)

# Configure mail
app.config['MAIL_SERVER'] = os.getenv('MAIL_SERVER', 'smtp.gmail.com')
app.config['MAIL_PORT'] = int(os.getenv('MAIL_PORT', 587))
app.config['MAIL_USE_TLS'] = os.getenv('MAIL_USE_TLS', 'True') == 'True'
app.config['MAIL_USE_SSL'] = os.getenv('MAIL_USE_SSL', 'False') == 'True'
app.config['MAIL_USERNAME'] = os.getenv('MAIL_USERNAME')
app.config['MAIL_PASSWORD'] = os.getenv('MAIL_PASSWORD')
app.config['MAIL_DEFAULT_SENDER'] = os.getenv('MAIL_DEFAULT_SENDER', 'Agenda Renta4 <noreply@renta4.com>')
app.config['MAIL_DEBUG'] = True

mail = Mail(app)

def test_email(recipient=None):
    """Send a test email"""

    print("=" * 70)
    print("  TEST: Configuración de Email")
    print("=" * 70)
    print()

    # Show configuration (hide password)
    print("📧 Configuración SMTP:")
    print(f"   Server:     {app.config['MAIL_SERVER']}")
    print(f"   Port:       {app.config['MAIL_PORT']}")
    print(f"   TLS:        {app.config['MAIL_USE_TLS']}")
    print(f"   SSL:        {app.config['MAIL_USE_SSL']}")
    print(f"   Username:   {app.config['MAIL_USERNAME']}")
    print(f"   Password:   {'*' * len(app.config['MAIL_PASSWORD'] or '')}")
    print(f"   Sender:     {app.config['MAIL_DEFAULT_SENDER']}")
    print()

    # Validate configuration
    if not app.config['MAIL_USERNAME'] or not app.config['MAIL_PASSWORD']:
        print("❌ ERROR: MAIL_USERNAME o MAIL_PASSWORD no están configurados")
        print()
        print("Configura las siguientes variables en .env:")
        print("  MAIL_USERNAME=tu-email@gmail.com")
        print("  MAIL_PASSWORD=tu-app-password")
        return False

    # Get recipient
    if not recipient:
        recipient = app.config['MAIL_USERNAME']

    print(f"📬 Destinatario: {recipient}")
    print()

    # Confirm
    response = input("¿Enviar email de prueba? (y/n): ")
    if response.lower() != 'y':
        print("❌ Cancelado")
        return False

    print()
    print("📤 Enviando email de prueba...")

    try:
        with app.app_context():
            # Build email body
            server = app.config['MAIL_SERVER']
            port = app.config['MAIL_PORT']
            tls = 'Activado' if app.config['MAIL_USE_TLS'] else 'Desactivado'
            sender = app.config['MAIL_DEFAULT_SENDER']

            html_body = f"""
<html>
<head>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
        .header {{ background: #667eea; color: white; padding: 30px; border-radius: 8px 8px 0 0; }}
        .content {{ background: #f9fafb; padding: 30px; }}
        .footer {{ background: #1f2937; color: #9ca3af; padding: 20px; border-radius: 0 0 8px 8px; font-size: 14px; }}
        .success {{ background: #dcfce7; padding: 15px; border-radius: 6px; border-left: 4px solid #10b981; margin: 20px 0; }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1 style="margin: 0;">🎉 Email de Prueba</h1>
            <p style="margin: 10px 0 0 0;">Sistema de Notificaciones - Agenda Renta4</p>
        </div>

        <div class="content">
            <div class="success">
                <strong>✅ ¡Configuración exitosa!</strong>
                <p style="margin: 10px 0 0 0;">
                    El sistema de emails está correctamente configurado y funcionando.
                </p>
            </div>

            <h2>Detalles de la Configuración</h2>
            <ul>
                <li><strong>Servidor SMTP:</strong> {server}</li>
                <li><strong>Puerto:</strong> {port}</li>
                <li><strong>TLS:</strong> {tls}</li>
                <li><strong>Remitente:</strong> {sender}</li>
            </ul>

            <h2>Próximos Pasos</h2>
            <ol>
                <li>Activar el scheduler automático en /crawler/scheduler</li>
                <li>Configurar la frecuencia de revalidación (diaria/semanal)</li>
                <li>Recibirás notificaciones automáticas cuando se detecten enlaces rotos</li>
            </ol>

            <p style="margin-top: 30px; color: #6b7280; font-size: 14px;">
                Este es un email de prueba generado automáticamente.<br>
                No es necesario responder a este mensaje.
            </p>
        </div>

        <div class="footer">
            <p style="margin: 0;">
                🤖 Generado por <strong>Agenda Renta4</strong> - Sistema de Monitoreo Web
            </p>
        </div>
    </div>
</body>
</html>
"""

            # Create message
            msg = Message(
                subject="[TEST] Agenda Renta4 - Prueba de Email",
                recipients=[recipient],
                html=html_body
            )

            # Send email
            mail.send(msg)

            print()
            print("=" * 70)
            print("  ✅ Email enviado correctamente")
            print("=" * 70)
            print()
            print(f"📬 Revisa tu bandeja de entrada: {recipient}")
            print("   (También revisa spam/promociones si no lo ves)")
            print()

            return True

    except Exception as e:
        print()
        print("=" * 70)
        print("  ❌ Error al enviar email")
        print("=" * 70)
        print()
        print(f"Error: {str(e)}")
        print()

        # Common errors
        if "Username and Password not accepted" in str(e):
            print("💡 Sugerencias:")
            print("   1. Verifica que MAIL_USERNAME y MAIL_PASSWORD sean correctos")
            print("   2. Si usas Gmail, necesitas una 'App Password':")
            print("      https://myaccount.google.com/apppasswords")
            print("   3. Verifica que 'Acceso de apps menos seguras' esté activado")
        elif "timed out" in str(e).lower():
            print("💡 Sugerencias:")
            print("   1. Verifica tu conexión a internet")
            print("   2. Verifica que el puerto (587) no esté bloqueado por firewall")
            print("   3. Prueba con otro servidor SMTP")

        print()
        return False


if __name__ == '__main__':
    recipient = sys.argv[1] if len(sys.argv) > 1 else None
    success = test_email(recipient)
    sys.exit(0 if success else 1)
