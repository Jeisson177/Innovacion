import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marketcheap/Screens/Consumidor/ShoppinfCart.dart';
import 'package:marketcheap/services/ProductoService.dart';
import '../../entities/Producto.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  _InicioScreenState createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  final ProductoService _productoService = ProductoService();
  List<Producto> _productos = [];

  @override
  void initState() {
    super.initState();
    _loadProductos();
  }

  // Cargar los productos desde Firestore
  Future<void> _loadProductos() async {
    List<Producto> productos = await _productoService.getProductos();
    setState(() {
      _productos = productos;
    });
  }

  // Obtener la dirección del usuario desde Firestore
  Future<String?> _obtenerDireccion() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
    if (doc.exists) {
      return doc.data()?['address'] ?? 'Sin dirección registrada';
    } else {
      return 'Sin dirección registrada';
    }
  }

  // Crear el tile de producto
  Widget _productoTile(BuildContext context, Producto producto) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFDED7D7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Image.network(producto.imagenUrl, width: 80, height: 80),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  producto.nombre,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(producto.descripcion, style: const TextStyle(fontSize: 14)),
                Text(
                  '\$${producto.precio.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Image.asset('assets/icons/ic_add.png', width: 30, height: 30),
            onPressed: () {
              final cartItem = Producto(
                id: producto.id,
                nombre: producto.nombre,
                marca: producto.marca,
                tienda: producto.tienda,
                precio: producto.precio,
                descripcion: producto.descripcion,
                categoria: producto.categoria,
                cantidadDisponible: producto.cantidadDisponible,
                imagenUrl: producto.imagenUrl,
                valoraciones: producto.valoraciones,
              );
              ShoppingCart.of(context).addItem(cartItem);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${producto.nombre} agregado al carrito'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar con dirección dinámica
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 98, 195, 107),
                    Color.fromARGB(255, 40, 132, 44),
                  ],
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white),
                  const SizedBox(width: 8),
                  FutureBuilder<String?>(
                    future: _obtenerDireccion(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text(
                          'Cargando...',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        );
                      } else if (snapshot.hasError) {
                        return const Text(
                          'Error',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        );
                      } else {
                        return Text(
                          snapshot.data ?? 'Sin dirección registrada',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        );
                      }
                    },
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Image.asset(
                      'assets/icons/ic_cart.png',
                      width: 24,
                      height: 24,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/carrito');
                    },
                  ),
                ],
              ),
            ),

            // Search bar
            Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Ingrese producto/tienda',
                  contentPadding: EdgeInsets.all(10),
                  border: InputBorder.none,
                ),
              ),
            ),

            // Promo banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 98, 195, 107),
                    Color.fromARGB(255, 40, 132, 44),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Image.asset('assets/icons/ic_megaphone.png', width: 50, height: 50),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Martes de limpieza\nTienda 'Doña Marta'\n2x1 en jabones y detergentes seleccionados",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            // Lista de productos
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: _productos.length,
                itemBuilder: (context, index) {
                  return _productoTile(context, _productos[index]);
                },
              ),
            ),

            // Bottom nav
            Container(
              height: 60,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 98, 195, 107),
                    Color.fromARGB(255, 40, 132, 44),
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _navButton(
                    context,
                    iconPath: 'assets/icons/ic_home.png',
                    onTap: () {}, // Ya estás en inicio
                  ),
                  _navButton(
                    context,
                    iconPath: 'assets/icons/ic_search.png',
                    onTap: () {
                      Navigator.pushNamed(context, '/mapa');
                    },
                  ),
                  _navButton(
                    context,
                    iconPath: 'assets/icons/ic_favorites.png',
                    onTap: () {
                      // Acción para ofertas
                    },
                  ),
                  _navButton(
                    context,
                    iconPath: 'assets/icons/ic_profile.png',
                    onTap: () {
                      Navigator.pushNamed(context, '/perfil');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navButton(BuildContext context, {required String iconPath, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: const Color.fromARGB(59, 9, 2, 2),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Image.asset(iconPath, width: 30, height: 30),
      ),
    );
  }
}
