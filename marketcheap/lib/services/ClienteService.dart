
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marketcheap/entities/Cliente.dart';

class ClienteService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Guardar un cliente en Firestore
  Future<void> saveCliente(Cliente cliente) async {
    try {
      await _db.collection('clientes').doc(cliente.id).set({
        'nombre': cliente.nombre,
        'apellido': cliente.apellido,
        'direccion': cliente.direccion,
        'correoElectronico': cliente.correoElectronico,
        'telefono': cliente.telefono,
        'carrito': cliente.carrito,
        'historialCompras': cliente.historialCompras,
      });
    } catch (e) {
      print("Error al guardar cliente: $e");
    }
  }

  // Obtener un cliente por su ID
  Future<Cliente?> getCliente(String clienteId) async {
    try {
      DocumentSnapshot doc = await _db.collection('clientes').doc(clienteId).get();
      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        return Cliente(
          id: clienteId,
          nombre: data['nombre'],
          apellido: data['apellido'],
          direccion: data['direccion'],
          correoElectronico: data['correoElectronico'],
          telefono: data['telefono'],
          carrito: List<String>.from(data['carrito']),
          historialCompras: List<String>.from(data['historialCompras']),
        );
      }
    } catch (e) {
      print("Error al obtener cliente: $e");
    }
    return null;
  }

   Future<void> agregarAlCarrito(String clienteId, String productoId) async {
    try {
      DocumentReference clienteRef = FirebaseFirestore.instance.collection('clientes').doc(clienteId);
      await clienteRef.update({
        'carrito': FieldValue.arrayUnion([productoId]),
      });
    } catch (e) {
      print("Error al agregar al carrito: $e");
    }
  }

  Future<void> comprarProductos(String clienteId) async {
    try {
      DocumentReference clienteRef = FirebaseFirestore.instance.collection('clientes').doc(clienteId);
      DocumentSnapshot clienteDoc = await clienteRef.get();
      List<String> carrito = List<String>.from(clienteDoc['carrito']);
      
      // Mover productos al historial
      await clienteRef.update({
        'historialCompras': FieldValue.arrayUnion(carrito),
        'carrito': [],
      });
    } catch (e) {
      print("Error al realizar compra: $e");
    }
  }

}
