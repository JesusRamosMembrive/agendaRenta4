-- ============================================================================
-- CORRECCIÓN DE ERRORES TIPOGRÁFICOS EN TABLA sections
-- Generado: 2025-10-30
-- ============================================================================
--
-- Este script corrige 39 errores tipográficos detectados en las URLs
-- de la tabla sections comparando con las URLs descubiertas por el crawler.
--
-- Ejecutar: psql $DATABASE_URL -f fix_typos.sql
-- ============================================================================

BEGIN;

-- Backup antes de modificar (crear tabla de respaldo)
CREATE TABLE IF NOT EXISTS sections_backup_20251030 AS
SELECT * FROM sections WHERE active = TRUE;

SELECT 'Backup creado: sections_backup_20251030' AS mensaje;

-- ============================================================================
-- CATEGORÍA 1: Trailing slash faltante/sobrante
-- ============================================================================

-- Planes De Pensiones - Tipos Planes De Pensiones (quitar slash final)
UPDATE sections SET url = 'https://www.r4.com/planes-de-pensiones/tipos-planes-de-pensiones'
WHERE url = 'https://www.r4.com/planes-de-pensiones/tipos-planes-de-pensiones/';

-- ============================================================================
-- CATEGORÍA 2: Letras faltantes al inicio de palabras
-- ============================================================================

-- Quieres Mas - Nversion Para Todos (falta 'i')
UPDATE sections SET url = 'https://www.r4.com/que-necesitas/quieres-mas/inversion-para-todos'
WHERE url = 'https://www.r4.com/que-necesitas/quieres-mas/nversion-para-todos';

-- Soluciones Easy - Ursos Finanzas Gratis (falta 'c')
UPDATE sections SET url = 'https://www.r4.com/soluciones-easy/cursos-finanzas-gratis'
WHERE url = 'https://www.r4.com/soluciones-easy/ursos-finanzas-gratis';

-- Soluciones Easy - Escarga Gratis Guia Que Son Etfs (falta 'd')
UPDATE sections SET url = 'https://www.r4.com/serviciosr4/descarga-gratis-guia-que-son-etfs'
WHERE url = 'https://www.r4.com/soluciones-easy/escarga-gratis-guia-que-son-etfs';

-- Soluciones Easy - Oletin Warrants (falta 'b')
UPDATE sections SET url = 'https://www.r4.com/soluciones-easy/boletin-warrants'
WHERE url = 'https://www.r4.com/soluciones-easy/oletin-warrants';

-- Soluciones Easy - Oletin Analisis Tecnico (falta 'b')
UPDATE sections SET url = 'https://www.r4.com/soluciones-easy/boletin-analisis-tecnico'
WHERE url = 'https://www.r4.com/soluciones-easy/oletin-analisis-tecnico';

-- Soluciones Easy - Roker Online Compra Acciones (falta 'b')
UPDATE sections SET url = 'https://www.r4.com/soluciones-easy/broker-online-compra-acciones'
WHERE url = 'https://www.r4.com/soluciones-easy/roker-online-compra-acciones';

-- Soluciones Easy - Roker Online Las Mejores Tarifas (falta 'b')
UPDATE sections SET url = 'https://www.r4.com/soluciones-easy/broker-online-las-mejores-tarifas'
WHERE url = 'https://www.r4.com/soluciones-easy/roker-online-las-mejores-tarifas';

-- Quieres Mas - Specialista Todos (falta 'e')
UPDATE sections SET url = 'https://www.r4.com/que-necesitas/quieres-mas/especialista-todos'
WHERE url = 'https://www.r4.com/que-necesitas/quieres-mas/specialista-todos';

-- Quieres Mas - Entable Sostenible (falta 'r')
UPDATE sections SET url = 'https://www.r4.com/que-necesitas/quieres-mas/rentable-sostenible'
WHERE url = 'https://www.r4.com/que-necesitas/quieres-mas/entable-sostenible';

-- Erviciosr4 (falta 's' al inicio)
UPDATE sections SET url = 'https://www.r4.com/serviciosr4'
WHERE url = 'https://www.r4.com/erviciosr4';

-- Erviciosr4 - Carteras Easy (falta 's' al inicio)
UPDATE sections SET url = 'https://www.r4.com/serviciosr4/carteras-easy'
WHERE url = 'https://www.r4.com/erviciosr4/carteras-easy';

-- Erviciosr4 - S50 (falta 's' al inicio)
UPDATE sections SET url = 'https://www.r4.com/serviciosr4/s50'
WHERE url = 'https://www.r4.com/erviciosr4/s50';

-- ============================================================================
-- CATEGORÍA 3: URLs con problema http/https
-- ============================================================================

