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
      apiKey: 'API-KEY', socketBaseUrl: 'http://192.168.1.24:3000/');
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
        startLocation: MdSoftLatLng(30.7052, 31.2677),
        endLocation: MdSoftLatLng(30.706341997359363, 31.26516825147782),
        floatingActionButtonIcon:
            const Icon(Icons.my_location, color: Colors.black),
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
