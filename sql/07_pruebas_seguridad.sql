-- =============================================================================
-- TRABAJO FINAL INTEGRADOR - BASES DE DATOS I (UTN)
-- Script Auxiliar: 07_pruebas_seguridad.sql (Etapa 4)
-- Demostración práctica de permisos permitidos y denegados con usr_biblioteca_app
-- =============================================================================

USE tpi_biblioteca;

-- -----------------------------------------------------------------------------
-- OPERACIÓN PERMITIDA 1: Consulta sobre la vista pública
-- -----------------------------------------------------------------------------
SELECT titulo, autor, editorial, anio_edicion, isbn 
FROM vista_catalogo_publico 
LIMIT 5;

-- -----------------------------------------------------------------------------
-- OPERACIÓN PERMITIDA 2: Actualización de datos permitidos
-- -----------------------------------------------------------------------------
UPDATE libro 
SET editorial = 'Editorial Sudamericana' 
WHERE id = 1;


-- -----------------------------------------------------------------------------
-- OPERACIONES DENEGADAS INTENCIONALES (Disparan Error 1142)
-- -----------------------------------------------------------------------------

-- Intento Denegado 1: Intento de borrado físico directo
-- Mensaje esperado: ERROR 1142 (42000): DELETE command denied to user 'usr_biblioteca_app'@'localhost' for table 'libro'
-- DELETE FROM libro WHERE id = 1;

-- Intento Denegado 2: Intento de destrucción de estructura (DROP TABLE)
-- Mensaje esperado: ERROR 1142 (42000): DROP command denied to user 'usr_biblioteca_app'@'localhost' for table 'libro'
-- DROP TABLE libro;

-- Intento Denegado 3: Intento de lectura no autorizada a tablas del sistema
-- Mensaje esperado: ERROR 1142 (42000): SELECT command denied to user 'usr_biblioteca_app'@'localhost' for table 'user'
-- SELECT * FROM mysql.user;
