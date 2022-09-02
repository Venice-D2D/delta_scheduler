abstract class Channel {
  /// Initializes current channel, and returns when it is ready to send data.
  /// TODO DataChannel.initSender will always have a BootstrapChannel as input
  Future<void> initSender({dynamic data = const {}});

  /// Initializes current channel, and returns when it is ready to receive data.
  Future<void> initReceiver({Map<String, dynamic> parameters = const {}});
}