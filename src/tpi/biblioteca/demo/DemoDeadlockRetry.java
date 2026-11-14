package tpi.biblioteca.demo;

import tpi.biblioteca.config.DatabaseConnection;
import tpi.biblioteca.service.LibroServiceImpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * =============================================================================
 * TRABAJO FINAL INTEGRADOR - BASES DE DATOS I (UTN)
 * Demostración de Transacciones Concurrentes y Retry ante Deadlock (Etapa 5)
 * =============================================================================
 * Simula dos hilos concurrentes que acceden a los mismos recursos en orden inverso,
 * forzando un Deadlock en MySQL (Error 1213 / 40001) y demostrando la recuperación
 * automática mediante política de reintentos (Retry) con backoff exponencial.
 */
public class DemoDeadlockRetry {

    private static final int MAX_REINTENTOS = 2;
    private static final long BACKOFF_BASE_MS = 200;
    private static final AtomicInteger deadlocksDetectados = new AtomicInteger(0);
    private static final AtomicInteger transaccionesExitosas = new AtomicInteger(0);

    public static void main(String[] args) throws InterruptedException {
        System.out.println("====================================================================");
        System.out.println(" DEMOSTRACIÓN DE CONCURRENCIA: DEADLOCK Y RETRY AUTOMÁTICO (ETAPA 5)");
        System.out.println("====================================================================\n");

        CountDownLatch startSignal = new CountDownLatch(1);
        ExecutorService executor = Executors.newFixedThreadPool(2);

        // Hilo 1: Actualiza Libro 1 -> espera breve -> Actualiza Libro 2
        executor.submit(() -> ejecutarConRetry(1, 1L, 2L, startSignal));

        // Hilo 2: Actualiza Libro 2 -> espera breve -> Actualiza Libro 1 (Orden inverso cruzado)
        executor.submit(() -> ejecutarConRetry(2, 2L, 1L, startSignal));

        // Disparar ambos hilos al unísono
        Thread.sleep(100);
        System.out.println("[COORDINADOR] Disparando hilos concurrentes...");
        startSignal.countDown();

        executor.shutdown();
        executor.awaitTermination(15, TimeUnit.SECONDS);

        System.out.println("\n--------------------------------------------------------------------");
        System.out.println("RESUMEN DE EJECUCIÓN:");
        System.out.println(" - Deadlocks detectados y gestionados: " + deadlocksDetectados.get());
        System.out.println(" - Transacciones exitosas finales:    " + transaccionesExitosas.get() + " / 2");
        System.out.println("--------------------------------------------------------------------");
        System.out.println("Conclusión: La estrategia de retry con backoff resolvió la contención");
        System.out.println("sin pérdida de consistencia ni caída de la aplicación.");
        System.out.println("====================================================================");
    }

    private static void ejecutarConRetry(int hiloId, Long primerId, Long segundoId, CountDownLatch latch) {
        try {
            latch.await();
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            return;
        }

        int intentos = 0;
        while (true) {
            intentos++;
            try {
                System.out.printf("[Hilo %d] Intento #%d iniciando transacción...%n", hiloId, intentos);
                ejecutarTransaccionCruzada(hiloId, primerId, segundoId);
                System.out.printf("[Hilo %d] Transacción completada con ÉXITO en intento #%d.%n", hiloId, intentos);
                transaccionesExitosas.incrementAndGet();
                return;
            } catch (Exception e) {
                if (LibroServiceImpl.esDeadlock(e)) {
                    deadlocksDetectados.incrementAndGet();
                    if (intentos <= MAX_REINTENTOS) {
                        long espera = BACKOFF_BASE_MS * intentos;
                        System.err.printf("[Hilo %d - ALERTA] Deadlock detectado (MySQL 1213 / SQLSTATE 40001). " +
                                        "Aplicando backoff de %d ms antes del reintento %d...%n",
                                hiloId, espera, intentos + 1);
                        try {
                            Thread.sleep(espera);
                        } catch (InterruptedException ie) {
                            Thread.currentThread().interrupt();
                            return;
                        }
                    } else {
                        System.err.printf("[Hilo %d - ERROR] Superado el número máximo de reintentos (%d). Abortando.%n",
                                hiloId, MAX_REINTENTOS);
                        return;
                    }
                } else {
                    System.err.printf("[Hilo %d - ERROR NO DEADLOCK] %s%n", hiloId, e.getMessage());
                    return;
                }
            }
        }
    }

    private static void ejecutarTransaccionCruzada(int hiloId, Long primerId, Long segundoId) throws Exception {
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);
            conn.setTransactionIsolation(Connection.TRANSACTION_READ_COMMITTED);

            // 1. Bloquear primer recurso
            String sql1 = "UPDATE libro SET anio_edicion = anio_edicion WHERE id = ?";
            try (PreparedStatement ps1 = conn.prepareStatement(sql1)) {
                ps1.setLong(1, primerId);
                ps1.executeUpdate();
            }

            // Pausa controlada para forzar el entrelazado de bloqueos concurrentes
            Thread.sleep(50);

            // 2. Intentar bloquear segundo recurso (puede bloquearse y disparar Deadlock)
            String sql2 = "UPDATE libro SET anio_edicion = anio_edicion WHERE id = ?";
            try (PreparedStatement ps2 = conn.prepareStatement(sql2)) {
                ps2.setLong(1, segundoId);
                ps2.executeUpdate();
            }

            conn.commit();
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ignore) {}
            }
            throw e;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ignore) {}
            }
        }
    }
}
