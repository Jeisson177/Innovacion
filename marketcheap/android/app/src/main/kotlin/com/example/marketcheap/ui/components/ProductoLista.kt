// Declaración del componente Composable
@Composable
fun ProductoLista(
    productos: List<Producto>,       // Parámetro 1: Lista de productos a mostrar
    onProductoClick: (Producto) -> Unit, // Parámetro 2: Función callback cuando se selecciona un producto
    modifier: Modifier = Modifier    // Parámetro 3: Modificador para personalización (opcional)
) {
    // LazyColumn es equivalente a RecyclerView (lista eficiente en memoria)
    LazyColumn(modifier = modifier) {
        // items() convierte la lista en componentes renderizables
        items(productos) { producto ->  // Itera sobre cada producto
            // Crea un ítem de producto para cada elemento
            ProductoItem(
                producto = producto,  // Pasa los datos del producto
                onAddToCart = {
                    onProductoClick(producto) // Ejecuta el callback recibido
                }
            )
        }
    }
}