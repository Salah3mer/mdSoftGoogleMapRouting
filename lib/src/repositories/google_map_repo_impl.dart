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
  }) async {
    try {
      final respnse = await dioClient
          .get('http://192.168.1.60:1209/directions', queryParameters: {
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'mode': 'driving',
        'key': apiKey,
      });
      if (respnse.statusCode != 200) {
        return Left(
            ServerFailure('Failed to fetch route: ${respnse.statusMessage}'));
      }
      final encoded =
          respnse.data['routes'][0]['overview_polyline']['points'] as String;
      final rawPoints = PolylinePoints().decodePolyline(encoded);
      final points =
          rawPoints.map((p) => LatLng(p.latitude, p.longitude)).toList();

      // 3) نحسب المسافة والمدة
      final leg = respnse.data['routes'][0]['legs'][0];
      final distanceKm = (leg['distance']['value'] as int) / 1000.0;
      final durationSec = leg['duration']['value'] as int;
      final duration = Duration(seconds: durationSec);

      return Right(DirctionRouteModel(
        coordinates: points,
        distance: distanceKm,
        duration: duration,
      ));
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      } else {
        return Left(ServerFailure(e.toString()));
      }
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
