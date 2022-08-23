import 'dart:math';

import 'package:channel_multiplexed_scheduler/channels/channel.dart';
import 'package:channel_multiplexed_scheduler/channels/channel_event.dart';
import 'package:channel_multiplexed_scheduler/file/file_chunk.dart';


class MockChannel extends Channel {
  bool isInit = false;
  List<int> sentChunksIds = [];

  @override
  Future<void> initSender() async {
    isInit = true;
  }

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