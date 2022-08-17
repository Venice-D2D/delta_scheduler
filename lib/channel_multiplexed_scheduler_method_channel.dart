import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'channel_multiplexed_scheduler_platform_interface.dart';

/// An implementation of [ChannelMultiplexedSchedulerPlatform] that uses method channels.
class MethodChannelChannelMultiplexedScheduler extends ChannelMultiplexedSchedulerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('channel_multiplexed_scheduler');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
