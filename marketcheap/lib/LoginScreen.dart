import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marketcheap/util/auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = Auth();
  String? _errorMessage;

  Future<void> _handleEmailLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    setState(() => _errorMessage = null);

    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Autenticación con Firebase Auth
      final UserCredential userCredential =
          await authService.signInWithEmail(email, password);

      if (userCredential.user == null) {
        Navigator.of(context).pop();
        throw Exception("No se pudo autenticar al usuario.");
      }

      final uid = userCredential.user!.uid;

      // Obtener datos del usuario desde Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();

      Navigator.of(context).pop();

      final userData = userDoc.data() as Map<String, dynamic>?;

      if (!userDoc.exists || userData == null || !userData.containsKey('rol')) {
        throw Exception("El usuario no tiene un rol asignado.");
      }

      final String userRole = userData['rol'];

      // Redirección según el rol
      if (userRole == 'proveedor') {
        Navigator.pushReplacementNamed(context, '/provider_home');
      } else {
        Navigator.pushReplacementNamed(context, '/inicio');
      }
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();
      String mensaje;
      switch (e.code) {
        case 'user-not-found':
          mensaje = 'No existe una cuenta con este correo electrónico.';
          break;
        case 'wrong-password':
          mensaje = 'La contraseña es incorrecta.';
          break;
        case 'invalid-email':
          mensaje = 'El correo ingresado no es válido.';
          break;
        case 'user-disabled':
          mensaje = 'Esta cuenta está deshabilitada.';
          break;
        case 'too-many-requests':
          mensaje = 'Demasiados intentos fallidos. Intenta más tarde.';
          break;
        default:
          mensaje = 'Error al iniciar sesión: ${e.message}';
      }
      setState(() => _errorMessage = mensaje);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
    } catch (e) {
      Navigator.of(context).pop();
      setState(() => _errorMessage = 'Error inesperado');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  void _handleSocialLogin(
      BuildContext context, Future<UserCredential?> Function() loginMethod) async {
    try {
      setState(() => _errorMessage = null);
      final userCredential = await loginMethod();

      if (userCredential?.user == null) {
        throw Exception("No se pudo autenticar con el proveedor social");
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userCredential!.user!.uid)
          .get();

      final userData = userDoc.data() as Map<String, dynamic>?;

      if (!userDoc.exists || userData == null || !userData.containsKey('rol')) {
        throw Exception("El usuario no tiene un rol asignado en la base de datos");
      }

      final userRole = userData['rol'];

      if (userRole == 'proveedor') {
        Navigator.pushReplacementNamed(context, '/provider_home');
      } else {
        Navigator.pushReplacementNamed(context, '/inicio');
      }
    } on FirebaseException catch (e) {
      setState(() => _errorMessage = 'Error de Firebase: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de autenticación: ${e.message ?? "Error desconocido"}')),
      );
    } catch (e) {
      setState(() => _errorMessage = 'Error al iniciar sesión');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.green],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              Image.asset('assets/icons/ic_marketcheap_logo.png', width: 120, height: 120),
              const SizedBox(height: 10),
              const Text('MarketCheap',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    _errorMessage!,
                    style:
                        const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Correo electrónico',
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  onPressed: _handleEmailLogin,
                  child: const Text('Iniciar sesión',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: OutlinedButton.icon(
                  icon: Image.asset('assets/icons/google.png', height: 24),
                  label: const Text("Iniciar sesión con Google"),
                  onPressed: () =>
                      _handleSocialLogin(context, authService.signInWithGoogle),
                ),
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/registro'),
                child: const Text(
                  '¿No tienes cuenta? Regístrate',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
