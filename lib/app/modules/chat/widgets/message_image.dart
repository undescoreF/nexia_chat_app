import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../../data/models/message_model.dart';
import '../controller/chat_controller.dart';
import '../views/image_screen_view.dart';

class MessageImageWidget extends StatelessWidget {
  final MessageModel message;
  final ChatController controller;
  final bool isMe;

  const MessageImageWidget({
    super.key,
    required this.message,
    required this.controller,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final progress = controller.uploadProgress[message.id];
      final isUploading = progress != null;

      return GestureDetector(
        onTap: () {
          Get.to(
            () => ImageScreenView.fromMessage(),
            arguments: {
              'imageUrl': message.fileUrl ?? '',
              'localFile': message.localFile,
            },
            transition: Transition.noTransition,
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 300,
                width: 220,
                child: message.fileUrl == null
                    ? Image.file(message.localFile!, fit: BoxFit.cover)
                    : CachedNetworkImage(
                        imageUrl: message.fileUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: Colors.black12),
                        errorWidget: (_, __, ___) => Icon(Icons.broken_image),
                      ),
              ),
            ),

            /// Loader
            if (isUploading && progress != 1)
              Container(
                height: 300,
                width: 220,
                color: Colors.black.withOpacity(.3),
                child: Center(
                  child: SizedBox(
                    height: 60,
                    width: 60,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 5,
                        ),
                        Text(
                          "${(progress! * 100).round()}%",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Text(
              _formatTime(message.sentAt),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ).paddingOnly(top: 35.h, left: 30.w),
            isMe
                ? _buildStatusIcon(
                    message.status,
                  ).paddingOnly(top: 35.h, left: 43.w)
                : Text(""),
          ],
        ),
      );
    });
  }

  String _formatTime(DateTime time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  Widget _buildStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return const Icon(Icons.access_time, size: 14, color: Colors.white70);
      case MessageStatus.sent:
        return const Icon(Icons.check, size: 14, color: Colors.white70);
      case MessageStatus.delivered:
        return const Icon(Icons.done_all, size: 14, color: Colors.white70);
      case MessageStatus.seen:
        return const Icon(
          Icons.done_all,
          size: 14,
          color: Colors.lightBlueAccent,
        );
    }
  }
}
