import 'dart:io';

import 'package:channel_multiplexed_scheduler/file/file_chunk.dart';
import 'package:channel_multiplexed_scheduler/scheduler/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

class MockScheduler extends Scheduler {}

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
      
      FileChunks chunks = scheduler.splitFile(file, chunksize);
      expect(chunks.length, (fileLength/chunksize).ceil());

      List<FileChunk> chunksList = chunks.values.toList();
      FileChunk lastChunk = chunksList.removeLast();

      // all chunks should have same size,
      // except the last one which might be smaller
      for (var chunk in chunksList) {
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
      FileChunks chunks = scheduler.splitFile(file, 1);
      expect(chunks.values.length, file.lengthSync());
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
          throwsA(predicate((e) => e is RangeError
              && e.message == 'Cannot send file because scheduler has no channel.')));
    });
  });
}