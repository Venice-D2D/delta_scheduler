import 'package:channel_multiplexed_scheduler/channels/channel_metadata.dart';
import 'package:channel_multiplexed_scheduler/channels/events/bootstrap_channel_event.dart';
import 'package:channel_multiplexed_scheduler/file/file_metadata.dart';

abstract class BootstrapChannel {
  late Function(BootstrapChannelEvent event, dynamic data) on;
  Future<void> sendFileMetadata(FileMetadata data);
  Future<void> sendChannelMetadata(ChannelMetadata data);
}