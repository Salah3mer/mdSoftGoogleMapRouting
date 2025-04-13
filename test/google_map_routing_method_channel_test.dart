import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdsoft_google_map_routing/google_map_routing_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelGoogleMapRouting platform = MethodChannelGoogleMapRouting();
  const MethodChannel channel = MethodChannel('mdsoft_google_map_routing');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
