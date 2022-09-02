import 'dart:convert';
import 'dart:io';

import 'package:channel_multiplexed_scheduler/channels/channel_metadata.dart';
import 'package:channel_multiplexed_scheduler/channels/implementation/bootstrap_channel.dart';
import 'package:channel_multiplexed_scheduler/file/file_metadata.dart';
import 'package:flutter/material.dart';

class FileBootstrapChannel extends BootstrapChannel {
  // This directory will store all package exchanged between sender and receiver.
  Directory directory;

  FileBootstrapChannel({required this.directory});


  @override
  Future<void> initReceiver({Map<String, dynamic> parameters = const {}}) async {
    // TODO listen created files and dispatch according events
    // TODO distinguish channel and file metadata
  }

  @override
  Future<void> initSender({data = const {}}) async {
    // TODO synchronize this with initReceiver (like FileDataChannel)
  }

  @override
  Future<void> sendChannelMetadata(ChannelMetadata data) async {
    _createMockPacket(data, true);
  }

  @override
  Future<void> sendFileMetadata(FileMetadata data) async {
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