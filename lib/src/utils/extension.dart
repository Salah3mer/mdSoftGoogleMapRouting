import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

extension BitmapDescriptorExtensions on String {
  Future<BitmapDescriptor> toBitmapDescriptor({double devicePixelRatio = 2.5}) {
    return BitmapDescriptor.asset(
      ImageConfiguration(devicePixelRatio: devicePixelRatio,),
      this,
    );
  }
}
