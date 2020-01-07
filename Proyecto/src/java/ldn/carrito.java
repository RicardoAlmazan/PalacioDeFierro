package ldn;

public class carrito {
    private int _idProducto;
    private int _cantidad;

    public carrito(int _idProducto, int _cantidad) {
        this._idProducto = _idProducto;
        this._cantidad = _cantidad;
    }

    public int getIdProducto() {
        return _idProducto;
    }

    public void setIdProducto(int _idProducto) {
        this._idProducto = _idProducto;
    }

    public int getCantidad() {
        return _cantidad;
    }

    public void setCantidad(int _cantidad) {
        this._cantidad = _cantidad;
    }
      
}
