import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marketcheap/Screens/Consumidor/ShoppinfCart.dart';
import 'package:marketcheap/entities/Producto.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For formatting date/time

class DetalleTienda extends StatefulWidget {
  final String storeName;

  const DetalleTienda({super.key, required this.storeName});

  @override
  _DetalleTiendaState createState() => _DetalleTiendaState();
}

class _DetalleTiendaState extends State<DetalleTienda> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Producto> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    print('Received storeName in DetalleTienda: ${widget.storeName}');
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (widget.storeName.isEmpty) {
      setState(() {
        _errorMessage = 'Nombre de tienda inválido';
        _isLoading = false;
      });
      print('Error: storeName is empty or invalid: ${widget.storeName}');
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'Usuario no autenticado. Por favor, inicia sesión.';
          _isLoading = false;
        });
        print('Error: User is not authenticated');
        return;
      }
      print('User authenticated with UID: ${user.uid}');

      print('Fetching products for storeName: ${widget.storeName}');
      final querySnapshot = await _firestore
          .collection('productos')
          .where('tienda', isEqualTo: widget.storeName)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _products = [];
          _isLoading = false;
        });
        print('No products found for storeName: ${widget.storeName}');
        return;
      }

      List<Producto> productsData = [];
      for (var doc in querySnapshot.docs) {
        final prodData = doc.data() as Map<String, dynamic>?;
        if (prodData != null) {
          productsData.add(Producto(
            id: doc.id,
            nombre: prodData['nombre']?.toString() ?? 'Sin nombre',
            marca: prodData['marca']?.toString() ?? 'Sin marca',
            tienda: prodData['tienda']?.toString() ?? widget.storeName,
            precio: (prodData['precio'] is num) ? (prodData['precio'] as num).toDouble() : 0.0,
            descripcion: prodData['descripcion']?.toString() ?? 'Sin descripción',
            categoria: prodData['categoria']?.toString() ?? 'Sin categoría',
            cantidadDisponible: (prodData['cantidadDisponible'] is num) ? (prodData['cantidadDisponible'] as num).toInt() : 0,
            imagenUrl: prodData['imagenUrl']?.toString() ?? '',
            valoraciones: List<double>.from(prodData['valoraciones'] ?? []),
          ));
        } else {
          print('Product data is null for ID: ${doc.id}');
        }
      }

      setState(() {
        _products = productsData;
        _isLoading = false;
      });
      print('Successfully fetched ${productsData.length} products');
      if (productsData.isNotEmpty) {
        print('Products data: ${productsData.map((p) => {'id': p.id, 'nombre': p.nombre, 'precio': p.precio}).toList()}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al cargar productos: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage!)),
      );
    }
  }

  List<Producto> _filterProducts(String query) {
    return _products.where((product) {
      final name = product.nombre.toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();
  }

  void _addToCart(Producto product, int quantity) {
    final cart = Provider.of<ShoppingCart>(context, listen: false);
    for (int i = 0; i < quantity; i++) {
      cart.addItem(product);
    }
    final now = DateTime.now();
    final formattedTime = DateFormat('hh:mm a').format(now);
    print('Added $quantity x ${product.nombre} to cart at $formattedTime on ${DateFormat('yyyy-MM-dd').format(now)}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$quantity x ${product.nombre} agregado${quantity > 1 ? 's' : ''} al carrito a las $formattedTime'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addAllToCart() {
    final cart = Provider.of<ShoppingCart>(context, listen: false);
    final filteredProducts = _filterProducts(_searchController.text);
    if (filteredProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay productos para agregar al carrito'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    for (var product in filteredProducts) {
      cart.addItem(product);
    }
    final now = DateTime.now();
    final formattedTime = DateFormat('hh:mm a').format(now);
    print('Added ${filteredProducts.length} products to cart at $formattedTime on ${DateFormat('yyyy-MM-dd').format(now)}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${filteredProducts.length} productos agregados al carrito a las $formattedTime'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _filterProducts(_searchController.text);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.storeName.isNotEmpty ? widget.storeName : 'Tienda sin nombre'),
        backgroundColor: const Color.fromARGB(255, 98, 195, 107),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar producto...',
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty && _errorMessage == null
                    ? const Center(child: Text('No hay productos disponibles'))
                    : ListView.builder(
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return _ProductItem(
                            product: product,
                            onAdd: (quantity) => _addToCart(product, quantity),
                          );
                        },
                      ),
          ),
          if (!_isLoading && _products.isNotEmpty && _errorMessage == null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _addAllToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 98, 195, 107),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Agregar todos al carrito',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _ProductItem extends StatefulWidget {
  final Producto product;
  final ValueChanged<int> onAdd;

  const _ProductItem({required this.product, required this.onAdd});

  @override
  __ProductItemState createState() => __ProductItemState();
}

class __ProductItemState extends State<_ProductItem> {
  late int quantity;

  @override
  void initState() {
    super.initState();
    quantity = 1; // Default quantity when adding
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<ShoppingCart>(context, listen: false);
    final existingItem = cart.items.firstWhere(
      (item) => item.producto.nombre == widget.product.nombre,
      orElse: () => CartItem(producto: widget.product, cantidad: 0),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.product.imagenUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image, size: 60),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Precio: \$${widget.product.precio.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Valoración: ${widget.product.obtenerValoracionPromedio().toStringAsFixed(1)}/5',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.red,
                  onPressed: quantity > 1
                      ? () {
                          setState(() {
                            quantity--;
                          });
                        }
                      : null,
                ),
                Text(
                  quantity.toString(),
                  style: const TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: Colors.green,
                  onPressed: () {
                    setState(() {
                      quantity++;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add_shopping_cart, color: Colors.green),
                  onPressed: () {
                    widget.onAdd(quantity);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}