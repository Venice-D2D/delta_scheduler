import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:channel_multiplexed_scheduler/channels/channel_metadata.dart';
import 'package:channel_multiplexed_scheduler/channels/implementation/bootstrap_channel.dart';
import 'package:channel_multiplexed_scheduler/channels/implementation/data_channel.dart';
import 'package:channel_multiplexed_scheduler/channels/events/data_channel_event.dart';
import 'package:channel_multiplexed_scheduler/file/file_chunk.dart';


/// This test Channel implementation emulates a network connection by using the
/// local file system as intermediate between sender and receiver.
class FileDataChannel extends DataChannel {
  // This directory will store all package exchanged between sender and receiver.
  Directory directory;
  // This file name is used to synchronize receiving and sending ends.
  final String receiverReadyFileName = "receiverIsReady";

  FileDataChannel({required this.directory});


  /// When a file is created in target directory, this reconstructs file chunk
  /// from said file and sends it to the receiver.
  @override
  Future<void> initReceiver({Map<String, dynamic> parameters = const {}}) async {
    directory.watch(events: FileSystemEvent.create).listen((event) {
      // Rebuild FileChunk instance.
      File receivedChunk = File(event.path);

      String name = receivedChunk.uri.pathSegments.last;
      if (name == receiverReadyFileName) return;

      FileChunk chunk = FileChunk(
          identifier: int.parse(receivedChunk.uri.pathSegments.last),
          data: receivedChunk.readAsBytesSync());

      // Send an event with received chunk as parameter.
      on(DataChannelEvent.data, chunk);
    });

    // Simulate delay before telling we're ready.
    //
    // Receiving end signals it's ready by creating a file named
    // "receiverIsReady" on watched directory; this file creation is then caught
    // by sending end (which in testing environment in on the same machine as
    // receiver end).
    await Future.delayed(Duration(milliseconds: Random().nextInt(1000)));
    File chunkFile = File("${directory.path}${Platform.pathSeparator}receiverIsReady");
    chunkFile.createSync();
  }

  /// Since this should return only when connection to client has been
  /// established (e.g. including a ServerSocket.accept() call), this simulates
  /// waiting for reception end to be ready before returning.
  /// Reception end will tell it's ready by creating a file in the watched
  /// directory.
  @override
  Future<void> initSender({data = const {}}) async {
    bool isReceiverReady = false;

    StreamSubscription stream = directory.watch(events: FileSystemEvent.create).listen((event) {
      File file = File(event.path);
      String name = file.uri.pathSegments.last;
      if (name == receiverReadyFileName) {
        isReceiverReady = true;
      }
    });

    // Simulate sending channel information to receiving end.
    BootstrapChannel channel = data;
    await channel.sendChannelMetadata(
        ChannelMetadata("176.122.202.107", "fileDataChannel", "3d91a583")
    );

    // If receiver end is not ready, we wait a bit.
    await Future.doWhile(() async {
      await Future.delayed(Duration(milliseconds: isReceiverReady ? 0 : 200));
      return !isReceiverReady;
    });

    stream.cancel();
  }

  /// Simulates sending chunks over network by writing them down in a directory
  /// as files.
  @override
  Future<void> sendChunk(FileChunk chunk) async {
    File chunkFile = File(directory.path + Platform.pathSeparator + chunk.identifier.toString());
    chunkFile.createSync();
    chunkFile.writeAsBytesSync(chunk.data);
    on(DataChannelEvent.acknowledgment, chunk.identifier);
  }
}