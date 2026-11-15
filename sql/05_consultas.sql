-- =============================================================================
-- TRABAJO FINAL INTEGRADOR - BASES DE DATOS I (UTN)
-- Script 05: Consultas de Negocio (Etapa 3)
-- Contiene: 2 consultas con JOIN, 1 con GROUP BY + HAVING y 1 con Subconsulta.
-- =============================================================================

USE tpi_biblioteca;

-- -----------------------------------------------------------------------------
-- CONSULTA 1 (JOIN 1:1): Ubicación de libros activos en estanterías
-- Qué hace:
-- Muestra los libros activos en idioma Español junto con los datos de su ficha
-- (ISBN, categoría Dewey y estantería), para saber en qué lugar físico están guardados.
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
-- CONSULTA 2 (JOIN + Agregación): Cantidad de libros y años por categoría e idioma
-- Qué hace:
-- Agrupa los libros por clasificación Dewey e idioma. Calcula cuántos ejemplares
-- hay, el año promedio de edición y cuáles son los libros más antiguos y más nuevos,
-- para conocer la composición general del catálogo de la biblioteca.
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
-- CONSULTA 3 (GROUP BY + HAVING): Editoriales con más de 650 libros activos
-- Qué hace:
-- Cuenta cuántos libros activos tiene cada editorial y filtra únicamente las que
-- superan los 650 títulos, mostrando también el primer y último año que editaron.
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
-- CONSULTA 4 (Subconsulta Correlacionada): Libros más recientes que el promedio del autor
-- Qué hace:
-- Compara cada libro con el año promedio en que publicó su autor. Muestra solo
-- aquellos libros editados después de ese promedio, es decir, las obras más
-- recientes de cada autor dentro del catálogo.
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
