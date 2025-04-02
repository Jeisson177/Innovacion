import 'package:flutter/material.dart';
import 'package:marketcheap/util/auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Auth authService = Auth();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _loginWithCredentials() async {
    final uid = await authService.signInWithEmail(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (uid != null) {
      Navigator.pushReplacementNamed(context, '/inicio');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Credenciales incorrectas")),
      );
    }
  }

  void _handleSocialLogin(Future Function() loginMethod) async {
    final user = await loginMethod();
    if (user != null) {
      Navigator.pushReplacementNamed(context, '/inicio');
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
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.green],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  'assets/icons/ic_marketcheap_logo.png',
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 10),
                const Text(
                  'MarketCheap',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Correo electrónico',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _loginWithCredentials,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Iniciar sesión',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Google Login
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: OutlinedButton.icon(
                    icon: Image.asset('assets/icons/google.png', height: 24),
                    label: const Text("Iniciar sesión con Google"),
                    onPressed: () => _handleSocialLogin(authService.signInWithGoogle),
                  ),
                ),
                const SizedBox(height: 10),

                // Facebook Login
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: OutlinedButton.icon(
                    icon: Image.asset('assets/icons/facebook.png', height: 24),
                    label: const Text("Iniciar sesión con Facebook"),
                    onPressed: () => _handleSocialLogin(authService.signInWithFacebook),
                  ),
                ),

                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/registro'),
                  child: const Text(
                    '¿No tienes cuenta? Regístrate',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