-- R4 - HOME
UPDATE sections SET url = 'http://www.r4.com'
WHERE url = 'https://www.r4.com/';

-- Broker Online
UPDATE sections SET url = 'http://www.r4.com/broker-online'
WHERE url = 'https://www.r4.com/broker-online';

-- Productos De Inversion - Bolsa
UPDATE sections SET url = 'http://www.r4.com/broker-online/productos-de-inversion/bolsa'
WHERE url = 'https://www.r4.com/broker-online/productos-de-inversion/bolsa';

-- Productos De Inversion - Etfs
UPDATE sections SET url = 'http://www.r4.com/broker-online/productos-de-inversion/etfs'
WHERE url = 'https://www.r4.com/broker-online/productos-de-inversion/etfs';

-- Carteras Gestionadas
UPDATE sections SET url = 'http://www.r4.com/carteras-gestionadas'
WHERE url = 'https://www.r4.com/carteras-gestionadas';

-- Carteras Gestionadas - Carteras De Fondos
UPDATE sections SET url = 'http://www.r4.com/carteras-gestionadas/carteras-de-fondos'
WHERE url = 'https://www.r4.com/carteras-gestionadas/carteras-de-fondos';

-- Carteras Gestionadas - Gestion Personalizada
UPDATE sections SET url = 'http://www.r4.com/carteras-gestionadas/gestion-personalizada'
WHERE url = 'https://www.r4.com/carteras-gestionadas/gestion-personalizada';

-- Fondos De Inversion - Seleccion50
UPDATE sections SET url = 'http://www.r4.com/fondos-de-inversion/seleccion50'
WHERE url = 'https://www.r4.com/fondos-de-inversion/seleccion50';

-- Planes De Pensiones
UPDATE sections SET url = 'http://r4.com/planes-de-pensiones'
WHERE url = 'https://www.r4.com/planes-de-pensiones';

-- Planes De Pensiones - Plan De Pensiones Autonomos
UPDATE sections SET url = 'http://r4.com/planes-de-pensiones/plan-de-pensiones-autonomos'
WHERE url = 'https://www.r4.com/planes-de-pensiones/plan-de-pensiones-autonomos';

-- ============================================================================
-- CATEGORÍA 4: URLs simplificadas/acortadas
-- ============================================================================

-- Soluciones Easy - ... (URL incompleta)
UPDATE sections SET url = 'https://www.r4.com/soluciones-easy'
WHERE url = 'https://www.r4.com/soluciones-easy/...';

-- Fondos Planes (falta /go/)
UPDATE sections SET url = 'https://www.r4.com/go/fondos-planes'
WHERE url = 'https://www.r4.com/fondos-planes';

-- Clientes -> Hazte Cliente
UPDATE sections SET url = 'https://www.r4.com/hazte-cliente'
WHERE url = 'https://www.r4.com/clientes';

-- ============================================================================
-- CATEGORÍA 5: URLs con parámetros adicionales
-- ============================================================================

-- Academiar4 - Formulario Cursos (falta query param)
UPDATE sections SET url = 'https://www.r4.com/academiar4/formulario-cursos?id=4369'
WHERE url = 'https://www.r4.com/academiar4/formulario-cursos';

-- Autor (URL extraña con espacio)
UPDATE sections SET url = 'https://www.r4.com/autor/%20'
WHERE url = 'https://www.r4.com/autor';

-- ============================================================================
-- CATEGORÍA 6: Cambios de ruta significativos
-- ============================================================================

-- Bolsa - Cursos Bolsa (cambio de nombre de página)
UPDATE sections SET url = 'https://www.r4.com/broker-online/productos-de-inversion/bolsa/que-es-la-bolsa'
WHERE url = 'https://www.r4.com/broker-online/productos-de-inversion/bolsa/cursos-bolsa';

-- Futuros - Garantias Futuros
UPDATE sections SET url = 'https://www.r4.com/broker-online/productos-de-inversion/futuros/que-son-futuros'
WHERE url = 'https://www.r4.com/broker-online/productos-de-inversion/futuros/garantias-futuros';

-- Planes De Pensiones - Categorias
UPDATE sections SET url = 'https://www.r4.com/planes-de-pensiones/planes/EP1'
WHERE url = 'https://www.r4.com/planes-de-pensiones/categorias';

-- ============================================================================
-- CATEGORÍA 7: URLs que ya no existen - MARCAR COMO INACTIVAS
-- ============================================================================

-- Estas URLs probablemente eran campañas temporales o fueron eliminadas
-- Las marcamos como inactivas en lugar de cambiar la URL

