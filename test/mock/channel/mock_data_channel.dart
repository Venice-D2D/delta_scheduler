import 'dart:math';

import 'package:channel_multiplexed_scheduler/channels/channel_metadata.dart';
import 'package:channel_multiplexed_scheduler/channels/bootstrap_channel.dart';
import 'package:channel_multiplexed_scheduler/channels/data_channel.dart';
import 'package:channel_multiplexed_scheduler/channels/events/data_channel_event.dart';
import 'package:channel_multiplexed_scheduler/channels/data_channel.dart';
import 'package:channel_multiplexed_scheduler/file/file_chunk.dart';
import 'package:flutter/material.dart';


/// This is a mock Channel implementation that's used in tests.
class MockDataChannel extends DataChannel {
  bool shouldDropChunks;
  bool isInitSender = false;
  bool isInitReceiver = false;
  List<int> sentChunksIds = [];

  MockDataChannel({this.shouldDropChunks = false});


  @override
  Future<void> initSender(BootstrapChannel channel) async {
    isInitSender = true;
  }

  @override
  Future<void> initReceiver(ChannelMetadata data) async {
    isInitReceiver = true;
  }

  /// Stupid chunk sending emulation, that acknowledges a chunk after a random
  /// delay to simulate network latency.
  /// If shouldDropChunks is set to true, this will simulate packet drop from
  /// time to time, not sending any acknowledgement at all.
  @override
  Future<void> sendChunk(FileChunk chunk) async {
    Random r = Random();
    if (shouldDropChunks && r.nextDouble() < 0.3) {
      debugPrint('==> [MockChannel] Dropped chunk n°${chunk.identifier}.');
      return;
    }

    await Future.delayed(Duration(milliseconds: r.nextInt(2000)), () {
      if (!sentChunksIds.contains(chunk.identifier)) {
        sentChunksIds.add(chunk.identifier);
      }
      on(DataChannelEvent.acknowledgment, chunk.identifier);
    });
  }
}