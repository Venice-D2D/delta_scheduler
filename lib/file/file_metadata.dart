/// This payload class holds data needed for the receiving device to initialize
/// primitives related to the file that will be sent once all data channels are
/// ready.
/// This is typically sent from sender to receiver through a bootstrap channel.
class FileMetadata {
  /// Name of the file to be transferred.
  final String name;

  /// Size of a file chunk.
  final int chunkSize;

  /// Number of file chunks.
  final int chunkCount;

  FileMetadata(this.name, this.chunkSize, this.chunkCount);


  @override
  String toString() {
    return "$name;$chunkSize;$chunkCount";
  }

  @override
  bool operator == (Object other) {
    return other is FileMetadata
        && name == other.name
        && chunkSize == other.chunkSize
        && chunkCount == other.chunkCount;
  }

  @override
  int get hashCode => Object.hash(name, chunkSize, chunkCount);
}