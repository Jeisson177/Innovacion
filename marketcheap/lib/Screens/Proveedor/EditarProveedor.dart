import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class EditarProveedor extends StatefulWidget {
  const EditarProveedor({super.key});

  @override
  _EditarProveedorState createState() => _EditarProveedorState();
}

class _EditarProveedorState extends State<EditarProveedor> {
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  LatLng _selectedLocation = const LatLng(4.7110, -74.0721); // Default Bogotá coordinates
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  String _selectedAddress = ''; // To store the address being selected

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
          _storeNameController.text = doc['storeName'] ?? 'Tienda Desconocida';
          _addressController.text = doc['direccion'] ?? 'AK #7 40 - 62, Bogotá, Colombia';
          _phoneController.text = doc['telefono'] ?? '';
          _selectedLocation = LatLng(
            doc['latitud'] ?? 4.7110,
            doc['longitud'] ?? -74.0721,
          );
          _selectedAddress = _addressController.text;
          _updateMarker(_selectedLocation);
          if (_mapController != null) {
            _mapController!.moveCamera(CameraUpdate.newLatLngZoom(_selectedLocation, 13.0));
          }
        });
      }
    } catch (e) {
      print("Error al cargar datos del proveedor: $e");
    }
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
            _addressController.text = query;
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
          _addressController.text = _selectedAddress;
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
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('proveedores').doc(uid).update({
          'storeName': _storeNameController.text.trim(),
          'direccion': _addressController.text.trim(),
          'telefono': _phoneController.text.trim(),
          'latitud': _selectedLocation.latitude,
          'longitud': _selectedLocation.longitude,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cambios guardados')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar cambios: $e')),
      );
    }
  }

  Future<void> _eliminarCuenta() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que quieres eliminar tu cuenta permanentemente? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance.collection('proveedores').doc(user.uid).delete();
          await user.delete();
          await FirebaseAuth.instance.signOut();
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cuenta eliminada permanentemente')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar cuenta: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F5F5), Color(0xFFE0F7E0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Editar Perfil',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _storeNameController,
                decoration: const InputDecoration(labelText: 'Nombre de la tienda'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Dirección'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Buscar dirección',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _searchLocation,
                  ),
                ),
              ),
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
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: _guardarCambios,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Guardar cambios', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _eliminarCuenta,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Eliminar cuenta', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
            Navigator.pushNamed(context, '/inicio_proveedor');
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }
}