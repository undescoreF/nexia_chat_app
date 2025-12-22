import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/message_model.dart';
import '../models/chat_model.dart';
import '../providers/chat_provider.dart';

class ChatRepository {
  final ChatProvider provider;

  ChatRepository({required this.provider});

  Future<String> createChat(String uidA, String uidB) {
    return provider.createChatIfNotExist(uidA, uidB);
  }

  Future<void> sendMessage(String chatId, MessageModel message) {
    return provider.sendMessage(chatId, message);
  }

  Stream<List<MessageModel>> getMessages(String chatId) {
    return provider.getMessagesStream(chatId);
  }

  Future<List<MessageModel>> getMessagesCache(String chatId) {
    return provider.getMessagesFromCache(chatId);
  }

  Stream<List<ChatModel>> getUserChats(String uid) {
    return provider.getUserChats(uid);
  }

  Stream<Map<String, dynamic>> uploadChatFile(String chatId, File file) {
    return provider.uploadFile(chatId, file);
  }

  Future<void> updateMessageStatus(
    String chatId,
    String messageId,
    MessageStatus status,
  ) {
    return provider.updateMessageStatus(chatId, messageId, status);
  }

  void initUnreadCount(ChatModel chat) {
    provider.initUnreadCount(chat);
  }

  Future<List<ChatModel>> getUserChatsFromCache(String uid) {
    return provider.getUserChatsFromCache(uid);
  }
}
