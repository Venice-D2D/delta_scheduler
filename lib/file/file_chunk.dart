import 'dart:typed_data';

/// This holds a section of the transferred file, and goes through data channels
/// from sender to receiver.
class FileChunk {
  /// Position of the file chunk in the final file.
  int identifier;

  /// File bytes.
  Uint8List data;

  FileChunk({required this.identifier, required this.data});
}