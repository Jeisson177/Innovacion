import 'package:flutter/material.dart';
import 'LoginScreen.dart';      // importa la pantalla de login
import 'InicioScreen.dart';    // importa la pantalla después de login

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
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/inicio': (context) => const InicioScreen(),
      },
    );
  }
}
