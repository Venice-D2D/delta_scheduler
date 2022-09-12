import 'dart:io';

import 'package:channel_multiplexed_scheduler/channels/channel.dart';
import 'package:channel_multiplexed_scheduler/channels/channel_metadata.dart';
import 'package:channel_multiplexed_scheduler/channels/events/bootstrap_channel_event.dart';
import 'package:channel_multiplexed_scheduler/channels/implementation/bootstrap_channel.dart';
import 'package:channel_multiplexed_scheduler/channels/implementation/data_channel.dart';
import 'package:channel_multiplexed_scheduler/channels/events/data_channel_event.dart';
import 'package:channel_multiplexed_scheduler/file/file_chunk.dart';
import 'package:channel_multiplexed_scheduler/file/file_metadata.dart';


class Receiver {
  final BootstrapChannel bootstrapChannel;
  late final List<Channel> _channels = [];
  final Map<int, FileChunk> _chunks = {};

  // Number of chunks we expect to receive.
  // Receiver will not end while it has not received expected chunks count.
  int _chunksCount = 0;

  Receiver(this.bootstrapChannel);


  /// Adds a channel to use to receive data.
  void useChannel(DataChannel channel) {
    _channels.add(channel);
    channel.on = (DataChannelEvent event, dynamic data) {
      FileChunk chunk = data;
      _chunks.putIfAbsent(chunk.identifier, () => chunk);
    };
  }

  /// Receives a file through available channels.
  Future<void> receiveFile(String destination) async {
    bool allChannelsInitialized = false;
    bool fileMetadataReceived = false;

    if (_channels.isEmpty) {
      throw StateError('Cannot receive file because receiver has no channel.');
    }

    // Open bootstrap channel.
    bootstrapChannel.on = (BootstrapChannelEvent event, dynamic data) async {
      switch(event) {
        case BootstrapChannelEvent.fileMetadata:
          // TODO use file name
          // TODO use chunk size
          FileMetadata fileMetadata = data;
          _chunksCount = fileMetadata.chunkCount;
          fileMetadataReceived = true;
          break;
        case BootstrapChannelEvent.channelMetadata:
          // Open all channels.
          ChannelMetadata channelMetadata = data;
          // TODO add a channel identifier, not to send all metadata to all channels
          await Future.wait(_channels.map((c) => c.initReceiver(
            parameters: {"data": channelMetadata}
          )));
          allChannelsInitialized = true;
          break;
      }
    };
    await bootstrapChannel.initReceiver();

    // Wait for bootstrap channel to receive channel information and initialize
    // them.
    while (!allChannelsInitialized || !fileMetadataReceived) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Wait for all chunks to arrive.
    await receiveAllChunks();

    // Fill destination file with received chunks.
    File newFile = File(destination);
    if (newFile.existsSync()) {
      newFile.deleteSync();
    }
    newFile.createSync();
    for (var chunk in _chunks.values) {
      newFile.writeAsBytesSync(chunk.data, mode: FileMode.append);
    }
  }


  Future<void> receiveAllChunks() async {
    while (_chunks.length != _chunksCount) {
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }
}