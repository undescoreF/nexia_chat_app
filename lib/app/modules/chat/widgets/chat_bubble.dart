import 'package:flutter/material.dart';
import 'package:nexachat/app/modules/chat/controller/chat_controller.dart';
import '../../../../data/models/message_model.dart';
import '../../../utils/appcolors.dart';
import 'message_content.dart';

class ChatBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final MessageModel? repliedMessage;
  final bool isGrouped;
  final bool showTime;
  final ChatController chatController;
  final Function(MessageModel)? onReplyTap;
  final Function(MessageModel)? onSwipeToReply;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.chatController,
    this.repliedMessage,
    this.isGrouped = false,
    this.showTime = true,
    this.onReplyTap,
    this.onSwipeToReply,
  });

  @override
  Widget build(BuildContext context) {
    final myBubbleColor = const Color(0xFF8B5CF6).withOpacity(0.9);
    final receivedBubbleColor = AppColors.background;
    final textColor = isMe ? Colors.white : Colors.black;

    final borderRadius = BorderRadius.only(
      topLeft: Radius.circular(isGrouped && !isMe ? 4 : 16),
      topRight: Radius.circular(isGrouped && isMe ? 4 : 16),
      bottomLeft: Radius.circular(isMe ? 16 : 4),
      bottomRight: Radius.circular(isMe ? 4 : 16),
    );

    final bubble = Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: isGrouped ? 1 : 8,
          bottom: showTime ? 6 : 1,
          left: isMe ? 60 : 8,
          right: isMe ? 8 : 60,
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              decoration: BoxDecoration(
                color: isMe ? myBubbleColor : receivedBubbleColor,
                borderRadius: borderRadius,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26.withOpacity(0.1),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.6),
                    offset: const Offset(-2, -2),
                    blurRadius: 4,
                  ),
                ],
              ),

              padding: message.mimeType == null
                  ? const EdgeInsets.symmetric(vertical: 8, horizontal: 12)
                  : const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (repliedMessage != null)
                    GestureDetector(
                      onTap: () => onReplyTap?.call(repliedMessage!),
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.55,
                        ),
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.white.withOpacity(0.2)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 4,
                              height: 35,
                              decoration: BoxDecoration(
                                color: isMe
                                    ? Colors.white
                                    : const Color(0xFF8B5CF6),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                repliedMessage!.text ?? "",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isMe
                                      ? Colors.white70
                                      : Colors.grey.shade700,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  //if (message.text != null && message.text!.isNotEmpty)
                  MessageContentWidget(
                    message: message,
                    isMe: isMe,
                    chatController: chatController,
                  ),

                  /*Text(
                      message.text!,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        height: 1.3,
                      ),
                    ),*/
                  if (showTime && message.mimeType == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2, right: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Text(
                            _formatTime(message.sentAt),
                            style: TextStyle(
                              fontSize: 10,
                              color: isMe
                                  ? Colors.white70
                                  : const Color(0xFF8B5CF6).withOpacity(0.9),
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            _buildStatusIcon(message.status),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Dismissible(
      key: ValueKey(message.id),
      direction: isMe
          ? DismissDirection.startToEnd
          : DismissDirection.endToStart,
      //onDismissed: (_) => onSwipeToReply?.call(message),
      confirmDismiss: (direction) async {
        onSwipeToReply?.call(message);
        return false;
      },
      background: Container(
        alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.deepPurpleAccent.withOpacity(0.3),
        child: const Icon(Icons.reply, color: Colors.deepPurple),
      ),
      child: bubble,
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
