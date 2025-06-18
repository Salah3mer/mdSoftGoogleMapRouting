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
import 'package:mdsoft_google_map_routing/src/utils/socket_service.dart';
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
  final String? tripId;
  final String? driverId;
  final bool isViewTrip;

  const MdSoftGoogleMapRouting({
    super.key,
    this.mapStyle,
    this.isUser = false,
    this.waypoints = const [],
    this.pointsName = const [],
    required this.endLocation,
    required this.startLocation,
    required this.carPosstion,
    this.tripId,
    this.driverId,
    this.isViewTrip = false,
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
            // if (state.isecRoute > 1) {
            //   GoogleMapConfig.tripStatusController.add(TripStatus.completed);
            // }
            // if (state.isecRoute <= 1) {
            //   GoogleMapConfig.tripStatusController
            //       .add(TripStatus.driverArrived);
            //   var cubit = context.read<GoogleMapCubit>();
            //   cubit.polyLines.clear();
            //   cubit.markers.clear();
            //   cubit.getDirectionsRoute(
            //     origin: startLocation.googleLatLng,
            //     destinationLocation: endLocation.googleLatLng,
            //     waypoints: waypoints,
            //     pointsName: pointsName,
            //   );
            // }
          }
        },
        builder: (context, state) {
          var cubit = context.read<GoogleMapCubit>();
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                GoogleMapWidget(
                    isViewTrip: isViewTrip,
                    tripId: tripId,
                    driverId: driverId,
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
    required this.isViewTrip,
    this.tripId,
    this.driverId,
  });

  final bool isUser;
  final bool isViewTrip;
  final List<String> pointsName;
  final GoogleMapCubit cubit;
  final String? mapStyle;
  final MdSoftLatLng startLocation;
  final MdSoftLatLng endLocation;
  final MdSoftLatLng carPosition;
  final List<MdSoftLatLng> waypoints;
  final String? tripId;
  final String? driverId;

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    print(
        "GoogleMapWidget initState called with tripId: ${widget.tripId}, driverId: ${widget.driverId} isUser: ${widget.isUser} isViewTrip: ${widget.isViewTrip} carPosition: ${widget.carPosition.googleLatLng} startLocation: ${widget.startLocation.googleLatLng} endLocation: ${widget.endLocation.googleLatLng} waypoints: ${widget.waypoints.map((e) => e.googleLatLng).toList()} pointsName: ${widget.pointsName} mapStyle: ${widget.mapStyle} ");
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isUser) {
        {
          GoogleMapConfig.tripStatusListener.listen((status) {
            debugPrint("Trip Status: $status");
            switch (status) {
              case TripStatus.driverArrived:
                {
                  var cubit = widget.cubit;
                  cubit.polyLines.clear();
                  cubit.markers.clear();
                  cubit.getDirectionsRoute(
                    origin: cubit.carLocation!,
                    destinationLocation: widget.endLocation.googleLatLng,
                    waypoints: widget.waypoints,
                    pointsName: widget.pointsName,
                  );
                }
                break;
              case TripStatus.completed:
                debugPrint("Trip has been completed.");
                break;
              case TripStatus.cancelled:
                debugPrint("Trip has been cancelled.");
                break;
            }
          });
        }
        _initLocationForUser();
      } else {
        BackGroundService().initializeService().then((_) {
          FlutterBackgroundService().invoke('setAsForeground');
          Future.delayed(const Duration(seconds: 1), () {
            widget.cubit.getMyStreemLocation(
                tripId: widget.tripId, driverId: widget.driverId);
          });
        });
      }
    });
  }

  @override
  void dispose() {
    if (!widget.isUser) {
      _stopTracking();
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _initLocationForUser() async {
    await widget.cubit.initializeDataAndSocket(tripId: widget.tripId!);
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
        await widget.cubit
            .getLocationMyCurrentLocation(
                carPosition: widget.carPosition.googleLatLng,
                isUser: widget.isUser)
            .then((_) {
          widget.cubit.getDirectionsRoute(
            isUser: widget.isUser,
            origin: widget.isUser
                ? widget.carPosition.googleLatLng
                : widget.cubit.currentLocation,
            isFromDriverToUser: true,
            destinationLocation: widget.startLocation.googleLatLng,
            waypoints: widget.isViewTrip ? widget.waypoints : [],
            pointsName: widget.isViewTrip
                ? widget.pointsName
                : [
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
