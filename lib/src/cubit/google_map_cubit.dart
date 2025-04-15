import 'dart:async';
import 'dart:math';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mdsoft_google_map_routing/google_map_routing.dart';
import 'package:mdsoft_google_map_routing/src/api/dio_client.dart';
import 'package:mdsoft_google_map_routing/src/api/failure.dart';
import 'package:mdsoft_google_map_routing/src/models/dirction_route_model/dirction_route_model.dart';
import 'package:mdsoft_google_map_routing/src/models/route_body_model/destination.dart';
import 'package:mdsoft_google_map_routing/src/models/route_body_model/lat_lng.dart';
import 'package:mdsoft_google_map_routing/src/models/route_body_model/location.dart';
import 'package:mdsoft_google_map_routing/src/models/route_body_model/origin.dart';
import 'package:mdsoft_google_map_routing/src/models/route_body_model/route_body_model.dart';
import 'package:mdsoft_google_map_routing/src/models/routes_model/routes_model.dart';
import 'package:mdsoft_google_map_routing/src/repositories/google_map_repo_impl.dart';
import 'package:mdsoft_google_map_routing/src/services/camira_service.dart';
import 'package:mdsoft_google_map_routing/src/services/location_service.dart';
import 'package:mdsoft_google_map_routing/src/utils/app_images.dart';
import 'package:mdsoft_google_map_routing/src/utils/constants.dart';
import 'package:mdsoft_google_map_routing/src/utils/extension.dart';
import 'package:mdsoft_google_map_routing/src/services/line_service.dart';
import 'package:mdsoft_google_map_routing/src/services/polyline_decoder.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mdsoft_google_map_routing/src/utils/socket_service.dart';
part 'google_map_state.dart';

class GoogleMapCubit extends Cubit<GoogleMapState> {
  GoogleMapCubit() : super(GoogleMapInitial());
  GoogleMapController? googleMapController;
  GoogleMapRepoImpl googleMapRepoImpl =
      GoogleMapRepoImpl(dioClient: DioClient(Dio()));
  LocationService locationService = LocationService();

  CameraPosition cameraPosition = const CameraPosition(
    target: LatLng(0.0, 0.0),
    bearing: 0.0,
    tilt: 0.0,
    zoom: 0,
  );

  Set<Marker> markers = {};
  Set<Polyline> polyLines = {};
  late LatLng currentLocation;
  LatLng? carLocation;

//? getLocation
  Future<void> getLocationMyCurrentLocation() async {
    try {
      LocationData locationData = await locationService.getLocation();
      currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
      var myCameraPosition = CameraPosition(target: currentLocation, zoom: 17);
      googleMapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          myCameraPosition,
        ),
      );
      updateCarMarker();

