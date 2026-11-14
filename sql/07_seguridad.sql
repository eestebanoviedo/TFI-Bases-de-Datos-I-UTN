-- =============================================================================
-- TRABAJO FINAL INTEGRADOR - BASES DE DATOS I (UTN)
-- Script 07: Seguridad y Principio de Menor Privilegio (Etapa 4)
-- Creación de usuario restringido de aplicación y asignación estricta de permisos.
-- =============================================================================

USE tpi_biblioteca;

-- 1. Eliminar usuario si existía previamente (idempotencia)
DROP USER IF EXISTS 'usr_biblioteca_app'@'localhost';

-- 2. Crear usuario con contraseña segura
CREATE USER 'usr_biblioteca_app'@'localhost' IDENTIFIED BY 'AppPass123!';

-- 3. Limpiar cualquier privilegio residual
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'usr_biblioteca_app'@'localhost';

-- 4. Otorgar permisos mínimos requeridos para la operación de la aplicación:
--    - Lectura exclusiva sobre las VISTAS seguras públicas y estadísticas.
--    - Lectura, Inserción y Modificación controlada sobre las tablas base.
--    - DENEGADO EXPLÍCITO: DELETE físico, DROP, ALTER, CREATE, TRUNCATE, GRANT OPTION.
GRANT SELECT ON tpi_biblioteca.vista_catalogo_publico TO 'usr_biblioteca_app'@'localhost';
GRANT SELECT ON tpi_biblioteca.vista_estadisticas_editorial TO 'usr_biblioteca_app'@'localhost';

GRANT SELECT, INSERT, UPDATE ON tpi_biblioteca.libro TO 'usr_biblioteca_app'@'localhost';
GRANT SELECT, INSERT, UPDATE ON tpi_biblioteca.ficha_bibliografica TO 'usr_biblioteca_app'@'localhost';

FLUSH PRIVILEGES;

-- 5. Verificar los privilegios efectivos asignados
SHOW GRANTS FOR 'usr_biblioteca_app'@'localhost';
