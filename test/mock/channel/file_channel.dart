import 'dart:io';

import 'package:channel_multiplexed_scheduler/channels/channel.dart';
import 'package:channel_multiplexed_scheduler/channels/channel_event.dart';
import 'package:channel_multiplexed_scheduler/file/file_chunk.dart';

class FileChannel extends Channel {
  Directory directory;
  FileChannel({required this.directory});

  @override
  Future<void> initReceiver() async {
    directory.watch(events: FileSystemEvent.create).listen((event) {
      // Rebuild FileChunk instance.
      File receivedChunk = File(event.path);
      FileChunk chunk = FileChunk(
          identifier: int.parse(receivedChunk.uri.pathSegments.last),
          data: receivedChunk.readAsBytesSync());

      // Send an event with received chunk as parameter.
      on(ChannelEvent.data, chunk);
    });
  }

  @override
  Future<void> initSender() async {}

  @override
  Future<void> sendChunk(FileChunk chunk) async {
    File chunkFile = File(directory.path + Platform.pathSeparator + chunk.identifier.toString());
    chunkFile.createSync();
    chunkFile.writeAsBytesSync(chunk.data);
    on(ChannelEvent.acknowledgment, chunk.identifier);
  }
}