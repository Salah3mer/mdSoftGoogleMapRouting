import 'package:google_maps_flutter/google_maps_flutter.dart';

class MdSoftLatLng {
  final LatLng _latLng;

  MdSoftLatLng(double latitude, double longitude)
      : _latLng = LatLng(latitude, longitude);

  double get latitude => _latLng.latitude;
  double get longitude => _latLng.longitude;

  LatLng get googleLatLng => _latLng;

  MdSoftLatLng copyWith({
    double? latitude,
    double? longitude,
  }) {
    return MdSoftLatLng(
      latitude ?? _latLng.latitude,
      longitude ?? _latLng.longitude,
    );
  }
}