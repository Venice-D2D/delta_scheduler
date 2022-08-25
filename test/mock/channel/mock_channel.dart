import 'dart:math';

import 'package:channel_multiplexed_scheduler/channels/channel.dart';
import 'package:channel_multiplexed_scheduler/channels/channel_event.dart';
import 'package:channel_multiplexed_scheduler/file/file_chunk.dart';
import 'package:flutter/material.dart';


/// This is a mock Channel implementation that's used in tests.
class MockChannel extends Channel {
  bool shouldDropChunks;
  bool isInitSender = false;
  bool isInitReceiver = false;
  List<int> sentChunksIds = [];

  MockChannel({this.shouldDropChunks = false});


  @override
  Future<void> initSender() async {
    isInitSender = true;
  }

  @override
  Future<void> initReceiver() async {
    isInitReceiver = true;
  }

  /// Stupid chunk sending emulation, that acknowledges a chunk after a random
  /// delay to simulate network latency.
  /// If shouldDropChunks is set to true, this will simulate packet drop from
  /// time to time, not sending any acknowledgement at all.
  @override
  Future<void> sendChunk(FileChunk chunk) async {
    Random r = Random();
    if (shouldDropChunks && r.nextBool()) {
      debugPrint('==> [MockChannel] Dropped chunk n°${chunk.identifier}.');
      return;
    }

    await Future.delayed(Duration(milliseconds: r.nextInt(2000)), () {
      if (!sentChunksIds.contains(chunk.identifier)) {
        sentChunksIds.add(chunk.identifier);
      }
      on(ChannelEvent.acknowledgment, chunk.identifier);
    });
  }
}