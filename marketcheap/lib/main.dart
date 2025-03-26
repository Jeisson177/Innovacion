import 'package:flutter/material.dart';
import 'LoginScreen.dart'; // Asegúrate de que LoginScreen.dart esté bien referenciado
import 'InicioScreen.dart'; // Asegúrate de que InicioScreen.dart esté bien referenciado

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MarketCheap',
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Pantalla inicial
      routes: {
        '/': (context) => const LoginScreen(), // Pantalla de Login
        '/inicio': (context) => const InicioScreen(), // Pantalla de Hello World
      },
    );
  }
}
