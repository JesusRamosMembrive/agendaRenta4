#!/bin/bash
# Script para aplicar migraciones de Stage 2 en producción
# Uso: ./apply_stage2_migrations.sh "postgresql://user:pass@host/db"

if [ -z "$1" ]; then
    echo "❌ Error: DATABASE_URL requerida"
    echo ""
    echo "Uso: $0 <database_url>"
    echo ""
    echo "Ejemplo:"
    echo "  $0 \"postgresql://user:pass@host:port/dbname\""
    exit 1
fi

DATABASE_URL="$1"

echo "=========================================="
echo "  Aplicando migraciones Stage 2"
echo "=========================================="
echo ""
echo "Database: ${DATABASE_URL:0:50}..."
echo ""

# Función para ejecutar migración
apply_migration() {
    local file=$1
    local name=$(basename "$file")

    echo "📄 Aplicando: $name"

    if psql "$DATABASE_URL" -f "$file" > /tmp/migration.log 2>&1; then
        echo "   ✅ $name aplicada correctamente"
    else
        echo "   ❌ Error al aplicar $name"
        echo ""
        echo "   Log de error:"
        cat /tmp/migration.log | sed 's/^/      /'
        echo ""

        # Preguntar si continuar
        read -p "   ¿Continuar con siguiente migración? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo ""
            echo "❌ Proceso cancelado por el usuario"
            exit 1
        fi
    fi
    echo ""
}

# Verificar que psql está instalado
if ! command -v psql &> /dev/null; then
    echo "❌ psql no encontrado. Instálalo con:"
    echo "   sudo apt-get install postgresql-client"
    exit 1
fi

# Aplicar migraciones en orden
echo "Aplicando migraciones..."
echo ""

apply_migration "migrations/002_add_crawler_tables.sql"
apply_migration "migrations/003_add_priority_flag.sql"
apply_migration "migrations/004_add_health_snapshots.sql"

echo "=========================================="
echo "  ✅ Migraciones completadas"
echo "=========================================="
echo ""
echo "Próximos pasos:"
echo "1. Verificar que las tablas se crearon correctamente"
echo "2. La app en Render debería funcionar ahora"
echo "3. Ejecutar el crawler desde la UI en producción"
echo ""
