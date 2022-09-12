import 'package:channel_multiplexed_scheduler/channels/channel_metadata.dart';
import 'package:channel_multiplexed_scheduler/channels/events/data_channel_event.dart';
import 'package:channel_multiplexed_scheduler/channels/bootstrap_channel.dart';
import 'package:channel_multiplexed_scheduler/file/file_chunk.dart';

abstract class DataChannel {
  /// Provides information to the scheduler about what's happening in the
  /// current channel.
  late Function(DataChannelEvent event, dynamic data) on;

  /// Initializes current channel, and returns when it is ready to send data.
  Future<void> initSender(BootstrapChannel channel);

  /// Initializes current channel, and returns when it is ready to receive data.
  Future<void> initReceiver(ChannelMetadata data);

  /// Sends a file piece through current channel, and returns after successful
  /// sending; this doesn't check if chunk was received.
  Future<void> sendChunk(FileChunk chunk);
}