import 'package:channel_multiplexed_scheduler/channels/channel_metadata.dart';
import 'package:channel_multiplexed_scheduler/channels/events/data_channel_event.dart';
import 'package:channel_multiplexed_scheduler/channels/abstractions/bootstrap_channel.dart';
import 'package:channel_multiplexed_scheduler/file/file_chunk.dart';

abstract class DataChannel {
  /// Identifies the current channel in a unique fashion.
  /// This must have the same value on both receiving and sending ends, so that
  /// channel metadata from sender is forwarded to corresponding receiver only.
  final String identifier;
  DataChannel(this.identifier);

  /// Provides information to sending and receiving ends about what's happening
  /// in the current channel.
  late Function(DataChannelEvent event, dynamic data) on;

  /// Initializes current channel, and returns when it is ready to send data.
  /// Once sockets are ready, this must send information about them through
  /// provided bootstrap channel.
  Future<void> initSender(BootstrapChannel channel);

  /// Initializes current channel from provided channel metadata, and returns
  /// when it is ready to receive data.
  Future<void> initReceiver(ChannelMetadata data);

  /// Sends a file piece through current channel, and returns after successful
  /// sending; this doesn't check if chunk was received.
  Future<void> sendChunk(FileChunk chunk);
}