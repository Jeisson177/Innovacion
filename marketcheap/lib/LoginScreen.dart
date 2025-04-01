import 'package:flutter/material.dart';
import 'package:marketcheap/util/auth.dart';
import 'InicioScreen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _handleSocialLogin(BuildContext context, Future Function() loginMethod) async {
    final userCredential = await loginMethod();
    if (userCredential != null) {
      Navigator.pushReplacementNamed(context, '/inicio');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al iniciar sesión")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Auth();

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
              Image.asset(
                'assets/icons/ic_marketcheap_logo.png',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 10),
              const Text(
                'MarketCheap',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Correo electrónico',
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/inicio');
                  },
                  child: const Text(
                    'Iniciar sesión',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Botón Google
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

              // Botón Facebook
              SizedBox(
                width: double.infinity,
                height: 45,
                child: OutlinedButton.icon(
                  icon: Image.asset('assets/icons/facebook.png', height: 24),
                  label: const Text("Iniciar sesión con Facebook"),
                  onPressed: () => _handleSocialLogin(context, authService.signInWithFacebook),
                ),
              ),

              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/registro');
                },
                child: const Text(
                  '¿No tienes cuenta? Regístrate',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
