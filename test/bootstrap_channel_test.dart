import 'dart:io';

import 'package:channel_multiplexed_scheduler/channels/events/bootstrap_channel_event.dart';
import 'package:channel_multiplexed_scheduler/channels/implementation/bootstrap_channel.dart';
import 'package:channel_multiplexed_scheduler/file/file_metadata.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock/channel/file_bootstrap_channel.dart';

void main() {
  late BootstrapChannel bootstrapSendingChannel;
  late BootstrapChannel bootstrapReceivingChannel;

  setUp(() async {
    // we use temporary storage to act as network for bootstrap channel
    Directory chunksFilesDir = Directory("${Directory.systemTemp.path}${Platform.pathSeparator}${DateTime.now().millisecondsSinceEpoch}${Platform.pathSeparator}bootstrap");
    chunksFilesDir.createSync(recursive: true);

    bootstrapSendingChannel = FileBootstrapChannel( directory: chunksFilesDir );
    bootstrapReceivingChannel = FileBootstrapChannel( directory: chunksFilesDir );

    // Initialize both channels.
    await Future.wait([
      bootstrapReceivingChannel.initReceiver(),
      bootstrapSendingChannel.initSender()
    ]);
  });

  test("should exchange file data between sending and receiving ends", () async {
    FileMetadata sentData = FileMetadata("vacation_picture.png", 100000, 3);
    bool received = false;

    // When receiving packet, check if contained data is correct.
    bootstrapReceivingChannel.on = (BootstrapChannelEvent event, dynamic data) {
      if (data is! FileMetadata) {
        throw TestFailure("Received data that is not of FileMetadata type.");
      }
      FileMetadata receivedData = data;
      expect(receivedData, sentData);
      received = true;
    };

    // Send test packet.
    await bootstrapSendingChannel.sendFileMetadata(sentData);

    // Wait for packet to be received.
    while (!received) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  });
}