import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  // Realizar pago
  Future<void> realizarPago(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Usuario no autenticado");

      // Actualizar stock
      for (final item in _items) {
        await _actualizarStockProducto(item);
      }

      // Registrar la compra en historial
      await _registrarCompra(user.uid);

      // Limpiar carrito
      _items.clear();
      notifyListeners();

      // Mensaje de confirmacion
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compra realizada con éxito')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar pago: $e')),
        );
      }
    }
  }

  Future<void> _actualizarStockProducto(CartItem item) async {
    final productRef = FirebaseFirestore.instance.collection('productos').doc(item.producto.id);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(productRef);
      if (!snapshot.exists) throw Exception("Producto no encontrado");

      final stockActual = snapshot['cantidadDisponible'] as int;
      if (stockActual < item.cantidad) {
        throw Exception("No hay suficiente stock para ${item.producto.nombre}");
      }

      transaction.update(productRef, {
        'cantidadDisponible': stockActual - item.cantidad,
      });
    });
  }

  Future<void> _registrarCompra(String userId) async {
    final compraRef = FirebaseFirestore.instance.collection('compras').doc();
    final itemsData = _items.map((item) => {
      'productoId': item.producto.id,
      'nombre': item.producto.nombre,
      'cantidad': item.cantidad,
      'precioUnitario': item.producto.precio,
      'tienda': item.producto.tienda,
    }).toList();

    await compraRef.set({
      'clienteId': userId,
      'fecha': FieldValue.serverTimestamp(),
      'items': itemsData,
      'total': total,
      'estado': 'completado',
    });

    // Actualizar historial del cliente
    final clienteRef = FirebaseFirestore.instance.collection('clientes').doc(userId);
    await clienteRef.update({
      'historialCompras': FieldValue.arrayUnion(_items.map((item) => item.producto.id).toList()),
    });
  }
}