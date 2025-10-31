-- ============================================================================
-- CORRECCIÓN DE ERRORES TIPOGRÁFICOS EN TABLA sections (FINAL)
-- Generado: 2025-10-30
-- ============================================================================
--
-- Estrategia FINAL:
-- - NO eliminar registros (tienen foreign keys a tasks)
-- - Desactivar URLs incorrectas/obsoletas
-- - Actualizar URLs con typos corregibles
--
-- ============================================================================

BEGIN;

-- Backup antes de modificar
CREATE TABLE IF NOT EXISTS sections_backup_20251030 AS
SELECT * FROM sections;

SELECT 'Backup creado: sections_backup_20251030 con ' || COUNT(*) || ' registros' as mensaje
FROM sections_backup_20251030;

-- ============================================================================
-- PASO 1: ACTUALIZAR URLs con errores tipográficos corregibles
-- ============================================================================

-- Trailing slash
UPDATE sections SET url = 'https://www.r4.com/planes-de-pensiones/tipos-planes-de-pensiones'
WHERE url = 'https://www.r4.com/planes-de-pensiones/tipos-planes-de-pensiones/';

-- Letras faltantes al inicio
UPDATE sections SET url = 'https://www.r4.com/que-necesitas/quieres-mas/inversion-para-todos'
WHERE url = 'https://www.r4.com/que-necesitas/quieres-mas/nversion-para-todos';

UPDATE sections SET url = 'https://www.r4.com/soluciones-easy/cursos-finanzas-gratis'
WHERE url = 'https://www.r4.com/soluciones-easy/ursos-finanzas-gratis';

UPDATE sections SET url = 'https://www.r4.com/serviciosr4/descarga-gratis-guia-que-son-etfs'
WHERE url = 'https://www.r4.com/soluciones-easy/escarga-gratis-guia-que-son-etfs';

UPDATE sections SET url = 'https://www.r4.com/soluciones-easy/boletin-warrants'
WHERE url = 'https://www.r4.com/soluciones-easy/oletin-warrants';

UPDATE sections SET url = 'https://www.r4.com/soluciones-easy/boletin-analisis-tecnico'
WHERE url = 'https://www.r4.com/soluciones-easy/oletin-analisis-tecnico';

UPDATE sections SET url = 'https://www.r4.com/soluciones-easy/broker-online-compra-acciones'
WHERE url = 'https://www.r4.com/soluciones-easy/roker-online-compra-acciones';

UPDATE sections SET url = 'https://www.r4.com/soluciones-easy/broker-online-las-mejores-tarifas'
WHERE url = 'https://www.r4.com/soluciones-easy/roker-online-las-mejores-tarifas';

UPDATE sections SET url = 'https://www.r4.com/que-necesitas/quieres-mas/especialista-todos'
WHERE url = 'https://www.r4.com/que-necesitas/quieres-mas/specialista-todos';

UPDATE sections SET url = 'https://www.r4.com/que-necesitas/quieres-mas/rentable-sostenible'
WHERE url = 'https://www.r4.com/que-necesitas/quieres-mas/entable-sostenible';

UPDATE sections SET url = 'https://www.r4.com/serviciosr4/carteras-easy'
WHERE url = 'https://www.r4.com/erviciosr4/carteras-easy';

UPDATE sections SET url = 'https://www.r4.com/serviciosr4/s50'
WHERE url = 'https://www.r4.com/erviciosr4/s50';

-- ============================================================================
-- PASO 2: DESACTIVAR URLs incorrectas que tienen un duplicado correcto
-- ============================================================================

-- Erviciosr4 (existe el correcto: serviciosr4)
UPDATE sections SET active = FALSE, name = name || ' [DUPLICADO-TYPO]'
WHERE url = 'https://www.r4.com/erviciosr4' AND active = TRUE;

-- ============================================================================
-- PASO 3: DESACTIVAR URLs obsoletas o que ya no existen
-- ============================================================================

-- URLs temporales/campañas ya terminadas
UPDATE sections SET active = FALSE, name = name || ' [OBSOLETA]'
WHERE url IN (
    'https://www.r4.com/soluciones-easy/cbermonday',
    'https://www.r4.com/soluciones-easy/broker-online-para-invertir-cob-ventaja',
    'https://www.r4.com/soluciones-easy/...',
    'https://www.r4.com/errores/error-404',
    'https://www.r4.com/conferencias',
    'https://www.r4.com/columnas-de-autores/el-blog-de-jsq',
    'https://www.r4.com/inversiones-alternativas',
    'https://www.r4.com/que-necesitas/soluciones-digitales',
    'https://www.r4.com/que-necesitas/quieres-mas',
    'https://www.r4.com/que-necesitas/quieres-mas/cercano-digital',
    'https://www.r4.com/que-necesitas/quieres-mas/mas-digital',
    'https://www.r4.com/normativa/dnie',
    'https://www.r4.com/clientes'
) AND active = TRUE;

