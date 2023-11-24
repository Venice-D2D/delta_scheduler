import 'package:async/async.dart';
import 'package:venice_core/channels/abstractions/data_channel.dart';
import 'package:delta_scheduler/scheduler/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:venice_core/network/message.dart';


/// This is a mock Scheduler implementation, used in tests.
class MockScheduler extends Scheduler {
  MockScheduler(super.bootstrapChannel);

  /// Stupid dummy implementation using only one channel.
  /// Note the while loop that won't quit once all messages have been sent, but
  /// once all messages have been acknowledged.
  @override
  Future<void> sendMessages(List<VeniceMessage> chunks, List<DataChannel> channels, Map<int, CancelableOperation> resubmissionTimers) async {
    while (chunks.isNotEmpty || resubmissionTimers.isNotEmpty) {
      if (chunks.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 200));
      } else {
        sendMessage(chunks.removeAt(0), channels[0]);
      }
    }

    debugPrint('[Scheduler] Finished dispatching all chunks to channels.');
  }
}