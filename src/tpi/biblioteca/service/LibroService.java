package tpi.biblioteca.service;

import tpi.biblioteca.entities.Libro;

import java.util.List;

public interface LibroService extends GenericService<Libro> {

    Libro insertarConFicha(Libro libro) throws Exception;

    Libro insertarConFichaConRetry(Libro libro, int maxReintentos, long backoffMs) throws Exception;

    List<Libro> buscarPorTituloOAutor(String filtro) throws Exception;
}

