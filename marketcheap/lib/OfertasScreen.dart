import 'package:flutter/material.dart';
import 'package:marketcheap/ProductList.dart';
import 'package:marketcheap/ShoppinfCart.dart';

class OfertasScreen extends StatelessWidget {
  final List<Producto> ofertas = [
    Producto(
      imagen: 'assets/images/oferta1.jpg',
      titulo: 'Detergente 3x2',
      descripcion: 'Oferta válida hasta agotar stock - Tienda LimpiaPlus',
      precio: '\$22.999',
    ),
    Producto(
      imagen: 'assets/images/oferta2.jpg',
      titulo: 'Arroz Roa x5kg',
      descripcion: 'Precio especial hoy - SuperAhorro',
      precio: '\$17.800',
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