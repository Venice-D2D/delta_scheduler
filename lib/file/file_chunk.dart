import 'dart:typed_data';

class FileChunk {
  int identifier;
  ByteBuffer data;

  FileChunk({required this.identifier, required this.data});
}