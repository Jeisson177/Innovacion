import 'package:flutter/material.dart';
import 'package:marketcheap/ShoppinfCart.dart';
import 'package:provider/provider.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.green],
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text('Cra. 7 #40 - 62', style: TextStyle(color: Colors.white, fontSize: 16)),
                  const Spacer(),
                  IconButton(
                    icon: Image.asset('assets/icons/ic_cart.png', width: 24, height: 24),
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
                  colors: [Colors.white, Colors.green],
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
                  )
                ],
              ),
            ),

            // Categorías
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset('assets/icons/ic_cleaning.png', width: 50, height: 50),
                  Image.asset('assets/icons/ic_food.png', width: 50, height: 50),
                  Image.asset('assets/icons/ic_beauty.png', width: 50, height: 50),
                  Image.asset('assets/icons/ic_health.png', width: 50, height: 50),
                ],
              ),
            ),

            // Productos scrollables
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(10),
                children: [
                  _productoTile(
                    context,
                    'assets/images/chocolatina_jet.jpg',
                    'Chocolatina Jet leche',
                    'Bolsa x12 und - Tienda El Gran Bodegón',
                    '\$14.500',
                  ),
                  _productoTile(
                    context,
                    'assets/images/cafe_cappuccino.jpg',
                    'Colcafé CAPPUCCINO Vainilla',
                    '6 sobres x 13g - Tienda Ofertrones',
                    '\$5.850',
                  ),
                  _productoTile(
                    context,
                    'assets/images/huevos.png',
                    'Huevos',
                    'Canasta 30 huevos AA - Tienda Don José',
                    '\$14.500',
                  ),
                ],
              ),
            ),

            // Bottom nav
            Container(
              height: 60,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset('assets/icons/ic_home.png', width: 30),
                  Image.asset('assets/icons/ic_search.png', width: 30),
                  Image.asset('assets/icons/ic_favorites.png', width: 30),
                  Image.asset('assets/icons/ic_profile.png', width: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productoTile(BuildContext context, String image, String title, String description, String price) {
    final cart = Provider.of<ShoppingCart>(context, listen: false);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFDED7D7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Image.asset(image, width: 80, height: 80),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(description, style: const TextStyle(fontSize: 14)),
                Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          IconButton(
            icon: Image.asset('assets/icons/ic_add.png', width: 30, height: 30),
            onPressed: () {
              cart.addItem(Producto(
                imagen: image,
                titulo: title,
                descripcion: description,
                precio: price,
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$title añadido al carrito'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
