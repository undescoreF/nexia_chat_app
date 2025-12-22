import 'dart:convert';
import 'dart:io';

/// Statut d’un message (pour afficher ✓, ✓✓, bleu, etc.)
enum MessageStatus { sending, sent, delivered, seen }

/// Entité de texte enrichi (liens, mentions, etc.)
class TextEntity {
  final String type; // "plain", "link", "bold", etc.
  final String text;

  TextEntity({required this.type, required this.text});

  factory TextEntity.fromJson(Map<String, dynamic> json) =>
      TextEntity(type: json['type'], text: json['text']);

  Map<String, dynamic> toJson() => {'type': type, 'text': text};
}

/// Modèle principal d’un message
class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String? senderName;
  final String? text;
  final List<TextEntity>? entities;

  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final String? mimeType;
  final String? thumbnailUrl;

  final String? replyTo;
  MessageStatus status;
  final DateTime sentAt;
  final DateTime? receivedAt;
  final DateTime? seenAt;
  final bool isForwarded;
  File? localFile;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.senderName,
    this.text,
    this.entities,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.mimeType,
    this.thumbnailUrl,
    this.replyTo,
    required this.status,
    required this.sentAt,
    this.receivedAt,
    this.seenAt,
    this.isForwarded = false,
    this.localFile,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
    id: json['id'].toString(),
    chatId: json['chatId'],
    senderId: json['senderId'],
    senderName: json['senderName'],
    text: json['text'],
    entities: (json['entities'] as List?)
        ?.map((e) => TextEntity.fromJson(e))
        .toList(),
    fileUrl: json['fileUrl'],
    fileName: json['fileName'],
    fileSize: json['fileSize'],
    mimeType: json['mimeType'],
    thumbnailUrl: json['thumbnailUrl'],
    replyTo: json['replyTo'],
    status: MessageStatus.values.firstWhere(
      (e) => e.toString() == 'MessageStatus.${json['status']}',
      orElse: () => MessageStatus.sent,
    ),
    sentAt: DateTime.parse(json['sentAt']),
    receivedAt: json['receivedAt'] != null
        ? DateTime.parse(json['receivedAt'])
        : null,
    seenAt: json['seenAt'] != null ? DateTime.parse(json['seenAt']) : null,
    isForwarded: json['isForwarded'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'chatId': chatId,
    'senderId': senderId,
    'senderName': senderName,
    'text': text,
    'entities': entities?.map((e) => e.toJson()).toList(),
    'fileUrl': fileUrl,
    'fileName': fileName,
    'fileSize': fileSize,
    'mimeType': mimeType,
    'thumbnailUrl': thumbnailUrl,
    'replyTo': replyTo,
    'status': status!.name,
    'sentAt': sentAt.toIso8601String(),
    'receivedAt': receivedAt?.toIso8601String(),
    'seenAt': seenAt?.toIso8601String(),
    'isForwarded': isForwarded,
  };

  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderName,
    String? text,
    List<TextEntity>? entities,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    String? mimeType,
    String? thumbnailUrl,
    String? replyTo,
    MessageStatus? status,
    DateTime? sentAt,
    DateTime? receivedAt,
    DateTime? seenAt,
    bool? isForwarded,
    File? localFile,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      text: text ?? this.text,
      entities: entities ?? this.entities,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      replyTo: replyTo ?? this.replyTo,
      status: status ?? this.status,
      sentAt: sentAt ?? this.sentAt,
      receivedAt: receivedAt ?? this.receivedAt,
      seenAt: seenAt ?? this.seenAt,
      isForwarded: isForwarded ?? this.isForwarded,
      localFile:
          localFile ??
          (this is MessageModel ? (this as dynamic).localFile : null),
    );
  }
}

/*  sentAt: convertTimestampOrString(json['sentAt']) ?? DateTime.now(),
    receivedAt: convertTimestampOrString(json['receivedAt']),
    seenAt: convertTimestampOrString(json['seenAt']),
DateTime? convertTimestampOrString(dynamic value) {
  if (value == null) return null;

  if (value is Timestamp) {
    return value.toDate();
  }

  if (value is String) {
    try {
      return DateTime.parse(value);
    } catch (e) {
      return null;
    }
  }

  return null;
}*/
