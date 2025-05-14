import 'package:google_maps_flutter/google_maps_flutter.dart';

class Proveedor {
  String id;
  String nombre;
  String nombreTienda;
  String correoElectronico;
  String telefono;
  String direccion;
  String descripcion;
  List<String> productos;
  LatLng? ubicacion; // Nueva propiedad para coordenadas

  Proveedor({
    required this.id,
    required this.nombre,
    required this.nombreTienda,
    required this.correoElectronico,
    required this.telefono,
    required this.direccion,
    required this.descripcion,
    required this.productos,
    this.ubicacion, // Añadido al constructor
  });
}