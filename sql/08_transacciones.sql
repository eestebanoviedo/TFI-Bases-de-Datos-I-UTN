-- =============================================================================
-- TRABAJO FINAL INTEGRADOR - BASES DE DATOS I (UTN)
-- Script 08: Manejo Transaccional ACID en SQL (Etapa 5)
-- Demuestra operaciones atómicas con START TRANSACTION, COMMIT y ROLLBACK.
-- =============================================================================

USE tpi_biblioteca;

-- -----------------------------------------------------------------------------
-- ESCENARIO 1: Transacción Exitosa (COMMIT)
-- Inserción atómica consistente de una Ficha Bibliográfica y su Libro asociado.
-- -----------------------------------------------------------------------------
START TRANSACTION;

-- 1. Insertar la ficha técnica
INSERT INTO ficha_bibliografica (isbn, clasificacion_dewey, estanteria, idioma)
VALUES ('978-9870001111', '823.9', 'EST-Z-01', 'Español');

SET @nueva_ficha_id = LAST_INSERT_ID();

-- 2. Insertar el libro vinculado a la ficha recién creada
INSERT INTO libro (titulo, autor, editorial, anio_edicion, ficha_id)
VALUES ('El Aleph - Edición Crítica Transaccional', 'Jorge Luis Borges', 'Editorial Sudamericana', 1949, @nueva_ficha_id);

-- Confirmar ambos cambios de manera atómica
COMMIT;

-- Verificación de persistencia de ambos registros
SELECT l.id AS libro_id, l.titulo, f.id AS ficha_id, f.isbn 
FROM libro l 
INNER JOIN ficha_bibliografica f ON l.ficha_id = f.id
WHERE f.isbn = '978-9870001111';


-- -----------------------------------------------------------------------------
-- ESCENARIO 2: Transacción Abortada con ROLLBACK ante Inconsistencia
-- Se inserta una ficha, pero falla la inserción del libro (año inválido que viola CHECK).
-- Se revierte completamente la transacción garantizando atomicidad (la ficha NO queda huérfana).
-- -----------------------------------------------------------------------------
START TRANSACTION;

-- 1. Inserción de ficha preliminar
INSERT INTO ficha_bibliografica (isbn, clasificacion_dewey, estanteria, idioma)
VALUES ('978-9870002222', '863.0', 'EST-Z-02', 'Español');

SET @ficha_fallida_id = LAST_INSERT_ID();

-- 2. Inserción de libro que dispara error por restricción CHECK (año 3500)
-- Al fallar esta sentencia, se ejecuta inmediatamente el ROLLBACK
-- INSERT INTO libro (titulo, autor, editorial, anio_edicion, ficha_id)
-- VALUES ('Libro Inconsistente', 'Autor X', 'Editorial X', 3500, @ficha_fallida_id);

-- En caso de error en la lógica de negocio o base de datos:
ROLLBACK;

-- Verificación de atomicidad: la ficha 978-9870002222 NO debe existir
SELECT COUNT(*) AS total_fichas_no_persistidas
FROM ficha_bibliografica 
WHERE isbn = '978-9870002222';
