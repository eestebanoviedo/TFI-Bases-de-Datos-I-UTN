package tpi.biblioteca.dao;

import tpi.biblioteca.entities.Libro;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

public interface LibroDao extends GenericDao<Libro> {

    List<Libro> buscarPorTituloOAutor(Connection conn, String filtro) throws SQLException;
}
