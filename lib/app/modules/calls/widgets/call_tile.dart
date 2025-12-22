import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/appcolors.dart';

enum CallType { incoming, outgoing, missed }

class CallHistoryTile extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final CallType callType;
  final bool isVideo;
  final VoidCallback onTap;

  const CallHistoryTile({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.callType,
    this.isVideo = false,
    required this.onTap,
  });

  IconData _getCallIcon() {
    switch (callType) {
      case CallType.incoming:
        return Icons.call_received;
      case CallType.outgoing:
        return Icons.call_made;
      case CallType.missed:
        return Icons.call_missed;
    }
  }

  Color _getCallColor() {
    switch (callType) {
      case CallType.incoming:
        return Colors.green;
      case CallType.outgoing:
        return Colors.blue;
      case CallType.missed:
        return Colors.red;
    }
  }

  String _getCallText() {
    switch (callType) {
      case CallType.incoming:
        return "Incoming call";
      case CallType.outgoing:
        return "Outgoing call";
      case CallType.missed:
        return "Missed call";
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 22.sp,
        backgroundImage: NetworkImage(avatarUrl),
      ),
      visualDensity: const VisualDensity(vertical: 3),
      title: Text(name, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Row(
        children: [
          Icon(_getCallIcon(), size: 16.sp, color: _getCallColor()),
          SizedBox(width: 2.w),
          Text(
            _getCallText(),
            style: Theme.of(
              context,
            ).textTheme.bodyLarge!.copyWith(color: Colors.grey),
          ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(
          isVideo ? Icons.videocam : Icons.call,
          color: AppColors.iconNonNeutral,
          size: 20.sp,
        ),
        onPressed: onTap,
      ),
    );
  }
}
