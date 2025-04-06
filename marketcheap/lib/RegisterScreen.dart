import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController(); // Nombre
  final TextEditingController _lastNameController = TextEditingController(); // Apellido
  final TextEditingController _addressController = TextEditingController(); // Dirección (opcional)
  final TextEditingController _phoneController = TextEditingController(); // Teléfono
  final TextEditingController _storeNameController = TextEditingController(); // Nombre de la tienda (proveedor)
  final TextEditingController _storeDescriptionController = TextEditingController(); // Descripción de la tienda (proveedor)

  String _selectedRole = 'cliente'; // Valor por defecto es 'cliente'

  Future<void> _register() async {
    try {
      // Crear usuario con Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      User? user = userCredential.user;

      if (user != null) {
        // Guardar el rol del usuario en Firestore
        await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).set({
          'rol': _selectedRole, // Guardamos el rol seleccionado
        });

        // Guardar los datos adicionales dependiendo del rol
        if (_selectedRole == 'proveedor') {
          // Guardar los datos del proveedor
          await FirebaseFirestore.instance.collection('proveedores').doc(user.uid).set({
            'storeName': _storeNameController.text,
            'email': _emailController.text.trim(),
            'phone': _phoneController.text.trim(),
            'address': _addressController.text.trim(),
            'storeDescription': _storeDescriptionController.text,
          });
        } else {
          // Guardar los datos del cliente
          await FirebaseFirestore.instance.collection('clientes').doc(user.uid).set({
            'firstName': _firstNameController.text,
            'lastName': _lastNameController.text,
            'address': _addressController.text.trim(),
            'phone': _phoneController.text.trim(),
          });
        }

        // Registro exitoso, redirigir según el rol
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro exitoso')),
        );

        if (_selectedRole == 'proveedor') {
          // Redirigir a la pantalla de proveedores
          Navigator.pushReplacementNamed(context, '/provider_home'); // Cambiar a tu ruta
        } else {
          // Redirigir a la pantalla de clientes
          Navigator.pushReplacementNamed(context, '/client_home'); // Cambiar a tu ruta
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFDFFFD8), Color(0xFF6BCB77)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                Image.asset('assets/icons/ic_marketcheap_logo.png', height: 100),
                const SizedBox(height: 10),
                const Text(
                  'Crear Cuenta',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    filled: true,
                    fillColor: Colors.white70,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    filled: true,
                    fillColor: Colors.white70,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                // Campos para cliente o proveedor
                if (_selectedRole == 'cliente') ...[
                  TextField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      filled: true,
                      fillColor: Colors.white70,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Apellido',
                      filled: true,
                      fillColor: Colors.white70,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                if (_selectedRole == 'cliente') ...[
                  const SizedBox(height: 20),
                  TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Dirección (opcional)',
                      filled: true,
                      fillColor: Colors.white70,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    filled: true,
                    fillColor: Colors.white70,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                if (_selectedRole == 'proveedor') ...[
                  TextField(
                    controller: _storeNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la tienda',
                      filled: true,
                      fillColor: Colors.white70,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _storeDescriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción de la tienda',
                      filled: true,
                      fillColor: Colors.white70,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                // Dropdown para seleccionar el rol
                DropdownButton<String>(
                  value: _selectedRole,
                  icon: const Icon(Icons.arrow_drop_down),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRole = newValue!;
                    });
                  },
                  items: <String>['cliente', 'proveedor']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value.capitalize()),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 60,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Registrarse',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Función para capitalizar la primera letra de los roles
extension StringCasingExtension on String {
  String capitalize() {
    return this.isEmpty ? this : '${this[0].toUpperCase()}${this.substring(1)}';
  }
}
