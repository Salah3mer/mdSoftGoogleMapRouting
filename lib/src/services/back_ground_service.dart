import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mdsoft_google_map_routing/src/services/location_service.dart'
    as location_service;
import 'package:mdsoft_google_map_routing/src/utils/socket_service.dart' as io;

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  final locationService = location_service.LocationService();
  Timer? updateTimer;
  final backgroundLocation = BackgroundServiceLocation();
  final socketService = io.SocketService();
  socketService.initializeSocket(socketBaseUrl: 'http://192.168.1.58:1210/');

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((_) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((_) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((_) {
    debugPrint('Service Stop');
    updateTimer?.cancel();
    backgroundLocation.clearLocation();
    service.stopSelf();
    service.invoke("stop");
  });

  service.on('updateLocation').listen((event) {
    if (event != null) {
      final lat = event['lat'];
      final lng = event['lng'];
      final tripId = event['tripId'];
      final driverId = event['driverId'];
      if (lat != null && lng != null && tripId != null && driverId != null) {
        backgroundLocation.setTripId(tripId);
        backgroundLocation.setDriverId(driverId);
        backgroundLocation.updateLocation(LatLng(lat, lng));
        if (event['destLat'] != null && event['destLng'] != null) {
          if (locationService.isAtDestination(LatLng(lat, lng),
              LatLng(event['destLat'] as double, event['destLng'] as double))) {
            service.invoke('stopService');
          }
        }
        debugPrint('Update BackgroundServiceLocation : $lat, $lng');
      } else {
        debugPrint('Invalid location data: lat=$lat, lng=$lng');
      }
    }
  });

  updateTimer = Timer.periodic(
    const Duration(seconds: 3),
    (timer) async {
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          service.setForegroundNotificationInfo(
            title: 'دليل الرحلة الذكي',
            content: 'يتم تحديث موقعك لحظياً لضمان رحلة آمنة',
          );

          debugPrint('ForegroundService is running at \\${DateTime.now()}');
          debugPrint(
              'Current location : \\${backgroundLocation.currentLocation?.latitude}, \\${backgroundLocation.currentLocation?.longitude} , tripId : \\${backgroundLocation.tripId} , driverId : \\${backgroundLocation.driverId}');

          if (socketService.socket.connected) {
            final currentLocation = backgroundLocation.currentLocation;
            final tripId = backgroundLocation.tripId;
            final driverId = backgroundLocation.driverId;

            if (currentLocation != null && tripId != null && driverId != null) {
              final lastSentLocation = backgroundLocation.lastSentLocation;
              final lastSentTripId = backgroundLocation.lastSentTripId;
              final lastSentDriverId = backgroundLocation.lastSentDriverId;

              bool locationChanged =
                  _hasLocationChanged(currentLocation, lastSentLocation);
              bool tripIdChanged = tripId != lastSentTripId;
              bool driverIdChanged = driverId != lastSentDriverId;

              if (locationChanged || tripIdChanged || driverIdChanged) {
                debugPrint('Socket connected - sending updated location');
                socketService.sendMessage('location', {
                  'latitude': currentLocation.latitude,
                  'longitude': currentLocation.longitude,
                  'tripId': tripId,
                  'driverId': driverId,
                });
                backgroundLocation.updateLastSentData(
                    currentLocation, tripId, driverId);
              } else {
                debugPrint(
                    'Location, tripId, and driverId unchanged - skipping send');
              }
            } else {
              debugPrint('Missing data: location, tripId, or driverId is null');
            }
          } else {
            debugPrint('Socket not connected - skipping send');
          }
        }
      }
      debugPrint('BackgroundService is running at \\${DateTime.now()}');
      service.invoke('update');
    },
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

class BackGroundService {
  final FlutterBackgroundService service = FlutterBackgroundService();

  Future<void> initializeService() async {
    await service.configure(
        iosConfiguration: IosConfiguration(
          onForeground: onStart,
          onBackground: onIosBackground,
          autoStart: true,
        ),
        androidConfiguration: AndroidConfiguration(
          onStart: onStart,
          isForegroundMode: true,
          autoStartOnBoot: false,
          autoStart: true,
        ));
  }
}

class BackgroundServiceLocation extends ChangeNotifier {
  static final BackgroundServiceLocation _instance =
      BackgroundServiceLocation._internal();
  LatLng? _currentLocation;
  String? _tripId;
  String? _driverId;
  LatLng? _lastSentLocation;
  String? _lastSentTripId;
  String? _lastSentDriverId;
  final List<LatLng> _locationHistory = [];
  static const int _maxHistoryLength = 3;

  BackgroundServiceLocation._internal();

  factory BackgroundServiceLocation() => _instance;

  LatLng? get currentLocation => _currentLocation;
  String? get tripId => _tripId;
  String? get driverId => _driverId;
  List<LatLng> get locationHistory => _locationHistory;
  LatLng? get lastSentLocation => _lastSentLocation;
  String? get lastSentTripId => _lastSentTripId;
  String? get lastSentDriverId => _lastSentDriverId;

  void updateLocation(LatLng? newLocation) {
    _currentLocation = newLocation;
    if (newLocation != null) {
      _locationHistory.add(newLocation);
      if (_locationHistory.length > _maxHistoryLength) {
        _locationHistory.removeAt(0);
      }
    }
    notifyListeners();
  }

  void setTripId(String id) {
    _tripId = id;
    notifyListeners();
  }

  void setDriverId(String id) {
    _driverId = id;
    notifyListeners();
  }

  void updateLastSentData(LatLng location, String tripId, String driverId) {
    _lastSentLocation = location;
    _lastSentTripId = tripId;
    _lastSentDriverId = driverId;
    notifyListeners();
  }

  void clearLocation() {
    _currentLocation = null;
    _tripId = null;
    _driverId = null;
    _locationHistory.clear();
    _lastSentLocation = null;
    _lastSentTripId = null;
    _lastSentDriverId = null;
    notifyListeners();
  }
}

bool _hasLocationChanged(LatLng currentLocation, LatLng? lastLocation) {
  if (lastLocation == null) return true;
  const double threshold = 0.0001;
  return (currentLocation.latitude - lastLocation.latitude).abs() > threshold ||
      (currentLocation.longitude - lastLocation.longitude).abs() > threshold;
}
