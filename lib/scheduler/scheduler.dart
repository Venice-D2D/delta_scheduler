import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:channel_multiplexed_scheduler/channels/events/bootstrap_channel_event.dart';
import 'package:channel_multiplexed_scheduler/channels/implementation/bootstrap_channel.dart';
import 'package:channel_multiplexed_scheduler/channels/implementation/data_channel.dart';
import 'package:channel_multiplexed_scheduler/channels/events/data_channel_event.dart';
import 'package:channel_multiplexed_scheduler/file/file_chunk.dart';
import 'package:channel_multiplexed_scheduler/file/file_metadata.dart';
import 'package:flutter/material.dart';


abstract class Scheduler {
  final BootstrapChannel bootstrapChannel;
  late final List<DataChannel> _channels = [];
  late List<FileChunk> _chunksQueue = [];
  final Map<int, CancelableOperation> _resubmissionTimers = {};

  Scheduler(this.bootstrapChannel);


  /// Adds a channel to be used to send file chunks.
  void useChannel(DataChannel channel) {
    _channels.add(channel);
    channel.on = (DataChannelEvent event, dynamic data) {
      switch (event) {
        case DataChannelEvent.acknowledgment:
          int chunkId = data;
          if (_resubmissionTimers.containsKey(chunkId)) {
            CancelableOperation timer = _resubmissionTimers.remove(chunkId)!;
            timer.cancel();
          }
          break;
        case DataChannelEvent.data:
          break;
      }
    };
  }

  /// Sends file chunks through available channels.
  ///
  /// While there are chunks to send, it unstacks them one by one, and choose
  /// a channel to send them.
  ///
  /// When sending a chunk, this registers a timeout callback, that triggers
  /// resending chunk if channel didn't send an acknowledgement.
  Future<void> sendFile(File file, int chunksize) async {
    if (_channels.isEmpty) {
      throw StateError('Cannot send file because scheduler has no channel.');
    }

    _chunksQueue = splitFile(file, chunksize);

    // Open bootstrap channel and send file metadata.
    await bootstrapChannel.initSender();
    await bootstrapChannel.sendFileMetadata(
        FileMetadata(file.uri.pathSegments.last, chunksize, _chunksQueue.length)
    );
    
    // Open all channels.
    // TODO force data channels to take a bootstrap channel as parameter
    await Future.wait(_channels.map((c) => c.initSender(data: bootstrapChannel)));

    // Begin sending chunks.
    await sendChunks(_chunksQueue, _channels, _resubmissionTimers);
  }

  /// This lets Scheduler instances implement their own chunks sending policy.
  /// 
  /// The implementation should send all chunks' content, by calling the 
  /// sendChunk method; it can also check for any resubmission timer presence, 
  /// to avoid finishing execution while some chunks have not been acknowledged.
  Future<void> sendChunks(
      List<FileChunk> chunks,
      List<DataChannel> channels,
      Map<int, CancelableOperation> resubmissionTimers);

  /// Sends a data chunk through a specified channel.
  /// 
  /// If such chunk is not acknowledged within a given duration, this will put
  /// the chunk at the head of the sending queue, for it to be resent as soon
  /// as possible.
  Future<void> sendChunk(FileChunk chunk, DataChannel channel) async {
    bool acknowledged = false;
    bool timedOut = false;

    _resubmissionTimers.putIfAbsent(
        chunk.identifier,
            () => CancelableOperation.fromFuture(
            Future.delayed(const Duration(seconds: 1), () {
              // Do not trigger chunk resending if it was previously
              // acknowledged.
              if (acknowledged) return;
              debugPrint("[Scheduler] Chunk n°${chunk.identifier} was not acknowledged in time, resending.");
              CancelableOperation timer = _resubmissionTimers.remove(chunk.identifier)!;
              timedOut = true;
              timer.cancel();
              _chunksQueue.insert(0, chunk);
            }),
              onCancel: () {
                // Do not print message if onCancel was called due to request
                // timeout.
                if (timedOut) return;
                acknowledged = true;
                debugPrint('[Scheduler] Chunk n°${chunk.identifier} was acknowledged.');
              }
        )
    );

    debugPrint("[Scheduler] Sending chunk n°${chunk.identifier}.");
    await channel.sendChunk(chunk);
  }

  /// Divides an input file into chunks of *chunksize* size.
  /// This will fail if input file is not accessible, or if input chunk size is
  /// invalid.
  List<FileChunk> splitFile (File file, int chunksize) {
    if (!file.existsSync()) {
      throw RangeError('Invalid input file (path="${file.path}").');
    }

    Uint8List bytes = file.readAsBytesSync();
    List<FileChunk> chunks = [];
    int bytesCount = bytes.length;
    int index = 0;

    if (chunksize <= 0 || chunksize > bytesCount) {
      throw RangeError('Invalid chunk size (was $chunksize).');
    }

    for (int i=0; i<bytesCount; i += chunksize) {
      chunks.add(FileChunk(
          identifier: index,
          data: bytes.sublist(i, i + chunksize > bytesCount
              ? bytesCount
              : i + chunksize)
      ));
      index += 1;
    }

    return chunks;
  }
}