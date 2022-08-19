import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:channel_multiplexed_scheduler/channels/channel_event.dart';
import 'package:channel_multiplexed_scheduler/file/file_chunk.dart';

import '../channels/channel.dart';


abstract class Scheduler {
  late final List<Channel> channels = [];
  late List<FileChunk> chunksQueue = [];
  final Map<int, CancelableOperation> resubmissionTimers = {};

  /// Adds a channel to be used to send file chunks.
  void useChannel(Channel channel) {
    channels.add(channel);
  }

  /// Sends file chunks through available channels.
  ///
  /// While there are chunks to send, it unstacks them one by one, and choose
  /// a channel to send them.
  ///
  /// When sending a chunk, this registers a timeout callback, that triggers
  /// resending chunk if channel didn't send an acknowledgement.
  Future<void> sendFile(File file, int chunksize) async {
    if (channels.isEmpty) {
      throw StateError('Cannot send file because scheduler has no channel.');
    }

    chunksQueue = splitFile(file, chunksize);

    // initialize channels event listeners
    for (var channel in channels) {
      channel.on = (ChannelEvent event, dynamic data) {
        switch (event) {
          case ChannelEvent.acknowledgment:
            int chunkId = data;
            CancelableOperation timer = resubmissionTimers.remove(chunkId)!;
            timer.cancel();
            break;
          case ChannelEvent.opened:
            // TODO: Handle this case.
            break;
        }
      };
    }
    
    // Open all channels.
    Future.wait(channels.map((c) => c.init()));

    // Stupid dummy implementation using only one channel.
    while (chunksQueue.isNotEmpty || resubmissionTimers.isNotEmpty) {
      if (chunksQueue.isEmpty) {
        sleep(const Duration(milliseconds: 200));
      } else {
        FileChunk toSend = chunksQueue.removeAt(0);
        channels[0].sendChunk(toSend);

        resubmissionTimers.putIfAbsent(
            toSend.identifier,
            () => CancelableOperation.fromFuture(
                Future.delayed(const Duration(seconds: 1), () {
                  resubmissionTimers.remove(toSend.identifier);
                  chunksQueue.insert(0, toSend);
                })
            )
        );
      }
    }
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