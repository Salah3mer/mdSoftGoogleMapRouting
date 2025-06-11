import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mdsoft_google_map_routing/google_map_routing.dart';
import 'package:mdsoft_google_map_routing_example/test_screen.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await Permission.notification.isDenied.then((value) async {
      if (value) {
        await Permission.notification.request();
      }
    });
  }
  await Permission.notification.isPermanentlyDenied.then((value) async {
    if (value) {
      await openAppSettings();
    }
  });
  if (!kIsWeb) {
    await requestLocationPermissions();
  }

  GoogleMapConfig.initialize(
      apiKey: 'API_KEY_HERE',
      socketBaseUrl: 'http://192.168.1.58:1210/');

  GoogleMapConfig.tripStatusListener.listen((status) {
    debugPrint("Trip Status: $status");
    switch (status) {
      case TripStatus.driverArrived:
        debugPrint("Driver has arrived to user.");
        break;
      case TripStatus.completed:
        debugPrint("Trip has been completed.");
        break;
      case TripStatus.cancelled:
        debugPrint("Trip has been cancelled.");
        break;
    }
  });
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TestScreen(),
    );
  }
}

class MapScreen extends StatelessWidget {
  const MapScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map Routing Demo'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.back_hand,
                color: Colors.black,
              )),
        ],
      ),
      body: MdSoftGoogleMapRouting(
        isUser: true,
        mapStyle: 'assets/json/map_style.json',
        waypoints: const [
          // MdSoftLatLng(30.704706366785057, 31.267074854681997),
          // MdSoftLatLng(30.70392502951272, 31.264789095920797)
        ],
        tripId: '6849443fc18ee0129c3b7ee8',
        driverId: '68481db7e4d29e0b70233043',
        pointsName: const [
          'بغداد - ٧ نيسان - زيونة - 712-18، بغداد، بغداد محافظة، العراق',
          'غداد - ٧ نيسان - الفضلية - الفضلية، بغداد، بغداد محافظة،',
          'point3',
          'point4'
        ],
        startLocation: MdSoftLatLng(33.324109627459805, 44.454690468237736),
        endLocation: MdSoftLatLng(33.3389507346804, 44.5090551674366),
        carPosstion: MdSoftLatLng(33.29801593950077, 44.350535916400325),
      ),
    );
  }
}

Future<bool> requestLocationPermissions() async {
  // Request foreground location permission first.
  PermissionStatus foregroundStatus =
      await Permission.locationWhenInUse.request();
  if (!foregroundStatus.isGranted) {
    print("Foreground location permission denied");
    return false;
  }

  // Then request background location permission.
  PermissionStatus backgroundStatus = await Permission.locationAlways.request();
  if (!backgroundStatus.isGranted) {
    print("Background location permission denied");
    return false;
  }

  print("Both foreground and background location permissions granted");
  return true;
}
