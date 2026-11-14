package tpi.biblioteca.dao;

import tpi.biblioteca.entities.FichaBibliografica;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class JdbcFichaBibliograficaDao implements FichaBibliograficaDao {

    private static final String INSERT_SQL =
            "INSERT INTO ficha_bibliografica (eliminado, isbn, clasificacion_dewey, estanteria, idioma) " +
            "VALUES (FALSE, ?, ?, ?, ?)";

    private static final String SELECT_BY_ID_SQL =
            "SELECT id, eliminado, isbn, clasificacion_dewey, estanteria, idioma " +
            "FROM ficha_bibliografica WHERE id = ?";

    private static final String SELECT_ALL_SQL =
            "SELECT id, eliminado, isbn, clasificacion_dewey, estanteria, idioma " +
            "FROM ficha_bibliografica WHERE eliminado = FALSE";

    private static final String UPDATE_SQL =
            "UPDATE ficha_bibliografica SET isbn = ?, clasificacion_dewey = ?, estanteria = ?, idioma = ? " +
            "WHERE id = ?";

    private static final String DELETE_SQL =
            "UPDATE ficha_bibliografica SET eliminado = TRUE WHERE id = ?";

    private static final String SELECT_BY_ISBN_SQL =
            "SELECT id, eliminado, isbn, clasificacion_dewey, estanteria, idioma " +
            "FROM ficha_bibliografica WHERE isbn = ? AND eliminado = FALSE";

    @Override
    public FichaBibliografica crear(Connection conn, FichaBibliografica f) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(INSERT_SQL, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, f.getIsbn());
            ps.setString(2, f.getClasificacionDewey());
            ps.setString(3, f.getEstanteria());
            ps.setString(4, f.getIdioma());
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    f.setId(rs.getLong(1));
                }
            }
        }
        return f;
    }

    @Override
    public FichaBibliografica leer(Connection conn, Long id) throws SQLException {
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
    public List<FichaBibliografica> leerTodos(Connection conn) throws SQLException {
        List<FichaBibliografica> lista = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(SELECT_ALL_SQL);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(mapRow(rs));
            }
        }
        return lista;
    }

    @Override
    public void actualizar(Connection conn, FichaBibliografica f) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(UPDATE_SQL)) {
            ps.setString(1, f.getIsbn());
            ps.setString(2, f.getClasificacionDewey());
            ps.setString(3, f.getEstanteria());
            ps.setString(4, f.getIdioma());
            ps.setLong(5, f.getId());
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
    public FichaBibliografica buscarPorIsbn(Connection conn, String isbn) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(SELECT_BY_ISBN_SQL)) {
            ps.setString(1, isbn);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    private FichaBibliografica mapRow(ResultSet rs) throws SQLException {
        FichaBibliografica f = new FichaBibliografica();
        f.setId(rs.getLong("id"));
        f.setEliminado(rs.getBoolean("eliminado"));
        f.setIsbn(rs.getString("isbn"));
        f.setClasificacionDewey(rs.getString("clasificacion_dewey"));
        f.setEstanteria(rs.getString("estanteria"));
        f.setIdioma(rs.getString("idioma"));
        return f;
    }
}
