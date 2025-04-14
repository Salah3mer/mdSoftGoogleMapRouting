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
  //?? Initialize Flutter and DartPlugin
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  final locationService = location_service.LocationService();
  Timer? updateTimer;
  final backgroundLocation = BackgroundServiceLocation();
  final socketService = io.SocketService();
  socketService.initializeSocket(socketBaseUrl: 'http://192.168.1.24:3000/');

  //* Set service states on Android (foreground / background)
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen(
      (_) {
        service.setAsForegroundService();
      },
    );
    service.on('setAsBackground').listen(
      (_) {
        service.setAsBackgroundService();
      },
    );
  }

  //! Listen for stop service request
  service.on('stopService').listen(
    (_) {
      debugPrint('Service Stop');
      updateTimer?.cancel();
      backgroundLocation.clearLocation();
      service.stopSelf();
      service.invoke("stop");
    },
  );

  //*********  Register listener for "updateLocation" event
  service.on('updateLocation').listen(
    (event) {
      if (event != null) {
        final lat = event['lat'];
        final lng = event['lng'];
        if (lat != null && lng != null) {
          //?  Update location and notify listeners
          backgroundLocation.updateLocation(LatLng(lat, lng));
          if (event['destLat'] != null && event['destLng'] != null) {
            if (locationService.isAtDestination(
                LatLng(lat, lng),
                LatLng(
                    event['destLat'] as double, event['destLng'] as double))) {
              service.invoke('stopService');
            }
          }
          debugPrint('Update BackgroundServiceLocation : $lat, $lng');
        } else {
          debugPrint('Invalid location data: lat=$lat, lng=$lng');
        }
      }
    },
  );

  updateTimer = Timer.periodic(
    const Duration(seconds: 3),
    (timer) async {
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          service.setForegroundNotificationInfo(
            title: 'دليل الرحلة الذكي',
            content: 'يتم تحديث موقعك لحظياً لضمان رحلة آمنة',
          );

          debugPrint('ForegroundService is running at ${DateTime.now()}');
          debugPrint(
              'Current location : ${backgroundLocation.currentLocation?.latitude}, ${backgroundLocation.currentLocation?.longitude}');

          if (socketService.socket.connected) {
            socketService.sendMessage('location', {
              'latitude': backgroundLocation.currentLocation?.latitude,
              'longitude': backgroundLocation.currentLocation?.longitude,
            });
          } else {
            debugPrint('Socket not connected - skipping send');
          }
        }
      }
      debugPrint('BackgroundService is running at ${DateTime.now()}');
      //?  Update location and notify listeners
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
      ),
    );
  }
}

class BackgroundServiceLocation extends ChangeNotifier {
  static final BackgroundServiceLocation _instance =
      BackgroundServiceLocation._internal();
  LatLng? _currentLocation;

  BackgroundServiceLocation._internal();

  factory BackgroundServiceLocation() => _instance;

  LatLng? get currentLocation => _currentLocation;

  void updateLocation(LatLng newLocation) {
    _currentLocation = newLocation;
    notifyListeners();
  }

  void clearLocation() {
    _currentLocation = null;
    notifyListeners();
  }
}
