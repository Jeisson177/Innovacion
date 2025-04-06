
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Agregar producto a favoritos
  Future<void> agregarAFavoritos(String productoId, String clienteId) async {
    try {
      await _db.collection('favoritos').add({
        'productoId': productoId,
        'clienteId': clienteId,
        'fechaAgregado': DateTime.now(),
      });
    } catch (e) {
      print("Error al agregar a favoritos: $e");
    }
  }

  // Obtener favoritos de un cliente
  Future<List<String>> obtenerFavoritos(String clienteId) async {
    try {
      QuerySnapshot snapshot = await _db.collection('favoritos').where('clienteId', isEqualTo: clienteId).get();
      return snapshot.docs.map((doc) => doc['productoId'] as String).toList();
    } catch (e) {
      print("Error al obtener favoritos: $e");
      return [];
    }
  }
}
