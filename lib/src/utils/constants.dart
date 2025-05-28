import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mdsoft_google_map_routing/google_map_routing.dart';

class GoogleMapConfig {
  static String _apiKey = '';
  static String _socketBaseUrl = '';
  static Color? _primaryColor;
  static void initialize(
      {required String apiKey,
      String? socketBaseUrl,
      Color? primaryColor}) async {
    _apiKey = apiKey;
    _primaryColor = primaryColor ?? const Color(0xff242021);
    _socketBaseUrl = socketBaseUrl ?? '';
  }

  static String get apiKey => _apiKey;
  static String get socketBaseUrl => _socketBaseUrl;
  static Color? get primaryColor => _primaryColor;

  static StreamController<TripStatus> tripStatusController =
      StreamController<TripStatus>.broadcast(
    onListen: () {
      debugPrint("tripStatusController onListen");
      // tripStatusController.add(TripStatus.initial);
    },
    onCancel: () {
      debugPrint("tripStatusController onCancel");
      // The controller should be closed elsewhere, not in onCancel.
    },
  );

  /// A stream that developers can listen to for TripStatus updates.
  static Stream<TripStatus> get tripStatusListener =>
      tripStatusController.stream;
}

enum TripStatus {
  driverArrived,
  completed,
  cancelled,
}
