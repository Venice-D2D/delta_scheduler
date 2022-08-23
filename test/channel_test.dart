import 'package:channel_multiplexed_scheduler/channels/channel.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock/channel/mock_channel.dart';

void main() {
  test("A channel instance shouldn't be able to send AND receive data", () async {
    Channel channel = MockChannel();
    await channel.initSender();
    expect(() async => await channel.initReceiver(),
        throwsA(predicate((e) => e is StateError
            && e.message == 'A channel must be used for data reception or sending, not both.')));
  });
}