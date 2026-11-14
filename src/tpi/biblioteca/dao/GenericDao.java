package tpi.biblioteca.dao;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

public interface GenericDao<T> {

    T crear(Connection conn, T entity) throws SQLException;

    T leer(Connection conn, Long id) throws SQLException;

    List<T> leerTodos(Connection conn) throws SQLException;

    void actualizar(Connection conn, T entity) throws SQLException;

    void eliminar(Connection conn, Long id) throws SQLException;
}
