import 'package:flutter_test/flutter_test.dart';
import 'package:channel_multiplexed_scheduler/channel_multiplexed_scheduler.dart';
import 'package:channel_multiplexed_scheduler/channel_multiplexed_scheduler_platform_interface.dart';
import 'package:channel_multiplexed_scheduler/channel_multiplexed_scheduler_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockChannelMultiplexedSchedulerPlatform 
    with MockPlatformInterfaceMixin
    implements ChannelMultiplexedSchedulerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ChannelMultiplexedSchedulerPlatform initialPlatform = ChannelMultiplexedSchedulerPlatform.instance;

  test('$MethodChannelChannelMultiplexedScheduler is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelChannelMultiplexedScheduler>());
  });

  test('getPlatformVersion', () async {
    ChannelMultiplexedScheduler channelMultiplexedSchedulerPlugin = ChannelMultiplexedScheduler();
    MockChannelMultiplexedSchedulerPlatform fakePlatform = MockChannelMultiplexedSchedulerPlatform();
    ChannelMultiplexedSchedulerPlatform.instance = fakePlatform;
  
    expect(await channelMultiplexedSchedulerPlugin.getPlatformVersion(), '42');
  });
}
