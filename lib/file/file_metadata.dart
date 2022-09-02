class FileMetadata {
  final String name;
  final int chunkSize;
  final int chunkCount;

  FileMetadata(this.name, this.chunkSize, this.chunkCount);

  @override
  String toString() {
    return "$name;$chunkSize;$chunkCount";
  }
}