import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _storeDescriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  LatLng? _selectedLatLng;
  String _direccion = "Seleccionando dirección...";
  late GoogleMapController _mapController;
  String _selectedRole = 'cliente';

  @override
  void initState() {
    super.initState();
    _obtenerUbicacionYDireccionInicial();
  }

  Future<void> _obtenerUbicacionYDireccionInicial() async {
    Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _selectedLatLng = LatLng(pos.latitude, pos.longitude);
    });
    _actualizarDireccionDesdeCoord(_selectedLatLng!);
  }

  Future<void> _actualizarDireccionDesdeCoord(LatLng coords) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(coords.latitude, coords.longitude);
    Placemark p = placemarks.first;
    setState(() {
      _direccion = '${p.street}, ${p.locality}, ${p.country}';
    });
  }

  Future<void> _searchAddress() async {
    try {
      List<Location> locations = await locationFromAddress(_searchController.text);
      if (locations.isNotEmpty) {
        Location loc = locations.first;
        setState(() {
          _selectedLatLng = LatLng(loc.latitude, loc.longitude);
        });
        _mapController.animateCamera(CameraUpdate.newLatLng(_selectedLatLng!));
        _actualizarDireccionDesdeCoord(_selectedLatLng!);
      } else {
        _showError('Dirección no encontrada');
      }
    } catch (e) {
      _showError('Error al buscar dirección: $e');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _register() async {
    try {
      if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
        _showError('Correo electrónico inválido');
        return;
      }
      if (_passwordController.text.length < 6) {
        _showError('La contraseña debe tener al menos 6 caracteres');
        return;
      }
      if (_selectedRole == 'cliente' && (_firstNameController.text.isEmpty || _lastNameController.text.isEmpty)) {
        _showError('Nombre y apellido son requeridos para cliente');
        return;
      }

      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).set({
          'rol': _selectedRole,
        });

        if (_selectedRole == 'proveedor') {
          await FirebaseFirestore.instance.collection('proveedores').doc(user.uid).set({
            'storeName': _storeNameController.text,
            'email': _emailController.text.trim(),
            'phone': _phoneController.text.trim(),
            'address': _direccion,
            'ubicacion': {
              'lat': _selectedLatLng?.latitude,
              'lng': _selectedLatLng?.longitude,
            },
            'storeDescription': _storeDescriptionController.text,
          });
        } else {
          await FirebaseFirestore.instance.collection('clientes').doc(user.uid).set({
            'firstName': _firstNameController.text,
            'lastName': _lastNameController.text,
            'address': _direccion,
            'ubicacion': {
              'lat': _selectedLatLng?.latitude,
              'lng': _selectedLatLng?.longitude,
            },
            'phone': _phoneController.text.trim(),
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro exitoso')));

        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      _showError('Error al registrar: $e');
    }
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedLatLng = position;
    });
    _actualizarDireccionDesdeCoord(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFDFFFD8), Color(0xFF6BCB77)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                Image.asset('assets/icons/ic_marketcheap_logo.png', height: 100),
                const SizedBox(height: 10),
                const Text('Crear Cuenta', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                DropdownButton<String>(
                  value: _selectedRole,
                  icon: const Icon(Icons.arrow_drop_down),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRole = newValue!;
                    });
                  },
                  items: <String>['cliente', 'proveedor']
                      .map<DropdownMenuItem<String>>((String value) => DropdownMenuItem<String>(value: value, child: Text(value.capitalize())))
                      .toList(),
                ),
                const SizedBox(height: 30),
                _buildTextField(_emailController, 'Correo electrónico', false),
                const SizedBox(height: 20),
                _buildTextField(_passwordController, 'Contraseña', true),
                const SizedBox(height: 20),
                if (_selectedRole == 'cliente') ...[
                  _buildTextField(_firstNameController, 'Nombre', false),
                  const SizedBox(height: 20),
                  _buildTextField(_lastNameController, 'Apellido', false),
                  const SizedBox(height: 20),
                  RawGestureDetector(
                    gestures: <Type, GestureRecognizerFactory>{
                      VerticalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<VerticalDragGestureRecognizer>(
                        () => VerticalDragGestureRecognizer(),
                        (VerticalDragGestureRecognizer instance) {
                          instance.onUpdate = (_) {};
                        },
                      ),
                    },
                    child: SizedBox(
                      height: 300,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _selectedLatLng ?? LatLng(4.7110, -74.0721),
                          zoom: 16,
                        ),
                        onMapCreated: (controller) => _mapController = controller,
                        markers: _selectedLatLng != null
                            ? {
                                Marker(
                                  markerId: const MarkerId("ubicacion"),
                                  position: _selectedLatLng!,
                                  draggable: true,
                                  onDragEnd: (nuevaPos) {
                                    setState(() => _selectedLatLng = nuevaPos);
                                    _actualizarDireccionDesdeCoord(nuevaPos);
                                  },
                                )
                              }
                            : {},
                        myLocationButtonEnabled: true,
                        zoomControlsEnabled: false,
                        zoomGesturesEnabled: true,
                        scrollGesturesEnabled: true,
                        rotateGesturesEnabled: true,
                        tiltGesturesEnabled: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("Dirección: $_direccion", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
                const SizedBox(height: 20),
                _buildTextField(_phoneController, 'Teléfono', false),
                const SizedBox(height: 20),
                if (_selectedRole == 'proveedor') ...[
                  _buildTextField(_searchController, 'Buscar dirección', false),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _searchAddress,
                    child: const Text('Buscar'),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 300,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _selectedLatLng ?? LatLng(4.7110, -74.0721),
                        zoom: 16,
                      ),
                      onMapCreated: (controller) => _mapController = controller,
                      markers: _selectedLatLng != null
                          ? {
                              Marker(
                                markerId: const MarkerId("ubicacion"),
                                position: _selectedLatLng!,
                                draggable: true,
                                onDragEnd: (nuevaPos) {
                                  setState(() => _selectedLatLng = nuevaPos);
                                  _actualizarDireccionDesdeCoord(nuevaPos);
                                },
                              )
                            }
                          : {},
                      onTap: _onMapTap,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      zoomGesturesEnabled: true,
                      scrollGesturesEnabled: true,
                      rotateGesturesEnabled: true,
                      tiltGesturesEnabled: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("Dirección: $_direccion", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                  _buildTextField(_storeNameController, 'Nombre de la tienda', false),
                  const SizedBox(height: 20),
                  _buildTextField(_storeDescriptionController, 'Descripción de la tienda', false),
                ],
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Registrarse', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, bool obscure) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white70,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() {
    return isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
  }
}