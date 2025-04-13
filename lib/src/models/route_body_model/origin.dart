import 'location.dart';

class Origin {
  LocationModel? location;

  Origin({this.location});

  factory Origin.fromJson(Map<String, dynamic> json) => Origin(
        location: json['location'] == null
            ? null
            : LocationModel.fromJson(json['location'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'location': location?.toJson(),
      };
}
