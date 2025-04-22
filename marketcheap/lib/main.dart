import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // <-- Importa Geolocator
import 'package:marketcheap/Screens/Consumidor/CartScreen.dart';
import 'package:marketcheap/Screens/Consumidor/MapScreen.dart';
import 'package:marketcheap/Screens/Consumidor/OfertasScreen.dart';
import 'package:marketcheap/Screens/Consumidor/ProfileScreen.dart';
import 'package:marketcheap/RegisterScreen.dart';
import 'package:marketcheap/Screens/Consumidor/ShoppinfCart.dart';
import 'package:marketcheap/util/firebase_options.dart';
import 'package:provider/provider.dart';
import 'LoginScreen.dart';
import 'Screens/Consumidor/InicioScreen.dart';
import 'Screens/Proveedor/InicioProvedor.dart';
import 'Screens/Proveedor/AgregarProductoScreen.dart';
import 'Screens/Consumidor/ConfiguracionScreen.dart';
import 'Screens/Proveedor/EditarProductoScreen.dart';



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
          '/provider_home': (context) => const InicioProveedor(),
          '/agregar_producto': (context) => const AgregarProductoScreen(),
          '/editar_producto': (context) => const EditarProductoScreen(),
          '/configurar_perfil': (context) => const ConfiguracionScreen(),
           

        },
      ),
    );
  }
}
