import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_place/google_place.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  late GooglePlace googlePlace;

  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};

  LatLng _initialPosition = const LatLng(4.6097, -74.0817); // Bogotá centro
  List<AutocompletePrediction> _predictions = [];

  @override
  void initState() {
    super.initState();
    googlePlace = GooglePlace("AIzaSyBthbDFH1bk6xgpb4Uyd3Fei-EpaAxxwi8"); // Usa tu API key real
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _autoCompleteSearch(String value) async {
    if (value.isEmpty) {
      setState(() => _predictions = []);
      return;
    }

    final result = await googlePlace.autocomplete.get(
      value,
      radius: 50000,
      language: "es",
      location: LatLon(_initialPosition.latitude, _initialPosition.longitude),
    );

    if (result != null && result.predictions != null) {
      setState(() {
        _predictions = result.predictions!;
      });
    }
  }

  Future<void> _selectPlace(String placeId) async {
    final detail = await googlePlace.details.get(placeId);
    final loc = detail?.result?.geometry?.location;

    if (loc != null) {
      final LatLng target = LatLng(loc.lat!, loc.lng!);

      setState(() {
        _searchController.clear();
        _predictions.clear();
        _markers.clear();
        _circles.clear();

        _markers.add(Marker(
          markerId: MarkerId("selected_place"),
          position: target,
          infoWindow: InfoWindow(title: detail!.result!.name),
        ));

        _circles.add(Circle(
          circleId: CircleId("area_circle"),
          center: target,
          radius: 500,
          fillColor: Colors.blue.withOpacity(0.2),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        ));
      });

      _mapController?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 15.5),
      ));
    }
  }

  Widget _buildSearchBox() {
    return Positioned(
      top: 70,
      left: 15,
      right: 15,
      child: Column(
        children: [
          Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(10),
            child: TextField(
              controller: _searchController,
              onChanged: _autoCompleteSearch,
              decoration: const InputDecoration(
                hintText: "Buscar lugar...",
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(15),
              ),
            ),
          ),
          ..._predictions.map((p) => ListTile(
                title: Text(p.description ?? ''),
                leading: const Icon(Icons.location_on),
                onTap: () => _selectPlace(p.placeId!),
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mapa interactivo"),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 14,
            ),
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: _markers,
            circles: _circles,
          ),
          _buildSearchBox(),
        ],
      ),
    );
  }
}
