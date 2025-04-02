import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // <-- Importa Geolocator
import 'package:marketcheap/CartScreen.dart';
import 'package:marketcheap/MapScreen.dart';
import 'package:marketcheap/OfertasScreen.dart';
import 'package:marketcheap/ProfileScreen.dart';
import 'package:marketcheap/RegisterScreen.dart';
import 'package:marketcheap/ShoppinfCart.dart';
import 'package:marketcheap/firebase_options.dart';
import 'package:provider/provider.dart';
import 'LoginScreen.dart';
import 'InicioScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Solicitar permisos de geolocalización antes de lanzar la app
  await _initLocationPermissions();

  runApp(MyApp());
}

Future<void> _initLocationPermissions() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return;
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      return;
    }
  }
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
          '/registro': (context) => const RegisterScreen(),
          '/mapa': (context) => const MapScreen(),
          '/perfil': (context) => const ProfileScreen(),
        },
      ),
    );
  }
}
