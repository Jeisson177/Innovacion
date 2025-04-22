import 'package:flutter/material.dart';
import 'package:marketcheap/entities/Producto.dart';
import 'package:provider/provider.dart';



class CartItem {
  final Producto producto;
  int cantidad;

  CartItem({required this.producto, this.cantidad = 1});
}

class ShoppingCart extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
  void addItem(Producto producto) {
    final existingIndex = _items.indexWhere((item) => item.producto.nombre == producto.nombre);
    
    if (existingIndex >= 0) {
      _items[existingIndex].cantidad++;
    } else {
      _items.add(CartItem(producto: producto));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.producto.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int newQuantity) {
    final index = _items.indexWhere((item) => item.producto.id == productId);
    if (index >= 0) {
      _items[index].cantidad = newQuantity;
      notifyListeners();
    }
  }

  double get total {
    return _items.fold(0, (sum, item) {
      final price = item.producto.precio;
      return sum + (price * item.cantidad);
    });
  }

  static ShoppingCart of(BuildContext context) {
    return Provider.of<ShoppingCart>(context, listen: false);
  }

  int get itemCount {
    return _items.fold(0, (sum, item) => sum + item.cantidad);
  }

  
}