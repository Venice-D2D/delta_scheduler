import 'package:channel_multiplexed_scheduler/channels/channel_event.dart';

typedef ChannelCallback = Function(ChannelEvent even, dynamic data);

abstract class Channel {
  /// Provides information to the scheduler about what's happening in the
  /// current channel.
  late ChannelCallback on;

  /// Initializes current channel, and returns when it is ready to send data.
  Future<void> initSender();

  /// Initializes current channel, and returns when it is ready to receive data.
  Future<void> initReceiver({Map<String, dynamic> parameters = const {}});
}