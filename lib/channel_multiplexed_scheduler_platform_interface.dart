import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'channel_multiplexed_scheduler_method_channel.dart';

abstract class ChannelMultiplexedSchedulerPlatform extends PlatformInterface {
  /// Constructs a ChannelMultiplexedSchedulerPlatform.
  ChannelMultiplexedSchedulerPlatform() : super(token: _token);

  static final Object _token = Object();

  static ChannelMultiplexedSchedulerPlatform _instance = MethodChannelChannelMultiplexedScheduler();

  /// The default instance of [ChannelMultiplexedSchedulerPlatform] to use.
  ///
  /// Defaults to [MethodChannelChannelMultiplexedScheduler].
  static ChannelMultiplexedSchedulerPlatform get instance => _instance;
  
  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ChannelMultiplexedSchedulerPlatform] when
  /// they register themselves.
  static set instance(ChannelMultiplexedSchedulerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
