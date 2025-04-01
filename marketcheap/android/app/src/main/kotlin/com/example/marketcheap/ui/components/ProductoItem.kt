@Composable
fun ProductoItem(
    producto: Producto,      // Datos del producto
    onAddToCart: () -> Unit, // Función al hacer clic
    modifier: Modifier = Modifier
) {
    Card(modifier = modifier.padding(8.dp)) {
        Column {
            // Muestra la imagen desde assets
            AsyncImage(
                model = "file:///android_asset/images/${producto.imagenUrl}",
                contentDescription = producto.nombre
            )
            
            Text(text = producto.nombre) // Nombre del producto
            Text(text = "$${producto.precio}") // Precio formateado
            
            // Muestra badge si está en oferta
            if(producto.enOferta) {
                Badge { Text("OFERTA") }
            }
            
            // Botón para agregar al carrito
            Button(onClick = onAddToCart) {
                Text("Agregar al carrito")
            }
        }
    }
}