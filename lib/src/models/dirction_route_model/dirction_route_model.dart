import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirctionRouteModel {
  final List<LatLng> coordinates;
  final double distance;
  final Duration duration;

  DirctionRouteModel({
    required this.coordinates,
    required this.distance,
    required this.duration,
  });

  factory DirctionRouteModel.fromJson(Map<String, dynamic> json) {
    return DirctionRouteModel(
      coordinates: (json['coordinates'] as List<dynamic>)
          .map((e) => LatLng(e['latitude'], e['longitude']))
          .toList(),
      distance: (json['distance'] as num).toDouble(),
      duration: Duration(seconds: json['duration']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coordinates': coordinates
          .map((e) => {'latitude': e.latitude, 'longitude': e.longitude})
          .toList(),
      'distance': distance,
      'duration': duration.inSeconds,
    };
  }
}
