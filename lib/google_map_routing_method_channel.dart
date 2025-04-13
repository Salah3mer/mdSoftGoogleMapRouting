import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'google_map_routing_platform_interface.dart';

/// An implementation of [GoogleMapRoutingPlatform] that uses method channels.
class MethodChannelGoogleMapRouting extends GoogleMapRoutingPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('google_map_routing');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
