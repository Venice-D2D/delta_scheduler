import 'package:venice_core/metadata/channel_metadata.dart';
import 'package:venice_core/channels/events/bootstrap_channel_event.dart';
import 'package:venice_core/channels/abstractions/bootstrap_channel.dart';
import 'package:venice_core/metadata/file_metadata.dart';

class MockBootstrapChannel extends BootstrapChannel {
  static const String mockChannelId1 = "mock_data_channel_1";
  static const String mockChannelId2 = "mock_data_channel_2";

  /// Some tests require to initialize several channels, this parameter allows
  /// to send multiple metadata if needed.
  final int dataChannelsCount;

  MockBootstrapChannel({this.dataChannelsCount = 1});

  @override
  Future<void> initReceiver({Map<String, dynamic> parameters = const {}}) async {
    on(BootstrapChannelEvent.channelMetadata, ChannelMetadata(mockChannelId1, "address", "identifier", "password"));
    if (dataChannelsCount == 2) {
      on(BootstrapChannelEvent.channelMetadata, ChannelMetadata(mockChannelId2, "address2", "identifier2", "password2"));
    }
  }

  @override
  Future<void> initSender({data = const {}}) async {}

  @override
  Future<void> sendChannelMetadata(ChannelMetadata data) async {}

  @override
  Future<void> sendFileMetadata(FileMetadata data) async {}

  @override
  Future<void> close() async {}
}