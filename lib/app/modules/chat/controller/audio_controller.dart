import 'package:get/get.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

class AudioController extends GetxController {
  final _recorder = AudioRecorder();
  var isRecording = false.obs;
  var recordDuration = Duration.zero.obs;
  Timer? _timer;
  String? audioPath;

  Future<void> startRecording() async {
    if (await _recorder.hasPermission()) {
      final dir = await getTemporaryDirectory();
      audioPath =
          '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';
      await _recorder.start(RecordConfig(), path: audioPath!);
      isRecording.value = true;
      recordDuration.value = Duration.zero;

      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        recordDuration.value += const Duration(seconds: 1);
      });
    }
  }

  Future<String?> stopRecording() async {
    _timer?.cancel();
    isRecording.value = false;
    return await _recorder.stop();
  }

  Future<void> cancelRecording() async {
    _timer?.cancel();
    isRecording.value = false;
    await _recorder.cancel();
    audioPath = null;
  }
}
