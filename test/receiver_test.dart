import 'dart:io';

import 'package:channel_multiplexed_scheduler/receiver/receiver.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock/channel/mock_bootstrap_channel.dart';
import 'mock/channel/mock_data_channel.dart';

void main() {
  late Receiver receiver;
  late String destination;

  setUpAll(() {
    destination = "${Directory.systemTemp.path}${Platform.pathSeparator}received.pdf";
  });
  setUp(() {
    receiver = Receiver( MockBootstrapChannel() );
  });

  test('should throw when receiving file with no channel', () {
    expect(() async => await receiver.receiveFile(destination),
          throwsA(predicate((e) => e is StateError
              && e.message == 'Cannot receive file because receiver has no channel.')));
  });

  test('should init channels', () async {
    MockDataChannel channel1 = MockDataChannel();
    MockDataChannel channel2 = MockDataChannel();
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