import 'dart:io';

import 'package:venice_core/channels/abstractions/bootstrap_channel.dart';
import 'package:delta_scheduler/scheduler/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venice_core/network/message.dart';

import 'mock/channel/mock_bootstrap_channel.dart';
import 'mock/channel/mock_data_channel.dart';
import 'mock/scheduler/mock_scheduler.dart';


void main() {
  late File file;
  late int fileLength;
  late BootstrapChannel bootstrapChannel;
  late Scheduler scheduler;

  setUpAll(() {
    file = File('test/assets/paper.pdf');
    fileLength = file.lengthSync();
  });
  setUp(() {
    bootstrapChannel = MockBootstrapChannel();
    scheduler = MockScheduler( bootstrapChannel );
  });


  group('useChannel', () {
    test('should throw when using 2 channels with same identifier', () {
      const String identifier = "mock_data_channel";
      MockDataChannel channel1 = MockDataChannel(identifier: identifier);
      MockDataChannel channel2 = MockDataChannel(identifier: identifier);
      scheduler.useChannel(channel1);

      expect(() => scheduler.useChannel(channel2),
          throwsA(predicate((e) => e is ArgumentError
              && e.message == 'Channel identifier "$identifier" is already used.')));
      });
  });

  group('splitFile', () {
    test("should split file into chunks", () {
      int chunksize = 1000;

      List<VeniceMessage> messages = scheduler.splitFile(file, chunksize);
      expect(messages.length, (fileLength/chunksize).ceil());
      VeniceMessage lastChunk = messages.removeLast();

      // all chunks should have same size,
      // except the last one which might be smaller
      for (var chunk in messages) {
        expect(chunk.data.length, chunksize);
      }
      expect(lastChunk.data.length <= chunksize, true);
    });

    test("should not split file with negative chunk size", () {
      expect(() => scheduler.splitFile(file, -42),
          throwsA(predicate((e) => e is RangeError
              && e.message == 'Invalid message maximum size (was -42).')));
    });

    test("should not split file with empty chunk size", () {
      expect(() => scheduler.splitFile(file, 0),
          throwsA(predicate((e) => e is RangeError
              && e.message == 'Invalid message maximum size (was 0).')));
    });

    test("should not split file with chunk size bigger than file size", () {
      int chunksize = fileLength + 42;

      expect(() => scheduler.splitFile(file, chunksize),
          throwsA(predicate((e) => e is RangeError
              && e.message == 'Invalid message maximum size (was $chunksize).')));
    });

    test("should split file in as many chunks as file bytes", () {
      List<VeniceMessage> messages = scheduler.splitFile(file, 1);
      expect(messages.length, file.lengthSync());
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
      MockDataChannel channel1 = MockDataChannel(identifier: "mock_data_channel_1");
      MockDataChannel channel2 = MockDataChannel(identifier: "mock_data_channel_2");
      scheduler.useChannel(channel1);
      scheduler.useChannel(channel2);

      await scheduler.sendFile(file, 100000);

      expect(channel1.isInitSender, true);
      expect(channel2.isInitSender, true);
    });

    test('should send all chunks through first channel with test strategy', () async {
      MockDataChannel channel1 = MockDataChannel(identifier: "mock_data_channel_1");
      MockDataChannel channel2 = MockDataChannel(identifier: "mock_data_channel_2");
      scheduler.useChannel(channel1);
      scheduler.useChannel(channel2);

      await scheduler.sendFile(file, 100000);

      // chunks are not sent in order, so we need to sort their ids
      channel1.sentMessagesIds.sort((int a, int b) => a - b);

      expect(channel1.sentMessagesIds, [0, 1, 2, 3, 4, 5, 6, 7, 8]);
      expect(channel2.sentMessagesIds.isEmpty, true);
    });

    test('should send all chunks even if some are dropped', () async {
      MockDataChannel channel = MockDataChannel(identifier: "mock_data_channel", shouldDropMessages: true);

      scheduler.useChannel(channel);
      await scheduler.sendFile(file, 100000);

      // chunks are not sent in order, so we need to sort their ids
      channel.sentMessagesIds.sort((int a, int b) => a - b);

      expect(channel.sentMessagesIds, [0, 1, 2, 3, 4, 5, 6, 7, 8]);
    });
  });
}