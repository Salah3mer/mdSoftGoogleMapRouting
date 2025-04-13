import 'package:flutter_test/flutter_test.dart';
import 'package:mdsoft_google_map_routing/google_map_routing.dart';
import 'package:mdsoft_google_map_routing/google_map_routing_method_channel.dart';
import 'package:mdsoft_google_map_routing/google_map_routing_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockGoogleMapRoutingPlatform
    with MockPlatformInterfaceMixin
    implements GoogleMapRoutingPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final GoogleMapRoutingPlatform initialPlatform =
      GoogleMapRoutingPlatform.instance;

  test('$MethodChannelGoogleMapRouting is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelGoogleMapRouting>());
  });

  test('getPlatformVersion', () async {
    MdSoftGoogleMapRouting googleMapRoutingPlugin = MdSoftGoogleMapRouting();
    MockGoogleMapRoutingPlatform fakePlatform = MockGoogleMapRoutingPlatform();
    GoogleMapRoutingPlatform.instance = fakePlatform;

    // expect(await googleMapRoutingPlugin.getPlatformVersion(), '42');
  });
}
