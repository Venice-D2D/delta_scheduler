import 'package:channel_multiplexed_scheduler/channels/channel.dart';
import 'package:flutter/material.dart';

class Receiver {
  late final List<Channel> _channels = [];

  /// Adds a channel to use to receive data.
  void useChannel(Channel channel) {}

  /// Receives a file through available channels.
  Future<void> receiveFile(Path destination) async {
    if (_channels.isEmpty) {
      throw StateError('Cannot receive file because receiver has no channel.');
    }
  }
}