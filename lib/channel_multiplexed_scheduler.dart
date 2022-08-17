import 'channel_multiplexed_scheduler_platform_interface.dart';

class ChannelMultiplexedScheduler {
  Future<String?> getPlatformVersion() {
    return ChannelMultiplexedSchedulerPlatform.instance.getPlatformVersion();
  }
}
