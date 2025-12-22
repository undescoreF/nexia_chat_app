import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

class MessageAudioController extends GetxController {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final String audioUrl;
  final File? localFile;
  final bool isMe;
  final bool isUploaded;

  final RxBool _isPlaying = false.obs;
  final RxBool _isLoading = false.obs;
  final Rx<Duration> _duration = Duration.zero.obs;
  final Rx<Duration> _position = Duration.zero.obs;

  MessageAudioController({
    required this.audioUrl,
    required this.localFile,
    required this.isMe,
    required this.isUploaded,
  }) {
    _initialize();
  }

  bool get isPlaying => _isPlaying.value;
  bool get isLoading => _isLoading.value;
  Duration get duration => _duration.value;
  Duration get position => _position.value;

  bool get isAudioReady => isUploaded || localFile != null;

  void _initialize() async {
    if (isAudioReady) {
      await _setupAudioPlayer();
    }
  }

  Future<void> _setupAudioPlayer() async {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying.value = state == PlayerState.playing;
      _isLoading.value =
          state == PlayerState.playing && _position.value.inMilliseconds == 0;
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      _duration.value = duration;
    });

    _audioPlayer.onPositionChanged.listen((position) {
      _position.value = position;
      _isLoading.value = false;
    });

    if (localFile != null && await localFile!.exists()) {
      await _audioPlayer.setSource(DeviceFileSource(localFile!.path));
    } else if (audioUrl.isNotEmpty) {
      await _audioPlayer.setSource(UrlSource(audioUrl));
    }
  }

  Future<void> togglePlayPause() async {
    if (!isAudioReady) return;

    if (_isPlaying.value) {
      await _audioPlayer.pause();
    } else {
      if (_position.value >= _duration.value &&
          _duration.value > Duration.zero) {
        await _audioPlayer.seek(Duration.zero);
        _duration.value = Duration.zero;
      }

      _isLoading.value = true;
      await _audioPlayer.resume();
    }
  }

  Future<void> seek(Duration position) async {
    if (!isAudioReady) return;
    await _audioPlayer.seek(position);
  }

  void resetToStart() {
    if (isAudioReady) {
      _audioPlayer.seek(Duration.zero);
      _isPlaying.value = false;
    }
  }

  Future<void> disposeAudio() async {
    await _audioPlayer.dispose();
  }
}
