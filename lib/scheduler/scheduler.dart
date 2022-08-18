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
    FileChunks chunks = splitFile(file, chunksize);
    // TODO send
  }

  // TODO comment
  FileChunks splitFile (File file, int chunksize) {
    Uint8List bytes = file.readAsBytesSync();
    FileChunks chunks = {};
    int bytesCount = bytes.length;
    int index = 0;

    for (int i=0; i<bytesCount; i += chunksize) {
      chunks.putIfAbsent(index, () => FileChunk(
          identifier: index,
          data: bytes.sublist(i, i + chunksize > bytesCount
              ? bytesCount
              : i + chunksize)
      ));
      index += 1;
    }

    return chunks;
  }
}