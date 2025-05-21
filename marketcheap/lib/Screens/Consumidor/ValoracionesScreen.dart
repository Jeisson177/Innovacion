import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marketcheap/entities/Pedido.dart';
import 'package:marketcheap/entities/Producto.dart';

class ValoracionesScreen extends StatefulWidget {
  const ValoracionesScreen({super.key});

  @override
  _ValoracionesScreenState createState() => _ValoracionesScreenState();
}

class _ValoracionesScreenState extends State<ValoracionesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Pedido> _orders = [];
  Map<String, double> _userRatings = {}; // Map of productId to user's rating
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // Load user's ratings from user_ratings collection
      final ratingsSnapshot = await _firestore
          .collection('user_ratings')
          .doc(userId)
          .get();

      final ratingsData = ratingsSnapshot.data();
      final userRatings = <String, double>{};
      if (ratingsData != null && ratingsData['ratings'] != null) {
        final ratingsList = ratingsData['ratings'] as List<dynamic>;
        for (var entry in ratingsList) {
          userRatings[entry['productId']] = (entry['rating'] as num).toDouble();
        }
      }

      // Load orders
      final querySnapshot = await _firestore
          .collection('pedidos')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        _userRatings = userRatings;
        _orders = querySnapshot.docs
            .map((doc) => Pedido.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
    }
  }

  Future<void> _submitRating(String productId, double rating) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // Update product ratings in productos collection
      final productRef = _firestore.collection('productos').doc(productId);
      final productDoc = await productRef.get();
      if (productDoc.exists) {
        final productData = productDoc.data()!;
        List<double> currentRatings = (productData['valoraciones'] as List<dynamic>? ?? []).cast<double>();
        currentRatings.add(rating);
        await productRef.update({'valoraciones': currentRatings});
      }

      // Update user_ratings to store this rating
      final userRatingsRef = _firestore.collection('user_ratings').doc(userId);
      await userRatingsRef.set({
        'ratings': FieldValue.arrayUnion([
          {'productId': productId, 'rating': rating}
        ]),
      }, SetOptions(merge: true));

      setState(() {
        _userRatings[productId] = rating; // Update local state
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Valoración enviada con éxito')),
      );

      // Redirect to InicioScreen
      Navigator.pushNamedAndRemoveUntil(context, '/inicio', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar valoración: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Valorar Productos'),
        backgroundColor: const Color(0xFF6BCB77),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('No hay productos comprados para valorar'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          final order = _orders[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pedido - Fecha: ${order.timestamp.toLocal().toString().split('.')[0]}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 10),
                                  ...order.items.map((item) {
                                    final product = item.producto;
                                    return _RatingTile(
                                      product: product,
                                      userRating: _userRatings[product.id],
                                      onRatingSubmitted: (rating) => _submitRating(product.id, rating),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _RatingTile extends StatefulWidget {
  final Producto product;
  final double? userRating; // User's existing rating for this product
  final Function(double) onRatingSubmitted;

  const _RatingTile({
    required this.product,
    required this.onRatingSubmitted,
    this.userRating,
  });

  @override
  __RatingTileState createState() => __RatingTileState();
}

class __RatingTileState extends State<_RatingTile> {
  double _rating = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.userRating != null) {
      _rating = widget.userRating!;
    }
  }

  void _updateRating(double newRating) {
    if (widget.userRating == null) {
      setState(() {
        _rating = newRating;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: widget.product.imagenUrl.isNotEmpty
                ? Image.network(
                    widget.product.imagenUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading image for ${widget.product.nombre}: $error');
                      return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  )
                : const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.product.nombre, style: const TextStyle(fontSize: 16)),
                Text(
                  widget.product.tienda.isNotEmpty ? widget.product.tienda : 'Proveedor no especificado',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 24,
                      ),
                      onPressed: widget.userRating == null
                          ? () {
                              _updateRating((index + 1).toDouble());
                            }
                          : null,
                    );
                  }),
                ),
                if (widget.userRating == null && _rating > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: ElevatedButton(
                      onPressed: () => widget.onRatingSubmitted(_rating),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6BCB77),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: const Text('Enviar Valoración', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}