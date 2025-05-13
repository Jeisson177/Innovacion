import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:marketcheap/entities/Producto.dart';
import 'package:marketcheap/entities/Proveedor.dart';
import 'package:marketcheap/services/geocoding_service.dart';

class ProductoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Clase auxiliar para productos con información de distancia
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

  // Metodos nuevos para filtrado por proximidad

  // Obtener productos cercanos a una dirección
  Future<List<ProductoConDistancia>> getProductosCercanos(
    String direccionUsuario, {
    double radioKm = 5.0,
  }) async {
  try {
    // 1. Convertir dirección del usuario a coordenadas
    final ubicacionUsuario = await GeocodingService.addressToLatLng(direccionUsuario);
    if (ubicacionUsuario == null) {
      throw Exception("No se pudo geocodificar la dirección del usuario");
    }

    // 2. Obtener todos los productos
    final productos = await getProductos();

    // 3. Obtener proveedores con sus ubicaciones
    final proveedores = await _getProveedoresConUbicacion();

    // 4. Procesar productos con información de distancia
    final productosConDistancia = await _calcularDistancias(
      productos,
      proveedores,
      ubicacionUsuario,
      radioKm,
    );

    // 5. Ordenar por distancia (más cercano primero)
    productosConDistancia.sort((a, b) => a.distanciaKm.compareTo(b.distanciaKm));

    return productosConDistancia;
    } catch (e) {
      print("Error al obtener productos cercanos: $e");
      throw e;
    }
  }

  // Metodo auxiliar para obtener proveedores con sus ubicaciones
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

        // Si ya tiene coordenadas en Firestore
        if (data['ubicacion'] != null) {
          proveedor.ubicacion = LatLng(
            (data['ubicacion'] as GeoPoint).latitude,
            (data['ubicacion'] as GeoPoint).longitude,
          );
        } else {
        // Geocodificar la dirección si no hay coordenadas
        proveedor.ubicacion = await GeocodingService.addressToLatLng(proveedor.direccion);

        // Opcional: actualizar Firestore con las nuevas coordenadas
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
      print("Error al obtener proveedores con ubicación: $e");
      throw e;
    }
  }

  // Metodo auxiliar para calcular distancias
  Future<List<ProductoConDistancia>> _calcularDistancias(
    List<Producto> productos,
    List<Proveedor> proveedores,
    LatLng ubicacionUsuario,
    double radioKm,
  ) async {
    List<ProductoConDistancia> resultados = [];

    for (var producto in productos) {
      try {
        // Buscar el proveedor correspondiente al producto
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

        // Si el proveedor tiene ubicación, calcular distancia
        if (proveedor.ubicacion != null) {
          final distancia = Geolocator.distanceBetween(
            ubicacionUsuario.latitude,
            ubicacionUsuario.longitude,
            proveedor.ubicacion!.latitude,
            proveedor.ubicacion!.longitude,
          ) / 1000; // Convertir a kilómetros

          // Filtrar por radio
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

  // Metodo para buscar productos por nombre o categoría (nuevo)
  Future<List<Producto>> buscarProductos(String query) async {
    try {
      // Buscar por nombre
      final nombreQuery = _db.collection('productos')
          .where('nombre', isGreaterThanOrEqualTo: query)
          .where('nombre', isLessThan: query + 'z')
          .limit(10);

      // Buscar por categoría
      final categoriaQuery = _db.collection('productos')
          .where('categoria', isGreaterThanOrEqualTo: query)
          .where('categoria', isLessThan: query + 'z')
          .limit(10);

      final nombreSnapshot = await nombreQuery.get();
      final categoriaSnapshot = await categoriaQuery.get();

      // Combinar resultados evitando duplicados
      final todosDocs = {...nombreSnapshot.docs, ...categoriaSnapshot.docs};

      return todosDocs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return Producto(
          id: doc.id,
          nombre: data['nombre'] ?? '',
          marca: data['marca'] ?? '',
          tienda: data['tienda'] ?? '',
          precio: (data['precio'] as num).toDouble(),
          descripcion: data['descripcion'] ?? '',
          categoria: data['categoria'] ?? '',
          cantidadDisponible: data['cantidadDisponible'] ?? 0,
          imagenUrl: data['imagenUrl'] ?? '',
          valoraciones: List<double>.from(data['valoraciones']?.map((v) => v.toDouble()) ?? []),
        );
      }).toList();
    } catch (e) {
      print("Error al buscar productos: $e");
      throw e;
    }
  }
}
