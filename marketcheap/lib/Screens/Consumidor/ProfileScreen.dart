import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:marketcheap/Screens/Consumidor/InicioScreen.dart';
import 'package:marketcheap/Screens/Consumidor/MapScreen.dart';
import 'package:marketcheap/LoginScreen.dart'; // Asegúrate de importar tu pantalla de login
import 'package:marketcheap/Screens/Consumidor/ConfiguracionScreen.dart'; // Asegúrate de importar tu pantalla de configuración

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String nombreCliente = "";
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosCliente();
  }

  Future<void> _cargarDatosCliente() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final doc = await FirebaseFirestore.instance.collection("clientes").doc(uid).get();
        final data = doc.data();
        if (data != null) {
          setState(() {
            nombreCliente = "${data['firstName']} ${data['lastName']}";
            cargando = false;
          });
        } else {
          setState(() {
            cargando = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se encontraron datos del cliente.')),
          );
        }
      }
    } catch (e) {
      print("Error al obtener los datos del cliente: $e");
      setState(() {
        cargando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener los datos del cliente.')),
      );
    }
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const InicioScreen()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MapScreen()));
        break;
    }
  }

  void _logOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header
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
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.black,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        nombreCliente,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        "Bienvenido !",
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Mis servicios",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1,
                      children: [
                        _buildServiceButton(Icons.settings, "Configuración", onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ConfiguracionScreen()),
                          );
                        }),
                        _buildServiceButton(Icons.star, "Favoritos", onTap: () {}),
                        _buildServiceButton(Icons.history, "Historial", onTap: () {}),
                        _buildServiceButton(Icons.notifications, "Notificaciones", onTap: () {}),
                        _buildServiceButton(Icons.logout, "LogOut", isLogout: true, onTap: _logOut),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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

  static Widget _buildServiceButton(IconData icon, String text, {VoidCallback? onTap, bool isLogout = false, double iconSize = 30}) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: isLogout
                  ? const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 220, 50, 50), // Rojo para LogOut
                        Color.fromARGB(255, 186, 36, 36),
                      ],
                    )
                  : const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 98, 195, 107),
                        Color.fromARGB(255, 40, 132, 44),
                      ],
                    ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: iconSize, color: Colors.white),
          ),
          const SizedBox(height: 5),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
