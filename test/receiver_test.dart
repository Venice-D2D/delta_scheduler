import 'dart:io';

import 'package:channel_multiplexed_scheduler/receiver/receiver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock/channel/mock_channel.dart';

void main() {
  late Receiver receiver;
  late String destination;

  setUpAll(() {
    destination = "${Directory.systemTemp.path}${Platform.pathSeparator}received.pdf";
  });
  setUp(() {
    receiver = Receiver();
  });

  test('should throw when receiving file with no channel', () {
    expect(() async => await receiver.receiveFile(destination),
          throwsA(predicate((e) => e is StateError
              && e.message == 'Cannot receive file because receiver has no channel.')));
  });

  test('should init channels', () async {
    MockChannel channel1 = MockChannel();
    MockChannel channel2 = MockChannel();
    receiver.useChannel(channel1);
    receiver.useChannel(channel2);

    // Don't await the result of this method, because we're not sending anything,
    // so this would never end...
    receiver.receiveFile(destination);

    expect(channel1.isInitReceiver, true);
    expect(channel2.isInitReceiver, true);
  });
}