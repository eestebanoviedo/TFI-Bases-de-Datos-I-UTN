-- =============================================================================
-- TRABAJO FINAL INTEGRADOR - BASES DE DATOS I (UTN)
-- Script 03: Generación y Carga de Datos Masivos con SQL Puro (Etapa 2)
-- Genera 10.000 fichas bibliográficas y 10.000 libros (20.000 registros en total)
-- Garantiza relación 1:1, integridad referencial (0 huérfanos) y reproducibilidad.
-- =============================================================================

USE tpi_biblioteca;

-- Desactivar temporalmente autocommit para máxima velocidad de inserción en masa
SET autocommit = 0;

-- 1. Limpiar datos existentes respetando integridad referencial
DELETE FROM libro;
DELETE FROM ficha_bibliografica;
ALTER TABLE libro AUTO_INCREMENT = 1;
ALTER TABLE ficha_bibliografica AUTO_INCREMENT = 1;

-- -----------------------------------------------------------------------------
-- 2. POBLADO MASIVO DE: ficha_bibliografica (10.000 registros)
-- Utiliza producto cartesiano controlado de dígitos para generar la serie 1..10000
-- -----------------------------------------------------------------------------
INSERT INTO ficha_bibliografica (id, eliminado, isbn, clasificacion_dewey, estanteria, idioma)
SELECT 
    nums.n AS id,
    -- 2% de fichas marcadas como baja lógica
    (MOD(nums.n, 50) = 0) AS eliminado,
    -- Formato ISBN-13 sintético garantizado único: 978-XXXXXXXXX-C
    CONCAT('978-', LPAD(nums.n, 9, '0'), '-', MOD(nums.n, 10)) AS isbn,
    dewey.codigo AS clasificacion_dewey,
    CONCAT(dewey.estanteria_base, '-', LPAD((MOD(nums.n, 40) + 1), 2, '0')) AS estanteria,
    idioma.nombre AS idioma
FROM (
    SELECT a.d + b.d * 10 + c.d * 100 + d.d * 1000 + 1 AS n
    FROM (SELECT 0 AS d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a
    CROSS JOIN (SELECT 0 AS d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b
    CROSS JOIN (SELECT 0 AS d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) c
    CROSS JOIN (SELECT 0 AS d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) d
) nums
JOIN catalogo_dewey_semilla dewey 
    ON dewey.id = (MOD(nums.n, 11) + 1)
JOIN catalogo_idiomas_semilla idioma 
    ON idioma.id = (MOD(nums.n, 6) + 1);

COMMIT;

-- -----------------------------------------------------------------------------
-- 3. POBLADO MASIVO DE: libro (10.000 registros vinculados 1:1)
-- Cada libro se enlaza estrictamente con ficha_id = id (1 a 1 perfecto)
-- -----------------------------------------------------------------------------
INSERT INTO libro (id, eliminado, titulo, autor, editorial, anio_edicion, ficha_id)
SELECT 
    nums.n AS id,
    -- Marcado lógico alineado con su ficha para consistencia
    (MOD(nums.n, 50) = 0) AS eliminado,
    -- Generación de título combinatorio realista: Prefijo + Núcleo + Sufijo + Vol.
    CONCAT(
        tit_pref.prefijo, ' ', 
        tit_nuc.nucleo, ' ', 
        tit_suf.sufijo, 
        ' (Vol. ', (MOD(nums.n, 12) + 1), ')'
    ) AS titulo,
    autor.nombre AS autor,
    editorial.nombre AS editorial,
    -- Rango de años de publicación coherente (1900 - 2025)
    (1900 + MOD(nums.n * 7, 126)) AS anio_edicion,
    -- FK que garantiza relación 1:1 estricta
    nums.n AS ficha_id
FROM (
    SELECT a.d + b.d * 10 + c.d * 100 + d.d * 1000 + 1 AS n
    FROM (SELECT 0 AS d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a
    CROSS JOIN (SELECT 0 AS d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b
    CROSS JOIN (SELECT 0 AS d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) c
    CROSS JOIN (SELECT 0 AS d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) d
) nums
JOIN catalogo_autores_semilla autor 
    ON autor.id = (MOD(nums.n, 25) + 1)
JOIN catalogo_editoriales_semilla editorial 
    ON editorial.id = (MOD(nums.n, 15) + 1)
JOIN catalogo_titulos_semilla tit_pref 
    ON tit_pref.id = (MOD(nums.n, 10) + 1)
JOIN catalogo_titulos_semilla tit_nuc 
    ON tit_nuc.id = (MOD(nums.n * 3, 10) + 1)
JOIN catalogo_titulos_semilla tit_suf 
    ON tit_suf.id = (MOD(nums.n * 7, 10) + 1);

COMMIT;

SET autocommit = 1;
