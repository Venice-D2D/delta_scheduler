import 'package:channel_multiplexed_scheduler/channels/channel.dart';
import 'package:channel_multiplexed_scheduler/channels/events/data_channel_event.dart';
import 'package:channel_multiplexed_scheduler/file/file_chunk.dart';

abstract class DataChannel implements Channel {
  /// Provides information to the scheduler about what's happening in the
  /// current channel.
  late Function(DataChannelEvent event, dynamic data) on;

  /// Sends a file piece through current channel, and returns after successful
  /// sending; this doesn't check if chunk was received.
  Future<void> sendChunk(FileChunk chunk);
}