import 'package:channel_multiplexed_scheduler/receiver/receiver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Receiver receiver;

  setUp(() {
    receiver = Receiver();
  });

  test('should throw when receiving file with no channel', () {
    expect(() async => await receiver.receiveFile(Path()),
          throwsA(predicate((e) => e is StateError
              && e.message == 'Cannot receive file because receiver has no channel.')));
  });
}