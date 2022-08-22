import 'package:async/async.dart';
import 'package:channel_multiplexed_scheduler/channels/channel.dart';
import 'package:channel_multiplexed_scheduler/file/file_chunk.dart';
import 'package:channel_multiplexed_scheduler/scheduler/scheduler.dart';
import 'package:flutter/material.dart';


class MockScheduler extends Scheduler {
  // Stupid dummy implementation using only one channel.
  @override
  Future<void> sendChunks(List<FileChunk> chunks, List<Channel> channels, Map<int, CancelableOperation> resubmissionTimers) async {
    while (chunks.isNotEmpty || resubmissionTimers.isNotEmpty) {
      if (chunks.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 200));
      } else {
        sendChunk(chunks.removeAt(0), channels[0]);
      }
    }

    debugPrint('[Scheduler] Finished dispatching all chunks to channels.');
  }
}