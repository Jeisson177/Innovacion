import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marketcheap/Screens/Consumidor/ShoppinfCart.dart';
import 'package:marketcheap/entities/Producto.dart';

class Pedido {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double total;
  final String paymentMethod;
  final DateTime timestamp;

  Pedido({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.paymentMethod,
    required this.timestamp,
  });

  // Convert Pedido to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => {
        'productoId': item.producto.id,
        'nombre': item.producto.nombre,
        'cantidad': item.cantidad,
        'precio': item.producto.precio,
        'tienda': item.producto.tienda, // Ensure tienda is saved
        'imagenUrl': item.producto.imagenUrl, // Ensure imagenUrl is saved
      }).toList(),
      'total': total,
      'paymentMethod': paymentMethod,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  // Create a Pedido from Firestore data
  factory Pedido.fromMap(Map<String, dynamic> map, String id) {
    return Pedido(
      id: id,
      userId: map['userId'] as String,
      items: (map['items'] as List<dynamic>).map((item) => CartItem(
        producto: Producto(
          id: item['productoId'],
          nombre: item['nombre'],
          marca: item['marca'] ?? '',
          tienda: item['tienda'] ?? 'Proveedor no especificado', // Use the stored tienda value
          precio: (item['precio'] as num).toDouble(),
          descripcion: item['descripcion'] ?? '',
          categoria: item['categoria'] ?? '',
          cantidadDisponible: item['cantidadDisponible'] ?? 0,
          imagenUrl: item['imagenUrl'] ?? '', // Use the stored imagenUrl value
          valoraciones: item['valoraciones'] != null
              ? (item['valoraciones'] as List<dynamic>).cast<double>()
              : [],
        ),
        cantidad: item['cantidad'] as int,
      )).toList(),
      total: (map['total'] as num).toDouble(),
      paymentMethod: map['paymentMethod'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}