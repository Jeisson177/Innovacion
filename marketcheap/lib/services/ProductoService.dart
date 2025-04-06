

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marketcheap/entities/Producto.dart';

class ProductoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Guardar un producto en Firestore
  Future<void> saveProducto(Producto producto) async {
    try {
      await _db.collection('productos').doc(producto.id).set({
        'nombre': producto.nombre,
        'marca': producto.marca,
        'tienda': producto.tienda,
        'precio': producto.precio,
        'descripcion': producto.descripcion,
        'categoria': producto.categoria,
        'cantidadDisponible': producto.cantidadDisponible,
        'imagenUrl': producto.imagenUrl,
        'valoraciones': producto.valoraciones,
      });
    } catch (e) {
      print("Error al guardar producto: $e");
    }
  }

  // Obtener un producto por su ID
  Future<Producto?> getProducto(String productoId) async {
    try {
      DocumentSnapshot doc = await _db.collection('productos').doc(productoId).get();
      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        return Producto(
          id: productoId,
          nombre: data['nombre'],
          marca: data['marca'],
          tienda: data['tienda'],
          precio: data['precio'],
          descripcion: data['descripcion'],
          categoria: data['categoria'],
          cantidadDisponible: data['cantidadDisponible'],
          imagenUrl: data['imagenUrl'],
          valoraciones: List<double>.from(data['valoraciones']),
        );
      }
    } catch (e) {
      print("Error al obtener producto: $e");
    }
    return null;
  }

  Future<List<Producto>> getProductos() async {
    try {
      QuerySnapshot querySnapshot = await _db.collection('productos').get();
      return querySnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return Producto(
          id: doc.id,
          nombre: data['nombre'],
          marca: data['marca'],
          tienda: data['tienda'],
          precio: data['precio'],
          descripcion: data['descripcion'],
          categoria: data['categoria'],
          cantidadDisponible: data['cantidadDisponible'],
          imagenUrl: data['imagenUrl'],
          valoraciones: List<double>.from(data['valoraciones']),
        );
      }).toList();
    } catch (e) {
      print("Error al obtener productos: $e");
      return [];
    }
  }

  Future<void> updateProducto(Producto producto) async {
    try {
      await _db.collection('productos').doc(producto.id).update({
        'nombre': producto.nombre,
        'marca': producto.marca,
        'tienda': producto.tienda,
        'precio': producto.precio,
        'descripcion': producto.descripcion,
        'categoria': producto.categoria,
        'cantidadDisponible': producto.cantidadDisponible,
        'imagenUrl': producto.imagenUrl,
        'valoraciones': producto.valoraciones,
      });
    } catch (e) {
      print("Error al actualizar producto: $e");
    }
  }

  Future<void> deleteProducto(String productoId) async {
    try {
      await _db.collection('productos').doc(productoId).delete();
    } catch (e) {
      print("Error al eliminar producto: $e");
    }
  }


}
