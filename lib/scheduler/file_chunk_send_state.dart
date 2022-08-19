import 'package:async/async.dart';
import 'package:channel_multiplexed_scheduler/file/file_chunk.dart';

class FileChunkSendState {
  FileChunk data;
  CancelableOperation resubmissionTimer;
  FileChunkSendState({required this.data, required this.resubmissionTimer});
}