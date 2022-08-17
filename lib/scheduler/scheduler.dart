import 'dart:io';
import 'dart:typed_data';

import 'package:channel_multiplexed_scheduler/file/file_chunk.dart';

import '../channels/channel.dart';

typedef FileChunks = Map<int, FileChunk>;

abstract class Scheduler {
  late List<Channel> _channels;

  /// Adds a channel to be used to send file chunks.
  void useChannel(Channel channel) {
    _channels.add(channel);
  }

  Future<void> sendFile(File file, int chunksize) async {
    FileChunks chunks = _splitFile(file, chunksize);
    // TODO send
  }

  // TODO comment
  // TODO test
  FileChunks _splitFile (File file, int chunksize) {
    Uint8List bytes = file.readAsBytesSync();
    FileChunks chunks = {};

    int index = 0;
    int byteIndex = 0;
    while (bytes.isNotEmpty) {
      chunks.putIfAbsent(index, () => FileChunk(identifier: index, data: bytes.sublist(byteIndex, byteIndex+chunksize)));
      byteIndex += chunksize;
      index += 1;
    }

    return chunks;
  }
}