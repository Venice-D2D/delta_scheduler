import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:channel_multiplexed_scheduler/channel_multiplexed_scheduler_method_channel.dart';

void main() {
  MethodChannelChannelMultiplexedScheduler platform = MethodChannelChannelMultiplexedScheduler();
  const MethodChannel channel = MethodChannel('channel_multiplexed_scheduler');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
