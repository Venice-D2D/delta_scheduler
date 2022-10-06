import 'dart:io';

import 'package:venice_core/channels/channel_metadata.dart';
import 'package:venice_core/channels/events/bootstrap_channel_event.dart';
import 'package:venice_core/channels/abstractions/bootstrap_channel.dart';
import 'package:venice_core/file/file_metadata.dart';
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

  test("should exchange channel data between sending and receiving ends", () async {
    ChannelMetadata sentData1 = ChannelMetadata("phantom_channel", "address", "identifier", "password");
    ChannelMetadata sentData2 = ChannelMetadata("phantom_channel", "address2", "identifier2", "password2");
    bool received1 = false;
    bool received2 = false;

    // When receiving packet, check if contained data is correct.
    bootstrapReceivingChannel.on = (BootstrapChannelEvent event, dynamic data) {
      if (data is! ChannelMetadata) {
        throw TestFailure("Received data that is not of ChannelMetadata type.");
      }
      ChannelMetadata receivedData = data;
      if (receivedData.apIdentifier == "identifier") {
        expect(receivedData, sentData1);
        received1 = true;
      } else {
        expect(receivedData, sentData2);
        received2 = true;
      }
    };

    // Send test packets.
    bootstrapSendingChannel.sendChannelMetadata(sentData1);
    bootstrapSendingChannel.sendChannelMetadata(sentData2);

    // Wait for packet to be received.
    while (!received1 || !received2) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  });
}