class Cliente {
  String id;
  String nombre;
  String apellido;
  String direccion;
  String correoElectronico;
  String telefono;
  List<String> carrito; // Lista de IDs de productos en el carrito
  List<String> historialCompras; // Lista de IDs de productos que el cliente ya ha comprado

  Cliente({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.direccion,
    required this.correoElectronico,
    required this.telefono,
    required this.carrito,
    required this.historialCompras,
  });

  // Métodos para agregar al carrito, comprar productos, etc.
}
