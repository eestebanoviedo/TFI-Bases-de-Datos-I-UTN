package tpi.biblioteca.dao;

import tpi.biblioteca.entities.FichaBibliografica;

public interface FichaBibliograficaDao extends GenericDao<FichaBibliografica> {

    FichaBibliografica buscarPorIsbn(java.sql.Connection conn, String isbn) throws java.sql.SQLException;
}
