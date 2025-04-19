import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:marketcheap/Screens/Consumidor/InicioScreen.dart';
import 'package:marketcheap/Screens/Consumidor/MapScreen.dart';
import 'package:marketcheap/LoginScreen.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection("clientes").doc(uid).get();
      final data = doc.data();
      if (data != null) {
        _nombreController.text = data['firstName'] ?? '';
        _apellidoController.text = data['lastName'] ?? '';
        _telefonoController.text = data['phone'] ?? '';
        _direccionController.text = data['address'] ?? ''; // Asegúrate de usar 'address' aquí
      }
    }
    setState(() {
      _cargando = false;
    });
  }

  Future<void> _guardarCambios() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection("clientes").doc(uid).update({
        'firstName': _nombreController.text,
        'lastName': _apellidoController.text,
        'phone': _telefonoController.text,
        'address': _direccionController.text, // Asegúrate de usar 'address' aquí
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Datos actualizados exitosamente")),
      );
    }
  }

  Future<void> _eliminarCuenta() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection("clientes").doc(uid).delete();
        await FirebaseAuth.instance.currentUser!.delete();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      print("Error eliminando cuenta: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hubo un error al eliminar la cuenta.")),
      );
    }
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const InicioScreen()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MapScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Volver a la pantalla anterior
          },
        ),
        title: const Text("Configuración"),
        backgroundColor: const Color.fromARGB(255, 40, 132, 44),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    "Editar Perfil",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(_nombreController, "Nombre"),
                  const SizedBox(height: 10),
                  _buildTextField(_apellidoController, "Apellido"),
                  const SizedBox(height: 10),
                  _buildTextField(_telefonoController, "Teléfono"),
                  const SizedBox(height: 10),
                  _buildTextField(_direccionController, "Dirección de entrega"),
                  const SizedBox(height: 30),
                  _buildRoundedButton("Guardar cambios", _guardarCambios),
                  const SizedBox(height: 20),
                  _buildRoundedButton("Eliminar cuenta", _eliminarCuenta, isDelete: true),
                ],
              ),
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
            onTap: _onItemTapped,
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

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _buildRoundedButton(String text, VoidCallback onTap, {bool isDelete = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
        decoration: BoxDecoration(
          color: isDelete ? Colors.red : const Color.fromARGB(255, 40, 132, 44),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
