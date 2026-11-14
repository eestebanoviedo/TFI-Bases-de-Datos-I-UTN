-- =============================================================================
-- TRABAJO FINAL INTEGRADOR - BASES DE DATOS I (UTN)
-- Script 05: Análisis de Planes de Ejecución y Benchmarking (Etapa 3)
-- Archivo: 05_explain.sql
-- Comparativa de rendimiento CON y SIN índices en 3 consultas representativas:
--   1. Consulta por Igualdad (WHERE autor = ?)
--   2. Consulta por Rango (WHERE anio_edicion BETWEEN ? AND ?)
--   3. Consulta con JOIN (libro.ficha_id = ficha_bibliografica.id con filtro temático)
-- =============================================================================

USE tpi_biblioteca;

-- =============================================================================
-- CASO 1: Consulta por Igualdad (Filtro exacto sobre autor)
-- =============================================================================

-- 1.A) Plan de ejecución CON ÍNDICE (idx_libro_autor)
-- Usa FORCE INDEX para garantizar el uso del índice secundario
EXPLAIN 
SELECT id, titulo, autor, editorial, anio_edicion 
FROM libro FORCE INDEX (idx_libro_autor) 
WHERE autor = 'Jorge Luis Borges';

EXPLAIN ANALYZE 
SELECT id, titulo, autor, editorial, anio_edicion 
FROM libro FORCE INDEX (idx_libro_autor) 
WHERE autor = 'Jorge Luis Borges';

-- 1.B) Plan de ejecución SIN ÍNDICE (Forzando Table Scan con IGNORE INDEX)
EXPLAIN 
SELECT id, titulo, autor, editorial, anio_edicion 
FROM libro IGNORE INDEX (idx_libro_autor) 
WHERE autor = 'Jorge Luis Borges';

EXPLAIN ANALYZE 
SELECT id, titulo, autor, editorial, anio_edicion 
FROM libro IGNORE INDEX (idx_libro_autor) 
WHERE autor = 'Jorge Luis Borges';


-- =============================================================================
-- CASO 2: Consulta por Rango (Filtro BETWEEN sobre anio_edicion)
-- =============================================================================

-- 2.A) Plan de ejecución CON ÍNDICE (idx_libro_anio)
EXPLAIN 
SELECT id, titulo, autor, anio_edicion 
FROM libro FORCE INDEX (idx_libro_anio) 
WHERE anio_edicion BETWEEN 1970 AND 1980;

EXPLAIN ANALYZE 
SELECT id, titulo, autor, anio_edicion 
FROM libro FORCE INDEX (idx_libro_anio) 
WHERE anio_edicion BETWEEN 1970 AND 1980;

-- 2.B) Plan de ejecución SIN ÍNDICE (Forzando Table Scan)
EXPLAIN 
SELECT id, titulo, autor, anio_edicion 
FROM libro IGNORE INDEX (idx_libro_anio) 
WHERE anio_edicion BETWEEN 1970 AND 1980;

EXPLAIN ANALYZE 
SELECT id, titulo, autor, anio_edicion 
FROM libro IGNORE INDEX (idx_libro_anio) 
WHERE anio_edicion BETWEEN 1970 AND 1980;


-- =============================================================================
-- CASO 3: Consulta con JOIN Multi-tabla y Filtro Temático
-- =============================================================================

-- 3.A) Plan de ejecución CON ÍNDICE en tabla asociada (idx_ficha_dewey)
EXPLAIN 
SELECT l.id, l.titulo, l.autor, f.isbn, f.clasificacion_dewey, f.estanteria
FROM libro l
INNER JOIN ficha_bibliografica f FORCE INDEX (idx_ficha_dewey) 
    ON l.ficha_id = f.id
WHERE f.clasificacion_dewey = '823.9';

EXPLAIN ANALYZE 
SELECT l.id, l.titulo, l.autor, f.isbn, f.clasificacion_dewey, f.estanteria
FROM libro l
INNER JOIN ficha_bibliografica f FORCE INDEX (idx_ficha_dewey) 
    ON l.ficha_id = f.id
WHERE f.clasificacion_dewey = '823.9';

-- 3.B) Plan de ejecución SIN ÍNDICE (Forzando Full Scan en tabla ficha_bibliografica)
EXPLAIN 
SELECT l.id, l.titulo, l.autor, f.isbn, f.clasificacion_dewey, f.estanteria
FROM libro l
INNER JOIN ficha_bibliografica f IGNORE INDEX (idx_ficha_dewey) 
    ON l.ficha_id = f.id
WHERE f.clasificacion_dewey = '823.9';

EXPLAIN ANALYZE 
SELECT l.id, l.titulo, l.autor, f.isbn, f.clasificacion_dewey, f.estanteria
FROM libro l
INNER JOIN ficha_bibliografica f IGNORE INDEX (idx_ficha_dewey) 
    ON l.ficha_id = f.id
WHERE f.clasificacion_dewey = '823.9';