-- URLs de categorías de fondos que no existen como páginas individuales
UPDATE sections SET active = FALSE, name = name || ' [NO EXISTE]'
WHERE url IN (
    'https://www.r4.com/fondos-de-inversion/categorias/fondos-de-inversion-criptomonedas',
    'https://www.r4.com/fondos-de-inversion/categorias/fondos-de-inversion-mixtos',
    'https://www.r4.com/fondos-de-inversion/categorias/fondos-de-inversion-monetarios',
    'https://www.r4.com/fondos-de-inversion/categorias/fondos-de-inversion-renta-fija',
    'https://www.r4.com/fondos-de-inversion/categorias/fondos-de-inversion-renta-variable',
    'https://www.r4.com/fondos-de-inversion/categorias/fondos-de-inversion-retorno-absoluto',
    'https://www.r4.com/fondos-de-inversion/categorias/fondos-de-inversion-tematicos',
    'https://www.r4.com/fondos-de-inversion/categorias/fondos-perfilados',
    'https://www.r4.com/planes-de-pensiones/categorias'
) AND active = TRUE;

-- URLs de carteras que ya no existen como páginas separadas
UPDATE sections SET active = FALSE, name = name || ' [NO EXISTE]'
WHERE url IN (
    'https://www.r4.com/carteras-gestionadas',
    'https://www.r4.com/carteras-gestionadas/carteras-acciones',
    'https://www.r4.com/carteras-gestionadas/carteras-acciones/5-grandes',
    'https://www.r4.com/carteras-gestionadas/carteras-acciones/cardiv',
    'https://www.r4.com/carteras-gestionadas/carteras-acciones/versatil',
    'https://www.r4.com/carteras-gestionadas/carteras-de-fondos/conservadora',
    'https://www.r4.com/carteras-gestionadas/carteras-de-fondos/dinamica',
    'https://www.r4.com/carteras-gestionadas/carteras-de-fondos/moderada',
    'https://www.r4.com/carteras-gestionadas/carteras-de-fondos/rendimiento',
    'https://www.r4.com/carteras-gestionadas/carteras-de-fondos/tolerante'
) AND active = TRUE;

-- URLs de productos que no existen
UPDATE sections SET active = FALSE, name = name || ' [NO EXISTE]'
WHERE url IN (
    'https://www.r4.com/broker-online',
    'https://www.r4.com/broker-online/productos-de-inversion/bolsa',
    'https://www.r4.com/broker-online/productos-de-inversion/bolsa/cursos-bolsa',
    'https://www.r4.com/broker-online/productos-de-inversion/cfds',
    'https://www.r4.com/broker-online/productos-de-inversion/cripto',
    'https://www.r4.com/broker-online/productos-de-inversion/derivados',
    'https://www.r4.com/broker-online/productos-de-inversion/etfs',
    'https://www.r4.com/broker-online/productos-de-inversion/futuros/garantias-futuros',
    'https://www.r4.com/broker-online/productos-de-inversion/warrants',
    'https://www.r4.com/fondos-de-inversion/sicav',
    'https://www.r4.com/fondos-de-inversion/seleccion50',
    'https://www.r4.com/fondos-planes',
    'https://www.r4.com/carteras-gestionadas/carteras-de-fondos',
    'https://www.r4.com/carteras-gestionadas/gestion-personalizada',
    'https://www.r4.com/planes-de-pensiones',
    'https://www.r4.com/planes-de-pensiones/plan-de-pensiones-autonomos',
    'https://www.r4.com/',
    'https://www.r4.com/autor',
    'https://www.r4.com/academiar4/formulario-cursos'
) AND active = TRUE;

-- ============================================================================
-- RESUMEN DE CAMBIOS
-- ============================================================================

SELECT '========== RESUMEN DE CAMBIOS ==========' AS titulo;

SELECT
    COUNT(*) FILTER (WHERE active = TRUE) as urls_activas,
    COUNT(*) FILTER (WHERE active = FALSE) as urls_desactivadas,
    COUNT(*) as total
FROM sections;

SELECT '========== VERIFICACIÓN ==========' AS titulo;

SELECT 'URLs activas ahora encontradas por crawler:' AS mensaje,
       COUNT(*) as cantidad
FROM sections s
WHERE s.active = TRUE
  AND s.url IN (SELECT url FROM discovered_urls WHERE crawl_run_id = 2);

SELECT 'URLs activas aún faltantes:' AS mensaje,
       COUNT(*) as cantidad
FROM sections s
WHERE s.active = TRUE
  AND s.url NOT IN (SELECT url FROM discovered_urls WHERE crawl_run_id = 2);

-- ============================================================================
-- COMMIT O ROLLBACK
-- ============================================================================

-- Aplicar cambios:
-- ROLLBACK;  -- NO aplicar cambios (preview)
COMMIT;  -- SÍ aplicar cambios

SELECT '✅ Cambios aplicados correctamente' AS resultado;
SELECT 'Backup guardado en: sections_backup_20251030' AS backup_info;
