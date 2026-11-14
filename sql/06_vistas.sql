-- =============================================================================
-- TRABAJO FINAL INTEGRADOR - BASES DE DATOS I (UTN)
-- Script 06: Definición de Vistas Seguras (Etapa 4)
-- Implementa 2 vistas que ocultan información técnica, sensible y registros dados de baja.
-- =============================================================================

USE tpi_biblioteca;

-- Eliminar vistas si existen para permitir re-ejecución
DROP VIEW IF EXISTS vista_catalogo_publico;
DROP VIEW IF EXISTS vista_estadisticas_editorial;

-- -----------------------------------------------------------------------------
-- 1. Vista: vista_catalogo_publico
-- Objetivo de Seguridad / Privacidad:
--   - Oculta la columna de control interno 'eliminado' (filtra solo activos).
--   - Oculta claves técnicas primarias y foráneas internas (id, ficha_id).
--   - Oculta la ubicación física exacta del depósito/estantería para evitar accesos
--     no autorizados al área de depósito restringido de la biblioteca.
-- -----------------------------------------------------------------------------
CREATE VIEW vista_catalogo_publico AS
SELECT 
    l.titulo,
    l.autor,
    l.editorial,
    l.anio_edicion,
    f.isbn,
    f.clasificacion_dewey,
    f.idioma
FROM libro l
INNER JOIN ficha_bibliografica f ON l.ficha_id = f.id
WHERE l.eliminado = FALSE 
  AND f.eliminado = FALSE;


-- -----------------------------------------------------------------------------
-- 2. Vista: vista_estadisticas_editorial
-- Objetivo de Seguridad / Privacidad:
--   - Oculta registros individuales y títulos concretos de autores.
--   - Expone únicamente información agregada y estadística por editorial,
--     permitiendo consultas analíticas sin exponer datos individuales del catálogo.
-- -----------------------------------------------------------------------------
CREATE VIEW vista_estadisticas_editorial AS
SELECT 
    l.editorial,
    COUNT(l.id) AS total_titulos_disponibles,
    COUNT(DISTINCT f.idioma) AS cantidad_idiomas,
    MIN(l.anio_edicion) AS primera_edicion_disponible,
    MAX(l.anio_edicion) AS ultima_edicion_disponible
FROM libro l
INNER JOIN ficha_bibliografica f ON l.ficha_id = f.id
WHERE l.eliminado = FALSE 
  AND f.eliminado = FALSE
GROUP BY l.editorial;

-- Pruebas de verificación de las vistas creadas
SELECT * FROM vista_catalogo_publico LIMIT 10;
SELECT * FROM vista_estadisticas_editorial LIMIT 10;
