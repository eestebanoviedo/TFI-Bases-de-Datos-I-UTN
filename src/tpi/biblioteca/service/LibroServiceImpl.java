package tpi.biblioteca.service;

import tpi.biblioteca.config.DatabaseConnection;
import tpi.biblioteca.dao.FichaBibliograficaDao;
import tpi.biblioteca.dao.JdbcFichaBibliograficaDao;
import tpi.biblioteca.dao.JdbcLibroDao;
import tpi.biblioteca.dao.LibroDao;
import tpi.biblioteca.entities.FichaBibliografica;
import tpi.biblioteca.entities.Libro;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

public class LibroServiceImpl implements LibroService {

    private final LibroDao libroDao = new JdbcLibroDao();
    private final FichaBibliograficaDao fichaDao = new JdbcFichaBibliograficaDao();

    @Override
    public Libro insertar(Libro libro) throws Exception {
        // insertar sólo libro, sin ficha
        validar(libro);
        try (Connection conn = DatabaseConnection.getConnection()) {
            return libroDao.crear(conn, libro);
        }
    }

    @Override
    public Libro insertarConFicha(Libro libro) throws Exception {
        validar(libro);
        FichaBibliografica ficha = libro.getFichaBibliografica();
        if (ficha == null) {
            throw new IllegalArgumentException("La ficha bibliográfica es obligatoria en esta operación");
        }

        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);

            // 1) Validar que no exista otra ficha con mismo ISBN (regla 1→1 + UNIQUE)
            if (ficha.getIsbn() != null && !ficha.getIsbn().isBlank()) {
                FichaBibliografica existente = fichaDao.buscarPorIsbn(conn, ficha.getIsbn().trim());
                if (existente != null) {
                    throw new IllegalStateException("Ya existe una ficha con ISBN: " + ficha.getIsbn());
                }
            }

            // 2) Crear ficha
            fichaDao.crear(conn, ficha);

            // 3) Asociar ficha al libro
            libro.setFichaBibliografica(ficha);

            // 4) Crear libro
            libroDao.crear(conn, libro);

            conn.commit();
            return libro;
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

    @Override
    public Libro insertarConFichaConRetry(Libro libro, int maxReintentos, long backoffMs) throws Exception {
        int intento = 0;
        while (true) {
            try {
                intento++;
                return insertarConFicha(libro);
            } catch (Exception e) {
                if (esDeadlock(e) && intento <= maxReintentos) {
                    System.err.printf("[LOG TRANSACCIONAL] Deadlock detectado (MySQL 1213 / SQLSTATE 40001). Reintento %d de %d en %d ms...%n",
                            intento, maxReintentos, backoffMs * intento);
                    try {
                        Thread.sleep(backoffMs * intento);
                    } catch (InterruptedException ie) {
                        Thread.currentThread().interrupt();
                        throw e;
                    }
                } else {
                    throw e;
                }
            }
        }
    }

    public static boolean esDeadlock(Throwable t) {
        while (t != null) {
            if (t instanceof SQLException sqlEx) {
                if (sqlEx.getErrorCode() == 1213 || "40001".equalsIgnoreCase(sqlEx.getSQLState())) {
                    return true;
                }
            }
            t = t.getCause();
        }
        return false;
    }


    @Override
    public Libro actualizar(Libro libro) throws Exception {
        if (libro.getId() == null || libro.getId() <= 0) {
            throw new IllegalArgumentException("ID de libro inválido");
        }
        validar(libro);
        try (Connection conn = DatabaseConnection.getConnection()) {
            libroDao.actualizar(conn, libro);
            return libro;
        }
    }

    @Override
    public void eliminar(Long id) throws Exception {
        if (id == null || id <= 0) throw new IllegalArgumentException("ID inválido");
        try (Connection conn = DatabaseConnection.getConnection()) {
            libroDao.eliminar(conn, id); // baja lógica
        }
    }

    @Override
    public Libro getById(Long id) throws Exception {
        try (Connection conn = DatabaseConnection.getConnection()) {
            return libroDao.leer(conn, id);
        }
    }

    @Override
    public List<Libro> getAll() throws Exception {
        try (Connection conn = DatabaseConnection.getConnection()) {
            return libroDao.leerTodos(conn);
        }
    }

    @Override
    public List<Libro> buscarPorTituloOAutor(String filtro) throws Exception {
        try (Connection conn = DatabaseConnection.getConnection()) {
            return libroDao.buscarPorTituloOAutor(conn, filtro.trim());
        }
    }

    private void validar(Libro l) {
        if (l.getTitulo() == null || l.getTitulo().trim().isEmpty()) {
            throw new IllegalArgumentException("El título es obligatorio");
        }
        if (l.getAutor() == null || l.getAutor().trim().isEmpty()) {
            throw new IllegalArgumentException("El autor es obligatorio");
        }
        l.setTitulo(l.getTitulo().trim());
        l.setAutor(l.getAutor().trim());
        if (l.getEditorial() != null) l.setEditorial(l.getEditorial().trim());
    }
}
