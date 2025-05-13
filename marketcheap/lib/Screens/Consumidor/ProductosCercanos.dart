import 'package:flutter/material.dart';
import 'package:marketcheap/Screens/Consumidor/ShoppinfCart.dart';
import 'package:marketcheap/entities/Producto.dart';
import 'package:provider/provider.dart';
import 'package:marketcheap/services/ProductoService.dart';

class ProductosCercanos extends StatefulWidget {
  final String direccionUsuario;

  const ProductosCercanos({super.key, required this.direccionUsuario});

  @override
  State<ProductosCercanos> createState() => _ProductosCercanosState();
}

class _ProductosCercanosState extends State<ProductosCercanos> {
  late Future<List<ProductoService.ProductoConDistancia>> _productosCercanos;
  double _radioKm = 5.0;

  @override
  void initState() {
    super.initState();
    _cargarProductosCercanos();
  }

  void _cargarProductosCercanos() {
    setState(() {
      _productosCercanos = ProductoService()
          .getProductosCercanos(widget.direccionUsuario, radioKm: _radioKm);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = ShoppingCart.of(context);

    return FutureBuilder<List<ProductoService.ProductoConDistancia>>(
      future: _productosCercanos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final productos = snapshot.data ?? [];

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  const Text('Radio: '),
                  Expanded(
                    child: Slider(
                      value: _radioKm,
                      min: 1,
                      max: 20,
                      divisions: 19,
                      label: "${_radioKm.round()} km",
                      onChanged: (value) {
                        setState(() => _radioKm = value);
                        _cargarProductosCercanos();
                      },
                    ),
                  ),
                  Text('${productos.length} productos'),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: productos.length,
                itemBuilder: (context, index) {
                  final producto = productos[index].producto;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDED7D7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Image.asset(producto.imagenUrl, width: 80, height: 80),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(producto.nombre,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(producto.descripcion,
                                  style: const TextStyle(fontSize: 14)),
                              Text('\$${producto.precio.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(
                                'A ${productos[index].distanciaKm.toStringAsFixed(1)} km',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Image.asset('assets/icons/ic_add.png', width: 30, height: 30),
                          onPressed: () => cart.addItem(producto),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}