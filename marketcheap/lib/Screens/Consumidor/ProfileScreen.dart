import 'package:flutter/material.dart';
import 'package:marketcheap/InicioScreen.dart';
import 'package:marketcheap/Screens/Consumidor/MapScreen.dart'; 

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0: // Inicio
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const InicioScreen()),
        );
        break;
      case 1: // Mapa
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MapScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Sección de perfil con gradiente
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 98, 195, 107),
                  Color.fromARGB(255, 40, 132, 44),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: const [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.black,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                SizedBox(height: 10),
                Text(
                  "Efraín Ortiz Pabón",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  "Hola",
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Sección de servicios
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Mis servicios",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Botones de servicios
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              padding: const EdgeInsets.all(20),
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _buildServiceButton(Icons.settings, "Configuración"),
                _buildServiceButton(Icons.star, "Favoritos"),
                _buildServiceButton(Icons.location_on, "Ubicación"),
                _buildServiceButton(Icons.history, "Historial"),
                _buildServiceButton(Icons.notifications, "Notificaciones"),
                _buildServiceButton(Icons.shopping_cart, "Mis pedidos"),
              ],
            ),
          ),
        ],
      ),

      // Barra de navegación inferior con gradiente usando Stack
      bottomNavigationBar: Stack(
        children: [
          Container(
            height: kBottomNavigationBarHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 98, 195, 107),
                  Color.fromARGB(255, 40, 132, 44),
                ],
              ),
            ),
          ),
          BottomNavigationBar(
            backgroundColor: Colors.transparent,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            showUnselectedLabels: true,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            onTap: (index) => _onItemTapped(context, index),
            items: [
              BottomNavigationBarItem(
                icon: Image.asset("assets/icons/ic_home.png", width: 24, height: 24),
                label: "Inicio",
              ),
              BottomNavigationBarItem(
                icon: Image.asset("assets/icons/ic_search.png", width: 24, height: 24),
                label: "Mapa",
              ),
              BottomNavigationBarItem(
                icon: Image.asset("assets/icons/ic_favorites.png", width: 24, height: 24),
                label: "Ofertas",
              ),
              BottomNavigationBarItem(
                icon: Image.asset("assets/icons/ic_profile.png", width: 24, height: 24),
                label: "Perfil",
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget para los botones de servicios
  static Widget _buildServiceButton(IconData icon, String text) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 98, 195, 107),
                Color.fromARGB(255, 40, 132, 44),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 30, color: Colors.white),
        ),
        const SizedBox(height: 5),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
