import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:marketcheap/entities/Producto.dart';
import 'package:marketcheap/services/ProductoService.dart';

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

  Future<void> _loadProductos() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid == null) {
        print("No hay proveedor autenticado.");
        return;
      }

      final doc = await FirebaseFirestore.instance.collection('proveedores').doc(uid).get();
      final nombreTienda = doc['storeName'];

      List<Producto> productos = await _productoService.getProductos(tienda: nombreTienda);

      setState(() {
        _productos = productos;
      });
    } catch (e) {
      print("Error al cargar productos: $e");
    }
  }

  void _navigateToAgregarProducto() async {
    await Navigator.pushNamed(context, '/agregar_producto');
    _loadProductos();
  }

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

  void _navigateToEditarProducto(Producto producto) {
    Navigator.pushNamed(
      context,
      '/editar_producto',
      arguments: producto,
    ).then((_) {
      _loadProductos();
    });
  }

  void _navigateToConfiguracionProveedor() {
    Navigator.pushNamed(context, '/configurar_proveedor');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Inicio Proveedor'
        ,style: TextStyle(color: Colors.white),
        )        ,        
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAgregarProducto,
            style: IconButton.styleFrom(
              foregroundColor: Colors.white,
            ),
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
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _navigateToEditarProducto(producto),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _deleteProducto(producto.id);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.green,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Configuración de proveedor',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            _navigateToConfiguracionProveedor();
          }
        },
      ),
    );
  }
}