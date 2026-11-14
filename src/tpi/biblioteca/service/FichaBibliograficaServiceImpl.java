package tpi.biblioteca.service;

import tpi.biblioteca.config.DatabaseConnection;
import tpi.biblioteca.dao.FichaBibliograficaDao;
import tpi.biblioteca.dao.JdbcFichaBibliograficaDao;
import tpi.biblioteca.entities.FichaBibliografica;

import java.sql.Connection;
import java.util.List;

public class FichaBibliograficaServiceImpl implements FichaBibliograficaService {

    private final FichaBibliograficaDao fichaDao = new JdbcFichaBibliograficaDao();

    @Override
    public FichaBibliografica insertar(FichaBibliografica f) throws Exception {
        validar(f);
        try (Connection conn = DatabaseConnection.getConnection()) {
            return fichaDao.crear(conn, f);
        }
    }

    @Override
    public FichaBibliografica actualizar(FichaBibliografica f) throws Exception {
        if (f.getId() == null || f.getId() <= 0) {
            throw new IllegalArgumentException("ID de ficha inválido");
        }
        validar(f);
        try (Connection conn = DatabaseConnection.getConnection()) {
            fichaDao.actualizar(conn, f);
            return f;
        }
    }

    @Override
    public void eliminar(Long id) throws Exception {
        if (id == null || id <= 0) throw new IllegalArgumentException("ID inválido");
        try (Connection conn = DatabaseConnection.getConnection()) {
            fichaDao.eliminar(conn, id);
        }
    }

    @Override
    public FichaBibliografica getById(Long id) throws Exception {
        try (Connection conn = DatabaseConnection.getConnection()) {
            return fichaDao.leer(conn, id);
        }
    }

    @Override
    public List<FichaBibliografica> getAll() throws Exception {
        try (Connection conn = DatabaseConnection.getConnection()) {
            return fichaDao.leerTodos(conn);
        }
    }

    @Override
    public FichaBibliografica getByIsbn(String isbn) throws Exception {
        try (Connection conn = DatabaseConnection.getConnection()) {
            return fichaDao.buscarPorIsbn(conn, isbn.trim());
        }
    }

    private void validar(FichaBibliografica f) {
        if (f.getIsbn() != null) f.setIsbn(f.getIsbn().trim());
        if (f.getEstanteria() != null) f.setEstanteria(f.getEstanteria().trim());
        if (f.getClasificacionDewey() != null) f.setClasificacionDewey(f.getClasificacionDewey().trim());
        if (f.getIdioma() != null) f.setIdioma(f.getIdioma().trim());
        // Podés agregar validaciones más estrictas de formato de ISBN si querés.
    }
}
