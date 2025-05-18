import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:marketcheap/entities/Producto.dart';
import 'package:marketcheap/entities/Proveedor.dart';

import 'GeocodingService.dart';

// Clase para productos con distancia (definida fuera de ProductoService)
class ProductoConDistancia {
  final Producto producto;
  final double distanciaKm;
  final String direccionTienda;
  final String nombreTienda;

  ProductoConDistancia({
    required this.producto,
    required this.distanciaKm,
    required this.direccionTienda,
    required this.nombreTienda,
  });
}

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

  Future<List<Producto>> getProductos({String? tienda}) async {
  try {
    Query query = _db.collection('productos');
    
    if (tienda != null) {
      query = query.where('tienda', isEqualTo: tienda);
    }

    QuerySnapshot querySnapshot = await query.get();

    return querySnapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return Producto(
        id: doc.id,
        nombre: data['nombre'] ?? '',
        marca: data['marca'] ?? '',
        tienda: data['tienda'] ?? '',
        precio: (data['precio'] as num).toDouble(), // Conversión segura
        descripcion: data['descripcion'] ?? '',
        categoria: data['categoria'] ?? '',
        cantidadDisponible: data['cantidadDisponible'] ?? 0,
        imagenUrl: data['imagenUrl'] ?? '',
        valoraciones: List<double>.from(data['valoraciones']?.map((v) => v.toDouble()) ?? []),
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

  // [Métodos para filtrado por proximidad]
  Future<List<ProductoConDistancia>> getProductosCercanos(
      String direccionUsuario, {
        double radioKm = 5.0,
      }) async {
    try {
      final ubicacionUsuario = await GeocodingService.addressToLatLng(direccionUsuario);
      if (ubicacionUsuario == null) throw Exception("No se pudo geocodificar la dirección");

      final productos = await getProductos();
      final proveedores = await _getProveedoresConUbicacion();

      final productosConDistancia = await _calcularDistancias(
        productos,
        proveedores,
        ubicacionUsuario,
        radioKm,
      );

      productosConDistancia.sort((a, b) => a.distanciaKm.compareTo(b.distanciaKm));
      return productosConDistancia;
    } catch (e) {
      print("Error al obtener productos cercanos: $e");
      throw e;
    }
  }

  Future<List<Proveedor>> _getProveedoresConUbicacion() async {
    try {
      final snapshot = await _db.collection('proveedores').get();
      List<Proveedor> proveedores = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final proveedor = Proveedor(
          id: doc.id,
          nombre: data['nombre'] ?? '',
          nombreTienda: data['nombreTienda'] ?? '',
          correoElectronico: data['correoElectronico'] ?? '',
          telefono: data['telefono'] ?? '',
          direccion: data['direccion'] ?? 'Dirección no disponible',
          descripcion: data['descripcion'] ?? '',
          productos: List<String>.from(data['productos'] ?? []),
        );

        if (data['ubicacion'] != null) {
          proveedor.ubicacion = LatLng(
            (data['ubicacion'] as GeoPoint).latitude,
            (data['ubicacion'] as GeoPoint).longitude,
          );
        } else {
          proveedor.ubicacion = await GeocodingService.addressToLatLng(proveedor.direccion);
          if (proveedor.ubicacion != null) {
            await _db.collection('proveedores').doc(doc.id).update({
              'ubicacion': GeoPoint(
                proveedor.ubicacion!.latitude,
                proveedor.ubicacion!.longitude,
              ),
            });
          }
        }
        proveedores.add(proveedor);
      }
      return proveedores;
    } catch (e) {
      print("Error al obtener proveedores: $e");
      throw e;
    }
  }

  Future<List<ProductoConDistancia>> _calcularDistancias(
      List<Producto> productos,
      List<Proveedor> proveedores,
      LatLng ubicacionUsuario,
      double radioKm,
      ) async {
    List<ProductoConDistancia> resultados = [];

    for (var producto in productos) {
      try {
        final proveedor = proveedores.firstWhere(
              (p) => p.nombreTienda == producto.tienda,
          orElse: () => Proveedor(
            id: '',
            nombre: '',
            nombreTienda: producto.tienda,
            correoElectronico: '',
            telefono: '',
            direccion: 'Dirección no disponible',
            descripcion: '',
            productos: [],
          ),
        );

        if (proveedor.ubicacion != null) {
          final distancia = Geolocator.distanceBetween(
            ubicacionUsuario.latitude,
            ubicacionUsuario.longitude,
            proveedor.ubicacion!.latitude,
            proveedor.ubicacion!.longitude,
          ) / 1000;

          if (distancia <= radioKm) {
            resultados.add(ProductoConDistancia(
              producto: producto,
              distanciaKm: distancia,
              direccionTienda: proveedor.direccion,
              nombreTienda: proveedor.nombreTienda,
            ));
          }
        }
      } catch (e) {
        print("Error procesando producto ${producto.id}: $e");
      }
    }
    return resultados;
  }



}
