import 'dart:io';

import 'package:channel_multiplexed_scheduler/file/file_chunk.dart';
import 'package:channel_multiplexed_scheduler/scheduler/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

class MockScheduler extends Scheduler {}

void main() {
  test("should split file into chunks", () {
    Scheduler scheduler = MockScheduler();
    File file = File('test/assets/paper.pdf');
    int chunksize = 1000;
    int fileLength = file.lengthSync();
    
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
    Scheduler scheduler = MockScheduler();
    File file = File('test/assets/paper.pdf');
    expect(() => scheduler.splitFile(file, -42),
        throwsA(predicate((e) => e is RangeError
            && e.message == 'Invalid chunk size (was -42).')));
  });

  test("should not split file with empty chunk size", () {
    Scheduler scheduler = MockScheduler();
    File file = File('test/assets/paper.pdf');
    expect(() => scheduler.splitFile(file, 0),
        throwsA(predicate((e) => e is RangeError
            && e.message == 'Invalid chunk size (was 0).')));
  });
}