      emit(GetLocationSuccessState());
    } on LocationServiceException catch (_) {
      emit(GetLocationErrorState(
          errorMessage: 'Please Check your location Serveice  '));
    } on LocationPermissionException catch (_) {
      emit(GetLocationErrorState(
          errorMessage: 'Please Check your  Location Permission '));
    }
  }

  ///? getMyStreemLocation
  double oldBearing = 0.0;
  double oldTilt = 0.0;
  DateTime lastUpdate = DateTime.now();
  bool _hasEmittedDestinationReached = false;
  Future<void> getMyStreemLocation() async {
    try {
      _hasEmittedDestinationReached = false;
      locationService.getRealTimeLocationData(
        (locationData) {
          if (locationData.latitude == null || locationData.longitude == null) {
            return;
          }

          if (DateTime.now().difference(lastUpdate).inMilliseconds < 500) {
            return;
          }
          LatLng newLocation =
              LatLng(locationData.latitude!, locationData.longitude!);
          debugPrint('newLocation: $newLocation');

          final newBearing = locationData.heading ??
              CamiraService.getBearing(currentLocation, newLocation);
          final bearing =
              CamiraService.smoothBearing(oldBearing, newBearing, 0.2);
          final tilt = CamiraService.getTilt(locationData.speed ?? 0.0)
              .clamp(20.0, 45.0);
          final double smoothtilt =
              CamiraService.smoothTilt(oldTilt, tilt, 0.2);
          if (_hasEmittedDestinationReached) return;
          if (locationService.isAtDestination(newLocation, destination)) {
            _hasEmittedDestinationReached = true;
            FlutterBackgroundService().invoke('stopService');
            locationService.stopTracking();
            emit(DestinationReachedState());

            return;
          }

          currentLocation = newLocation;
          oldBearing = bearing;
          oldTilt = smoothtilt;

          updateRoute(newLocation);
          updateCarMarker();

          googleMapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: newLocation,
                zoom:
                    CamiraService.calculateZoom(speed: locationData.speed ?? 0),
                bearing: bearing,
                tilt: smoothtilt,
              ),
            ),
          );
          lastUpdate = DateTime.now();
          FlutterBackgroundService().invoke(
            'updateLocation',
            {
              'lat': newLocation.latitude,
              'lng': newLocation.longitude,
              'destLat': destination.latitude,
            },
          );
          emit(GetMyStreemLocationSuccessState());
        },
      );
    } on LocationServiceException catch (_) {
      emit(GetLocationErrorState(
          errorMessage: 'Please Check your location Serveice  '));
    } on LocationPermissionException catch (_) {
      emit(GetLocationErrorState(
          errorMessage: 'Please Check your  Location Permission '));
    }
  }

  late SocketService socketService = SocketService();

  Future<void> initializeDataAndSocket() async {
    try {
      socketService.initializeSocket();
      socketService.onMessage('location', (locationData) async {
        if (locationData != null) {}
        if (locationData['latitude'] == null ||
            locationData['longitude'] == null) {
          return;
        }
        LatLng newLocation =
            LatLng(locationData['latitude']!, locationData['longitude']!);
        debugPrint('newLocation: $newLocation');
        updateRoute(newLocation);
        carLocation = newLocation;
        updateCarMarker(isUser: true);

        googleMapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: newLocation,
              zoom: 17,
              bearing: 0,
              tilt: 0,
            ),
          ),
        );
        lastUpdate = DateTime.now();
      });
    } catch (e) {
      debugPrint('Error initializing data and socket: $e');
    }
  }

