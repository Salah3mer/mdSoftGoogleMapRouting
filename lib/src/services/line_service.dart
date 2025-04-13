import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LineService {
  int findClosestSegmentIndex(List<LatLng> fullRoute, LatLng currentPosition) {
    double minDistance = double.maxFinite;
    int closestIndex = 0;

    for (int i = 0; i < fullRoute.length - 1; i++) {
      final distance = distanceToSegment(
        currentPosition,
        fullRoute[i],
        fullRoute[i + 1],
      );

      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }
    return closestIndex;
  }

  double distanceToSegment(LatLng p, LatLng a, LatLng b) {
    double lat1 = a.latitude, lon1 = a.longitude;
    double lat2 = b.latitude, lon2 = b.longitude;
    double lat3 = p.latitude, lon3 = p.longitude;

    // ✅ تحويل الدرجات إلى راديان
    double toRadians(double degree) => degree * pi / 180;

    lat1 = toRadians(lat1);
    lon1 = toRadians(lon1);
    lat2 = toRadians(lat2);
    lon2 = toRadians(lon2);
    lat3 = toRadians(lat3);
    lon3 = toRadians(lon3);

    // ✅ حساب المسافة بين A و B
    double dLon = lon2 - lon1;
    double dLat = lat2 - lat1;
    double segmentLength = dLat * dLat + dLon * dLon;

    // ✅ إسقاط النقطة P على الخط AB
    double t = ((lat3 - lat1) * dLat + (lon3 - lon1) * dLon) / segmentLength;
    t = t.clamp(0, 1); // نجبر t تكون بين 0 و 1 عشان تكون على القطعة المستقيمة

    // ✅ النقطة الإسقاطية على الخط
    double closestLat = lat1 + t * dLat;
    double closestLon = lon1 + t * dLon;

    // ✅ تحويل الراديان إلى درجات
    closestLat = closestLat * 180 / pi;
    closestLon = closestLon * 180 / pi;

    // ✅ حساب المسافة بين النقطة P والنقطة الإسقاطية
    return haversineDistance(p, LatLng(closestLat, closestLon));
  }

// ✅ دالة تحسب المسافة بين نقطتين باستخدام قانون Haversine
  double haversineDistance(LatLng p1, LatLng p2) {
    const double R = 6371000; // نصف قطر الأرض بالمتر
    double lat1 = toRadians(p1.latitude);
    double lon1 = toRadians(p1.longitude);
    double lat2 = toRadians(p2.latitude);
    double lon2 = toRadians(p2.longitude);

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a =
        pow(sin(dLat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dLon / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // المسافة بالمتر
  }

  double toRadians(double degree) => degree * pi / 180;

  LatLng getClosestPointOnSegment(LatLng p, LatLng a, LatLng b) {
    double lat1 = a.latitude, lon1 = a.longitude;
    double lat2 = b.latitude, lon2 = b.longitude;
    double lat3 = p.latitude, lon3 = p.longitude;

    // ✅ تحويل الدرجات إلى راديان
    double toRadians(double degree) => degree * pi / 180;

    lat1 = toRadians(lat1);
    lon1 = toRadians(lon1);
    lat2 = toRadians(lat2);
    lon2 = toRadians(lon2);
    lat3 = toRadians(lat3);
    lon3 = toRadians(lon3);

    // ✅ حساب اتجاه القطعة المستقيمة A → B
    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;
    double segmentLengthSquared = dLat * dLat + dLon * dLon;

    // ✅ حساب معامل الإسقاط t
    double t =
        ((lat3 - lat1) * dLat + (lon3 - lon1) * dLon) / segmentLengthSquared;
    t = t.clamp(0, 1); // نجبر t تكون بين 0 و 1 عشان تبقى داخل حدود القطعة

    // ✅ تحديد النقطة الإسقاطية على القطعة
    double closestLat = lat1 + t * dLat;
    double closestLon = lon1 + t * dLon;

    // ✅ تحويل الراديان إلى درجات
    closestLat = closestLat * 180 / pi;
    closestLon = closestLon * 180 / pi;

    return LatLng(closestLat, closestLon);
  }
}
