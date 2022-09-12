import 'package:channel_multiplexed_scheduler/channels/channel_metadata.dart';
import 'package:channel_multiplexed_scheduler/channels/events/bootstrap_channel_event.dart';
import 'package:channel_multiplexed_scheduler/channels/abstractions/bootstrap_channel.dart';
import 'package:channel_multiplexed_scheduler/file/file_metadata.dart';

class MockBootstrapChannel extends BootstrapChannel {
  @override
  Future<void> initReceiver({Map<String, dynamic> parameters = const {}}) async {
    on(BootstrapChannelEvent.channelMetadata, ChannelMetadata("address", "identifier", "password"));
  }

  @override
  Future<void> initSender({data = const {}}) async {}

  @override
  Future<void> sendChannelMetadata(ChannelMetadata data) async {}

  @override
  Future<void> sendFileMetadata(FileMetadata data) async {}
}