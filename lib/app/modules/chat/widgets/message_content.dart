import 'package:flutter/material.dart';
import 'package:nexachat/app/modules/chat/controller/chat_controller.dart';

import '../../../../data/models/message_model.dart';
import 'message_audio.dart';
import 'message_file.dart';
import 'message_image.dart';
import 'message_pdf.dart';
import 'message_video.dart';

class MessageContentWidget extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final ChatController chatController;

  const MessageContentWidget({
    super.key,
    required this.message,
    required this.isMe,
    required this.chatController,
  });

  @override
  Widget build(BuildContext context) {
    final mime = message.mimeType ?? "";
    final url = message.fileUrl ?? "";
    final text = message.text;

    ///TEXT
    if (message.text != null) {
      return Text(
        message.text ?? "",
        style: TextStyle(
          color: isMe ? Colors.white : Colors.black,
          fontSize: 15,
          height: 1.3,
        ),
      );
    }

    /// IMAGES
    if (mime.startsWith("image/")) {
      //return MessageImageWidget(url: url, thumbnailUrl: message.thumbnailUrl);
      return MessageImageWidget(
        message: message,
        controller: chatController,
        isMe: isMe,
      );
    }

    /// VIDEOS
    if (mime.startsWith("video/")) {
      return MessageVideoWidget(url: url, thumbnailUrl: message.thumbnailUrl);
    }

    /// AUDIO
    if (mime.startsWith("audio/")) {
      return MessageAudioWidget(
        isMe: isMe,
        message: message,
        controller: chatController,
      );
    }

    /// PDF
    if (mime == "application/pdf") {
      return MessagePdfWidget(
        url: url,
        fileName: message.fileName,
        message: message,
        isMe: isMe,
      );
    }

    /// AUTRES FICHIERS (word, txt, zip…)
    return MessageGenericFileWidget(
      url: url,
      fileName: message.fileName ?? "Fichier",
      mimeType: mime,
      size: message.fileSize,
      message: message,
    );
  }
}
