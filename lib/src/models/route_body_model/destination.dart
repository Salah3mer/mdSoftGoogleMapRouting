import 'location.dart';

class Destination {
  LocationModel? location;

  Destination({this.location});

  factory Destination.fromJson(Map<String, dynamic> json) => Destination(
        location: json['location'] == null
            ? null
            : LocationModel.fromJson(json['location'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'location': location?.toJson(),
      };
}
