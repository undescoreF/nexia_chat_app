import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_trimmer/video_trimmer.dart';

import '../../../utils/appcolors.dart';

class TrimmerView extends StatefulWidget {
  final Trimmer trimmer;

  const TrimmerView({super.key, required this.trimmer});

  @override
  State<TrimmerView> createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  double _startValue = 0.0;
  double _endValue = 0.0;
  bool _isPlaying = false;

  bool _progressVisibility = false;

  Future<String?> _saveVideo() async {
    setState(() {
      _progressVisibility = true;
    });

    String? _value;

    await widget.trimmer
        .saveTrimmedVideo(
          startValue: _startValue,
          endValue: _endValue,
          onSave: (outputPath) {},
        )
        .then((value) {
          setState(() {
            _progressVisibility = false;
            //_value = value;
          });
        });

    return _value;
  }

  void _loadVideo() {
    widget.trimmer.loadVideo(videoFile: widget.trimmer.currentVideoFile!);
  }

  @override
  void initState() {
    super.initState();

    _loadVideo();
  }

  @override
  void dispose() {
    widget.trimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Couper la vidéo"),
        leading: IconButton(
          onPressed: () {
            widget.trimmer.dispose();
            Navigator.pop(context);
          },
          icon: Icon(Icons.keyboard_arrow_left, color: Colors.black),
        ),
      ),
      body: Builder(
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.only(bottom: 30.0),
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Visibility(
                  visible: _progressVisibility,
                  child: LinearProgressIndicator(backgroundColor: Colors.red),
                ),
                ElevatedButton(
                  onPressed: _progressVisibility
                      ? null
                      : () async {
                          _saveVideo().then((outputPath) {
                            debugPrint('OUTPUT PATH: $outputPath');
                            final snackBar = SnackBar(
                              content: Text('Video Saved successfully'),
                            );
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(snackBar);
                          });
                        },
                  child: Text("SAVE"),
                ),
                Expanded(child: VideoViewer(trimmer: widget.trimmer)),
                Center(
                  child: TrimViewer(
                    trimmer: widget.trimmer,
                    viewerHeight: 50.0,
                    viewerWidth: MediaQuery.of(context).size.width,
                    //maxVideoLength: const Duration(seconds: 10),
                    onChangeStart: (value) => _startValue = value,
                    onChangeEnd: (value) => _endValue = value,
                    onChangePlaybackState: (value) =>
                        setState(() => _isPlaying = value),
                  ),
                ),
                TextButton(
                  child: _isPlaying
                      ? Icon(Icons.pause, size: 80.0, color: Colors.white)
                      : Icon(Icons.play_arrow, size: 80.0, color: Colors.white),
                  onPressed: () async {
                    bool playbackState = await widget.trimmer
                        .videoPlaybackControl(
                          startValue: _startValue,
                          endValue: _endValue,
                        );
                    setState(() {
                      _isPlaying = playbackState;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
