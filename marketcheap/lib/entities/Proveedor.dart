

class Proveedor {
  String id;
  String nombre;
  String nombreTienda;
  String correoElectronico;
  String telefono;
  String direccion;
  String descripcion;
  List<String> productos; // Lista de IDs de productos que el proveedor ha subido

  Proveedor({
    required this.id,
    required this.nombre,
    required this.nombreTienda,
    required this.correoElectronico,
    required this.telefono,
    required this.direccion,
    required this.descripcion,
    required this.productos,
  });

  // Métodos para agregar productos, etc.
}
