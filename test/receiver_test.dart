import 'dart:io';

import 'package:channel_multiplexed_scheduler/receiver/receiver.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock/channel/mock_bootstrap_channel.dart';
import 'mock/channel/mock_data_channel.dart';

void main() {
  late Receiver receiver;
  late Directory destination;

  setUpAll(() {
    destination = Directory("${Directory.systemTemp.path}${Platform.pathSeparator}");
  });
  setUp(() {
    receiver = Receiver( MockBootstrapChannel() );
  });

  test('should throw when receiving file with no channel', () {
    expect(() async => await receiver.receiveFile(destination),
          throwsA(predicate((e) => e is StateError
              && e.message == 'Cannot receive file because receiver has no channel.')));
  });

  test('should throw with incorrect destination', () {
    MockDataChannel channel1 = MockDataChannel(identifier: "mock_data_channel");
    receiver.useChannel(channel1);

    expect(() async => await receiver.receiveFile(Directory('/this/path/does/not/exist')),
        throwsA(predicate((e) => e is ArgumentError
            && e.message == 'Destination directory does not exist.')));
  });

  test('should throw when using 2 channels with same identifier', () {
    const String identifier = "mock_data_channel";
    MockDataChannel channel1 = MockDataChannel(identifier: identifier);
    MockDataChannel channel2 = MockDataChannel(identifier: identifier);
    receiver.useChannel(channel1);

    expect(() => receiver.useChannel(channel2),
        throwsA(predicate((e) => e is ArgumentError
            && e.message == 'Channel identifier "$identifier" is already used.')));
  });

  test('should init channels', () async {
    MockDataChannel channel1 = MockDataChannel(identifier: "mock_data_channel_1");
    MockDataChannel channel2 = MockDataChannel(identifier: "mock_data_channel_2");
    receiver.useChannel(channel1);
    receiver.useChannel(channel2);

    // Don't await the result of this method, because we're not sending anything,
    // so this would never end...
    receiver.receiveFile(destination);

    // Since receiver waits for data from bootstrap channel to initialize
    // channels, we leave it some time before checking if channels are indeed
    // initialized.
    await Future.delayed(const Duration(milliseconds: 500), () {
      expect(channel1.isInitReceiver, true);
      expect(channel2.isInitReceiver, true);
    });
  });
}