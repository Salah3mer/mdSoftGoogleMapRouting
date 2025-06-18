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
      apiKey: 'API_KEY_HERE', socketBaseUrl: 'http://192.168.1.58:1210/');

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
      body: Stack(
        children: [
          Positioned.fill(
            child: MdSoftGoogleMapRouting(
              isUser: true,
              // isViewTrip: false,
              mapStyle: 'assets/json/map_style.json',
              // waypoints: [
              //   MdSoftLatLng(33.35403511061299, 44.17075417935848),
              //   MdSoftLatLng(33.2148730014512, 44.209555350244045)
              // ],
              tripId: '685279422d0fd21d948a0a59',
              // driverId: '68481db7e4d29e0b70233043',
              pointsName: const [
                'بغداد - ٧ نيسان - زيونة - 712-18، بغداد، بغداد محافظة، العراق',
                'غداد - ٧ نيسان - الفضلية - الفضلية، بغداد، بغداد محافظة،',
                // 'العراق',
                // 'بغداد - ٧ نيسان - زيونة - 712-18، بغداد، بغداد محافظة، العراق',
              ],
              startLocation: MdSoftLatLng(33.3359333, 44.3565117),
              endLocation: MdSoftLatLng(33.31988132874132, 44.330820702016354),
              carPosstion: MdSoftLatLng(33.26444, 44.3105317),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: ElevatedButton(
                onPressed: () {
                  GoogleMapConfig.tripStatusController
                      .add(TripStatus.driverArrived);
                },
                child: const Text('Start Trip')),
          ),
        ],
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
