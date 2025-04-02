import 'package:flutter/material.dart';
import 'package:marketcheap/ProductList.dart';
import 'package:marketcheap/ShoppinfCart.dart';

class OfertasScreen extends StatelessWidget {
  final List<Producto> ofertas = [
    Producto(
      imagen: 'assets/images/papel.jpg',
      titulo: 'Papel higienico 3x2, 4 rollos c/u',
      descripcion: 'Oferta válida hasta agotar stock - Tienda LimpiaPlus',
      precio: '\$17.000',
    ),
    Producto(
      imagen: 'assets/images/arroz.jpg',
      titulo: 'Arroz Diana x5.000g',
      descripcion: 'Precio especial hoy - SuperAhorro',
      precio: '\$4.000',
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