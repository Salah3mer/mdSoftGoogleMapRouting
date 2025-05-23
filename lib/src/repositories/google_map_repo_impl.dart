import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:mdsoft_google_map_routing/src/api/dio_client.dart';
import 'package:mdsoft_google_map_routing/src/api/end_points.dart';
import 'package:mdsoft_google_map_routing/src/api/failure.dart';
import 'package:mdsoft_google_map_routing/src/models/dirction_route_model/dirction_route_model.dart';
import 'package:mdsoft_google_map_routing/src/models/route_body_model/route_body_model.dart';
import 'package:mdsoft_google_map_routing/src/models/routes_model/routes_model.dart';
import 'package:mdsoft_google_map_routing/src/repositories/google_map_repo.dart';
import 'package:mdsoft_google_map_routing/src/utils/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapRepoImpl extends GoogleMapRepo {
  final DioClient dioClient;

  GoogleMapRepoImpl({required this.dioClient});
  final String apiKey = GoogleMapConfig.apiKey;

  @override
  Future<Either<Failure, DirctionRouteModel>> getDirections({
    required LatLng origin,
    required LatLng destination,
    List<LatLng> waypoints = const [],
  }) async {
    try {
      final params = {
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'mode': 'driving',
        'key': apiKey,
      };

      if (waypoints.isNotEmpty) {
        final wpList =
            waypoints.map((p) => '${p.latitude},${p.longitude}').toList();
        params['waypoints'] = wpList.join('|');
        debugPrint('waypoints: ${params['waypoints']}');
      }
      final dynamic response;
      if (kIsWeb) {
        response = await dioClient.get(
          'http://209.250.237.58:1210/directions',
          queryParameters: params,
        );
      } else {
        response = await dioClient.get(
          'https://maps.googleapis.com/maps/api/directions/json',
          queryParameters: params,
        );
      }

      if (response.statusCode != 200) {
        return Left(ServerFailure('Failed: ${response.statusMessage}'));
      }

      // Decode polyline
      final encoded =
          response.data['routes'][0]['overview_polyline']['points'] as String;
      final rawPoints = PolylinePoints().decodePolyline(encoded);
      final coordinates =
          rawPoints.map((pt) => LatLng(pt.latitude, pt.longitude)).toList();

      // Sum legs
      final legs = response.data['routes'][0]['legs'] as List<dynamic>;
      final totalDistanceKm = legs.fold<double>(
        0.0,
        (sum, leg) => sum + (leg['distance']['value'] as int) / 1000.0,
      );
      final totalDurationSec = legs.fold<int>(
        0,
        (sum, leg) => sum + (leg['duration']['value'] as int),
      );
      final totalDuration = Duration(seconds: totalDurationSec);

      return Right(DirctionRouteModel(
        coordinates: coordinates,
        distance: totalDistanceKm,
        duration: totalDuration,
      ));
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RoutesModel>> getRoutes(
      {required RouteBodyModel routeBodyModel}) async {
    try {
      Response response = await dioClient.post(
        EndPoints.routesFullBaseUrl,
        data: routeBodyModel.toJson(),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': apiKey,
          'X-Goog-FieldMask':
              'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline',
        },
      );
      return Right(RoutesModel.fromJson(response.data));
    } catch (failure) {
      if (failure is DioException) {
        return Left(ServerFailure.fromDioError(failure));
      } else {
        return Left(ServerFailure(failure.toString()));
      }
    }
  }
}
