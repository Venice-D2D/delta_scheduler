import 'dart:io';

import 'package:channel_multiplexed_scheduler/channels/channel.dart';
import 'package:channel_multiplexed_scheduler/channels/events/channel_event.dart';
import 'package:channel_multiplexed_scheduler/file/file_chunk.dart';


class Receiver {
  late final List<Channel> _channels = [];
  final Map<int, FileChunk> _chunks = {};
  final int _chunksCount = 9; // TODO handle this from scheduler through a channel

  /// Adds a channel to use to receive data.
  void useChannel(Channel channel) {
    _channels.add(channel);
    channel.on = (ChannelEvent event, dynamic data) {
      FileChunk chunk = data;
      _chunks.putIfAbsent(chunk.identifier, () => chunk);
    };
  }

  /// Receives a file through available channels.
  Future<void> receiveFile(String destination) async {
    if (_channels.isEmpty) {
      throw StateError('Cannot receive file because receiver has no channel.');
    }

    // Open all channels.
    Future.wait(_channels.map((c) => c.initReceiver()));

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