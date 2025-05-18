import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConfiguracionProveedor extends StatefulWidget {
  const ConfiguracionProveedor({super.key});

  @override
  _ConfiguracionProveedorState createState() => _ConfiguracionProveedorState();
}

class _ConfiguracionProveedorState extends State<ConfiguracionProveedor> {
  String _storeName = 'Tienda Desconocida';
  String _providerEmail = 'email@desconocido.com';

  @override
  void initState() {
    super.initState();
    _loadProviderData();
  }

  Future<void> _loadProviderData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final doc = await FirebaseFirestore.instance.collection('proveedores').doc(uid).get();
        setState(() {
          _storeName = doc['storeName'] ?? 'Tienda Desconocida';
          _providerEmail = FirebaseAuth.instance.currentUser?.email ?? 'email@desconocido.com';
        });
      }
    } catch (e) {
      print("Error al cargar datos del proveedor: $e");
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesión cerrada')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: $e')),
        );
      }
    }
  }

  void _navigateToInicio() {
    Navigator.pushNamed(context, '/provider_home');
  }

  void _navigateToEditarProveedor() {
    Navigator.pushNamed(context, '/editar_proveedor');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Color(0xFFE0F7E0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Profile Section
            Container(
              padding: const EdgeInsets.only(top: 50, bottom: 20),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.store,
                      size: 60,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _storeName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Proveedor - $_providerEmail',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    '¡Bienvenido!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Services Section
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configuración',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildServiceButton(
                          icon: Icons.settings,
                          label: 'Configuración',
                          color: Colors.green,
                          onTap: () {
                            // Placeholder for future configuration settings
                            _navigateToEditarProveedor();
                          },
                        ),
                        const SizedBox(width: 20),
                        _buildServiceButton(
                          icon: Icons.logout,
                          label: 'LogOut',
                          color: Colors.red,
                          onTap: _logout,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.green,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Configuración de perfil',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            _navigateToInicio();
          }
        },
      ),
    );
  }

  Widget _buildServiceButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}