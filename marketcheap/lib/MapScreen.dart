import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  LatLng? _initialPosition; // Ahora es nullable para evitar usar un valor incorrecto
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError("El servicio de ubicación está desactivado.");
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          _showError("Los permisos de ubicación están denegados permanentemente.");
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
        _addMarkers(position.latitude, position.longitude);
      });

      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_initialPosition!, 14.0),
        );
      }
    } catch (e) {
      _showError("Error al obtener la ubicación: $e");
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (_initialPosition != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_initialPosition!, 14.0),
      );
    }
  }

  void _addMarkers(double lat, double lng) {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId('1'),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: 'Tu ubicación'),
      ));
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tiendas registradas"),
        backgroundColor: Colors.green[700],
      ),
      body: _initialPosition == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _initialPosition!,
                zoom: 14.0,
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
    );
  }
}
