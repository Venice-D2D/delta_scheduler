import 'package:channel_multiplexed_scheduler/file/file_chunk.dart';

class FileChunkSendState {
  FileChunk data;
  Future timer;
  FileChunkSendState({required this.data, required this.timer});
}