import 'dart:math';

import 'package:venice_core/metadata/channel_metadata.dart';
import 'package:venice_core/channels/abstractions/bootstrap_channel.dart';
import 'package:venice_core/channels/abstractions/data_channel.dart';
import 'package:venice_core/channels/events/data_channel_event.dart';
import 'package:flutter/material.dart';
import 'package:venice_core/network/message.dart';


/// This is a mock Channel implementation that's used in tests.
class MockDataChannel extends DataChannel {
  bool shouldDropMessages;
  bool isInitSender = false;
  bool isInitReceiver = false;
  List<int> sentMessagesIds = [];

  MockDataChannel({required String identifier, this.shouldDropMessages = false}) : super(identifier);


  @override
  Future<void> initSender(BootstrapChannel channel) async {
    isInitSender = true;
  }

  @override
  Future<void> initReceiver(ChannelMetadata data) async {
    isInitReceiver = true;
  }

  /// Stupid message sending emulation, that acknowledges a chunk after a random
  /// delay to simulate network latency.
  /// If [shouldDropMessages] is set to true, this will simulate packet drop from
  /// time to time, not sending any acknowledgement at all.
  @override
  Future<void> sendMessage(VeniceMessage chunk) async {
    Random r = Random();
    if (shouldDropMessages && r.nextDouble() < 0.3) {
      debugPrint('==> [MockChannel] Dropped message n°${chunk.messageId}.');
      return;
    }

    await Future.delayed(Duration(milliseconds: r.nextInt(2000)), () {
      if (!sentMessagesIds.contains(chunk.messageId)) {
        sentMessagesIds.add(chunk.messageId);
      }
      on(DataChannelEvent.acknowledgment, chunk.messageId);
    });
  }

  @override
  Future<void> close() async {}
}