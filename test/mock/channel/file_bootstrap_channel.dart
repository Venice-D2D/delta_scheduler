import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:channel_multiplexed_scheduler/channels/channel_metadata.dart';
import 'package:channel_multiplexed_scheduler/channels/events/bootstrap_channel_event.dart';
import 'package:channel_multiplexed_scheduler/channels/abstractions/bootstrap_channel.dart';
import 'package:channel_multiplexed_scheduler/file/file_metadata.dart';
import 'package:flutter/material.dart';

class FileBootstrapChannel extends BootstrapChannel {
  // This directory will store all package exchanged between sender and receiver.
  Directory directory;
  // This file name is used to synchronize receiving and sending ends.
  final String receiverReadyFileName = "receiverIsReady";

  FileBootstrapChannel({required this.directory});


  @override
  Future<void> initReceiver({Map<String, dynamic> parameters = const {}}) async {
    debugPrint("[FileBootstrapChannel][initReceiver] Start receiving end initialization.");
    directory.watch(events: FileSystemEvent.create).listen((event) async {
      File receivedPacket = File(event.path);
      String name = receivedPacket.uri.pathSegments.last;
      if (name == receiverReadyFileName) return;

      String content = await receivedPacket.readAsString();
      List<String> words = content.split(";");

      final String indicator = words[0];
      if (words.length != 4) {
        throw StateError("Received mock packet with incorrect format.");
      }
      if (!["c", "f"].contains(indicator)) {
        throw StateError("Received mock packet with incorrect data type.");
      }

      if (indicator == "c") {
        ChannelMetadata data = ChannelMetadata(words[1], words[2], words[3]);
        debugPrint("[FileBootstrapChannel][receiver] Received channel metadata: \"$data\".");
        on(BootstrapChannelEvent.channelMetadata, data);
      } else {
        FileMetadata data = FileMetadata(words[1], int.parse(words[2]), int.parse(words[3]));
        debugPrint("[FileBootstrapChannel][receiver] Received file metadata: \"$data\".");
        on(BootstrapChannelEvent.fileMetadata, data);
      }
    });

    // Simulate delay before telling we're ready.
    //
    // Receiving end signals it's ready by creating a file named
    // "receiverIsReady" on watched directory; this file creation is then caught
    // by sending end (which in testing environment in on the same machine as
    // receiver end).
    await Future.delayed(Duration(milliseconds: Random().nextInt(1000)));
    debugPrint("[FileBootstrapChannel][initReceiver] Reception end is ready.");
    File chunkFile = File("${directory.path}${Platform.pathSeparator}$receiverReadyFileName");
    chunkFile.createSync();
  }

  @override
  Future<void> initSender({data = const {}}) async {
    debugPrint("[FileBootstrapChannel][initSender] Start sending end initialization.");
    bool isReceiverReady = false;

    StreamSubscription stream = directory.watch(events: FileSystemEvent.create).listen((event) {
      File file = File(event.path);
      String name = file.uri.pathSegments.last;
      if (name == receiverReadyFileName) {
        isReceiverReady = true;
      }
    });

    // If receiver end is not ready, we wait a bit.
    await Future.doWhile(() async {
      await Future.delayed(Duration(milliseconds: isReceiverReady ? 0 : 200));
      return !isReceiverReady;
    });

    stream.cancel();
    debugPrint("[FileBootstrapChannel][initSender] Sending end is ready.");
  }

  @override
  Future<void> sendChannelMetadata(ChannelMetadata data) async {
    debugPrint("[FileBootstrapChannel][sendChannelMetadata] Send channel metadata.");
    _createMockPacket(data, true);
  }

  @override
  Future<void> sendFileMetadata(FileMetadata data) async {
    debugPrint("[FileBootstrapChannel][sendChannelMetadata] Send file metadata.");
    _createMockPacket(data, false);
  }

  /// This helper function creates a file on watched directory, representing a
  /// packet sent over network.
  Future<void> _createMockPacket(dynamic content, bool isChannelMetadata) async {
    if (content is! ChannelMetadata && content is! FileMetadata) {
      throw StateError("Tried to send mock packet with incorrect data type.");
    }

    File packetFile = File(directory.path + Platform.pathSeparator + UniqueKey().toString());
    await packetFile.create();

    String packetContent = content.toString();
    String finalContent = "${content is ChannelMetadata ? "c" : "f"};$packetContent";

    await packetFile.writeAsBytes(utf8.encode(finalContent));
  }
}