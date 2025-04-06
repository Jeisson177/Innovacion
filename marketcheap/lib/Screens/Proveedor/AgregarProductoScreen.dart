import 'package:flutter/material.dart';
import 'package:marketcheap/services/ProductoService.dart';

import '../../entities/Producto.dart';


class AgregarProductoScreen extends StatefulWidget {
  const AgregarProductoScreen({super.key});

  @override
  _AgregarProductoScreenState createState() => _AgregarProductoScreenState();
}

class _AgregarProductoScreenState extends State<AgregarProductoScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();
  final TextEditingController _imagenUrlController = TextEditingController();

  final ProductoService _productoService = ProductoService();

  Future<void> _guardarProducto() async {
    final nombre = _nombreController.text.trim();
    final marca = _marcaController.text.trim();
    final precio = double.tryParse(_precioController.text.trim()) ?? 0.0;
    final descripcion = _descripcionController.text.trim();
    final categoria = _categoriaController.text.trim();
    final imagenUrl = _imagenUrlController.text.trim();

    if (nombre.isEmpty || marca.isEmpty || precio <= 0.0 || descripcion.isEmpty || categoria.isEmpty || imagenUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Todos los campos son obligatorios')));
      return;
    }

    Producto producto = Producto(
      id: DateTime.now().toString(), // ID único para el producto
      nombre: nombre,
      marca: marca,
      tienda: 'NombreTienda',  // Este valor debería ser el nombre del proveedor
      precio: precio,
      descripcion: descripcion,
      categoria: categoria,
      cantidadDisponible: 100,  // Puedes ajustar la cantidad disponible según lo que necesites
      imagenUrl: imagenUrl,
      valoraciones: [],
    );

    try {
      await _productoService.saveProducto(producto);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Producto agregado')));
      Navigator.pop(context); // Volver a la pantalla anterior
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar producto: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Producto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre del producto'),
              ),
              TextField(
                controller: _marcaController,
                decoration: const InputDecoration(labelText: 'Marca del producto'),
              ),
              TextField(
                controller: _precioController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Precio'),
              ),
              TextField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              TextField(
                controller: _categoriaController,
                decoration: const InputDecoration(labelText: 'Categoría'),
              ),
              TextField(
                controller: _imagenUrlController,
                decoration: const InputDecoration(labelText: 'Imagen URL'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarProducto,
                child: const Text('Guardar Producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
