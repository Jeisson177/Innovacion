import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marketcheap/Screens/Consumidor/ShoppinfCart.dart';
import 'package:marketcheap/services/ProductoService.dart';
import '../../entities/Producto.dart';
import 'package:provider/provider.dart';

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

    final doc = await FirebaseFirestore.instance.collection('clientes').doc(uid).get();
    if (doc.exists) {
      return doc.data()?['address'] ?? 'Sin dirección registrada';
    } else {
      return 'Sin dirección registrada';
    }
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
                  return _ProductoTile(product: _productos[index]);
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
                      Navigator.pushNamed(context, '/valoraciones');
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

class _ProductoTile extends StatefulWidget {
  final Producto product;

  const _ProductoTile({required this.product});

  @override
  __ProductoTileState createState() => __ProductoTileState();
}

class __ProductoTileState extends State<_ProductoTile> {
  late int quantity;

  @override
  void initState() {
    super.initState();
    quantity = 1; // Default quantity when adding
  }

  void _addToCart() {
    final cart = Provider.of<ShoppingCart>(context, listen: false);
    for (int i = 0; i < quantity; i++) {
      cart.addItem(widget.product);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$quantity x ${widget.product.nombre} agregado${quantity > 1 ? 's' : ''} al carrito'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.product.imagenUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image, size: 60),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Precio: \$${widget.product.precio.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Valoración: ${widget.product.obtenerValoracionPromedio().toStringAsFixed(1)}/5',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.red,
                  onPressed: quantity > 1
                      ? () {
                          setState(() {
                            quantity--;
                          });
                        }
                      : null,
                ),
                Text(
                  quantity.toString(),
                  style: const TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: Colors.green,
                  onPressed: () {
                    setState(() {
                      quantity++;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add_shopping_cart, color: Colors.green),
                  onPressed: _addToCart,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}