import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../../data/models/message_model.dart';
import '../../../utils/appcolors.dart';
import '../controller/chat_controller.dart';
import '../controller/message_audio_controller.dart';

class MessageAudioWidget extends StatefulWidget {
  final MessageModel message;
  final ChatController controller;
  final bool isMe;

  const MessageAudioWidget({
    super.key,
    required this.message,
    required this.controller,
    required this.isMe,
  });

  @override
  State<MessageAudioWidget> createState() => _MessageAudioWidgetState();
}

class _MessageAudioWidgetState extends State<MessageAudioWidget> {
  late MessageAudioController _audioController;

  @override
  void initState() {
    super.initState();
    _audioController = Get.put(
      MessageAudioController(
        audioUrl: widget.message.fileUrl ?? '',
        localFile: widget.message.localFile,
        isMe: widget.isMe,
        isUploaded: widget.message.fileUrl != null,
      ),
      tag: widget.message.id,
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  String _formatTime(DateTime time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  Widget _buildStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return const Icon(Icons.access_time, size: 14, color: Colors.grey);
      case MessageStatus.sent:
        return const Icon(Icons.check, size: 14, color: Colors.grey);
      case MessageStatus.delivered:
        return const Icon(Icons.done_all, size: 14, color: Colors.grey);
      case MessageStatus.seen:
        return const Icon(
          Icons.done_all,
          size: 14,
          color: Colors.lightBlueAccent,
        );
    }
  }

  @override
  void dispose() {
    Get.delete<MessageAudioController>(tag: widget.message.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final progress = widget.controller.uploadProgress[widget.message.id];
      final isUploading = progress != null && progress != 1;

      return Container(
        constraints: BoxConstraints(minWidth: 200, maxWidth: 70.w),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: widget.isMe ? Colors.white : Colors.grey[200],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 0),
              visualDensity: const VisualDensity(vertical: -4),
              minLeadingWidth: 0,
              leading: _buildAudioButton(isUploading),
              title: _buildAudioProgress(isUploading),
            ),

            /// Loader pendant l'upload
            /* if (isUploading)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 4,
                          color: Colors.white,
                        ),
                        Text(
                          "${(progress! * 100).round()}%",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            */
            Text(
              _formatTime(widget.message.sentAt),
              style: TextStyle(
                color: AppColors.iconNonNeutral,
                fontWeight: FontWeight.bold,
              ),
            ).paddingOnly(top: 6.h, left: 30.w),
            widget.isMe
                ? _buildStatusIcon(
                    widget.message.status,
                  ).paddingOnly(top: 6.h, left: 44.w)
                : Text(""),
          ],
        ),
      );
    });
  }

  Widget _buildAudioButton(bool isUploading) {
    if (isUploading) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.iconNonNeutral,
          shape: BoxShape.circle,
        ),
        child: SizedBox(
          width: 14,
          height: 14,
          child: Stack(
            children: [
              CircularProgressIndicator(
                strokeWidth: 2,
                value: widget.controller.uploadProgress[widget.message.id]!,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.iconNonNeutral,
                ),
              ),
              Center(
                child: Icon(Icons.headphones_rounded, color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    /// Si chargement de la lecture
    /*if (_audioController.isLoading) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: widget.isMe ? Colors.green : Colors.grey[400],
          shape: BoxShape.circle,
        ),
        child: SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );

    }
    */

    // Bouton play/pause normal
    return GestureDetector(
      onTap: _audioController.isAudioReady
          ? _audioController.togglePlayPause
          : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: widget.isMe ? AppColors.iconNonNeutral : Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(
          _audioController.isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 18,
        ),
      ).paddingOnly(bottom: 1.h),
    );
  }

  Widget _buildAudioProgress(bool isUploading) {
    final double value = _audioController.duration.inMilliseconds > 0
        ? _audioController.position.inMilliseconds /
              _audioController.duration.inMilliseconds
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Slider pour la progression
        SliderTheme(
          data: SliderThemeData(
            //trackHeight: 1,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5.0),
          ),
          child: Slider(
            value: value.clamp(0.0, 1.0),
            onChanged: _audioController.isAudioReady && !isUploading
                ? (newValue) {
                    final newPosition = Duration(
                      milliseconds:
                          (newValue * _audioController.duration.inMilliseconds)
                              .round(),
                    );
                    _audioController.seek(newPosition);
                  }
                : null,
            min: 0.0,
            max: 1.0,
            activeColor: widget.isMe
                ? AppColors.iconNonNeutral
                : Colors.grey[600],
            inactiveColor: Colors.grey[300],
            thumbColor: widget.isMe
                ? AppColors.iconNonNeutral
                : Colors.grey[800],
          ),
        ),

        // Durée seulement
        Container(
          width: 100.w,
          // color: Colors.red,
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: widget.isMe ? Colors.black54 : Colors.black45,
                fontSize: 14.sp,
              ),
              children: [
                TextSpan(
                  text: _audioController.isAudioReady
                      ? _formatDuration(_audioController.position)
                      : '--:--',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' / '),
                TextSpan(
                  text: _audioController.isAudioReady
                      ? _formatDuration(_audioController.duration)
                      : '--:--',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
