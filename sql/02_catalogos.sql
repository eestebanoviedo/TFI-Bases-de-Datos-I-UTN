-- =============================================================================
-- TRABAJO FINAL INTEGRADOR - BASES DE DATOS I (UTN)
-- Script 02: Catálogos Semilla para Generación Masiva (Etapa 2)
-- Tablas auxiliares con vocabularios de dominio (autores, editoriales, temas, idiomas)
-- Nota: No modifican el esquema de 2 entidades (libro <-> ficha_bibliografica).
-- =============================================================================

USE tpi_biblioteca;

-- Eliminar tablas catálogo auxiliares previas si existen
DROP TABLE IF EXISTS catalogo_autores_semilla;
DROP TABLE IF EXISTS catalogo_editoriales_semilla;
DROP TABLE IF EXISTS catalogo_titulos_semilla;
DROP TABLE IF EXISTS catalogo_dewey_semilla;
DROP TABLE IF EXISTS catalogo_idiomas_semilla;

-- 1. Catálogo Semilla de Autores Reconocidos
CREATE TABLE catalogo_autores_semilla (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL
) ENGINE=InnoDB;

INSERT INTO catalogo_autores_semilla (nombre) VALUES
('Jorge Luis Borges'),
('Gabriel García Márquez'),
('Julio Cortázar'),
('Mario Vargas Llosa'),
('Isabel Allende'),
('Ernesto Sabato'),
('Adolfo Bioy Casares'),
('Miguel de Cervantes'),
('William Shakespeare'),
('Fyodor Dostoevsky'),
('Leo Tolstoy'),
('Franz Kafka'),
('George Orwell'),
('Aldous Huxley'),
('Virginia Woolf'),
('Jane Austen'),
('Edgar Allan Poe'),
('Arthur Conan Doyle'),
('H.P. Lovecraft'),
('Isaac Asimov'),
('Philip K. Dick'),
('Ray Bradbury'),
('J.R.R. Tolkien'),
('C.S. Lewis'),
('Ursula K. Le Guin');

-- 2. Catálogo Semilla de Editoriales
CREATE TABLE catalogo_editoriales_semilla (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

INSERT INTO catalogo_editoriales_semilla (nombre) VALUES
('Editorial Sudamericana'),
('Alianza Editorial'),
('Penguin Random House'),
('Planeta'),
('Minotauro'),
('Fondo de Cultura Económica'),
('Anagrama'),
('Alfaguara'),
('Cátedra'),
('Siglo XXI Editores'),
('Tusquets Editores'),
('Gredos'),
('Akal'),
('Oceano'),
('Norma');

-- 3. Catálogo Semilla de Componentes para Títulos Sintéticos Coherentes
CREATE TABLE catalogo_titulos_semilla (
    id INT AUTO_INCREMENT PRIMARY KEY,
    prefijo VARCHAR(50) NOT NULL,
    nucleo VARCHAR(50) NOT NULL,
    sufijo VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

INSERT INTO catalogo_titulos_semilla (prefijo, nucleo, sufijo) VALUES
('El Secreto de', 'la Eternidad', 'en el Laberinto'),
('Crónica de', 'las Sombras', 'del Tiempo Perdido'),
('Tratado sobre', 'la Memoria', 'de los Espejos'),
('Historia de', 'un Destino', 'en la Ciudad Invisible'),
('El Misterio de', 'la Razón', 'Bajo las Estrellas'),
('Canto a', 'la Soledad', 'del Olvido'),
('Los Senderos de', 'la Aurora', 'en el Horizonte'),
('Fragmentos de', 'un Sueño', 'Olvidado'),
('Fundación de', 'la Esperanza', 'en el Vacío'),
('El Eco de', 'la Tempestad', 'y el Silencio');

-- 4. Catálogo Semilla de Clasificación Decimal Dewey
CREATE TABLE catalogo_dewey_semilla (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(20) NOT NULL,
    descripcion VARCHAR(80) NOT NULL,
    estanteria_base VARCHAR(10) NOT NULL
) ENGINE=InnoDB;

INSERT INTO catalogo_dewey_semilla (codigo, descripcion, estanteria_base) VALUES
('004.0', 'Informática y Procesamiento de Datos', 'EST-A'),
('100.0', 'Filosofía y Psicología', 'EST-B'),
('200.0', 'Religión y Mitología', 'EST-C'),
('300.0', 'Ciencias Sociales y Política', 'EST-D'),
('500.0', 'Ciencias Naturales y Matemáticas', 'EST-E'),
('600.0', 'Tecnología y Ciencias Aplicadas', 'EST-F'),
('700.0', 'Las Artes y Recreación', 'EST-G'),
('800.0', 'Literatura General', 'EST-H'),
('823.9', 'Literatura Narrativa en Inglés', 'EST-I'),
('863.0', 'Literatura Narrativa en Español', 'EST-J'),
('900.0', 'Historia y Geografía', 'EST-K');

-- 5. Catálogo Semilla de Idiomas
CREATE TABLE catalogo_idiomas_semilla (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL
) ENGINE=InnoDB;

INSERT INTO catalogo_idiomas_semilla (nombre) VALUES
('Español'),
('Inglés'),
('Francés'),
('Alemán'),
('Italiano'),
('Portugués');
