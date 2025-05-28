import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'package:mdsoft_google_map_routing/google_map_routing.dart';
import 'package:mdsoft_google_map_routing/google_map_routing_method_channel.dart';
import 'package:mdsoft_google_map_routing/google_map_routing_platform_interface.dart';
import 'package:mdsoft_google_map_routing/src/models/dirction_route_model/dirction_route_model.dart';
import 'package:mdsoft_google_map_routing/src/models/route_body_model/route_body_model.dart';
import 'package:mdsoft_google_map_routing/src/models/routes_model/routes_model.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockGoogleMapRoutingPlatform
    with MockPlatformInterfaceMixin
    implements GoogleMapRoutingPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<DirctionRouteModel> getDirections(
      {required LatLng origin, required LatLng destination}) {
    // TODO: implement getDirections
    throw UnimplementedError();
  }

  @override
  Future<RoutesModel> getRoutes({required RouteBodyModel routeBodyModel}) {
    // TODO: implement getRoutes
    throw UnimplementedError();
  }
}

void main() {
  final GoogleMapRoutingPlatform initialPlatform =
      GoogleMapRoutingPlatform.instance;

  test('$MethodChannelGoogleMapRouting is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelGoogleMapRouting>());
  });

  test('getPlatformVersion', () async {
    MdSoftGoogleMapRouting googleMapRoutingPlugin =
        const MdSoftGoogleMapRouting();
    MockGoogleMapRoutingPlatform fakePlatform = MockGoogleMapRoutingPlatform();
    GoogleMapRoutingPlatform.instance = fakePlatform;

    // expect(await googleMapRoutingPlugin.getPlatformVersion(), '42');
  });
}
