import 'dart:io';

import 'package:async/src/cancelable_operation.dart';
import 'package:channel_multiplexed_scheduler/channels/channel.dart';
import 'package:channel_multiplexed_scheduler/channels/channel_event.dart';
import 'package:channel_multiplexed_scheduler/file/file_chunk.dart';
import 'package:channel_multiplexed_scheduler/scheduler/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

class MockScheduler extends Scheduler {
  // Stupid dummy implementation using only one channel.
  @override
  Future<void> sendChunks(List<FileChunk> chunks, Map<int, CancelableOperation> resubmissionTimers) async {
    while (chunksQueue.isNotEmpty || resubmissionTimers.isNotEmpty) {
      if (chunksQueue.isEmpty) {
        sleep(const Duration(milliseconds: 200));
      } else {
        sendChunk(chunksQueue.removeAt(0), channels[0]);
      }
    }
  }
}

class MockChannel extends Channel {
  bool isInit = false;
  List<int> sentChunksIds = [];

  @override
  Future<void> init() async {
    isInit = true;
  }

  @override
  void sendChunk(FileChunk chunk) {
    sentChunksIds.add(chunk.identifier);
    on(ChannelEvent.acknowledgment, chunk.identifier);
  }
}

void main() {
  late File file;
  late int fileLength;
  late Scheduler scheduler;

  setUpAll(() {
    file = File('test/assets/paper.pdf');
    fileLength = file.lengthSync();
  });
  setUp(() {
    scheduler = MockScheduler();
  });


  group('splitFile', () {
    test("should split file into chunks", () {
      int chunksize = 1000;

      List<FileChunk> chunks = scheduler.splitFile(file, chunksize);
      expect(chunks.length, (fileLength/chunksize).ceil());
      FileChunk lastChunk = chunks.removeLast();

      // all chunks should have same size,
      // except the last one which might be smaller
      for (var chunk in chunks) {
        expect(chunk.data.length, chunksize);
      }
      expect(lastChunk.data.length <= chunksize, true);
    });

    test("should not split file with negative chunk size", () {
      expect(() => scheduler.splitFile(file, -42),
          throwsA(predicate((e) => e is RangeError
              && e.message == 'Invalid chunk size (was -42).')));
    });

    test("should not split file with empty chunk size", () {
      expect(() => scheduler.splitFile(file, 0),
          throwsA(predicate((e) => e is RangeError
              && e.message == 'Invalid chunk size (was 0).')));
    });

    test("should not split file with chunk size bigger than file size", () {
      int chunksize = fileLength + 42;

      expect(() => scheduler.splitFile(file, chunksize),
          throwsA(predicate((e) => e is RangeError
              && e.message == 'Invalid chunk size (was $chunksize).')));
    });

    test("should split file in as many chunks as file bytes", () {
      List<FileChunk> chunks = scheduler.splitFile(file, 1);
      expect(chunks.length, file.lengthSync());
    });

    test("should throw with non-existing file", () {
      expect(() => scheduler.splitFile(File(''), 1000),
          throwsA(predicate((e) => e is RangeError
              && e.message == 'Invalid input file (path="").')));
    });
  });


  group('sendFile', () {
    test('should throw when sending file with no channel', () {
      expect(() async => await scheduler.sendFile(file, 100000),
          throwsA(predicate((e) => e is StateError
              && e.message == 'Cannot send file because scheduler has no channel.')));
    });

    test('should init channels', () async {
      MockChannel channel1 = MockChannel();
      MockChannel channel2 = MockChannel();
      scheduler.useChannel(channel1);
      scheduler.useChannel(channel2);

      await scheduler.sendFile(file, 100000);

      expect(channel1.isInit, true);
      expect(channel2.isInit, true);
    });

    test('should send all chunks through first channel with test strategy', () async {
      MockChannel channel1 = MockChannel();
      MockChannel channel2 = MockChannel();
      scheduler.useChannel(channel1);
      scheduler.useChannel(channel2);

      await scheduler.sendFile(file, 100000);

      expect(channel1.sentChunksIds, [0, 1, 2, 3, 4, 5, 6, 7, 8]);
      expect(channel2.sentChunksIds.isEmpty, true);
    });
  });
}