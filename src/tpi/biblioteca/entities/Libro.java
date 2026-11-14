package tpi.biblioteca.entities;

public class Libro extends BaseEntity {

    private String titulo;
    private String autor;
    private String editorial;
    private Integer anioEdicion;
    private FichaBibliografica fichaBibliografica; // relación 1→1

    public Libro() {}

    public Libro(Long id, boolean eliminado, String titulo, String autor,
                 String editorial, Integer anioEdicion, FichaBibliografica fichaBibliografica) {
        super(id, eliminado);
        this.titulo = titulo;
        this.autor = autor;
        this.editorial = editorial;
        this.anioEdicion = anioEdicion;
        this.fichaBibliografica = fichaBibliografica;
    }

    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }

    public String getAutor() { return autor; }
    public void setAutor(String autor) { this.autor = autor; }

    public String getEditorial() { return editorial; }
    public void setEditorial(String editorial) { this.editorial = editorial; }

    public Integer getAnioEdicion() { return anioEdicion; }
    public void setAnioEdicion(Integer anioEdicion) { this.anioEdicion = anioEdicion; }

    public FichaBibliografica getFichaBibliografica() { return fichaBibliografica; }
    public void setFichaBibliografica(FichaBibliografica fichaBibliografica) { this.fichaBibliografica = fichaBibliografica; }

    @Override
    public String toString() {
        return "Libro{" +
                "id=" + id +
                ", titulo='" + titulo + '\'' +
                ", autor='" + autor + '\'' +
                ", editorial='" + editorial + '\'' +
                ", anioEdicion=" + anioEdicion +
                ", fichaBibliografica=" + (fichaBibliografica != null ? fichaBibliografica.getIsbn() : "SIN FICHA") +
                ", eliminado=" + eliminado +
                '}';
    }
}
