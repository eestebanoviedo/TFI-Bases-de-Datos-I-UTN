-- =============================================================================
-- TRABAJO FINAL INTEGRADOR - BASES DE DATOS I (UTN)
-- Script 01: Definición de Esquema y Restricciones de Integridad (Etapa 1)
-- Dominio: Sistema de Biblioteca (Libro <-> FichaBibliografica, Relación 1:1)
-- =============================================================================

CREATE DATABASE IF NOT EXISTS tpi_biblioteca 
    CHARACTER SET utf8mb4 
    COLLATE utf8mb4_unicode_ci;

USE tpi_biblioteca;

-- Eliminar tablas en orden por dependencias de clave foránea
DROP TABLE IF EXISTS libro;
DROP TABLE IF EXISTS ficha_bibliografica;

-- -----------------------------------------------------------------------------
-- 1. Tabla: ficha_bibliografica
-- -----------------------------------------------------------------------------
CREATE TABLE ficha_bibliografica (
    id BIGINT AUTO_INCREMENT,
    eliminado BOOLEAN NOT NULL DEFAULT FALSE,
    isbn VARCHAR(17) NULL,
    clasificacion_dewey VARCHAR(20) NULL,
    estanteria VARCHAR(20) NULL,
    idioma VARCHAR(30) NULL,
    
    -- Clave Primaria
    CONSTRAINT pk_ficha_bibliografica PRIMARY KEY (id),
    
    -- Restricción de Unicidad
    CONSTRAINT uq_ficha_isbn UNIQUE (isbn),
    
    -- Restricciones de Dominio y Validación (CHECK)
    CONSTRAINT chk_ficha_isbn_formato CHECK (
        isbn IS NULL OR CHAR_LENGTH(TRIM(isbn)) >= 10
    ),
    CONSTRAINT chk_ficha_dewey_no_vacio CHECK (
        clasificacion_dewey IS NULL OR CHAR_LENGTH(TRIM(clasificacion_dewey)) > 0
    ),
    CONSTRAINT chk_ficha_idioma_no_vacio CHECK (
        idioma IS NULL OR CHAR_LENGTH(TRIM(idioma)) > 0
    )
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 2. Tabla: libro
-- Relación 1:1 unidireccional modelada con FK ficha_id y restricción UNIQUE
-- -----------------------------------------------------------------------------
CREATE TABLE libro (
    id BIGINT AUTO_INCREMENT,
    eliminado BOOLEAN NOT NULL DEFAULT FALSE,
    titulo VARCHAR(150) NOT NULL,
    autor VARCHAR(120) NOT NULL,
    editorial VARCHAR(100) NULL,
    anio_edicion INT NULL,
    ficha_id BIGINT NULL,
    
    -- Clave Primaria
    CONSTRAINT pk_libro PRIMARY KEY (id),
    
    -- Relación 1:1: una ficha pertenece a lo sumo a un libro
    CONSTRAINT uq_libro_ficha_id UNIQUE (ficha_id),
    
    -- Clave Foránea con preservación ante eliminación física
    CONSTRAINT fk_libro_ficha 
        FOREIGN KEY (ficha_id) REFERENCES ficha_bibliografica(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
        
    -- Restricciones de Dominio (CHECK)
    CONSTRAINT chk_libro_titulo_no_vacio CHECK (
        CHAR_LENGTH(TRIM(titulo)) > 0
    ),
    CONSTRAINT chk_libro_autor_no_vacio CHECK (
        CHAR_LENGTH(TRIM(autor)) > 0
    ),
    CONSTRAINT chk_libro_anio_valido CHECK (
        anio_edicion IS NULL OR (anio_edicion >= 868 AND anio_edicion <= 2026)
    )
) ENGINE=InnoDB;
