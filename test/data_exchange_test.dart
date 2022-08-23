import 'dart:io';

import 'package:channel_multiplexed_scheduler/channels/channel.dart';
import 'package:channel_multiplexed_scheduler/receiver/receiver.dart';
import 'package:channel_multiplexed_scheduler/scheduler/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock/channel/file_channel.dart';
import 'mock/channel/mock_channel.dart';
import 'mock/scheduler/mock_scheduler.dart';

void main() {
  late Scheduler scheduler;
  late Receiver receiver;
  late File file;

  setUpAll(() {
    file = File('test/assets/paper.pdf');
  });
  setUp(() {
    scheduler = MockScheduler();
    receiver = Receiver();
  });

  test('scheduler should exchange file with receiver', () async {
    // we use temporary storage to act as network
    Directory chunksFilesDir = Directory(Directory.systemTemp.path + Platform.pathSeparator + DateTime.now().millisecondsSinceEpoch.toString());
    chunksFilesDir.createSync();

    // sending part
    Channel sendChannel = FileChannel(directory: chunksFilesDir);
    scheduler.useChannel(sendChannel);

    // receiving end
    Channel receiveChannel = FileChannel(directory: chunksFilesDir);
    receiver.useChannel(receiveChannel);

    // Wait for both data sending and reception to end.
    await Future.wait([
      receiver.receiveFile(Path()),
      scheduler.sendFile(file, 100000)
    ]);
  });
}