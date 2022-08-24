import 'dart:math';

import 'package:channel_multiplexed_scheduler/channels/channel.dart';
import 'package:channel_multiplexed_scheduler/channels/channel_event.dart';
import 'package:channel_multiplexed_scheduler/file/file_chunk.dart';


/// This is a mock Channel implementation that's used in tests.
class MockChannel extends Channel {
  bool isInitSender = false;
  bool isInitReceiver = false;
  List<int> sentChunksIds = [];

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
  @override
  Future<void> sendChunk(FileChunk chunk) async {
    await Future.delayed(Duration(milliseconds: Random().nextInt(2000)), () {
      if (!sentChunksIds.contains(chunk.identifier)) {
        sentChunksIds.add(chunk.identifier);
      }
      on(ChannelEvent.acknowledgment, chunk.identifier);
    });
  }
}