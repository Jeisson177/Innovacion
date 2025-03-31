import 'package:flutter/material.dart';
import 'package:marketcheap/ShoppinfCart.dart';
import 'package:provider/provider.dart';
import 'LoginScreen.dart';
import 'InicioScreen.dart';
import 'OfertasScreen.dart';
import 'CartScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShoppingCart(),
      child: MaterialApp(
        title: 'MarketCheap',
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/inicio': (context) => const InicioScreen(),
          '/ofertas': (context) => OfertasScreen(),
          '/carrito': (context) => const CartScreen(),
        },
      ),
    );
  }
}