import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CamiraService {
  static double getBearing(LatLng start, LatLng end) {
    double lat1 = _degToRad(start.latitude);
    double lon1 = _degToRad(start.longitude);
    double lat2 = _degToRad(end.latitude);
    double lon2 = _degToRad(end.longitude);

    // الفرق في خطوط الطول
    double dLon = lon2 - lon1;

    // معادلة حساب Bearing
    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);

    // تحويل الناتج من راديان إلى درجات
    double bearing = _radToDeg(atan2(y, x));

    // ضبط النتيجة في نطاق 0 - 360
    return (bearing + 360) % 360;
  }

  static double _degToRad(double degrees) => degrees * pi / 180.0;
  static double _radToDeg(double radians) => radians * 180.0 / pi;

  static double smoothBearing(
      double oldBearing, double newBearing, double alpha) {
    // حساب الفرق مع مراعاة الالتفاف من 0 لـ 360
    double diff = (newBearing - oldBearing + 540) % 360 - 180;
    double finalBearing = oldBearing + alpha * diff;
    return (finalBearing + 360) % 360;
  }

  static double getTilt(double speed) {
    const maxSpeed = 130.0; // سرعة قصوى افتراضية (km/h)
    const maxTilt = 45.0; // أقصى زاوية tilt
    return ((speed / maxSpeed) * maxTilt).clamp(20.0, maxTilt);
  }

  static double smoothTilt(double oldTilt, double newTilt, double alpha) {
    return oldTilt + alpha * (newTilt - oldTilt);
  }

  static const double _maxSpeed = 130.0;
  static const double _minZoom = 16.0;
  static const double _maxZoom = 20.0;
  static double _lastZoom = 18.0;
  static double _lastSpeed = 0.0;
  static DateTime _lastUpdate = DateTime.now();
  static double calculateZoom({
    required double speed,
    double? acceleration,
    List<LatLng>? route,
    double screenWidth = 360.0,
  }) {
    // 1. Non-linear scaling with exponential decay
    final num normalizedSpeed = pow(speed / _maxSpeed, 0.6).clamp(0.0, 1.0);

    // 2. Base zoom calculation
    double baseZoom = _minZoom + (_maxZoom - _minZoom) * (1 - normalizedSpeed);

    // 3. Acceleration adjustment (0.5 zoom change per 3m/s²)
    if (acceleration != null) {
      final double accelFactor = (acceleration.clamp(-3.0, 3.0) / 3.0).abs();
      baseZoom -= accelFactor * 0.5;
    }

    // 4. Upcoming turn detection
    if (route != null && route.length > 10) {
      final double turnDistance = _calculateNextTurnDistance(route);
      if (turnDistance < 200) {
        baseZoom -= (1 - (turnDistance / 200)) * 2.0;
      }
    }

    // 5. Hysteresis effect to prevent flickering
    final double timeFactor =
        DateTime.now().difference(_lastUpdate).inMilliseconds / 1000;
    final double speedDelta = (speed - _lastSpeed).abs();

    double hysteresis = 0.3 + // Base hysteresis
        0.1 * speedDelta + // Dynamic based on speed change
        0.2 * timeFactor; // Time-based relaxation

    if (baseZoom > _lastZoom + hysteresis) {
      _lastZoom += hysteresis * 0.8;
    } else if (baseZoom < _lastZoom - hysteresis) {
      _lastZoom -= hysteresis * 0.8;
    }

    // 6. Screen size adaptation
    final double dpiFactor = (screenWidth / 360.0).clamp(0.8, 1.2);
    _lastZoom *= dpiFactor;

    // 7. Final clamping and update
    _lastZoom = _lastZoom.clamp(_minZoom, _maxZoom);
    _lastSpeed = speed;
    _lastUpdate = DateTime.now();

    return _lastZoom;
  }

  static double _calculateNextTurnDistance(List<LatLng> route) {
    // Implementation for turn detection algorithm
    // يمكن استخدام خوارزمية اكتشاف التغيرات في الاتجاه
    return double.infinity;
  }
}
