import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:venice_core/channels/abstractions/bootstrap_channel.dart';
import 'package:venice_core/channels/events/data_channel_event.dart';
import 'package:venice_core/channels/abstractions/data_channel.dart';
import 'package:venice_core/metadata/file_metadata.dart';
import 'package:flutter/material.dart';
import 'package:venice_core/network/message.dart';


/// The Scheduler class goal is to send a file to a Receiver instance that's
/// located on another device.
///
/// To do so, it uses multiple data channels; it is responsible for their
/// initialization, but also in the implementation of the channel choice
/// strategy (*i.e.* in choosing which channel to use to send a given file
/// message).
abstract class Scheduler {
  final BootstrapChannel bootstrapChannel;
  late final List<DataChannel> _channels = [];
  late List<VeniceMessage> _messagesQueue = [];
  final Map<int, CancelableOperation> _resubmissionTimers = {};

  Scheduler(this.bootstrapChannel);


  /// Adds a channel to be used to send file chunks.
  void useChannel(DataChannel channel) {
    if (_channels.where((element) => element.identifier == channel.identifier).isNotEmpty) {
      throw ArgumentError('Channel identifier "${channel.identifier}" is already used.');
    }
    
    _channels.add(channel);
    channel.on = (DataChannelEvent event, dynamic data) {
      switch (event) {
        case DataChannelEvent.acknowledgment:
          int msgId = data;
          if (_resubmissionTimers.containsKey(msgId)) {
            CancelableOperation timer = _resubmissionTimers.remove(msgId)!;
            timer.cancel();
          }
          break;
        case DataChannelEvent.data:
          break;
      }
    };
  }

  /// Sends a file through available channels.
  ///
  /// While there are messages to send, it unstacks them one by one, and choose
  /// a channel to send them.
  ///
  /// When sending a message, this registers a timeout callback, that triggers
  /// resending messages if channel didn't send an acknowledgement.
  Future<void> sendFile(File file, int msgMaxSize) async {
    if (_channels.isEmpty) {
      throw StateError('Cannot send file because scheduler has no channel.');
    }

    _messagesQueue = splitFile(file, msgMaxSize);

    // Open bootstrap channel and send file metadata.
    await bootstrapChannel.initSender();
    await bootstrapChannel.sendFileMetadata(
        FileMetadata(file.uri.pathSegments.last, msgMaxSize, _messagesQueue.length)
    );
    
    // Open all channels.
    await Future.wait(_channels.map((c) => c.initSender( bootstrapChannel )));
    debugPrint("[Scheduler] All data channels are ready, data sending can start.\n");

    // Begin sending messages.
    await sendMessages(_messagesQueue, _channels, _resubmissionTimers);
  }

  /// This lets Scheduler instances implement their own message sending policy.
  /// 
  /// The implementation should send all messages' content, by calling the 
  /// sendMessage method; it can also check for any resubmission timer presence, 
  /// to avoid finishing execution while some messages have not been
  /// acknowledged.
  Future<void> sendMessages(
      List<VeniceMessage> messages,
      List<DataChannel> channels,
      Map<int, CancelableOperation> resubmissionTimers);

  /// Sends a message through a specified channel.
  /// 
  /// If such message is not acknowledged within a given duration, this will put
  /// the message at the head of the sending queue, for it to be resent as soon
  /// as possible.
  Future<void> sendMessage(VeniceMessage msg, DataChannel channel) async {
    bool acknowledged = false;
    bool timedOut = false;

    _resubmissionTimers.putIfAbsent(
        msg.messageId,
            () => CancelableOperation.fromFuture(
            Future.delayed(const Duration(seconds: 1), () {
              // Do not trigger message resending if it was previously
              // acknowledged.
              if (acknowledged) return;
              debugPrint("[Scheduler] Message n°${msg.messageId} was not acknowledged in time, resending.");
              CancelableOperation timer = _resubmissionTimers.remove(msg.messageId)!;
              timedOut = true;
              timer.cancel();
              _messagesQueue.insert(0, msg);
            }),
              onCancel: () {
                // Do not print message if onCancel was called due to request
                // timeout.
                if (timedOut) return;
                acknowledged = true;
                debugPrint('[Scheduler] Message n°${msg.messageId} was acknowledged.');
              }
        )
    );

    debugPrint("[Scheduler] Sending message n°${msg.messageId}.");
    await channel.sendMessage(msg);
  }

  /// Divides an input file into messages of [maxSize] size.
  /// This will fail if input file is not accessible, or if input size is
  /// invalid.
  List<VeniceMessage> splitFile (File file, int maxSize) {
    if (!file.existsSync()) {
      throw RangeError('Invalid input file (path="${file.path}").');
    }

    Uint8List bytes = file.readAsBytesSync();
    List<VeniceMessage> messages = [];
    int bytesCount = bytes.length;
    int index = 0;

    if (maxSize <= 0 || maxSize > bytesCount) {
      throw RangeError('Invalid message maximum size (was $maxSize).');
    }

    for (int i=0; i<bytesCount; i += maxSize) {
      Uint8List data = bytes.sublist(i, i + maxSize > bytesCount
          ? bytesCount
          : i + maxSize);
      messages.add(VeniceMessage.data(index, data));
      index += 1;
    }

    return messages;
  }
}