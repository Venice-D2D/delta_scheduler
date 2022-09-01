import 'dart:io';

import 'package:channel_multiplexed_scheduler/channels/channel_metadata.dart';
import 'package:channel_multiplexed_scheduler/channels/implementation/bootstrap_channel.dart';
import 'package:channel_multiplexed_scheduler/file/file_metadata.dart';

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
    // TODO create file with metadata
  }

  @override
  Future<void> sendFileMetadata(FileMetadata data) async {
    // TODO create file with metadata
  }
}