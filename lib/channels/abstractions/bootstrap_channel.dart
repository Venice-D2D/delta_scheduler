import 'package:channel_multiplexed_scheduler/channels/channel_metadata.dart';
import 'package:channel_multiplexed_scheduler/channels/events/bootstrap_channel_event.dart';
import 'package:channel_multiplexed_scheduler/file/file_metadata.dart';

abstract class BootstrapChannel {
  late Function(BootstrapChannelEvent event, dynamic data) on;
  /// Initializes current channel, and returns when it is ready to send data.
  Future<void> initSender();

  /// Initializes current channel, and returns when it is ready to receive data.
  Future<void> initReceiver();

  Future<void> sendFileMetadata(FileMetadata data);
  Future<void> sendChannelMetadata(ChannelMetadata data);
}