import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nexachat/app/utils/appcolors.dart';
import 'package:sizer/sizer.dart';

import '../../../../data/models/message_model.dart';
import '../../../services/file_service.dart';

class MessagePdfWidget extends StatelessWidget {
  final String url;
  final String? fileName;
  final bool isUploading;
  final double? uploadProgress;
  final MessageModel message;
  final bool isMe;

  const MessagePdfWidget({
    super.key,
    required this.url,
    this.fileName,
    this.isUploading = false,
    this.uploadProgress,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final fileService = FileService();
        fileService.openDocumentFile(filePathOrUrl: url, fileName: fileName!);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          ListTile(
            leading: CircleAvatar(
              child: isUploading && uploadProgress != null
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: uploadProgress,
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.iconNonNeutral,
                          ),
                        ),
                        Center(child: Icon(Icons.picture_as_pdf)),
                      ],
                    )
                  : Icon(Icons.picture_as_pdf),
            ),
            visualDensity: VisualDensity(vertical: 4),
            title: Text(
              fileName ?? "PDF Document",
              style: TextStyle(color: isMe ? Colors.white : Colors.black),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            subtitle: Text(
              _getFileSize(message.fileSize ?? 0),
              style: TextStyle(color: isMe ? Colors.white : Colors.black54),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            trailing: isUploading ? SizedBox(width: 24, height: 24) : null,
          ),
          Text(
            _formatTime(message.sentAt),
            style: TextStyle(
              color: isMe ? Colors.white : AppColors.iconNonNeutral,
              fontWeight: FontWeight.bold,
            ),
          ).paddingOnly(top: 3.h, left: 30.w),
          isMe
              ? _buildStatusIcon(
                  message.status,
                ).paddingOnly(top: 3.h, left: 43.w)
              : Text(""),
        ],
      ),
    );
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

  String _getFileSize(int size) {
    if (size == null) return 'Unknown size';
    if (size! < 1024) return '$size B';
    if (size! < 1048576) return '${(size! / 1024).toStringAsFixed(1)} KB';
    return '${(size! / 1048576).toStringAsFixed(1)} MB';
  }
}
