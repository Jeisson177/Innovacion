import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:marketcheap/CartScreen.dart';
import 'package:marketcheap/OfertasScreen.dart';
import 'package:marketcheap/ShoppinfCart.dart';
import 'package:marketcheap/firebase_options.dart';
import 'package:provider/provider.dart';
import 'LoginScreen.dart'; // Asegúrate de que LoginScreen.dart esté bien referenciado
import 'InicioScreen.dart'; // Asegúrate de que InicioScreen.dart esté bien referenciado

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
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