package tpi.biblioteca.entities;

public abstract class BaseEntity {
    protected Long id;
    protected boolean eliminado;

    public BaseEntity() {
        this.eliminado = false;
    }

    public BaseEntity(Long id, boolean eliminado) {
        this.id = id;
        this.eliminado = eliminado;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public boolean isEliminado() { return eliminado; }
    public void setEliminado(boolean eliminado) { this.eliminado = eliminado; }
}
