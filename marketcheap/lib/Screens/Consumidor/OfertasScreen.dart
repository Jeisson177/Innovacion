import 'package:flutter/material.dart';
import 'package:marketcheap/Screens/Consumidor/ProductList.dart';
import 'package:marketcheap/entities/Producto.dart';

class OfertasScreen extends StatelessWidget {
  final List<Producto> ofertas = [
    Producto(
      imagenUrl: 'assets/images/papel.jpg',
      nombre: 'Papel higienico 3x2, 4 rollos c/u',
      descripcion: 'Oferta válida hasta agotar stock - Tienda LimpiaPlus',
      precio: 17000,
      categoria: 'Hogar',
      cantidadDisponible: 10,
      marca: 'scott',
      tienda: 'LimpiaPlus',
      valoraciones: [4.5, 3.8, 4.2, 4.9, 5.0],
      id: '123',
    ),
    Producto(
      imagenUrl: 'assets/images/arroz.jpg',
      nombre: 'Arroz Diana x5.000g',
      descripcion: 'Precio especial hoy - SuperAhorro',
      precio: 4000,
      categoria: 'Alimentos',
      cantidadDisponible: 5,
      marca: 'Diana',
      tienda: 'SuperAhorro',
      valoraciones: [4.5, 3.8, 4.2, 4.9, 5.0],
      id: '456',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ofertas Especiales')),
      body: ProductList(productos: ofertas),
    );
  }
}