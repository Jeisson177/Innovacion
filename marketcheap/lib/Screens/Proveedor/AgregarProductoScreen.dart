import 'package:flutter/material.dart';
import 'package:marketcheap/services/ProductoService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final TextEditingController _cantidadController = TextEditingController();

  final ProductoService _productoService = ProductoService();

  Future<void> _guardarProducto() async {
    final nombre = _nombreController.text.trim();
    final marca = _marcaController.text.trim();
    final precio = double.tryParse(_precioController.text.trim()) ?? 0.0;
    final descripcion = _descripcionController.text.trim();
    final categoria = _categoriaController.text.trim();
    final imagenUrl = _imagenUrlController.text.trim();
    final cantidad = int.tryParse(_cantidadController.text.trim()) ?? 0;

    if (nombre.isEmpty || marca.isEmpty || precio <= 0.0 || descripcion.isEmpty || categoria.isEmpty || imagenUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Todos los campos son obligatorios')));
      return;
    }

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        throw Exception('Usuario no autenticado');
      }

      final doc = await FirebaseFirestore.instance.collection('proveedores').doc(uid).get();
      final storeName = doc['storeName'] ?? '';

      if (storeName.isEmpty) {
        throw Exception('El proveedor no tiene un nombre de tienda asignado');
      }

      Producto producto = Producto(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: nombre,
        marca: marca,
        tienda: storeName,
        precio: precio,
        descripcion: descripcion,
        categoria: categoria,
        cantidadDisponible: cantidad,
        imagenUrl: imagenUrl,
        valoraciones: [],
      );

      await _productoService.saveProducto(producto);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Producto agregado')));
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar producto: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Producto',
        style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _guardarProducto,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F5F5), Color(0xFFE0F7E0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(_nombreController, 'Nombre del producto', Icons.local_offer),
                      _buildTextField(_marcaController, 'Marca del producto', Icons.store),
                      _buildTextField(_cantidadController, 'Cantidad en stock', Icons.inventory, keyboardType: TextInputType.number),
                      _buildTextField(_precioController, 'Precio', Icons.attach_money, keyboardType: TextInputType.number),
                      _buildTextField(_descripcionController, 'Descripción', Icons.description),
                      _buildTextField(_categoriaController, 'Categoría', Icons.category),
                      _buildTextField(_imagenUrlController, 'Imagen URL', Icons.image),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarProducto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Guardar Producto', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.green),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _marcaController.dispose();
    _precioController.dispose();
    _descripcionController.dispose();
    _categoriaController.dispose();
    _imagenUrlController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }
}