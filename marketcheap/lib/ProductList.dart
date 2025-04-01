import 'package:flutter/material.dart';
import 'package:marketcheap/ShoppinfCart.dart';
import 'package:provider/provider.dart';

class ProductList extends StatelessWidget {
  final List<Producto> productos;

  const ProductList({super.key, required this.productos});

  @override
  Widget build(BuildContext context) {
    final cart = ShoppingCart.of(context);

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: productos.length,
      itemBuilder: (context, index) {
        final producto = productos[index];
        return _ItemProducto(
          producto: producto,
          onAddToCart: () => cart.addItem(producto),
        );
      },
    );
  }
}

class _ItemProducto extends StatelessWidget {
  final Producto producto;
  final VoidCallback onAddToCart;

  const _ItemProducto({
    required this.producto,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFDED7D7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Image.asset(producto.imagen, width: 80, height: 80),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(producto.titulo, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(producto.descripcion, 
                    style: const TextStyle(fontSize: 14)),
                Text(producto.precio, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          IconButton(
            icon: Image.asset('assets/icons/ic_add.png', width: 30, height: 30),
            onPressed: onAddToCart,
          ),
        ],
      ),
    );
  }
}