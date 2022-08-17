import 'package:channel_multiplexed_scheduler/channels/channel_event.dart';
import 'package:channel_multiplexed_scheduler/file/file_chunk.dart';

typedef ChannelCallback = Function(ChannelEvent even, dynamic data);

abstract class Channel {
  /// Provides information to the scheduler about what's happening in the
  /// current channel.
  ChannelCallback on;
  Channel({required this.on});

  /// Initializes current channel, and returns when it is ready to send data.
  Future<void> init();

  /// Sends a file piece through current channel, and returns after successful
  /// sending; this doesn't check if chunk was received.
  void sendChunk(FileChunk chunk);
}