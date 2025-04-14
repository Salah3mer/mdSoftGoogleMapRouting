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
  final Widget? floatingActionButtonIcon;
  final String? mapStyle;
  final MdSoftLatLng startLocation;
  final MdSoftLatLng endLocation;
  final List<MdSoftLatLng> waypoints;
  final bool isUser;
  const MdSoftGoogleMapRouting(
      {super.key,
      this.floatingActionButtonIcon,
      this.mapStyle,
      this.isUser = false,
      this.waypoints = const [],
      required this.endLocation,
      required this.startLocation});

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
        }
      }, builder: (context, state) {
        var cubit = context.read<GoogleMapCubit>();
        return Scaffold(
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                GoogleMapWidget(
                    waypoints: waypoints,
                    isUser: isUser,
                    cubit: cubit,
                    mapStyle: mapStyle,
                    startLocation: startLocation,
                    endLocation: endLocation),
                isUser ? const SizedBox.shrink() : const IconBack(),
              ],
            ),
            floatingActionButton: isUser
                ? const SizedBox.shrink()
                : SizedBox(
                    height: 46,
                    width: 46,
                    child: FloatingActionButton(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        side: BorderSide(color: Colors.transparent),
                      ),
                      backgroundColor: Colors.white.withValues(alpha: .9),
                      onPressed: () async {
                        BackGroundService().initializeService();
                        FlutterBackgroundService().invoke('setAsForeground');
                        cubit.getMyStreemLocation();
                      },
                      child: floatingActionButtonIcon ??
                          Icon(
                            Icons.my_location,
                            color: GoogleMapConfig.primaryColor,
                          ),
                    ),
                  ));
      }),
    );
  }
}

class GoogleMapWidget extends StatefulWidget {
  const GoogleMapWidget({
    super.key,
    required this.waypoints,
    required this.cubit,
    required this.mapStyle,
    required this.startLocation,
    required this.endLocation,
    required this.isUser,
  });
  final bool isUser;
  final GoogleMapCubit cubit;
  final String? mapStyle;
  final MdSoftLatLng startLocation;
  final MdSoftLatLng endLocation;
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

    if (widget.isUser) {
      _initLocationForUser();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  void _initLocationForUser() async {
    widget.cubit.initializeDataAndSocket();
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
            origin: widget.startLocation.googleLatLng,
            destination: widget.endLocation.googleLatLng,
            waypoints: widget.waypoints,
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
