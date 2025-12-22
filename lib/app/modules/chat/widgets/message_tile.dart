import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nexachat/app/utils/appcolors.dart';
import 'package:sizer/sizer.dart';

import '../../../../data/models/message_model.dart';
import '../views/chat_page.dart';

class MessageTile extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String time;
  final String avatarUrl;
  final bool isUnread;
  final int unreadCount;
  final String lastMessageStatus;
  final bool isMe;

  const MessageTile({
    super.key,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.avatarUrl,
    this.unreadCount = 0,
    this.isUnread = false,
    required this.lastMessageStatus,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      visualDensity: const VisualDensity(vertical: -2),

      //isThreeLine: true,
      leading: avatarUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(360),
              child: CachedNetworkImage(
                imageUrl: avatarUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                placeholder: (_, __) => CircleAvatar(
                  radius: 24,
                  child: Icon(Icons.person, size: 24),
                ),
                errorWidget: (_, __, ___) => CircleAvatar(
                  radius: 24,
                  child: Text(
                    name[0].toUpperCase(),
                    style: TextStyle(fontSize: 22.sp),
                  ),
                ),
              ),
            )
          : CircleAvatar(
              radius: 24,
              child: Text(
                name[0].toUpperCase(),
                style: TextStyle(fontSize: 22.sp),
              ),
            ),

      title: Text(name, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Row(
        children: [
          if (getMessageStatus(lastMessageStatus) != null && isMe)
            _buildStatusIcon(
              getMessageStatus(lastMessageStatus)!,
            ).paddingOnly(top: 0.8.h),
          SizedBox(
            width: 50.w,
            child: Text(
              lastMessage,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: 16.sp),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ).paddingOnly(top: 0.8.h, left: 1.w),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //Text(time, style: Theme.of(context).textTheme.bodySmall),
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: unreadCount > 0
                  ? AppColors.iconNonNeutral
                  : AppColors.iconNeutral,
              fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          unreadCount > 0
              ? Badge(
                  backgroundColor: AppColors.iconNonNeutral,
                  label: Center(child: Text("$unreadCount")),
                ).paddingOnly(top: 1.h)
              : Badge(
                  backgroundColor: Colors.transparent,
                ).paddingOnly(top: 1.h),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return const Icon(Icons.access_time, size: 16, color: Colors.grey);
      case MessageStatus.sent:
        return const Icon(Icons.check, size: 16, color: Colors.grey);
      case MessageStatus.delivered:
        return const Icon(Icons.done_all, size: 16, color: Colors.grey);
      case MessageStatus.seen:
        return const Icon(
          Icons.done_all,
          size: 16,
          color: Colors.lightBlueAccent,
        );
    }
  }

  MessageStatus? getMessageStatus(String status) {
    if (status == "sent") {
      return MessageStatus.sent;
    } else if (status == "sending") {
      return MessageStatus.sending;
    } else if (status == "delivered") {
      return MessageStatus.delivered;
    } else if (status == "seen") {
      return MessageStatus.seen;
    } else {
      return null;
    }
  }
}
