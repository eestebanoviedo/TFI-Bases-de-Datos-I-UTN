-- =============================================================================
-- TRABAJO FINAL INTEGRADOR - BASES DE DATOS I (UTN)
-- Script 04: Creación y Gestión de Índices (Etapa 3)
-- Optimización de planes de ejecución para consultas sobre grandes volúmenes
-- =============================================================================

USE tpi_biblioteca;

-- Procedimiento utilitario para eliminación idempotente de índices
DELIMITER //
DROP PROCEDURE IF EXISTS sp_drop_index_safe //
CREATE PROCEDURE sp_drop_index_safe(IN in_table VARCHAR(64), IN in_index VARCHAR(64))
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.statistics 
        WHERE table_schema = DATABASE() AND table_name = in_table AND index_name = in_index
    ) THEN
        SET @drop_query = CONCAT('ALTER TABLE ', in_table, ' DROP INDEX ', in_index);
        PREPARE stmt_drop FROM @drop_query;
        EXECUTE stmt_drop;
        DEALLOCATE PREPARE stmt_drop;
    END IF;
END //
DELIMITER ;

-- Eliminar índices previos si existieran
CALL sp_drop_index_safe('libro', 'idx_libro_autor');
CALL sp_drop_index_safe('libro', 'idx_libro_anio');
CALL sp_drop_index_safe('ficha_bibliografica', 'idx_ficha_dewey');
CALL sp_drop_index_safe('ficha_bibliografica', 'idx_ficha_idioma');
DROP PROCEDURE IF EXISTS sp_drop_index_safe;

-- -----------------------------------------------------------------------------
-- 1. Índice en autor: optimiza búsquedas exactas y filtrado por autor
-- -----------------------------------------------------------------------------
CREATE INDEX idx_libro_autor ON libro(autor);

-- -----------------------------------------------------------------------------
-- 2. Índice en anio_edicion: optimiza filtros por rango (BETWEEN, >=, <=)
-- -----------------------------------------------------------------------------
CREATE INDEX idx_libro_anio ON libro(anio_edicion);

-- -----------------------------------------------------------------------------
-- 3. Índice en clasificacion_dewey: acelera agrupaciones y filtros temáticos
-- -----------------------------------------------------------------------------
CREATE INDEX idx_ficha_dewey ON ficha_bibliografica(clasificacion_dewey);

-- -----------------------------------------------------------------------------
-- 4. Índice en idioma: optimiza filtros de idioma en catálogo
-- -----------------------------------------------------------------------------
CREATE INDEX idx_ficha_idioma ON ficha_bibliografica(idioma);

-- Verificación de índices creados en las tablas
SHOW INDEX FROM libro;
SHOW INDEX FROM ficha_bibliografica;
