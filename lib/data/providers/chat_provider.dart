import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../../data/models/message_model.dart';
import '../models/chat_model.dart';
import 'notification_provider.dart';

String getMessageTypeFromMime(String mime) {
  if (mime.startsWith('image/')) return 'image';
  if (mime.startsWith('video/')) return 'video';
  if (mime.startsWith('audio/')) return 'audio';
  if (mime.startsWith('application/')) return 'file';
  return 'text';
}

String getPreviewFromMime(String mime) {
  if (mime.startsWith('image/')) return "📷 Photo";
  if (mime.startsWith('video/')) return "🎥 Video";
  if (mime.startsWith('audio/')) return "🎤 Audio";
  if (mime.startsWith('application/')) return "📄 File";
  return "";
}

class ChatProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final NotificationProvider _notificationProvider = NotificationProvider();

  ChatProvider() {
    // Activation du cache Firestore
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  /// Crée un chat si inexistant
  Future<String> createChatIfNotExist(String uidA, String uidB) async {
    final chatId = [uidA, uidB]..sort();
    final chatDocId = chatId.join("_");
    final docRef = _firestore.collection('chats').doc(chatDocId);

    final doc = await docRef.get();
    if (!doc.exists) {
      final userA = await _firestore.collection('users').doc(uidA).get();
      final userB = await _firestore.collection('users').doc(uidB).get();

      await docRef.set({
        'participants': chatId,
        'participantsInfo': [
          {
            'uid': uidA,
            'name': userA['name'],
            'avatarUrl': userA['profileImageUrl'],
          },
          {
            'uid': uidB,
            'name': userB['name'],
            'avatarUrl': userB['profileImageUrl'],
          },
        ],
        'lastMessage': "",
        'lastMessageType': "text",
        'lastMessagePreview': "",
        'lastMessageSender': "",
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    }

    return chatDocId;
  }

  /// Envoie un message
  Future<void> sendMessage(String chatId, MessageModel message) async {
    final docRef = _firestore.collection('chats').doc(chatId);

    try {
      await docRef.collection('messages').doc(message.id).set(message.toJson());
      /*  final json = message.toJson()..remove('sentAt');
      await docRef.collection('messages').doc(message.id).set({
        ...json,
        'sentAt': FieldValue.serverTimestamp(),
      });*/

      final mime = message.mimeType ?? "text/plain";
      final type = getMessageTypeFromMime(mime);

      await docRef.update({
        'lastMessage': type == 'text' ? message.text : '',
        'lastMessageType': type,
        'lastMessagePreview': type == 'text'
            ? message.text
            : getPreviewFromMime(mime),
        'lastMessageSender': message.senderId,
        'lastMessageStatus': message.status.name,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
      await updateMessageStatus(chatId, message.id, MessageStatus.sent);
      final receiverId = getReceiverId(chatId, message.senderId);
      final recipientOneSignalIds = await getOneSignalIdsForUser(receiverId);
      if (recipientOneSignalIds.isNotEmpty) {
        await _notificationProvider.sendNotification(
          playerIds: recipientOneSignalIds,
          title: message.senderName ?? "Nouveau message",
          body: "New message",
        );
      }
    } catch (e) {
      debugPrint("Erreur envoi message: $e");
    }
  }

  /// Récupère les messages depuis le cache (optionnel)
  Future<List<MessageModel>> getMessagesFromCache(String chatId) async {
    final snapshot = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .get(const GetOptions(source: Source.cache));

    return snapshot.docs
        .map((doc) => MessageModel.fromJson(doc.data()))
        .toList();
  }

  /// Streaming temps réel
  Stream<List<MessageModel>> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Récupère tous les chats de l'utilisateur
  Stream<List<ChatModel>> getUserChats(String uid) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList(),
        );
  }

  ///envoyer un fichier
  Stream<Map<String, dynamic>> uploadFile(String chatId, File file) async* {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

      final ref = _storage.ref().child('chat_files/$chatId/$fileName');

      final uploadTask = ref.putFile(file);

      // file progession
      await for (final snapshot in uploadTask.snapshotEvents) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;

        yield {
          'status': 'uploading',
          'progress': progress,
          'fileName': fileName,
          'mimeType': lookupMimeType(file.path) ?? 'application/octet-stream',
        };
      }

      // fiche uploadé
      final url = await ref.getDownloadURL();
      final metadata = await ref.getMetadata();

      yield {
        'status': 'completed',
        'progress': 1.0,
        'fileName': fileName,
        'fileUrl': url,
        'mimeType': lookupMimeType(file.path) ?? 'application/octet-stream',
        'fileSize': metadata.size ?? 0,
      };
    } catch (e) {
      yield {'status': 'error', 'error': e.toString()};
    }
  }

  /// Met à jour le status d’un message (sent, delivered, seen)
  Future<void> updateMessageStatus(
    String chatId,
    String messageId,
    MessageStatus status,
  ) async {
    final messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId);

    // Mettre à jour le status du message
    await messageRef.update({'status': status.name});

    // Mettre à jour le chat si ce message est le dernier
    final chatRef = _firestore.collection('chats').doc(chatId);
    final lastMessageSnapshot = await chatRef
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .limit(1)
        .get();

    if (lastMessageSnapshot.docs.isNotEmpty &&
        lastMessageSnapshot.docs.first.id == messageId) {
      await chatRef.update({'lastMessageStatus': status.name});
    }
  }

  ///unread count
  void initUnreadCount(ChatModel chat) {
    final myUid = FirebaseAuth.instance.currentUser!.uid;

    _firestore
        .collection('chats')
        .doc(chat.id)
        .collection('messages')
        .snapshots()
        .listen((snapshot) {
          chat.unreadCount.value = snapshot.docs
              .where(
                (doc) => doc['senderId'] != myUid && doc['status'] != 'seen',
              )
              .length;
        });
  }

  ///users chat list  from cache
  Future<List<ChatModel>> getUserChatsFromCache(String uid) async {
    final snapshot = await _firestore
        .collection('chats')
        .where('participants', arrayContains: uid)
        .orderBy('lastMessageTime', descending: true)
        .get(GetOptions(source: Source.cache));

    return snapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList();
  }

  Future<List<String>> getOneSignalIdsForUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data.containsKey('oneSignalPlayerIds')) {
          final List<dynamic> ids = data['oneSignalPlayerIds'];
          return ids.cast<String>();
        }
      }
      return [];
    } catch (e) {
      debugPrint("Erreur récupération OneSignal IDs: $e");
      return [];
    }
  }

  String getReceiverId(String chatId, String senderId) {
    final parts = chatId.split('_'); // ["uid1", "uid2"]
    if (parts[0] == senderId) {
      return parts[1];
    } else {
      return parts[0];
    }
  }
}
