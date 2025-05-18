import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeocodingService {
  // Convierte dirección textual a coordenadas
  static Future<LatLng?> addressToLatLng(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
      return null;
    } catch (e) {
      print("Error en geocodificación: $e");
      return null;
    }
  }

  // Convierte coordenadas a dirección textual
  static Future<String?> latLngToAddress(LatLng position) async {
    try {
      final places = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (places.isNotEmpty) {
        final place = places.first;
        return "${place.street}, ${place.locality}, ${place.country}";
      }
      return null;
    } catch (e) {
      print("Error en geocodificación inversa: $e");
      return null;
    }
  }
}