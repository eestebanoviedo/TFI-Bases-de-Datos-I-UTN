package tpi.biblioteca.demo;

import tpi.biblioteca.config.DatabaseConnection;
import tpi.biblioteca.dao.JdbcLibroDao;
import tpi.biblioteca.dao.LibroDao;
import tpi.biblioteca.entities.Libro;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.List;

/**
 * =============================================================================
 * TRABAJO FINAL INTEGRADOR - BASES DE DATOS I (UTN)
 * Demostración de Seguridad: SQL Injection vs PreparedStatement Seguro (Etapa 4)
 * =============================================================================
 * Muestra el contraste entre:
 *   1. Consulta vulnerable por concatenación dinámica (Statement).
 *   2. Consulta segura parametrizada (PreparedStatement en JdbcLibroDao).
 */
public class DemoSqlInjection {

    public static void main(String[] args) {
        System.out.println("====================================================================");
        System.out.println(" DEMOSTRACIÓN DE SEGURIDAD: PREVENCIÓN DE SQL INJECTION (ETAPA 4)   ");
        System.out.println("====================================================================\n");

        // Entrada maliciosa típica para eludir autenticación o filtrar toda la tabla
        String entradaMaliciosa = "' OR '1'='1";

        System.out.println("Entrada del usuario simulada: " + entradaMaliciosa);
        System.out.println("--------------------------------------------------------------------\n");

        // 1. ESCENARIO VULNERABLE: Concatenación dinámica con Statement
        System.out.println("1. CASO VULNERABLE (Concatenación directa con java.sql.Statement):");
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement()) {

            String queryVulnerable = "SELECT id, titulo, autor FROM libro " +
                    "WHERE eliminado = FALSE AND (titulo LIKE '%" + entradaMaliciosa + "%')";

            System.out.println("   SQL generado en tiempo de ejecución:");
            System.out.println("   >> " + queryVulnerable);

            int registrosExpuestos = 0;
            try (ResultSet rs = stmt.executeQuery(queryVulnerable)) {
                while (rs.next()) {
                    registrosExpuestos++;
                }
            }

            System.out.println("   [PELIGRO] Registros devueltos por ataque: " + registrosExpuestos);
            System.out.println("   Diagnóstico: La comilla alteró la sintaxis SQL. La condición '1'='1'");
            System.out.println("   evaluó a VERDADERO para todas las filas, filtrando toda la base de datos.\n");

        } catch (Exception e) {
            System.err.println("   Error en escenario vulnerable: " + e.getMessage());
        }

        // 2. ESCENARIO SEGURO: Parámetros tipados con PreparedStatement
        System.out.println("2. CASO SEGURO (Consulta Parametrizada con JdbcLibroDao):");
        try (Connection conn = DatabaseConnection.getConnection()) {
            LibroDao libroDao = new JdbcLibroDao();

            System.out.println("   SQL parametrizado compilado en el motor:");
            System.out.println("   >> SELECT ... WHERE eliminado = FALSE AND (UPPER(l.titulo) LIKE ? OR UPPER(l.autor) LIKE ?)");

            // El DAO ejecuta: ps.setString(1, "%" + entradaMaliciosa.toUpperCase() + "%");
            List<Libro> resultadosSeguros = libroDao.buscarPorTituloOAutor(conn, entradaMaliciosa);

            System.out.println("   [ÉXITO] Registros devueltos: " + resultadosSeguros.size());
            System.out.println("   Diagnóstico: PreparedStatement envía el comando SQL y los datos por canales");
            System.out.println("   separados en el protocolo binario de MySQL. La entrada se trata como un");
            System.out.println("   literal de texto puro y no puede modificar la estructura lógica de la consulta.");

        } catch (Exception e) {
            System.err.println("   Error en escenario seguro: " + e.getMessage());
        }

        System.out.println("\n====================================================================");
        System.out.println(" FIN DE LA DEMOSTRACIÓN                                              ");
        System.out.println("====================================================================");
    }
}
