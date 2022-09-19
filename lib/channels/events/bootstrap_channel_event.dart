/// These events will be fired on the bootstrap channel, to indicate the type
/// of data that was received.
enum BootstrapChannelEvent {
  /// Indicates that payload is of ChannelMetadata type.
  channelMetadata,

  /// Indicates that payload is of FileMetadata type.
  fileMetadata
}