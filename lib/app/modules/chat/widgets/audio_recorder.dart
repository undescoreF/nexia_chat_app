import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:nexachat/app/utils/appcolors.dart';

class RecordUI extends StatelessWidget {
  final Duration duration;
  final VoidCallback onCancel;
  final VoidCallback onStop;

  const RecordUI({
    super.key,
    required this.duration,
    required this.onCancel,
    required this.onStop,
  });

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inMinutes)}:${two(d.inSeconds % 60)}";
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.mic, color: Colors.red),
        const SizedBox(width: 8),
        Text(_formatDuration(duration), style: const TextStyle(fontSize: 16)),
        const Spacer(),
        IconButton(onPressed: onCancel, icon: const Icon(Icons.close)),
        IconButton(
          onPressed: onStop,
          icon: Icon(Icons.check, color: AppColors.iconNonNeutral),
        ),
      ],
    );
  }
}

class AudioPreview extends StatefulWidget {
  final String filePath;
  final VoidCallback onCancel;
  final VoidCallback onSend;

  const AudioPreview({
    super.key,
    required this.filePath,
    required this.onCancel,
    required this.onSend,
  });

  @override
  State<AudioPreview> createState() => _AudioPreviewState();
}

class _AudioPreviewState extends State<AudioPreview> {
  final AudioPlayer _player = AudioPlayer();
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player.setSource(DeviceFileSource(widget.filePath));
    _player.onDurationChanged.listen((d) => setState(() => _duration = d));
    _player.onPositionChanged.listen((p) => setState(() => _position = p));
    _player.onPlayerComplete.listen(
      (_) => setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      }),
    );
  }

  void _playPause() {
    if (_isPlaying) {
      _player.pause();
      setState(() => _isPlaying = false);
    } else {
      _player.play(DeviceFileSource(widget.filePath));
      setState(() => _isPlaying = true);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(1, 1)),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: AppColors.iconNonNeutral,
              size: 30,
            ),
            onPressed: _playPause,
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(
                  value: _duration.inMilliseconds == 0
                      ? 0
                      : _position.inMilliseconds / _duration.inMilliseconds,
                ),
                SizedBox(height: 4),
                Text(
                  "${_position.inSeconds}s / ${_duration.inSeconds}s",
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(onPressed: widget.onCancel, icon: Icon(Icons.close)),
          IconButton(
            onPressed: widget.onSend,
            icon: Icon(Icons.send, color: AppColors.iconNonNeutral),
          ),
        ],
      ),
    );
  }
}
