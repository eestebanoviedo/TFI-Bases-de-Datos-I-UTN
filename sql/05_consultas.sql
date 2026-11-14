-- =============================================================================
-- TRABAJO FINAL INTEGRADOR - BASES DE DATOS I (UTN)
-- Script 05: Consultas Complejas y Reportes de Valor de Negocio (Etapa 3)
-- Incluye 2 consultas con JOIN, 1 con GROUP BY + HAVING y 1 con Subconsulta.
-- =============================================================================

USE tpi_biblioteca;

-- -----------------------------------------------------------------------------
-- CONSULTA 1: Catálogo Físico de Obras Activas (JOIN 1:1)
-- Utilidad Práctica:
-- Esta consulta permite al personal bibliotecario y a los lectores localizar de forma
-- inmediata en qué estantería física se encuentra cada ejemplar activo (no dado de baja),
-- vinculando la ficha técnica (ISBN, Dewey, estantería) con los datos bibliográficos.
-- -----------------------------------------------------------------------------
SELECT 
    l.id AS libro_id,
    l.titulo,
    l.autor,
    l.editorial,
    l.anio_edicion,
    f.isbn,
    f.clasificacion_dewey,
    f.estanteria,
    f.idioma
FROM libro l
INNER JOIN ficha_bibliografica f ON l.ficha_id = f.id
WHERE l.eliminado = FALSE 
  AND f.eliminado = FALSE
  AND f.idioma = 'Español'
ORDER BY f.estanteria, l.titulo
LIMIT 50;


-- -----------------------------------------------------------------------------
-- CONSULTA 2: Inventario Analítico por Clasificación Temática e Idioma (JOIN + Agregación)
-- Utilidad Práctica:
-- Brinda a la dirección de la biblioteca una visión estratégica del acervo bibliográfico,
-- calculando el volumen de títulos, el rango temporal (año mínimo y máximo) y el año 
-- promedio por categoría Dewey e idioma para orientar compras y descarte de material.
-- -----------------------------------------------------------------------------
SELECT 
    f.clasificacion_dewey,
    f.idioma,
    COUNT(l.id) AS total_ejemplares,
    MIN(l.anio_edicion) AS edicion_mas_antigua,
    MAX(l.anio_edicion) AS edicion_mas_reciente,
    ROUND(AVG(l.anio_edicion), 1) AS promedio_anio_edicion
FROM libro l
INNER JOIN ficha_bibliografica f ON l.ficha_id = f.id
WHERE l.eliminado = FALSE
GROUP BY f.clasificacion_dewey, f.idioma
ORDER BY f.clasificacion_dewey, total_ejemplares DESC;


-- -----------------------------------------------------------------------------
-- CONSULTA 3: Editoriales Principales con Alto Volumen de Catálogo (GROUP BY + HAVING)
-- Utilidad Práctica:
-- Filtra y categoriza a las casas editoriales con presencia dominante en la biblioteca
-- (más de 650 títulos activos en acervo). Facilita la gestión de convenios, compras
-- corporativas por lote y auditoría de concentración de proveedores editoriales.
-- -----------------------------------------------------------------------------
SELECT 
    l.editorial,
    COUNT(*) AS total_titulos_activos,
    MIN(l.anio_edicion) AS primer_anio_en_catalogo,
    MAX(l.anio_edicion) AS ultimo_anio_en_catalogo,
    ROUND(AVG(l.anio_edicion), 0) AS anio_promedio_editorial
FROM libro l
WHERE l.eliminado = FALSE
GROUP BY l.editorial
HAVING COUNT(*) > 650
ORDER BY total_titulos_activos DESC;


-- -----------------------------------------------------------------------------
-- CONSULTA 4: Obras Contemporáneas por Autor (Subconsulta Correlacionada)
-- Utilidad Práctica:
-- Identifica títulos cuya fecha de edición supera el año promedio de publicación de
-- las obras de su mismo autor. Sirve para curaduría literaria, exposiciones de obras
-- recientes y recomendaciones de catálogo basadas en la última etapa de cada autor.
-- -----------------------------------------------------------------------------
SELECT 
    l.id,
    l.titulo,
    l.autor,
    l.editorial,
    l.anio_edicion,
    (SELECT ROUND(AVG(l_sub.anio_edicion), 1) 
     FROM libro l_sub 
     WHERE l_sub.autor = l.autor AND l_sub.eliminado = FALSE) AS anio_promedio_autor
FROM libro l
WHERE l.eliminado = FALSE
  AND l.anio_edicion > (
      SELECT AVG(l2.anio_edicion)
      FROM libro l2
      WHERE l2.autor = l.autor 
        AND l2.eliminado = FALSE
  )
ORDER BY l.autor, l.anio_edicion DESC
LIMIT 50;
