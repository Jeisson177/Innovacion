import 'package:flutter/material.dart';
import 'package:marketcheap/util/auth.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Auth();

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.green],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 80),
              const Text('Crear cuenta', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),

              // Email
              TextField(
                controller: authService.emailController,
                decoration: InputDecoration(
                  hintText: 'Correo electrónico',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 15),

              // Password
              TextField(
                controller: authService.passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 30),

              // Register button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  onPressed: () async {
                    final user = await authService.signUpWithEmail(
                      authService.emailController.text.trim(),
                      authService.passwordController.text.trim(),
                    );

                    if (user != null) {
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error al registrarse')),
                      );
                    }
                  },
                  child: const Text('Registrarse', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  '¿Ya tienes cuenta? Inicia sesión',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
