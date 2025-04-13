import 'destination.dart';
import 'origin.dart';
import 'route_modifiers.dart';

class RouteBodyModel {
  Origin? origin;
  Destination? destination;
  String? travelMode;
  String? routingPreference;
  bool? computeAlternativeRoutes;
  RouteModifiers? routeModifiers;
  String? languageCode;
  String? units;

  RouteBodyModel({
    this.origin,
    this.destination,
    this.travelMode='DRIVE',
    this.routingPreference='TRAFFIC_AWARE',
    this.computeAlternativeRoutes=false,
    this.routeModifiers,
    this.languageCode='en-US',
    this.units='IMPERIAL',
  });

  factory RouteBodyModel.fromJson(Map<String, dynamic> json) {
    return RouteBodyModel(
      origin: json['origin'] == null
          ? null
          : Origin.fromJson(json['origin'] as Map<String, dynamic>),
      destination: json['destination'] == null
          ? null
          : Destination.fromJson(json['destination'] as Map<String, dynamic>),
      travelMode: json['travelMode'] as String?,
      routingPreference: json['routingPreference'] as String?,
      computeAlternativeRoutes: json['computeAlternativeRoutes'] as bool?,
      routeModifiers: json['routeModifiers'] == null
          ? null
          : RouteModifiers.fromJson(
              json['routeModifiers'] as Map<String, dynamic>),
      languageCode: json['languageCode'] as String?,
      units: json['units'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'origin': origin?.toJson(),
        'destination': destination?.toJson(),
        'travelMode': travelMode,
        'routingPreference': routingPreference,
        'computeAlternativeRoutes': computeAlternativeRoutes,
        'routeModifiers': routeModifiers?.toJson(),
        'languageCode': languageCode,
        'units': units,
      };
}
