/// These events will be fired on data channels, to indicate the type of data
/// that was received.
enum DataChannelEvent {
  /// Indicates that payload is the identifier of the file chunk that was
  /// acknowledged.
  acknowledgment,

  /// Indicates that payload is of FileChunk type.
  data
}