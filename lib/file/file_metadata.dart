class FileMetadata {
  final String name;
  final int chunkSize;
  final int chunkCount;

  FileMetadata(this.name, this.chunkSize, this.chunkCount);

  @override
  String toString() {
    return "$name;$chunkSize;$chunkCount";
  }

  @override
  bool operator ==(Object other) {
    return other is FileMetadata && name == other.name && chunkSize == other.chunkSize && chunkCount == other.chunkCount;
  }

  @override
  int get hashCode => int.parse("${name.hashCode}${chunkSize.hashCode}${chunkCount.hashCode}");

}