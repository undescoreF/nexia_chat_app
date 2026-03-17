import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nexachat/app/utils/appcolors.dart';
import 'package:sizer/sizer.dart';

import '../../../../data/models/message_model.dart';
import '../../../services/file_service.dart';

class MessageGenericFileWidget extends StatelessWidget {
  final String url;
  final String fileName;
  final String mimeType;
  final int? size;
  final bool isUploading;
  final double? uploadProgress;
  final MessageModel message;

  const MessageGenericFileWidget({
    super.key,
    required this.url,
    required this.fileName,
    required this.mimeType,
    this.size,
    this.isUploading = false,
    this.uploadProgress,
    required this.message,
  });

  String _getFileSize() {
    if (size == null) return 'Unknown size';
    if (size! < 1024) return '$size B';
    if (size! < 1048576) return '${(size! / 1024).toStringAsFixed(1)} KB';
    return '${(size! / 1048576).toStringAsFixed(1)} MB';
  }

  IconData _getFileIcon() {
    if (mimeType.contains('word') || mimeType.contains('document')) {
      return Icons.description;
    } else if (mimeType.contains('excel') || mimeType.contains('spreadsheet')) {
      return Icons.table_chart;
    } else if (mimeType.contains('powerpoint') ||
        mimeType.contains('presentation')) {
      return Icons.slideshow;
    } else if (mimeType.contains('zip') || mimeType.contains('archive')) {
      return Icons.folder_zip;
    } else if (mimeType.contains('text')) {
      return Icons.text_snippet;
    } else {
      return Icons.insert_drive_file;
    }
  }

  String _getFileType() {
    if (mimeType.contains('word')) return 'DOCUMENT';
    if (mimeType.contains('excel')) return 'SPREADSHEET';
    if (mimeType.contains('powerpoint')) return 'PRESENTATION';
    if (mimeType.contains('pdf')) return 'PDF';
    if (mimeType.contains('zip')) return 'ARCHIVE';
    if (mimeType.contains('text')) return 'TEXT';
    return 'FILE';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final fileService = FileService();
        fileService.openDocumentFile(filePathOrUrl: url, fileName: fileName);
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
                        Center(child: Icon(_getFileIcon())),
                      ],
                    )
                  : Icon(_getFileIcon()),
            ),
            visualDensity: VisualDensity(vertical: 4),
            title: Text(
              fileName,
              style: TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            subtitle: Text(
              "${_getFileType()} • ${_getFileSize()}",
              style: TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            trailing: isUploading ? SizedBox(width: 24, height: 24) : null,
          ),
          Text(
            _formatTime(message.sentAt),
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ).paddingOnly(top: 3.h, left: 30.w),
          _buildStatusIcon(message.status).paddingOnly(top: 3.h, left: 43.w),
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
}
