import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:venice_core/metadata/channel_metadata.dart';
import 'package:venice_core/channels/abstractions/bootstrap_channel.dart';
import 'package:venice_core/channels/abstractions/data_channel.dart';
import 'package:venice_core/channels/events/data_channel_event.dart';
import 'package:flutter/material.dart';
import 'package:venice_core/network/message.dart';

/// This test Channel implementation emulates a network connection by using the
/// local file system as intermediate between sender and receiver.
class FileDataChannel extends DataChannel {
  // This directory will store all package exchanged between sender and receiver.
  Directory directory;
  // This file name is used to synchronize receiving and sending ends.
  final String receiverReadyFileName = "receiverIsReady";
  late StreamSubscription stream;

  FileDataChannel(
      {required this.directory,
      String identifier = FileDataChannel.channelIdentifier})
      : super(identifier);

  static const String channelIdentifier = "file_data_channel";

  /// When a file is created in target directory, this reconstructs file chunk
  /// from said file and sends it to the receiver.
  @override
  Future<void> initReceiver(ChannelMetadata data) async {
    debugPrint(
        "[FileDataChannel][initReceiver] Start receiving end initialization.");

    stream = directory.watch(events: FileSystemEvent.create).listen((event) {
      // Rebuild FileChunk instance.
      File receivedChunk = File(event.path);
      String name = receivedChunk.uri.pathSegments.last;

      // Ignore self-created files
      if (name.startsWith('ACK')) return;
      if (name == receiverReadyFileName) return;

      VeniceMessage chunk = VeniceMessage.data(
          int.parse(receivedChunk.uri.pathSegments.last),
          receivedChunk.readAsBytesSync());

      // Send an event with received chunk as parameter.
      on(DataChannelEvent.data, chunk);

      // Acknowledge chunck to sending end.
      File chunkFile = File(
          "${directory.path}${Platform.pathSeparator}ACK${chunk.messageId}");
      chunkFile.createSync();
    });

    // Simulate delay before telling we're ready.
    //
    // Receiving end signals it's ready by creating a file named
    // "receiverIsReady" on watched directory; this file creation is then caught
    // by sending end (which in testing environment in on the same machine as
    // receiver end).
    await Future.delayed(Duration(milliseconds: Random().nextInt(1000)));
    debugPrint("[FileDataChannel][initReceiver] Reception end is ready.");
    File chunkFile =
        File("${directory.path}${Platform.pathSeparator}receiverIsReady");
    chunkFile.createSync();
  }

  /// Since this should return only when connection to client has been
  /// established (e.g. including a ServerSocket.accept() call), this simulates
  /// waiting for reception end to be ready before returning.
  /// Reception end will tell it's ready by creating a file in the watched
  /// directory.
  @override
  Future<void> initSender(BootstrapChannel channel) async {
    debugPrint(
        "[FileDataChannel][initSender] Start sending end initialization.");
    bool isReceiverReady = false;

    stream = directory.watch(events: FileSystemEvent.create).listen((event) {
      File file = File(event.path);
      String name = file.uri.pathSegments.last;
      if (name == receiverReadyFileName) {
        isReceiverReady = true;
      } else if (name.startsWith('ACK')) {
        int identifier = int.parse(name.substring(3));
        on(DataChannelEvent.acknowledgment, identifier);
      }
    });

    // Simulate sending channel information to receiving end.
    await channel.sendChannelMetadata(ChannelMetadata(
        identifier, "176.122.202.107", "FileDataChannel", "3d91a583"));

    // If receiver end is not ready, we wait a bit.
    await Future.doWhile(() async {
      await Future.delayed(Duration(milliseconds: isReceiverReady ? 0 : 200));
      return !isReceiverReady;
    });

    debugPrint("[FileDataChannel][initSender] Sending end is ready.");
  }

  /// Simulates sending chunks over network by writing them down in a directory
  /// as files.
  @override
  Future<void> sendMessage(VeniceMessage chunk) async {
    File chunkFile = File(
        directory.path + Platform.pathSeparator + chunk.messageId.toString());
    chunkFile.createSync();
    chunkFile.writeAsBytesSync(chunk.data);
  }

  @override
  Future<void> close() async {
    stream.cancel();
  }
}
