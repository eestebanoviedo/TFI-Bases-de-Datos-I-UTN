-- =============================================================================
-- TRABAJO FINAL INTEGRADOR - BASES DE DATOS I (UTN)
-- Script Auxiliar: 01_pruebas_restricciones.sql (Etapa 1)
-- Demostración de restricciones de integridad (2 correctas, 2+ erróneas)
-- =============================================================================

USE tpi_biblioteca;

-- -----------------------------------------------------------------------------
-- PRUEBAS CORRECTAS
-- -----------------------------------------------------------------------------

-- Inserción Correcta 1: Ficha bibliográfica completa y libro asociado
INSERT INTO ficha_bibliografica (isbn, clasificacion_dewey, estanteria, idioma)
VALUES ('978-0141439518', '823.7', 'E-01', 'Inglés');

SET @id_ficha_1 = LAST_INSERT_ID();

INSERT INTO libro (titulo, autor, editorial, anio_edicion, ficha_id)
VALUES ('Orgullo y Prejuicio', 'Jane Austen', 'Penguin Classics', 1813, @id_ficha_1);

-- Inserción Correcta 2: Libro y ficha con campos opcionales nulos
INSERT INTO ficha_bibliografica (isbn, clasificacion_dewey, estanteria, idioma)
VALUES ('978-8420651354', '863.3', 'E-02', 'Español');

SET @id_ficha_2 = LAST_INSERT_ID();

INSERT INTO libro (titulo, autor, editorial, anio_edicion, ficha_id)
VALUES ('Don Quijote de la Mancha', 'Miguel de Cervantes', 'Alianza', 1605, @id_ficha_2);


-- -----------------------------------------------------------------------------
-- PRUEBAS ERRÓNEAS INTENCIONALES (Ejecutar individualmente para verificar error)
-- -----------------------------------------------------------------------------

-- Inserción Errónea 1: Violación de CHECK constraint (chk_libro_anio_valido)
-- Mensaje esperado: Error Code 3819: Check constraint 'chk_libro_anio_valido' is violated.
-- INSERT INTO libro (titulo, autor, editorial, anio_edicion, ficha_id)
-- VALUES ('Libro del Futuro', 'Autor Ficticio', 'Editorial X', 2999, NULL);

-- Inserción Errónea 2: Violación de UNIQUE constraint (uq_ficha_isbn)
-- Mensaje esperado: Error Code 1062: Duplicate entry '978-0141439518' for key 'ficha_bibliografica.uq_ficha_isbn'.
-- INSERT INTO ficha_bibliografica (isbn, clasificacion_dewey, estanteria, idioma)
-- VALUES ('978-0141439518', '800.0', 'E-99', 'Español');

-- Inserción Errónea 3: Violación de UNIQUE constraint en relación 1:1 (uq_libro_ficha_id)
-- Mensaje esperado: Error Code 1062: Duplicate entry for key 'libro.uq_libro_ficha_id'.
-- INSERT INTO libro (titulo, autor, editorial, anio_edicion, ficha_id)
-- VALUES ('Otro Libro Intentando Usar Misma Ficha', 'Autor Y', 'Editorial Y', 2020, @id_ficha_1);

-- Inserción Errónea 4: Violación de FOREIGN KEY constraint (fk_libro_ficha)
-- Mensaje esperado: Error Code 1452: Cannot add or update a child row: a foreign key constraint fails.
-- INSERT INTO libro (titulo, autor, editorial, anio_edicion, ficha_id)
-- VALUES ('Libro con Ficha Fantasma', 'Autor Fantasma', 'Editorial Z', 2021, 999999);
