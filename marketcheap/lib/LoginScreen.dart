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
  String mensaje;
  try {
    // Obtener el userCredential correctamente
    UserCredential userCredential = (await authService.signInWithEmail(email, password)) as UserCredential;
    
    // Verificar si el usuario fue autenticado correctamente
    if (userCredential != null && userCredential.user != null) {
      // Obtener el rol del usuario desde Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('usuarios').doc(userCredential.user!.uid).get();
      String userRole = userDoc['rol'];

      // Redirigir según el rol
      if (userRole == 'proveedor') {
        Navigator.pushReplacementNamed(context, '/provider_home'); // Pantalla del proveedor
      } else {
        Navigator.pushReplacementNamed(context, '/inicio'); // Pantalla del cliente
      }
    }
  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case 'user-not-found':
        mensaje = 'Usuario no encontrado. Verifica el correo.';
        break;
      case 'wrong-password':
        mensaje = 'Contraseña incorrecta.';
        break;
      case 'invalid-email':
        mensaje = 'Correo electrónico inválido.';
        break;
      case 'user-disabled':
        mensaje = 'Esta cuenta ha sido desactivada.';
        break;
      default:
        mensaje = 'Error al iniciar sesión. Intenta de nuevo.';
    }
    setState(() {
      _errorMessage = mensaje;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  } catch (_) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error desconocido al iniciar sesión.')),
    );
    setState(() {
      _errorMessage = 'Error al iniciar sesión';
    });
  }
}



  void _handleSocialLogin(BuildContext context, Future Function() loginMethod) async {
    final userCredential = await loginMethod();
    if (userCredential != null) {
      // Obtener el rol del usuario desde Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('usuarios').doc(userCredential.user!.uid).get();
      String userRole = userDoc['rol'];

      // Redirigir según el rol
      if (userRole == 'proveedor') {
        Navigator.pushReplacementNamed(context, '/provider_home'); // Pantalla del proveedor
      } else {
        Navigator.pushReplacementNamed(context, '/client_home'); // Pantalla del cliente
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al iniciar sesión")),
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
              const Text('MarketCheap', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              // Campo de correo
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Correo electrónico',
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 15),

              // Campo de contraseña
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

              // Botón de login con email
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  onPressed: _handleEmailLogin,
                  child: const Text('Iniciar sesión', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              
              const SizedBox(height: 20),

              // Login con Google
              SizedBox(
                width: double.infinity,
                height: 45,
                child: OutlinedButton.icon(
                  icon: Image.asset('assets/icons/google.png', height: 24),
                  label: const Text("Iniciar sesión con Google"),
                  onPressed: () => _handleSocialLogin(context, authService.signInWithGoogle),
                ),
              ),

              const SizedBox(height: 10),

              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/registro'),
                child: const Text(
                  '¿No tienes cuenta? Regístrate',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
