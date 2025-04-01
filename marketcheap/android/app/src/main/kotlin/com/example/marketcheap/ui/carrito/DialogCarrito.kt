@Composable
fun DialogCarrito(
    viewModel: CarritoViewModel,  // Recibe el ViewModel que gestiona el estado
    onDismiss: () -> Unit        // Función para cerrar el diálogo
) {
    // Crea un diálogo de Material Design
    AlertDialog(
        onDismissRequest = onDismiss,  // Se cierra al tocar fuera o presionar "back"
        title = { Text("Tu Carrito") }, // Título del diálogo
        text = {
            Column {
                // Itera sobre cada producto en el carrito
                viewModel.carrito.entries.forEach { (producto, cantidad) ->
                    Row(              // Fila para cada producto
                        verticalAlignment = Alignment.CenterVertically,
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        // Nombre y precio del producto
                        Text(
                            "${producto.nombre} - $${producto.precio}",
                            modifier = Modifier.weight(1f)
                        )
                        
                        // Botón para disminuir cantidad
                        IconButton(
                            onClick = {
                                viewModel.actualizarCantidad(producto, cantidad - 1)
                            }
                        ) {
                            Icon(Icons.Default.Remove, "-")
                        }
                        
                        // Muestra la cantidad actual
                        Text("$cantidad")
                        
                        // Botón para aumentar cantidad
                        IconButton(
                            onClick = {
                                viewModel.actualizarCantidad(producto, cantidad + 1)
                            }
                        ) {
                            Icon(Icons.Default.Add, "+")
                        }
                    }
                }
                
                // Línea divisoria
                Divider()
                
                // Muestra el total calculado
                Text(
                    "Total: $${viewModel.calcularTotal()}",
                    style = MaterialTheme.typography.h6,
                    modifier = Modifier.align(Alignment.End)
                )
            }
        },
        // Botón de confirmación (en este caso solo para cerrar)
        confirmButton = {
            Button(onClick = onDismiss) {
                Text("Cerrar")
            }
        }
    )
}