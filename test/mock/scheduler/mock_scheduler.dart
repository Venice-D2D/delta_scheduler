import 'package:async/async.dart';
import 'package:channel_multiplexed_scheduler/channels/data_channel.dart';
import 'package:channel_multiplexed_scheduler/file/file_chunk.dart';
import 'package:channel_multiplexed_scheduler/scheduler/scheduler.dart';
import 'package:flutter/material.dart';


/// This is a mock Scheduler implementation, used in tests.
class MockScheduler extends Scheduler {
  /// Stupid dummy implementation using only one channel.
  /// Note the while loop that won't quit once all chunks have been sent, but
  /// once all chunks have been acknowledged.
  @override
  Future<void> sendChunks(List<FileChunk> chunks, List<DataChannel> channels, Map<int, CancelableOperation> resubmissionTimers) async {
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