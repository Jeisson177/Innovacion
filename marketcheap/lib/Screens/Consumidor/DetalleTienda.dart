import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetalleTienda extends StatefulWidget {
  final String storeName;

  const DetalleTienda({super.key, required this.storeName});

  @override
  _DetalleTiendaState createState() => _DetalleTiendaState();
}

class _DetalleTiendaState extends State<DetalleTienda> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _products = [];
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

    // Validate storeName
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

      List<Map<String, dynamic>> productsData = [];
      for (var doc in querySnapshot.docs) {
        final prodData = doc.data() as Map<String, dynamic>?;
        if (prodData != null) {
          prodData['id'] = doc.id;
          productsData.add(prodData);
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
        print('Products data: $productsData');
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

  List<Map<String, dynamic>> _filterProducts(String query) {
    return _products.where((product) {
      final name = product['nombre']?.toString().toLowerCase() ?? '';
      return name.contains(query.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.storeName),
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
                        itemCount: _filterProducts(_searchController.text).length,
                        itemBuilder: (context, index) {
                          final product = _filterProducts(_searchController.text)[index];
                          return ListTile(
                            leading: const Icon(Icons.local_offer, color: Colors.green),
                            title: Text(product['nombre'] ?? 'Sin nombre'),
                            subtitle: Text(
                              'Precio: \$${product['precio']?.toString() ?? 'N/A'}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          );
                        },
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