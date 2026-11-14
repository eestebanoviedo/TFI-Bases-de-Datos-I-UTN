-- =============================================================================
-- TRABAJO FINAL INTEGRADOR - BASES DE DATOS I (UTN)
-- Script Auxiliar: 03_verificaciones_consistencia.sql (Etapa 2)
-- Cuadro de verificación de integridad y volumen de datos poblados
-- =============================================================================

USE tpi_biblioteca;

-- -----------------------------------------------------------------------------
-- 1. Conteo total de filas por tabla (Volumen global >= 10.000)
-- -----------------------------------------------------------------------------
SELECT 'Conteo Total' AS verificacion, 
       (SELECT COUNT(*) FROM ficha_bibliografica) AS total_fichas,
       (SELECT COUNT(*) FROM libro) AS total_libros,
       ((SELECT COUNT(*) FROM ficha_bibliografica) + (SELECT COUNT(*) FROM libro)) AS total_acumulado;

-- -----------------------------------------------------------------------------
-- 2. Detección de claves foráneas huérfanas (Debe dar 0)
-- -----------------------------------------------------------------------------
SELECT 'FK Huerfanas' AS verificacion,
       COUNT(*) AS total_huerfanos
FROM libro l
LEFT JOIN ficha_bibliografica f ON l.ficha_id = f.id
WHERE l.ficha_id IS NOT NULL AND f.id IS NULL;

-- -----------------------------------------------------------------------------
-- 3. Verificación de Cardinalidad 1:1 estricta (Debe dar 0 fichas duplicadas)
-- -----------------------------------------------------------------------------
SELECT 'Duplicados en Relacion 1:1' AS verificacion,
       COUNT(*) AS fichas_con_mas_de_un_libro
FROM (
    SELECT ficha_id, COUNT(*) AS cnt
    FROM libro
    WHERE ficha_id IS NOT NULL
    GROUP BY ficha_id
    HAVING COUNT(*) > 1
) sub;

-- -----------------------------------------------------------------------------
-- 4. Verificación de Rango de Dominio (Años de edición entre 868 y 2026)
-- -----------------------------------------------------------------------------
SELECT 'Rango de Anios' AS verificacion,
       MIN(anio_edicion) AS anio_minimo,
       MAX(anio_edicion) AS anio_maximo,
       SUM(CASE WHEN anio_edicion < 868 OR anio_edicion > 2026 THEN 1 ELSE 0 END) AS anios_invalidos
FROM libro;

-- -----------------------------------------------------------------------------
-- 5. Distribución por Estado Lógico (eliminado)
-- -----------------------------------------------------------------------------
SELECT 'Distribucion Eliminados' AS verificacion,
       SUM(CASE WHEN eliminado = 0 THEN 1 ELSE 0 END) AS activos,
       SUM(CASE WHEN eliminado = 1 THEN 1 ELSE 0 END) AS baja_logica,
       ROUND(AVG(eliminado) * 100, 2) AS porcentaje_baja
FROM libro;
