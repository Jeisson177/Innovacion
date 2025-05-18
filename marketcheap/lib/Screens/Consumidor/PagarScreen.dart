import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marketcheap/Screens/Consumidor/ShoppinfCart.dart';
import 'package:provider/provider.dart';
import 'package:marketcheap/entities/Pedido.dart';

class PagarScreen extends StatefulWidget {
  final double total;
  final List<CartItem> items;

  const PagarScreen({super.key, required this.total, required this.items});

  @override
  _PagarScreenState createState() => _PagarScreenState();
}

class _PagarScreenState extends State<PagarScreen> {
  String? _selectedMethod;
  final TextEditingController _nequiPhoneController = TextEditingController();
  final TextEditingController _nequiAmountController = TextEditingController();
  final TextEditingController _efectivoAmountController = TextEditingController();
  final TextEditingController _tarjetaNumberController = TextEditingController();
  final TextEditingController _tarjetaExpiryController = TextEditingController();
  final TextEditingController _tarjetaCvvController = TextEditingController();
  final TextEditingController _tarjetaAmountController = TextEditingController();

  Future<void> _processPayment() async {
    double enteredAmount;
    bool isValid = false;

    switch (_selectedMethod) {
      case 'Nequi':
        enteredAmount = double.tryParse(_nequiAmountController.text) ?? 0.0;
        isValid = enteredAmount == widget.total;
        break;
      case 'Efectivo':
        enteredAmount = double.tryParse(_efectivoAmountController.text) ?? 0.0;
        isValid = enteredAmount == widget.total;
        break;
      case 'Tarjeta':
        enteredAmount = double.tryParse(_tarjetaAmountController.text) ?? 0.0;
        isValid = enteredAmount == widget.total;
        break;
      default:
        return;
    }

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El monto ingresado no coincide con el total del carrito'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      for (var item in widget.items) {
        final productRef = FirebaseFirestore.instance.collection('productos').doc(item.producto.id);
        final productDoc = await productRef.get();
        if (productDoc.exists) {
          final currentStock = productDoc.data()!['cantidadDisponible'] as int;
          final newStock = currentStock - item.cantidad;
          if (newStock < 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Stock insuficiente para ${item.producto.nombre}'),
                duration: const Duration(seconds: 2),
              ),
            );
            return;
          }
          await productRef.update({'cantidadDisponible': newStock});
        }
      }

      final userId = FirebaseAuth.instance.currentUser!.uid;
      final pedido = Pedido(
        id: '',
        userId: userId,
        items: widget.items,
        total: widget.total,
        paymentMethod: _selectedMethod!,
        timestamp: DateTime.now(),
      );

      final docRef = await FirebaseFirestore.instance.collection('pedidos').add(pedido.toMap());
      await docRef.update({'id': docRef.id});

      Provider.of<ShoppingCart>(context, listen: false).clearCart();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compra realizada con éxito'),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(context, '/inicio', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al procesar el pago: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nequiPhoneController.dispose();
    _nequiAmountController.dispose();
    _efectivoAmountController.dispose();
    _tarjetaNumberController.dispose();
    _tarjetaExpiryController.dispose();
    _tarjetaCvvController.dispose();
    _tarjetaAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Método de Pago'),
        backgroundColor: const Color.fromARGB(255, 98, 195, 107),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total a pagar: \$${widget.total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildPaymentOption('Nequi'),
            if (_selectedMethod == 'Nequi') ...[
              const SizedBox(height: 10),
              TextField(
                controller: _nequiPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Número de celular',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nequiAmountController,
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 10),
            _buildPaymentOption('Efectivo'),
            if (_selectedMethod == 'Efectivo') ...[
              const SizedBox(height: 10),
              TextField(
                controller: _efectivoAmountController,
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 10),
            _buildPaymentOption('Tarjeta'),
            if (_selectedMethod == 'Tarjeta') ...[
              const SizedBox(height: 10),
              TextField(
                controller: _tarjetaNumberController,
                decoration: const InputDecoration(
                  labelText: 'Número de tarjeta',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tarjetaExpiryController,
                      decoration: const InputDecoration(
                        labelText: 'Fecha de expiración (MM/AA)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.datetime,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _tarjetaCvvController,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _tarjetaAmountController,
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 20),
            if (_selectedMethod != null)
              ElevatedButton(
                onPressed: _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 98, 195, 107),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Confirmar Pago',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String method) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      elevation: 2,
      child: ListTile(
        title: Text(
          method,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Radio<String>(
          value: method,
          groupValue: _selectedMethod,
          onChanged: (value) {
            setState(() {
              _selectedMethod = value;
            });
          },
          activeColor: const Color.fromARGB(255, 98, 195, 107),
        ),
      ),
    );
  }
}