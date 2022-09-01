import 'package:channel_multiplexed_scheduler/channels/channel_metadata.dart';
import 'package:channel_multiplexed_scheduler/channels/implementation/bootstrap_channel.dart';
import 'package:channel_multiplexed_scheduler/file/file_metadata.dart';

class MockBootstrapChannel extends BootstrapChannel {
  @override
  Future<void> initReceiver({Map<String, dynamic> parameters = const {}}) async {}

  @override
  Future<void> initSender({data = const {}}) async {}

  @override
  Future<void> sendChannelMetadata(ChannelMetadata data) async {}

  @override
  Future<void> sendFileMetadata(FileMetadata data) async {}
}