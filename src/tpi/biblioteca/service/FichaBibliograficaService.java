package tpi.biblioteca.service;

import tpi.biblioteca.entities.FichaBibliografica;

public interface FichaBibliograficaService extends GenericService<FichaBibliografica> {
    FichaBibliografica getByIsbn(String isbn) throws Exception;
}
