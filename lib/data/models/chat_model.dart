import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:nexachat/data/models/participants_info.dart';

class ChatModel {
  final String id;
  final List<String> participants;
  final List<ParticipantInfo> participantsInfo;

  final String lastMessage;
  final String lastMessageType;
  final String lastMessagePreview;
  final String lastMessageSender;
  final DateTime? lastMessageTime;
  final String lastMessageStatus;

  final bool isUnread;
  RxInt unreadCount = 0.obs;
  ChatModel({
    required this.id,
    required this.participants,
    required this.participantsInfo,
    required this.lastMessage,
    required this.lastMessageType,
    required this.lastMessagePreview,
    required this.lastMessageSender,
    required this.lastMessageTime,
    required this.isUnread,
    required this.lastMessageStatus,
  });

  factory ChatModel.fromFirestore(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ChatModel(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      participantsInfo: (data['participantsInfo'] as List<dynamic>? ?? [])
          .map((e) => ParticipantInfo.fromMap(e))
          .toList(),

      lastMessage: data['lastMessage'] ?? "",
      lastMessageType: data['lastMessageType'] ?? "text",
      lastMessagePreview: data['lastMessagePreview'] ?? "",
      lastMessageSender: data['lastMessageSender'] ?? "",
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
      lastMessageStatus: data['lastMessageStatus'] ?? 'sent',

      // default = false
      isUnread: data['isUnread'] ?? false,
    );
  }
}
