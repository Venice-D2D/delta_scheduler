import 'dart:typed_data';

class FileChunk {
  int identifier;
  Uint8List data;

  FileChunk({required this.identifier, required this.data});
}