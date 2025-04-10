

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:marketcheap/entities/Producto.dart';
import 'package:marketcheap/services/ProductoService.dart';  // Asegúrate de tener la clase Producto

class InicioProveedor extends StatefulWidget {
  const InicioProveedor({super.key});

  @override
  _InicioProveedorState createState() => _InicioProveedorState();
}

class _InicioProveedorState extends State<InicioProveedor> {
  final ProductoService _productoService = ProductoService();
  List<Producto> _productos = [];

  @override
  void initState() {
    super.initState();
    _loadProductos();
  }

  // Cargar los productos del proveedor
  Future<void> _loadProductos() async {
  try {
    // Obtener el UID del proveedor autenticado
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      print("No hay proveedor autenticado.");
      return;
    }

    // Obtener nombre de la tienda desde Firestore
    final doc = await FirebaseFirestore.instance.collection('proveedores').doc(uid).get();
    final nombreTienda = doc['storeName'];

    // Obtener productos que pertenezcan a esa tienda
    List<Producto> productos = await _productoService.getProductos(tienda: nombreTienda);

    setState(() {
      _productos = productos;
    });
  } catch (e) {
    print("Error al cargar productos: $e");
  }
}

  // Pantalla de agregar producto
  void _navigateToAgregarProducto() {
    Navigator.pushNamed(context, '/agregar_producto'); // Cambia a tu ruta para agregar productos
  }

  // Eliminar producto
  Future<void> _deleteProducto(String productoId) async {
    try {
      await _productoService.deleteProducto(productoId);
      setState(() {
        _productos.removeWhere((producto) => producto.id == productoId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto eliminado')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar producto: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio Proveedor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAgregarProducto,  // Navegar a la pantalla para agregar productos
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tus productos:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _productos.isEmpty
                ? const Center(child: Text('No tienes productos disponibles.'))
                : Expanded(
                    child: ListView.builder(
                      itemCount: _productos.length,
                      itemBuilder: (context, index) {
                        final producto = _productos[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: Image.network(
                              producto.imagenUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                            title: Text(producto.nombre),
                            subtitle: Text('Precio: \$${producto.precio}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteProducto(producto.id),
                            ),
                            onTap: () {
                              // Agregar funcionalidad para editar el producto si es necesario
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