//? getMapStyle
  late String mapStyleString;
  Color primaryColor = GoogleMapConfig.primaryColor!;
  Future<void> getMapStyle(
      {required String mapStyle, Color? primaryColor}) async {
    mapStyleString = await rootBundle.loadString(mapStyle);
    this.primaryColor = primaryColor ?? this.primaryColor;
    googleMapController!.setMapStyle(mapStyleString);
    emit(GetMapStyleSuccessState());
  }

  //? getDirections
  DirctionRouteModel? routeModel;
  late LatLng destination;
  Future<void> getDirectionsRoute({
    required LatLng origin,
    required LatLng destination,
    required List<MdSoftLatLng> waypoints,
    required List<String> pointsName,
  }) async {
    final latlonWaypoints =
        waypoints.map((e) => LatLng(e.latitude, e.longitude)).toList();
    final result = await googleMapRepoImpl.getDirections(
        origin: origin, destination: destination, waypoints: latlonWaypoints);
    result.fold(
      (l) {
        debugPrint(l.message.toString());
        emit(GetDirectionsErrorState(errorMessage: l.message));
      },
      (r) async {
        routeModel = r;
        this.destination = destination;
        await setMarkers(
            startLocation: origin,
            destination: destination,
            pointsName: pointsName,
            waypoints: latlonWaypoints);
        await getBounds(routeModel!.coordinates);
        updateRoute(origin);
        emit(GetDirectionsSuccessState());
      },
    );
  }

  //? getRoutes

  Future<void> getRoutes() async {
    emit(GetRoutesLoadingState());
    Either<Failure, RoutesModel> result = await googleMapRepoImpl.getRoutes(
      routeBodyModel: RouteBodyModel(
        origin: Origin(
          location: LocationModel(
            latLng: LatLngModel(
              latitude: currentLocation.latitude,
              longitude: currentLocation.longitude,
            ),
          ),
        ),
        destination: Destination(
          location: LocationModel(
            latLng: LatLngModel(
              latitude: destination.latitude,
              longitude: destination.longitude,
            ),
          ),
        ),
      ),
    );
    result.fold(
      (failure) {
        emit(GetRoutesFailureState(failure: failure.message));
      },
      (routesModel) async {
        List<LatLng> pointsForRoute = getPointsForRoute(
          encodedPolyline: routesModel.routes!.first.polyline!.encodedPolyline!,
        );
        updateRoute(currentLocation);
        await getBounds(pointsForRoute);
        emit(GetRoutesSuccessState());
      },
    );
  }

  List<LatLng> getPointsForRoute({required String encodedPolyline}) {
    return PolylineDecoder.run(encodedPolyline);
  }

  //? updateRoute
  LineService lineService = LineService();
  void updateRoute(LatLng currentPosition) {
    if (routeModel == null || routeModel!.coordinates.isEmpty) return;
    final fullRoute = routeModel!.coordinates;
    // 1. إيجاد أقرب قطعة
    final closestIndex =
        lineService.findClosestSegmentIndex(fullRoute, currentPosition);
    // 2. حساب النقطة الأقرب على القطعة
    final closestPoint = lineService.getClosestPointOnSegment(
      currentPosition,
      fullRoute[closestIndex],
      fullRoute[closestIndex + 1],
    );
    // 3. تقسيم المسار
    final completedRoute = [
      ...fullRoute.sublist(0, closestIndex + 1),
      closestPoint,
    ];
    final remainingRoute = [
      closestPoint,
      ...fullRoute.sublist(closestIndex + 1),
    ];
    // 4. تحديث الخطوط
    polyLines.clear();
    // الخط المكتمل
    polyLines.add(
      Polyline(
        width: 5,
        endCap: Cap.roundCap,
        startCap: Cap.roundCap,
        jointType: JointType.round,
        points: completedRoute,
        color: primaryColor.withOpacity(.32),
        patterns: [PatternItem.dash(15), PatternItem.gap(15)],
        polylineId: const PolylineId('completedRoute'),
      ),
    );

    // الخط المتبقي
    polyLines.add(
      Polyline(
        width: 5,
        endCap: Cap.roundCap,
        startCap: Cap.roundCap,
        jointType: JointType.round,
        points: remainingRoute,
        color: primaryColor,
        polylineId: const PolylineId('remainingRoute'),
      ),
    );
    emit(UpdateRouteSuccessState());
  }

  ///? setMarkers
  Future<void> setMarkers(
      {required LatLng startLocation,
      required LatLng destination,
      required List<LatLng> waypoints,
      required List<String> pointsName,
      bool isUser = false}) async {
    markers.add(
      Marker(
        markerId: const MarkerId('startLocation'),
        position: startLocation,
        infoWindow: InfoWindow(title: pointsName[0]),
        icon: await AppImages.from.toBitmapDescriptor(devicePixelRatio: 2.5),
      ),
    );

    markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: destination,
        infoWindow: InfoWindow(title: pointsName[1]),
        icon: await AppImages.goTo.toBitmapDescriptor(devicePixelRatio: 2.5),
      ),
    );
    if (waypoints.isNotEmpty) {
      for (var i = 0; i < waypoints.length; i++) {
        markers.add(Marker(
          markerId: MarkerId('waypoint $i '),
          position: waypoints[i],
          infoWindow: InfoWindow(title: pointsName[i + 2]),
          icon: await AppImages.point.toBitmapDescriptor(devicePixelRatio: 2.5),
        ));
      }
    }

    markers.removeWhere((marker) => marker.markerId.value == 'car');

    markers.add(
      Marker(
        markerId: const MarkerId('car'),
        position: isUser ? carLocation ?? const LatLng(0, 0) : currentLocation,
        icon: await AppImages.car.toBitmapDescriptor(devicePixelRatio: 2.5),
        rotation: 0, // أول مرة بدون دوران
      ),
    );

    emit(SetMarkersSuccessState());
  }

  //? updateCarMarker
  Future<void> updateCarMarker({isUser = false}) async {
    markers.removeWhere((marker) => marker.markerId.value == 'car');
    markers.add(
      Marker(
        markerId: const MarkerId('car'),
        position: isUser ? carLocation ?? const LatLng(0, 0) : currentLocation,
        icon: await AppImages.car.toBitmapDescriptor(devicePixelRatio: 2.5),
      ),
    );

    emit(SetMarkersSuccessState());
  }

  ///? getBounds
  Future<void> getBounds(List<LatLng> coordinates) async {
    var southWestLat = coordinates.first.latitude;
    var southWestLng = coordinates.first.longitude;
    var northEastlat = coordinates.first.latitude;
    var northEastLng = coordinates.first.longitude;

    for (var point in coordinates) {
      southWestLat = min(southWestLat, point.latitude);
      southWestLng = min(southWestLng, point.longitude);
      northEastlat = max(northEastlat, point.latitude);
      northEastLng = max(northEastLng, point.longitude);
    }

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(southWestLat, southWestLng),
      northeast: LatLng(northEastlat, northEastLng),
    );

    googleMapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        bounds,
        40,
      ),
    );
    emit(GetBoundsSuccessState());
  }
}
