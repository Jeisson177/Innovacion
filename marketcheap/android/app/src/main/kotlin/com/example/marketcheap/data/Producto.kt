data class Producto(
    val id: String,
    val nombre: String,
    val precio: Double,
    val imagenUrl: String,
    val enOferta: Boolean = false
)