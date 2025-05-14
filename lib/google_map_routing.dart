import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mdsoft_google_map_routing/src/cubit/google_map_cubit.dart';
import 'package:mdsoft_google_map_routing/src/models/md_soft_lat_lng.dart';
import 'package:mdsoft_google_map_routing/src/services/back_ground_service.dart';
import 'package:mdsoft_google_map_routing/src/services/location_service.dart';
import 'package:mdsoft_google_map_routing/src/services/toastification_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mdsoft_google_map_routing/src/utils/constants.dart';
import 'package:toastification/toastification.dart';
export 'src/cubit/google_map_cubit.dart';
export 'src/repositories/google_map_repo_impl.dart';
export 'src/services/location_service.dart';
export 'src/utils/constants.dart';
export 'src/utils/app_images.dart';
export 'src/models/md_soft_lat_lng.dart';

class MdSoftGoogleMapRouting extends StatelessWidget {
  final String? mapStyle;
  final MdSoftLatLng startLocation;
  final MdSoftLatLng endLocation;
  final List<MdSoftLatLng> waypoints;
  final List<String> pointsName;
  final bool isUser;
  final MdSoftLatLng carPosstion;

  const MdSoftGoogleMapRouting({
    super.key,
    this.mapStyle,
    this.isUser = false,
    this.waypoints = const [],
    this.pointsName = const [],
    required this.endLocation,
    required this.startLocation,
    required this.carPosstion,
  });

  /// test
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GoogleMapCubit(),
      child: BlocConsumer<GoogleMapCubit, GoogleMapState>(
        listener: (context, state) {
          if (state is GetLocationErrorState) {
            showToastificationWidget(
              message: state.errorMessage,
              context: context,
            );
          }
          if (state is GetPlaceDetailsErrorState) {
            showToastificationWidget(
              message: state.errorMessage,
              context: context,
            );
          }

          if (state is GetDirectionsErrorState) {
            showToastificationWidget(
              message: state.errorMessage,
              context: context,
            );
          }
          if (state is GetRoutesFailureState) {
            showToastificationWidget(
              message: state.failure,
              context: context,
            );
          }
          if (state is DestinationReachedState) {
            showToastificationWidget(
              message: 'تم الوصول الي وجهتك',
              context: context,
              notificationType: ToastificationType.success,
            );
            if (state.isecRoute <= 1) {
              var cubit = context.read<GoogleMapCubit>();
              cubit.polyLines.clear();
              cubit.markers.clear();
              cubit.getDirectionsRoute(
                origin: startLocation.googleLatLng,
                destinationLocation: endLocation.googleLatLng,
                waypoints: waypoints,
                pointsName: pointsName,
              );
            }
          }
        },
        builder: (context, state) {
          var cubit = context.read<GoogleMapCubit>();
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                GoogleMapWidget(
                    carPosition: carPosstion,
                    pointsName: pointsName,
                    waypoints: waypoints,
                    isUser: isUser,
                    cubit: cubit,
                    mapStyle: mapStyle,
                    startLocation: startLocation,
                    endLocation: endLocation),
              ],
            ),
          );
        },
      ),
    );
  }
}

class GoogleMapWidget extends StatefulWidget {
  const GoogleMapWidget({
    super.key,
    required this.pointsName,
    required this.waypoints,
    required this.cubit,
    required this.mapStyle,
    required this.startLocation,
    required this.endLocation,
    required this.isUser,
    required this.carPosition,
  });

  final bool isUser;
  final List<String> pointsName;
  final GoogleMapCubit cubit;
  final String? mapStyle;
  final MdSoftLatLng startLocation;
  final MdSoftLatLng endLocation;
  final MdSoftLatLng carPosition;
  final List<MdSoftLatLng> waypoints;

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isUser) {
        _initLocationForUser();
      } else {
        BackGroundService().initializeService().then((_) {
          FlutterBackgroundService().invoke('setAsForeground');
          Future.delayed(const Duration(seconds: 1), () {
            widget.cubit.getMyStreemLocation();
          });
        });
      }
    });
  }

  @override
  void dispose() {
    if (widget.isUser) {
      _stopTracking();
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _initLocationForUser() async {
    await widget.cubit.initializeDataAndSocket();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint("AppLifecycleState: $state");
    if (state == AppLifecycleState.detached) {
      _stopTracking();
      FlutterBackgroundService().invoke('stopService');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      markers: widget.cubit.markers,
      polylines: widget.cubit.polyLines,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      rotateGesturesEnabled: false,
      compassEnabled: false,
      initialCameraPosition: widget.cubit.cameraPosition,
      myLocationEnabled: false,
      onMapCreated: (GoogleMapController controller) async {
        widget.cubit.googleMapController = controller;
        widget.cubit.getMapStyle(mapStyle: widget.mapStyle!);
        await widget.cubit.getLocationMyCurrentLocation().then((_) {
          widget.cubit.getDirectionsRoute(
            origin: widget.isUser
                ? widget.carPosition.googleLatLng
                : widget.cubit.currentLocation,
            isFromDriverToUser: true,
            destinationLocation: widget.startLocation.googleLatLng,
            waypoints: [],
            pointsName: [
              'Current Location For the Driver',
              widget.pointsName[0],
            ],
          );
        });
      },
    );
  }
}

class IconBack extends StatelessWidget {
  const IconBack({super.key});

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      top: 48,
      start: 16,
      child: Container(
        height: 42,
        width: 42,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _stopTracking();
          },
          color: GoogleMapConfig.primaryColor,
        ),
      ),
    );
  }
}

void _stopTracking() {
  final locationService = LocationService();
  FlutterBackgroundService().invoke('stopService');
  locationService.stopTracking();
  debugPrint("Tracking and background service have been stopped.");
}
