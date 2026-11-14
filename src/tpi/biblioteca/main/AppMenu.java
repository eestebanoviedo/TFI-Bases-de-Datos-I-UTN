package tpi.biblioteca.main;

import tpi.biblioteca.entities.FichaBibliografica;
import tpi.biblioteca.entities.Libro;
import tpi.biblioteca.service.FichaBibliograficaService;
import tpi.biblioteca.service.FichaBibliograficaServiceImpl;
import tpi.biblioteca.service.LibroService;
import tpi.biblioteca.service.LibroServiceImpl;

import java.util.List;
import java.util.Scanner;

public class AppMenu {

    private final Scanner scanner = new Scanner(System.in);
    private final LibroService libroService = new LibroServiceImpl();
    private final FichaBibliograficaService fichaService = new FichaBibliograficaServiceImpl();

    public void run() {
        boolean running = true;
        while (running) {
            mostrarMenu();
            String opcion = scanner.nextLine().trim();
            try {
                switch (opcion) {
                    case "1" -> crearLibroConFicha();
                    case "2" -> listarLibros();
                    case "3" -> buscarLibro();
                    case "4" -> actualizarLibro();
                    case "5" -> eliminarLibro();
                    case "6" -> crearFichaIndependiente();
                    case "7" -> listarFichas();
                    case "0" -> running = false;
                    default -> System.out.println("Opción inválida.");
                }
            } catch (Exception e) {
                System.out.println("Error: " + e.getMessage());
            }
        }
        System.out.println("Saliendo...");
        scanner.close();
    }

    private void mostrarMenu() {
        System.out.println("==== BIBLIOTECA ====");
        System.out.println("1) Crear libro + ficha (transaccional)");
        System.out.println("2) Listar libros");
        System.out.println("3) Buscar libro por título/autor");
        System.out.println("4) Actualizar libro");
        System.out.println("5) Eliminar libro (baja lógica)");
        System.out.println("6) Crear ficha bibliográfica independiente");
        System.out.println("7) Listar fichas bibliográficas");
        System.out.println("0) Salir");
        System.out.print("Opción: ");
    }

    private void crearLibroConFicha() throws Exception {
        System.out.println("=== Nuevo libro con ficha ===");
        System.out.print("Título: ");
        String titulo = scanner.nextLine().trim();
        System.out.print("Autor: ");
        String autor = scanner.nextLine().trim();
        System.out.print("Editorial (opcional): ");
        String editorial = scanner.nextLine().trim();
        System.out.print("Año edición (opcional): ");
        String anioStr = scanner.nextLine().trim();
        Integer anio = anioStr.isEmpty() ? null : Integer.parseInt(anioStr);

        System.out.println("=== Ficha bibliográfica ===");
        System.out.print("ISBN (opcional pero recomendado): ");
        String isbn = scanner.nextLine().trim();
        System.out.print("Clasificación Dewey (opcional): ");
        String dewey = scanner.nextLine().trim();
        System.out.print("Estantería (opcional): ");
        String estanteria = scanner.nextLine().trim();
        System.out.print("Idioma (opcional): ");
        String idioma = scanner.nextLine().trim();

        FichaBibliografica ficha = new FichaBibliografica();
        ficha.setIsbn(isbn.isEmpty() ? null : isbn);
        ficha.setClasificacionDewey(dewey.isEmpty() ? null : dewey);
        ficha.setEstanteria(estanteria.isEmpty() ? null : estanteria);
        ficha.setIdioma(idioma.isEmpty() ? null : idioma);

        Libro libro = new Libro();
        libro.setTitulo(titulo);
        libro.setAutor(autor);
        libro.setEditorial(editorial.isEmpty() ? null : editorial);
        libro.setAnioEdicion(anio);
        libro.setFichaBibliografica(ficha);

        libroService.insertarConFicha(libro);
        System.out.println("Libro creado con ID: " + libro.getId() +
                " y ficha ID: " + libro.getFichaBibliografica().getId());
    }

    private void listarLibros() throws Exception {
        List<Libro> libros = libroService.getAll();
        if (libros.isEmpty()) {
            System.out.println("No hay libros.");
            return;
        }
        libros.forEach(System.out::println);
    }

    private void buscarLibro() throws Exception {
        System.out.print("Ingrese texto a buscar (título o autor): ");
        String filtro = scanner.nextLine().trim();
        if (filtro.isEmpty()) {
            System.out.println("El texto no puede estar vacío.");
            return;
        }
        List<Libro> libros = libroService.buscarPorTituloOAutor(filtro);
        if (libros.isEmpty()) {
            System.out.println("No se encontraron libros.");
            return;
        }
        libros.forEach(System.out::println);
    }

    private void actualizarLibro() throws Exception {
        System.out.print("ID de libro a actualizar: ");
        Long id = Long.parseLong(scanner.nextLine().trim());
        Libro libro = libroService.getById(id);
        if (libro == null) {
            System.out.println("No se encontró libro con ID: " + id);
            return;
        }

        System.out.println("Dejar vacío para mantener el valor actual.");
        System.out.println("Título actual: " + libro.getTitulo());
        System.out.print("Nuevo título: ");
        String titulo = scanner.nextLine().trim();
        if (!titulo.isEmpty()) libro.setTitulo(titulo);

        System.out.println("Autor actual: " + libro.getAutor());
        System.out.print("Nuevo autor: ");
        String autor = scanner.nextLine().trim();
        if (!autor.isEmpty()) libro.setAutor(autor);

        System.out.println("Editorial actual: " + libro.getEditorial());
        System.out.print("Nueva editorial: ");
        String editorial = scanner.nextLine().trim();
        if (!editorial.isEmpty()) libro.setEditorial(editorial);

        System.out.println("Año edición actual: " + libro.getAnioEdicion());
        System.out.print("Nuevo año (vacío = mantener): ");
        String anioStr = scanner.nextLine().trim();
        if (!anioStr.isEmpty()) libro.setAnioEdicion(Integer.parseInt(anioStr));

        libroService.actualizar(libro);
        System.out.println("Libro actualizado.");
    }

    private void eliminarLibro() throws Exception {
        System.out.print("ID de libro a eliminar: ");
        Long id = Long.parseLong(scanner.nextLine().trim());
        libroService.eliminar(id);
        System.out.println("Libro eliminado (baja lógica).");
    }

    private void crearFichaIndependiente() throws Exception {
        System.out.println("=== Nueva ficha bibliográfica ===");
        System.out.print("ISBN: ");
        String isbn = scanner.nextLine().trim();
        System.out.print("Clasificación Dewey: ");
        String dewey = scanner.nextLine().trim();
        System.out.print("Estantería: ");
        String estanteria = scanner.nextLine().trim();
        System.out.print("Idioma: ");
        String idioma = scanner.nextLine().trim();

        FichaBibliografica ficha = new FichaBibliografica();
        ficha.setIsbn(isbn.isEmpty() ? null : isbn);
        ficha.setClasificacionDewey(dewey.isEmpty() ? null : dewey);
        ficha.setEstanteria(estanteria.isEmpty() ? null : estanteria);
        ficha.setIdioma(idioma.isEmpty() ? null : idioma);

        fichaService.insertar(ficha);
        System.out.println("Ficha creada con ID: " + ficha.getId());
    }

    private void listarFichas() throws Exception {
        List<FichaBibliografica> fichas = fichaService.getAll();
        if (fichas.isEmpty()) {
            System.out.println("No hay fichas.");
            return;
        }
        fichas.forEach(System.out::println);
    }
}
