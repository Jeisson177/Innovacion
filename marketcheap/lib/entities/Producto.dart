

class Producto {
  String id;
  String nombre;
  String marca;
  String tienda; // Nombre del proveedor o tienda
  double precio;
  String descripcion;
  String categoria;
  int cantidadDisponible;
  String imagenUrl;
  List<double> valoraciones; // Lista de calificaciones

  Producto({
    required this.id,
    required this.nombre,
    required this.marca,
    required this.tienda,
    required this.precio,
    required this.descripcion,
    required this.categoria,
    required this.cantidadDisponible,
    required this.imagenUrl,
    required this.valoraciones,
  });

  // Método para agregar una valoración
  void agregarValoracion(double valoracion) {
    valoraciones.add(valoracion);
  }

  // Método para obtener la valoración promedio
  double obtenerValoracionPromedio() {
    if (valoraciones.isEmpty) return 0.0;
    double sum = valoraciones.reduce((a, b) => a + b);
    return sum / valoraciones.length;
  }
}
