import 'dart:async';
import 'dart:io';

import 'package:venice_core/channels/abstractions/bootstrap_channel.dart';
import 'package:venice_core/channels/abstractions/data_channel.dart';
import 'package:channel_multiplexed_scheduler/receiver/receiver.dart';
import 'package:channel_multiplexed_scheduler/scheduler/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock/channel/file_bootstrap_channel.dart';
import 'mock/channel/file_data_channel.dart';
import 'mock/scheduler/mock_scheduler.dart';

void main() {
  late Scheduler scheduler;
  late Receiver receiver;
  late BootstrapChannel bootstrapSendingChannel;
  late BootstrapChannel bootstrapReceivingChannel;
  late File file;
  late Directory destination;
  final int currentTime = DateTime.now().millisecondsSinceEpoch;

  setUpAll(() {
    file = File('test/assets/paper.pdf');
    destination = Directory("${Directory.systemTemp.path}${Platform.pathSeparator}");
  });
  setUp(() {
    // we use temporary storage to act as network for bootstrap channel
    Directory chunksFilesDir = Directory("${Directory.systemTemp.path}${Platform.pathSeparator}$currentTime${Platform.pathSeparator}bootstrap");
    chunksFilesDir.createSync(recursive: true);

    bootstrapSendingChannel = FileBootstrapChannel( directory: chunksFilesDir );
    bootstrapReceivingChannel = FileBootstrapChannel( directory: chunksFilesDir );
    scheduler = MockScheduler( bootstrapSendingChannel );
    receiver = Receiver( bootstrapReceivingChannel );
  });

  test('scheduler should exchange file with receiver', () async {
    // we use temporary storage to act as network
    Directory chunksFilesDir = Directory(Directory.systemTemp.path + Platform.pathSeparator + (currentTime+1).toString());
    chunksFilesDir.createSync();

    // sending part
    DataChannel sendChannel = FileDataChannel(directory: chunksFilesDir);
    scheduler.useChannel(sendChannel);

    // receiving end
    DataChannel receiveChannel = FileDataChannel(directory: chunksFilesDir);
    receiver.useChannel(receiveChannel);

    // Wait for both data sending and reception to end.
    await Future.wait([
      receiver.receiveFile(destination),
      scheduler.sendFile(file, 100000)
    ]);
    
    File receivedFile = File(destination.path+Platform.pathSeparator+file.uri.pathSegments.last);
    expect(receivedFile.existsSync(), true);
    expect(receivedFile.lengthSync() != 0, true);
  });

  // TODO This test uses a zone to catch asynchronous error; it seems to work when run via IDE, but not via `flutter test`.
  test('receiver should throw when receiving channel metadata matching no channel', () async {
    // we use temporary storage to act as network
    Directory chunksFilesDir = Directory(Directory.systemTemp.path + Platform.pathSeparator + (currentTime+1).toString());
    chunksFilesDir.createSync();

    const String id = "file_data_channel";

    // sending part
    DataChannel sendChannel = FileDataChannel(directory: chunksFilesDir, identifier: id);
    scheduler.useChannel(sendChannel);

    // receiving end (but with no matching identifier)
    DataChannel receiveChannel = FileDataChannel(directory: chunksFilesDir, identifier: "file_data_channel_2");
    receiver.useChannel(receiveChannel);

    scheduler.sendFile(file, 100000);

    // run receiving end in a guarded zone to catch asynchronous error
    bool gotError = false;

    runZonedGuarded(() async {
      await receiver.receiveFile(destination);
    }, (error, stack) {
      gotError = true;
      expect(error is ArgumentError, true);
      expect((error as ArgumentError).message, 'No channel with identifier "$id" was found in receiver channels.');
    });

    // wait until an error got thrown
    while (!gotError) {
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }, skip: true);
}