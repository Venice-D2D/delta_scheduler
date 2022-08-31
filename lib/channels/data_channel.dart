import 'package:channel_multiplexed_scheduler/channels/channel.dart';
import 'package:channel_multiplexed_scheduler/file/file_chunk.dart';

abstract class DataChannel extends Channel {
  /// Sends a file piece through current channel, and returns after successful
  /// sending; this doesn't check if chunk was received.
  Future<void> sendChunk(FileChunk chunk);
}