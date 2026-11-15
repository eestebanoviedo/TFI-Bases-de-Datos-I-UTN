-- =============================================================================
-- TRABAJO FINAL INTEGRADOR - BASES DE DATOS I (UTN)
-- Script 09: Guía de Concurrencia, Deadlocks y Aislamiento (Etapa 5)
-- Instrucciones para probar en dos terminales simultáneas de MySQL.
-- =============================================================================

USE tpi_biblioteca;

-- =============================================================================
-- PARTE A: CÓMO PROVOCAR UN DEADLOCK EN VIVO (Error 1213)
-- =============================================================================
-- Abrí dos terminales conectadas a MySQL:
-- Terminal 1 = Sesión 1
-- Terminal 2 = Sesión 2

-- [PASO 1] En Sesión 1: iniciamos transacción y modificamos el libro 1
-- START TRANSACTION;
-- UPDATE libro SET anio_edicion = 1991 WHERE id = 1;
-- (Queda bloqueado el registro 1. NO hagas COMMIT todavía).

-- [PASO 2] En Sesión 2: iniciamos transacción y modificamos el libro 2
-- START TRANSACTION;
-- UPDATE libro SET anio_edicion = 1992 WHERE id = 2;
-- (Queda bloqueado el registro 2. NO hagas COMMIT todavía).

-- [PASO 3] En Sesión 1: intentamos modificar el libro 2 (queda en espera)
-- UPDATE libro SET anio_edicion = 2001 WHERE id = 2;
-- (La Sesión 1 se queda pausada esperando que la Sesión 2 libere el libro 2).

-- [PASO 4] En Sesión 2: intentamos modificar el libro 1 (¡salta el Deadlock!)
-- UPDATE libro SET anio_edicion = 2002 WHERE id = 1;
-- (Como las dos sesiones se esperan mutuamente, MySQL corta el ciclo y cancela una).

-- Mensaje real de MySQL en la sesión elegida como víctima:
-- ERROR 1213 (40001): Deadlock found when trying to get lock; try restarting transaction
-- La otra sesión se destraba sola y puede confirmar con:
-- COMMIT;


-- =============================================================================
-- PARTE B: COMPARACIÓN DE NIVELES DE AISLAMIENTO
-- =============================================================================

-- CASO 1: En READ COMMITTED (permite lecturas no repetibles)
-- ---------------------------------------------------------
-- [Sesión 1]:
-- SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- START TRANSACTION;
-- SELECT titulo, anio_edicion FROM libro WHERE id = 10;
-- (Nos devuelve, por ejemplo: 1970)

-- [Sesión 2]:
-- UPDATE libro SET anio_edicion = 2024 WHERE id = 10;
-- COMMIT;

-- [Sesión 1]:
-- SELECT titulo, anio_edicion FROM libro WHERE id = 10;
-- (Resultado: ¡cambió a 2024 en la misma transacción! Vimos el cambio ajeno).
-- COMMIT;


-- CASO 2: En REPEATABLE READ (el modo por defecto de MySQL con InnoDB)
-- -------------------------------------------------------------------
-- [Sesión 1]:
-- SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- START TRANSACTION;
-- SELECT titulo, anio_edicion FROM libro WHERE id = 10;
-- (Nos devuelve el año actual según el último commit, por ejemplo 2024)

-- [Sesión 2]:
-- UPDATE libro SET anio_edicion = 1980 WHERE id = 10;
-- COMMIT;

-- [Sesión 1]:
-- SELECT titulo, anio_edicion FROM libro WHERE id = 10;
-- (Resultado: sigue mostrando 2024. No ve el cambio ajeno hasta terminar la transacción).
-- COMMIT;
-- SELECT titulo, anio_edicion FROM libro WHERE id = 10;
-- (Recién después del COMMIT de la Sesión 1 vemos el valor 1980).
