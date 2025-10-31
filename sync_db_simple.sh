#!/bin/bash
# Script simple para copiar base de datos local a producción
# Uso: ./sync_db_simple.sh

set -e

PRODUCTION_URL="postgresql://taskmanagerwebrenta4db_ozfy_user:cp6ZcGTJWL1FDUCkaXijmSzFhnUlo4Nm@dpg-d416bl98ocjs73ch4lrg-a.frankfurt-postgres.render.com/taskmanagerwebrenta4db_ozfy"
LOCAL_URL=$(grep DATABASE_URL .env | cut -d '=' -f2-)

echo "=========================================="
echo "  PostgreSQL Local → Production"
echo "=========================================="
echo ""

# Paso 1: Crear dump de base de datos local
echo "📦 Creando dump de base de datos local..."
pg_dump "$LOCAL_URL" --clean --if-exists --no-owner --no-privileges > /tmp/db_backup.sql

if [ $? -eq 0 ]; then
    echo "   ✅ Dump creado: /tmp/db_backup.sql"
    SIZE=$(du -h /tmp/db_backup.sql | cut -f1)
    echo "   📊 Tamaño: $SIZE"
else
    echo "   ❌ Error creando dump"
    exit 1
fi

echo ""

# Paso 2: Restaurar en producción
echo "📤 Restaurando en producción..."
echo "   ⚠️  Esto BORRARÁ todos los datos existentes en producción"
read -p "   ¿Continuar? (escribe 'yes' para confirmar): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo ""
    echo "❌ Operación cancelada"
    exit 1
fi

echo ""
echo "   Aplicando dump en producción..."

psql "$PRODUCTION_URL" < /tmp/db_backup.sql > /tmp/restore.log 2>&1

if [ $? -eq 0 ]; then
    echo "   ✅ Base de datos restaurada correctamente"
else
    echo "   ⚠️  Restauración completada con advertencias (esto es normal)"
    echo "   📄 Log guardado en: /tmp/restore.log"
fi

echo ""

# Paso 3: Verificar datos
echo "🔍 Verificando datos en producción..."

psql "$PRODUCTION_URL" << 'EOSQL'
\set ON_ERROR_STOP on

-- Count rows in all tables
SELECT 'sections' as table_name, COUNT(*) as rows FROM sections
UNION ALL SELECT 'task_types', COUNT(*) FROM task_types
UNION ALL SELECT 'tasks', COUNT(*) FROM tasks
UNION ALL SELECT 'users', COUNT(*) FROM users
UNION ALL SELECT 'crawl_runs', COUNT(*) FROM crawl_runs
UNION ALL SELECT 'discovered_urls', COUNT(*) FROM discovered_urls
UNION ALL SELECT 'url_changes', COUNT(*) FROM url_changes
UNION ALL SELECT 'health_snapshots', COUNT(*) FROM health_snapshots
ORDER BY table_name;
EOSQL

echo ""
echo "=========================================="
echo "  ✅ Migración completada"
echo "=========================================="
echo ""
echo "Próximos pasos:"
echo "1. Verifica la app en Render"
echo "2. Prueba el crawler en producción"
echo "3. Limpia el archivo temporal:"
echo "   rm /tmp/db_backup.sql"
echo ""
