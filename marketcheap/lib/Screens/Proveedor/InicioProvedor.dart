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
  void _navigateToAgregarProducto() async {
  final result = await Navigator.pushNamed(context, '/agregar_producto');
  
    _loadProductos();
  
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
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>_navigateToEditarProducto(producto),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _deleteProducto(producto.id);
                                  },
                                ),
                              ]

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
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.delete_forever, color: Colors.red),
          label: 'Eliminar Cuenta',
        ),
      ],
      onTap: (index) {
        if (index == 1) {
          _eliminarCuenta();
        }
      },
    ),


    );
  }
  // Navegar a la pantalla de edición de producto
  void _navigateToEditarProducto(Producto producto) {
    Navigator.pushNamed(
      context,
      '/editar_producto', 
      arguments: producto, 
    ).then((_) {
      _loadProductos();
    });
  }
  //eliminar cuenta desde inicio , se puede cambiar despues

  Future<void> _eliminarCuenta() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que quieres eliminar tu cuenta permanentemente? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Primero eliminar los productos asociados a esta tienda
          final doc = await FirebaseFirestore.instance
              .collection('proveedores')
              .doc(user.uid)
              .get();
          
          final storeName = doc['storeName'];
          
          // Eliminar todos los productos de esta tienda
          final querySnapshot = await FirebaseFirestore.instance
              .collection('productos')
              .where('tienda', isEqualTo: storeName)
              .get();
          
          final batch = FirebaseFirestore.instance.batch();
          for (var doc in querySnapshot.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();
          
          // Luego eliminar el documento del proveedor
          await FirebaseFirestore.instance
              .collection('proveedores')
              .doc(user.uid)
              .delete();
          
          // Finalmente eliminar la cuenta de autenticación
          await user.delete();
          
          // Cerrar sesión y redirigir al login
          await FirebaseAuth.instance.signOut();
          
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context, 
              '/login', 
              (route) => false
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cuenta eliminada permanentemente')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar cuenta: $e')),
          );
        }
      }
    }
  }


}
