package tpi.biblioteca.dao;

import tpi.biblioteca.entities.FichaBibliografica;
import tpi.biblioteca.entities.Libro;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class JdbcLibroDao implements LibroDao {

    private static final String INSERT_SQL =
            "INSERT INTO libro (eliminado, titulo, autor, editorial, anio_edicion, ficha_id) " +
            "VALUES (FALSE, ?, ?, ?, ?, ?)";

    private static final String SELECT_BY_ID_SQL =
            "SELECT l.id, l.eliminado, l.titulo, l.autor, l.editorial, l.anio_edicion, " +
            "       f.id AS ficha_id, f.isbn, f.clasificacion_dewey, f.estanteria, f.idioma, f.eliminado AS ficha_eliminado " +
            "FROM libro l LEFT JOIN ficha_bibliografica f ON l.ficha_id = f.id " +
            "WHERE l.id = ?";

    private static final String SELECT_ALL_SQL =
            "SELECT l.id, l.eliminado, l.titulo, l.autor, l.editorial, l.anio_edicion, " +
            "       f.id AS ficha_id, f.isbn, f.clasificacion_dewey, f.estanteria, f.idioma, f.eliminado AS ficha_eliminado " +
            "FROM libro l LEFT JOIN ficha_bibliografica f ON l.ficha_id = f.id " +
            "WHERE l.eliminado = FALSE";

    private static final String UPDATE_SQL =
            "UPDATE libro SET titulo = ?, autor = ?, editorial = ?, anio_edicion = ?, ficha_id = ? WHERE id = ?";

    private static final String DELETE_SQL =
            "UPDATE libro SET eliminado = TRUE WHERE id = ?";

    private static final String SEARCH_SQL =
            "SELECT l.id, l.eliminado, l.titulo, l.autor, l.editorial, l.anio_edicion, " +
            "       f.id AS ficha_id, f.isbn, f.clasificacion_dewey, f.estanteria, f.idioma, f.eliminado AS ficha_eliminado " +
            "FROM libro l LEFT JOIN ficha_bibliografica f ON l.ficha_id = f.id " +
            "WHERE l.eliminado = FALSE AND (UPPER(l.titulo) LIKE ? OR UPPER(l.autor) LIKE ?)";

    @Override
    public Libro crear(Connection conn, Libro libro) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(INSERT_SQL, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, libro.getTitulo());
            ps.setString(2, libro.getAutor());
            ps.setString(3, libro.getEditorial());
            if (libro.getAnioEdicion() != null) {
                ps.setInt(4, libro.getAnioEdicion());
            } else {
                ps.setNull(4, Types.INTEGER);
            }
            if (libro.getFichaBibliografica() != null && libro.getFichaBibliografica().getId() != null) {
                ps.setLong(5, libro.getFichaBibliografica().getId());
            } else {
                ps.setNull(5, Types.BIGINT);
            }
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    libro.setId(rs.getLong(1));
                }
            }
        }
        return libro;
    }

    @Override
    public Libro leer(Connection conn, Long id) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(SELECT_BY_ID_SQL)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    @Override
    public List<Libro> leerTodos(Connection conn) throws SQLException {
        List<Libro> lista = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(SELECT_ALL_SQL);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(mapRow(rs));
            }
        }
        return lista;
    }

    @Override
    public void actualizar(Connection conn, Libro libro) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(UPDATE_SQL)) {
            ps.setString(1, libro.getTitulo());
            ps.setString(2, libro.getAutor());
            ps.setString(3, libro.getEditorial());
            if (libro.getAnioEdicion() != null) {
                ps.setInt(4, libro.getAnioEdicion());
            } else {
                ps.setNull(4, Types.INTEGER);
            }
            if (libro.getFichaBibliografica() != null && libro.getFichaBibliografica().getId() != null) {
                ps.setLong(5, libro.getFichaBibliografica().getId());
            } else {
                ps.setNull(5, Types.BIGINT);
            }
            ps.setLong(6, libro.getId());
            ps.executeUpdate();
        }
    }

    @Override
    public void eliminar(Connection conn, Long id) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(DELETE_SQL)) {
            ps.setLong(1, id);
            ps.executeUpdate();
        }
    }

    @Override
    public List<Libro> buscarPorTituloOAutor(Connection conn, String filtro) throws SQLException {
        List<Libro> lista = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(SEARCH_SQL)) {
            String pattern = "%" + filtro.toUpperCase() + "%";
            ps.setString(1, pattern);
            ps.setString(2, pattern);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(mapRow(rs));
                }
            }
        }
        return lista;
    }

    private Libro mapRow(ResultSet rs) throws SQLException {
        FichaBibliografica ficha = null;
        Long fichaId = rs.getLong("ficha_id");
        if (!rs.wasNull()) {
            ficha = new FichaBibliografica();
            ficha.setId(fichaId);
            ficha.setEliminado(rs.getBoolean("ficha_eliminado"));
            ficha.setIsbn(rs.getString("isbn"));
            ficha.setClasificacionDewey(rs.getString("clasificacion_dewey"));
            ficha.setEstanteria(rs.getString("estanteria"));
            ficha.setIdioma(rs.getString("idioma"));
        }

        Libro l = new Libro();
        l.setId(rs.getLong("id"));
        l.setEliminado(rs.getBoolean("eliminado"));
        l.setTitulo(rs.getString("titulo"));
        l.setAutor(rs.getString("autor"));
        l.setEditorial(rs.getString("editorial"));
        int anio = rs.getInt("anio_edicion");
        l.setAnioEdicion(rs.wasNull() ? null : anio);
        l.setFichaBibliografica(ficha);
        return l;
    }
}
