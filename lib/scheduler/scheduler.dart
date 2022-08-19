import 'dart:io';
import 'dart:typed_data';

import 'package:channel_multiplexed_scheduler/channels/channel_event.dart';
import 'package:channel_multiplexed_scheduler/file/file_chunk.dart';

import '../channels/channel.dart';


abstract class Scheduler {
  late final List<Channel> channels = [];

  /// Adds a channel to be used to send file chunks.
  void useChannel(Channel channel) {
    channels.add(channel);
  }

  Future<void> sendFile(File file, int chunksize) async {
    if (channels.isEmpty) {
      throw StateError('Cannot send file because scheduler has no channel.');
    }

    List<FileChunk> chunks = splitFile(file, chunksize);

    // initialize channels event listeners
    for (var channel in channels) {
      channel.on = (ChannelEvent event, dynamic data) {
        switch (event) {
          case ChannelEvent.acknowledgment:
            // TODO: Handle this case.
            break;
          case ChannelEvent.opened:
            // TODO: Handle this case.
            break;
        }
      };
    }
    
    // open all channels
    Future.wait(channels.map((c) => c.init()));

    // TODO create a map { int => {chunk, timeout} }
  }

  /// Divides an input file into chunks of *chunksize* size.
  /// This will fail if input file is not accessible, or if input chunk size is
  /// invalid.
  List<FileChunk> splitFile (File file, int chunksize) {
    if (!file.existsSync()) {
      throw RangeError('Invalid input file (path="${file.path}").');
    }

    Uint8List bytes = file.readAsBytesSync();
    List<FileChunk> chunks = [];
    int bytesCount = bytes.length;
    int index = 0;

    if (chunksize <= 0 || chunksize > bytesCount) {
      throw RangeError('Invalid chunk size (was $chunksize).');
    }

    for (int i=0; i<bytesCount; i += chunksize) {
      chunks.add(FileChunk(
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