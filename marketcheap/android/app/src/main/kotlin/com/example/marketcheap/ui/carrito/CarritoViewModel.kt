class CarritoViewModel : ViewModel() {
    private val _carrito = mutableStateMapOf<Producto, Int>()
    val carrito: SnapshotStateMap<Producto, Int> = _carrito
    
    fun agregarProducto(producto: Producto) {
        _carrito[producto] = _carrito.getOrDefault(producto, 0) + 1
    }
    
    fun actualizarCantidad(producto: Producto, cantidad: Int) {
        if (cantidad > 0) {
            _carrito[producto] = cantidad
        } else {
            _carrito.remove(producto)
        }
    }
    
    fun calcularTotal(): Double {
        return _carrito.entries.sumOf { it.key.precio * it.value }
    }
}