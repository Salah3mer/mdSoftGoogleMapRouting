part of 'google_map_cubit.dart';

abstract class GoogleMapState {
  const GoogleMapState();
}

class GoogleMapInitial extends GoogleMapState {}

class GetLocationSuccessState extends GoogleMapState {}

class GetLocationErrorState extends GoogleMapState {
  String errorMessage;

  GetLocationErrorState({required this.errorMessage});
}

class GetMyStreemLocationErrorState extends GoogleMapState {
  String errorMessage;

  GetMyStreemLocationErrorState({required this.errorMessage});
}

class GetMapStyleSuccessState extends GoogleMapState {}

class GetMyStreemLocationSuccessState extends GoogleMapState {}

class GetPredictionsErrorState extends GoogleMapState {
  String errorMessage;

  GetPredictionsErrorState({required this.errorMessage});
}

class GetPredictionsSuccessState extends GoogleMapState {}

class GetPlaceDetailsSuccessState extends GoogleMapState {}

class GetPlaceDetailsErrorState extends GoogleMapState {
  String errorMessage;

  GetPlaceDetailsErrorState({required this.errorMessage});
}

class GetDirectionsSuccessState extends GoogleMapState {}

class GetDirectionsErrorState extends GoogleMapState {
  String errorMessage;

  GetDirectionsErrorState({required this.errorMessage});
}

class SetMarkersSuccessState extends GoogleMapState {}

class GetBoundsSuccessState extends GoogleMapState {}

class UpdateRouteSuccessState extends GoogleMapState {}

class GetRoutesLoadingState extends GoogleMapState {}

class GetRoutesSuccessState extends GoogleMapState {}

class GetRoutesFailureState extends GoogleMapState {
  String failure;

  GetRoutesFailureState({required this.failure});
}

class DestinationReachedState extends GoogleMapState {
  final int isecRoute;

  DestinationReachedState({required this.isecRoute});
}
