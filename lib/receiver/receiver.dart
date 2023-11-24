import 'dart:io';

import 'package:venice_core/metadata/channel_metadata.dart';
import 'package:venice_core/channels/events/bootstrap_channel_event.dart';
import 'package:venice_core/channels/abstractions/bootstrap_channel.dart';
import 'package:venice_core/channels/events/data_channel_event.dart';
import 'package:venice_core/channels/abstractions/data_channel.dart';
import 'package:venice_core/metadata/file_metadata.dart';
import 'package:venice_core/network/message.dart';


/// The Receiver class goal is to receive a file from a Scheduler instance
/// that's running on another device.
class Receiver {
  final BootstrapChannel bootstrapChannel;
  late final List<DataChannel> _channels = [];
  final Map<int, VeniceMessage> _messages = {};

  /// Number of messages we expect to receive.
  /// Receiver will not end while it has not received expected chunks count.
  late int _messagesCount;

  /// Name of the file that will be created by the received.
  /// It is transmitted through the bootstrap channel.
  late String _filename;

  Receiver(this.bootstrapChannel);


  /// Adds a channel to use to receive data.
  void useChannel(DataChannel channel) {
    if (_channels.where((element) => element.identifier == channel.identifier).isNotEmpty) {
      throw ArgumentError('Channel identifier "${channel.identifier}" is already used.');
    }
    
    _channels.add(channel);
    channel.on = (DataChannelEvent event, dynamic data) {
      VeniceMessage chunk = data;
      _messages.putIfAbsent(chunk.messageId, () => chunk);
    };
  }

  /// Receives a file through available channels.
  Future<void> receiveFile(Directory destination) async {
    bool allChannelsInitialized = false;
    bool fileMetadataReceived = false;

    if (_channels.isEmpty) {
      throw StateError('Cannot receive file because receiver has no channel.');
    }

    if (!destination.existsSync()) {
      throw ArgumentError('Destination directory does not exist.');
    }

    int initializedChannels = 0;

    // Open bootstrap channel.
    bootstrapChannel.on = (BootstrapChannelEvent event, dynamic data) async {
      switch(event) {
        case BootstrapChannelEvent.fileMetadata:
          // TODO use chunk size
          FileMetadata fileMetadata = data;
          _filename = fileMetadata.name;
          _messagesCount = fileMetadata.chunkCount;
          fileMetadataReceived = true;
          break;
        case BootstrapChannelEvent.channelMetadata:
          // Open all channels.
          ChannelMetadata channelMetadata = data;

          // Get matching channel to only send data to it, and not other channels.
          DataChannel matchingChannel = _channels.firstWhere((element) =>
              element.identifier == channelMetadata.channelIdentifier,
              orElse: () => throw ArgumentError(
                  'No channel with identifier "${channelMetadata.channelIdentifier}" was found in receiver channels.')
          );
          await matchingChannel.initReceiver(channelMetadata);

          // Start receiving once all channels have been initialized.
          initializedChannels += 1;
          if (initializedChannels == _channels.length) {
            allChannelsInitialized = true;
          }

          break;
      }
    };

    await bootstrapChannel.initReceiver();

    // Wait for bootstrap channel to receive channel information and initialize
    // them.
    while (!allChannelsInitialized || !fileMetadataReceived) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Wait for all messages to arrive.
    await receiveAllMessages();

    // Fill destination file with received messages.
    File newFile = File(destination.path+Platform.pathSeparator+_filename);
    if (newFile.existsSync()) {
      newFile.deleteSync();
    }
    newFile.createSync();
    for (var msg in _messages.values) {
      newFile.writeAsBytesSync(msg.data, mode: FileMode.append);
    }
  }


  Future<void> receiveAllMessages() async {
    while (_messages.length != _messagesCount) {
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }
}