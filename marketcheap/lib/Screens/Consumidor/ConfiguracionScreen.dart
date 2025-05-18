import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:marketcheap/Screens/Consumidor/InicioScreen.dart';
import 'package:marketcheap/Screens/Consumidor/MapScreen.dart';
import 'package:marketcheap/LoginScreen.dart';
import 'package:marketcheap/Screens/Consumidor/ProfileScreen.dart';

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
  final _searchController = TextEditingController();
  bool _cargando = true;
  LatLng _selectedLocation = const LatLng(4.7110, -74.0721); // Default Bogotá coordinates
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  String _selectedAddress = '';

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }


  void _navigateToProfile(){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }


  Future<void> _cargarDatos() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection("clientes").doc(uid).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          _nombreController.text = data['firstName'] ?? '';
          _apellidoController.text = data['lastName'] ?? '';
          _telefonoController.text = data['phone'] ?? '';
          _direccionController.text = data['address'] ?? '';
          _selectedLocation = LatLng(
            data['latitud'] ?? 4.7110,
            data['longitud'] ?? -74.0721,
          );
          _selectedAddress = _direccionController.text;
          _updateMarker(_selectedLocation);
          if (_mapController != null) {
            _mapController!.moveCamera(CameraUpdate.newLatLngZoom(_selectedLocation, 13.0));
          }
        });
      }
    }
    setState(() {
      _cargando = false;
    });
  }

  Future<void> _searchLocation() async {
    try {
      final query = _searchController.text.trim();
      if (query.isNotEmpty) {
        final locations = await locationFromAddress(query);
        if (locations.isNotEmpty) {
          final newLocation = LatLng(locations.first.latitude, locations.first.longitude);
          setState(() {
            _selectedLocation = newLocation;
            _direccionController.text = query;
            _selectedAddress = query;
            _updateMarker(_selectedLocation);
            if (_mapController != null) {
              _mapController!.moveCamera(CameraUpdate.newLatLngZoom(_selectedLocation, 13.0));
            }
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al buscar ubicación: $e')),
      );
    }
  }

  Future<void> _updateSelectedAddress(LatLng location) async {
    try {
      final placemarks = await placemarkFromCoordinates(location.latitude, location.longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        setState(() {
          _selectedAddress = '${placemark.street}, ${placemark.locality}, ${placemark.country}';
          _direccionController.text = _selectedAddress;
        });
      }
    } catch (e) {
      print("Error al obtener dirección: $e");
      setState(() {
        _selectedAddress = 'No se pudo obtener la dirección';
      });
    }
  }

  void _updateMarker(LatLng location) {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('selected-location'),
          position: location,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          onTap: () {
            if (_mapController != null) {
              _mapController!.moveCamera(CameraUpdate.newLatLng(location));
            }
          },
        ),
      };
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
      _updateMarker(_selectedLocation);
      _mapController!.moveCamera(CameraUpdate.newLatLngZoom(_selectedLocation, 13.0));
    });
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _selectedLocation = position.target;
      _updateMarker(_selectedLocation);
      _updateSelectedAddress(_selectedLocation);
    });
  }

  Future<void> _guardarCambios() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection("clientes").doc(uid).update({
        'firstName': _nombreController.text,
        'lastName': _apellidoController.text,
        'phone': _telefonoController.text,
        'address': _direccionController.text,
        'latitud': _selectedLocation.latitude,
        'longitud': _selectedLocation.longitude,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Datos actualizados exitosamente")),
      );
      _navigateToProfile();
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
            Navigator.pop(context);
          },
        ),
        title: const Text("Configuración", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 40, 132, 44),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 10),
                    _buildTextField(_searchController, "Buscar dirección", suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _searchLocation,
                    )),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: _selectedLocation,
                          zoom: 13.0,
                        ),
                        onCameraMove: _onCameraMove,
                        markers: _markers,
                        mapType: MapType.normal,
                        myLocationButtonEnabled: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _selectedAddress.isNotEmpty ? _selectedAddress : 'Selecciona una ubicación en el mapa',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: Column(
                        children: [
                          _buildRoundedButton("Guardar cambios", _guardarCambios),
                          const SizedBox(height: 20),
                          _buildRoundedButton("Eliminar cuenta", _eliminarCuenta, isDelete: true),
                        ],
                      ),
                    ),
                  ],
                ),
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

  Widget _buildTextField(TextEditingController controller, String label, {Widget? suffixIcon}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffixIcon,
      ),
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

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }
}