import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:marketcheap/Screens/Consumidor/CartScreen.dart';
import 'package:marketcheap/Screens/Consumidor/MapScreen.dart';
import 'package:marketcheap/Screens/Consumidor/OfertasScreen.dart';
import 'package:marketcheap/Screens/Consumidor/ProfileScreen.dart';
import 'package:marketcheap/Screens/Consumidor/RegisterScreen.dart';
import 'package:marketcheap/Screens/Consumidor/ShoppinfCart.dart';
import 'package:marketcheap/util/supabase_config.dart'; // nuevo archivo con config
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'LoginScreen.dart';
import 'Screens/Consumidor/InicioScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // Solicitar permisos de geolocalización
  await _initLocationPermissions();

  runApp(const MyApp());
}

Future<void> _initLocationPermissions() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) return;

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) return;
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