UPDATE sections SET active = FALSE
WHERE url IN (
    'https://www.r4.com/soluciones-easy/cbermonday',
    'https://www.r4.com/soluciones-easy/broker-online-para-invertir-cob-ventaja',
    'https://www.r4.com/errores/error-404',
    'https://www.r4.com/conferencias',
    'https://www.r4.com/columnas-de-autores/el-blog-de-jsq',
    'https://www.r4.com/inversiones-alternativas',
    'https://www.r4.com/que-necesitas/soluciones-digitales',
    'https://www.r4.com/que-necesitas/quieres-mas',
    'https://www.r4.com/que-necesitas/quieres-mas/cercano-digital',
    'https://www.r4.com/que-necesitas/quieres-mas/mas-digital',
    'https://www.r4.com/normativa/dnie'
);

-- ============================================================================
-- URLs de categorías de fondos - parecen redireccionar al listado principal
-- Marcar como inactivas si no se encuentran páginas individuales
-- ============================================================================

UPDATE sections SET active = FALSE
WHERE url IN (
    'https://www.r4.com/fondos-de-inversion/categorias/fondos-de-inversion-criptomonedas',
    'https://www.r4.com/fondos-de-inversion/categorias/fondos-de-inversion-mixtos',
    'https://www.r4.com/fondos-de-inversion/categorias/fondos-de-inversion-monetarios',
    'https://www.r4.com/fondos-de-inversion/categorias/fondos-de-inversion-renta-fija',
    'https://www.r4.com/fondos-de-inversion/categorias/fondos-de-inversion-renta-variable',
    'https://www.r4.com/fondos-de-inversion/categorias/fondos-de-inversion-retorno-absoluto',
    'https://www.r4.com/fondos-de-inversion/categorias/fondos-de-inversion-tematicos',
    'https://www.r4.com/fondos-de-inversion/categorias/fondos-perfilados'
);

-- URLs de carteras individuales - parecen no existir como páginas separadas
UPDATE sections SET active = FALSE
WHERE url IN (
    'https://www.r4.com/carteras-gestionadas/carteras-acciones',
    'https://www.r4.com/carteras-gestionadas/carteras-acciones/5-grandes',
    'https://www.r4.com/carteras-gestionadas/carteras-acciones/cardiv',
    'https://www.r4.com/carteras-gestionadas/carteras-acciones/versatil',
    'https://www.r4.com/carteras-gestionadas/carteras-de-fondos/conservadora',
    'https://www.r4.com/carteras-gestionadas/carteras-de-fondos/dinamica',
    'https://www.r4.com/carteras-gestionadas/carteras-de-fondos/moderada',
    'https://www.r4.com/carteras-gestionadas/carteras-de-fondos/rendimiento',
    'https://www.r4.com/carteras-gestionadas/carteras-de-fondos/tolerante'
);

-- URLs de productos que no existen como páginas individuales
UPDATE sections SET active = FALSE
WHERE url IN (
    'https://www.r4.com/broker-online/productos-de-inversion/cfds',
    'https://www.r4.com/broker-online/productos-de-inversion/cripto',
    'https://www.r4.com/broker-online/productos-de-inversion/derivados',
    'https://www.r4.com/broker-online/productos-de-inversion/warrants',
    'https://www.r4.com/fondos-de-inversion/sicav'
);

-- ============================================================================
-- RESUMEN DE CAMBIOS
-- ============================================================================

SELECT 'RESUMEN DE CORRECCIONES:' AS mensaje;

SELECT
    COUNT(*) FILTER (WHERE active = TRUE) as urls_activas,
    COUNT(*) FILTER (WHERE active = FALSE) as urls_desactivadas,
    COUNT(*) as total
FROM sections;

SELECT 'URLs corregidas y ahora encontradas:' AS mensaje;

SELECT COUNT(*) as urls_corregidas_encontradas
FROM sections s
WHERE s.active = TRUE
  AND s.url IN (
    SELECT url FROM discovered_urls WHERE crawl_run_id = 2
  );

SELECT 'URLs aún faltantes después de correcciones:' AS mensaje;

SELECT COUNT(*) as urls_aun_faltantes
FROM sections s
WHERE s.active = TRUE
  AND s.url NOT IN (
    SELECT url FROM discovered_urls WHERE crawl_run_id = 2
  );

-- ============================================================================
-- COMMIT O ROLLBACK
-- ============================================================================

-- Si todo se ve bien, descomentar COMMIT:
-- COMMIT;

-- Para revisar sin aplicar cambios, descomentar ROLLBACK:
ROLLBACK;

SELECT 'Script ejecutado en modo ROLLBACK (no se aplicaron cambios)' AS mensaje;
SELECT 'Para aplicar cambios: editar script y descomentar COMMIT' AS mensaje;
