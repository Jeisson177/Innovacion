import 'package:flutter/material.dart';

class Producto {
  final String imagen;
  final String titulo;
  final String descripcion;
  final String precio;

  Producto({
    required this.imagen,
    required this.titulo,
    required this.descripcion,
    required this.precio,
  });
}

class CartItem {
  final Producto producto;
  int cantidad;

  CartItem({required this.producto, this.cantidad = 1});
}

class ShoppingCart extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  void addItem(Producto producto) {
    final existingIndex = _items.indexWhere((item) => item.producto.titulo == producto.titulo);
    
    if (existingIndex >= 0) {
      _items[existingIndex].cantidad++;
    } else {
      _items.add(CartItem(producto: producto));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.producto.titulo == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int newQuantity) {
    final index = _items.indexWhere((item) => item.producto.titulo == productId);
    if (index >= 0) {
      _items[index].cantidad = newQuantity;
      notifyListeners();
    }
  }

  double get total {
    return _items.fold(0, (sum, item) {
      final price = double.parse(item.producto.precio.replaceAll(RegExp(r'[^0-9.]'), ''));
      return sum + (price * item.cantidad);
    });
  }

  static ShoppingCart of(BuildContext context) {
    return Provider.of<ShoppingCart>(context, listen: false);
  }
}