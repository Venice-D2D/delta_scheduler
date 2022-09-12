import 'package:channel_multiplexed_scheduler/channels/channel_metadata.dart';
import 'package:channel_multiplexed_scheduler/channels/events/bootstrap_channel_event.dart';
import 'package:channel_multiplexed_scheduler/file/file_metadata.dart';

abstract class BootstrapChannel {
  /// Provides information to sending and receiving ends about what's happening
  /// in the current channel.
  late Function(BootstrapChannelEvent event, dynamic data) on;

  /// Initializes current channel, and returns when it is ready to send data.
  Future<void> initSender();

  /// Initializes current channel, and returns when it is ready to receive data.
  Future<void> initReceiver();

  /// Sends file metadata to receiving end.
  Future<void> sendFileMetadata(FileMetadata data);

  /// Sends channel metadata to receiving end, for it to initialize data
  /// channels before starting file exchange.
  Future<void> sendChannelMetadata(ChannelMetadata data);
}