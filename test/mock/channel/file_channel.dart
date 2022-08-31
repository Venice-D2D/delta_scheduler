import 'dart:io';

import 'package:channel_multiplexed_scheduler/channels/events/channel_event.dart';
import 'package:channel_multiplexed_scheduler/channels/data_channel.dart';
import 'package:channel_multiplexed_scheduler/file/file_chunk.dart';


/// This test Channel implementation emulates a network connection by using the
/// local file system as intermediate between sender and receiver.
class FileChannel extends DataChannel {
  // This directory will store all package exchanged between sender and receiver.
  Directory directory;
  FileChannel({required this.directory});

  /// When a file is created in target directory, this reconstructs file chunk
  /// from said file and sends it to the receiver.
  @override
  Future<void> initReceiver({Map<String, dynamic> parameters = const {}}) async {
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

  /// Simulates sending chunks over network by writing them down in a directory
  /// as files.
  @override
  Future<void> sendChunk(FileChunk chunk) async {
    File chunkFile = File(directory.path + Platform.pathSeparator + chunk.identifier.toString());
    chunkFile.createSync();
    chunkFile.writeAsBytesSync(chunk.data);
    on(ChannelEvent.acknowledgment, chunk.identifier);
  }
}