import 'package:dartz/dartz.dart';
import 'package:mdsoft_google_map_routing/src/api/failure.dart';
import 'package:mdsoft_google_map_routing/src/models/dirction_route_model/dirction_route_model.dart';
import 'package:mdsoft_google_map_routing/src/models/route_body_model/route_body_model.dart';
import 'package:mdsoft_google_map_routing/src/models/routes_model/routes_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class GoogleMapRepo {
  Future<Either<Failure, DirctionRouteModel>> getDirections({
    required LatLng origin,
    required LatLng destination,
  });
  Future<Either<Failure, RoutesModel>> getRoutes(
      {required RouteBodyModel routeBodyModel});
}
