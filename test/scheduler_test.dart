import 'dart:io';

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
  });
}