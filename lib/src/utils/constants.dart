import 'package:flutter/material.dart';

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
}
