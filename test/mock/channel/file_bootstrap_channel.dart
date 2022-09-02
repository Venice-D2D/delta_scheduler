import 'dart:convert';
import 'dart:io';

import 'package:channel_multiplexed_scheduler/channels/channel.dart';
import 'package:channel_multiplexed_scheduler/channels/channel_metadata.dart';
import 'package:channel_multiplexed_scheduler/channels/events/bootstrap_channel_event.dart';
import 'package:channel_multiplexed_scheduler/channels/implementation/bootstrap_channel.dart';
import 'package:channel_multiplexed_scheduler/file/file_metadata.dart';
import 'package:flutter/material.dart';

class FileBootstrapChannel extends BootstrapChannel {
  // This directory will store all package exchanged between sender and receiver.
  Directory directory;

  FileBootstrapChannel({required this.directory});


  @override
  Future<void> initReceiver({Map<String, dynamic> parameters = const {}}) async {
    debugPrint("[FileBootstrapChannel][initReceiver] Start receiving end initialization.");
    directory.watch(events: FileSystemEvent.create).listen((event) async {
      File receivedPacket = File(event.path);
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
    debugPrint("[FileBootstrapChannel][initReceiver] Reception end is ready.");
  }

  @override
  Future<void> initSender({data = const {}}) async {
    // TODO synchronize this with initReceiver (like FileDataChannel)
    debugPrint("[FileBootstrapChannel][initSender] Start sending end initialization.");
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