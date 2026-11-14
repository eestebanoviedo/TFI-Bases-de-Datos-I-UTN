-- =============================================================================
-- TRABAJO FINAL INTEGRADOR - BASES DE DATOS I (UTN)
-- Script 09: Guía de Concurrencia, Deadlocks y Niveles de Aislamiento (Etapa 5)
-- Instrucciones paso a paso para ejecutar en dos sesiones simultáneas de MySQL.
-- =============================================================================

USE tpi_biblioteca;

-- =============================================================================
-- PARTE A: REPRODUCCIÓN CONTROLADA DE DEADLOCK (Error 1213 / SQLSTATE 40001)
-- =============================================================================
-- Instrucciones:
-- Abrir dos terminales o dos pestañas en MySQL Workbench / CLI:
-- Terminal 1 -> Sesión 1
-- Terminal 2 -> Sesión 2

-- -----------------------------------------------------------------------------
-- [PASO 1] En SESIÓN 1: Iniciar transacción y bloquear Registro 1
-- -----------------------------------------------------------------------------
-- START TRANSACTION;
-- UPDATE libro SET anio_edicion = 1991 WHERE id = 1;
-- (Bloqueo exclusivo X adquirido sobre id = 1. NO hacer COMMIT aún).

-- -----------------------------------------------------------------------------
-- [PASO 2] En SESIÓN 2: Iniciar transacción y bloquear Registro 2
-- -----------------------------------------------------------------------------
-- START TRANSACTION;
-- UPDATE libro SET anio_edicion = 1992 WHERE id = 2;
-- (Bloqueo exclusivo X adquirido sobre id = 2. NO hacer COMMIT aún).

-- -----------------------------------------------------------------------------
-- [PASO 3] En SESIÓN 1: Intentar actualizar Registro 2 (Queda en espera / WAIT)
-- -----------------------------------------------------------------------------
-- UPDATE libro SET anio_edicion = 2001 WHERE id = 2;
-- (La sesión 1 se queda bloqueada esperando que la Sesión 2 libere id = 2).

-- -----------------------------------------------------------------------------
-- [PASO 4] En SESIÓN 2: Intentar actualizar Registro 1 (¡DISPARA DEADLOCK!)
-- -----------------------------------------------------------------------------
-- UPDATE libro SET anio_edicion = 2002 WHERE id = 1;
-- (El motor detecta el ciclo de espera circular y aborta una de las dos transacciones).

-- Resultado observado en la víctima elegida por InnoDB:
-- ERROR 1213 (40001): Deadlock found when trying to get lock; try restarting transaction
-- La otra sesión se desbloquea y puede ejecutar COMMIT;


-- =============================================================================
-- PARTE B: COMPARACIÓN DE NIVELES DE AISLAMIENTO
-- Comparación entre READ COMMITTED y REPEATABLE READ (Lecturas No Repetibles)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- CASO 1: Comportamiento en READ COMMITTED (Permite lecturas no repetibles)
-- -----------------------------------------------------------------------------
-- [Sesión 1]:
-- SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- START TRANSACTION;
-- SELECT titulo, anio_edicion FROM libro WHERE id = 10;
-- (Retorna por ejemplo: anio_edicion = 1970)

-- [Sesión 2]:
-- UPDATE libro SET anio_edicion = 2024 WHERE id = 10;
-- COMMIT;

-- [Sesión 1]:
-- SELECT titulo, anio_edicion FROM libro WHERE id = 10;
-- (Resultado: ¡Cambia a 2024 dentro de la misma transacción! Lectura no repetible observada).
-- COMMIT;


-- -----------------------------------------------------------------------------
-- CASO 2: Comportamiento en REPEATABLE READ (Por defecto en InnoDB, Snapshot MVCC)
-- -----------------------------------------------------------------------------
-- [Sesión 1]:
-- SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- START TRANSACTION;
-- SELECT titulo, anio_edicion FROM libro WHERE id = 10;
-- (Retorna: anio_edicion = 2024 según el último commit).

-- [Sesión 2]:
-- UPDATE libro SET anio_edicion = 1980 WHERE id = 10;
-- COMMIT;

-- [Sesión 1]:
-- SELECT titulo, anio_edicion FROM libro WHERE id = 10;
-- (Resultado: Continúa retornando 2024. Se preserva la lectura consistente por MVCC).
-- COMMIT;
-- SELECT titulo, anio_edicion FROM libro WHERE id = 10;
-- (Recién tras el COMMIT se visualiza 1980).
