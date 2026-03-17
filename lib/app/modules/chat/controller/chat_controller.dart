import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';
import 'package:nexachat/data/providers/user_provider.dart';
import 'package:nexachat/data/repositories/user_repository.dart';
import '../../../../data/models/chat_model.dart';
import '../../../../data/models/message_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/chat_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../auth/controllers/auth_controller.dart';
import 'package:intl/intl.dart';

import '../../auth/controllers/userController.dart';
import '../../settings/Controllers/languages_controller.dart';

enum Language { fr, en, ru }

class ChatController extends GetxController {
  final ChatRepository repository;
  ChatController({required this.repository});

  @override
  Future<void> onInit() async {
    super.onInit();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    if (Get.isRegistered<UserController>()) {
      userController = Get.find<UserController>();
    } else {
      userController = Get.put(
        UserController(UserRepository(UserProvider())),
        permanent: true,
      );
      username = await userController.getUsername(uid);
    }
    loadUserChats(uid);
  }

  /// Liste des messages observable
  var messages = <MessageModel>[].obs;

  ///liste des chats
  var userChats = <ChatModel>[].obs;
  var isLoadingChats = true.obs;
  var displayedChats = <ChatModel>[].obs;
  Stream<List<MessageModel>>? _messagesStream;
  String? _currentChatId;
  final uploadProgress = <String, double>{}.obs;
  var searchQuery = ''.obs;

  late final UserController userController;
  var username = "";

  ///keybord
  var show = false.obs;

  /// Charge d'abord le cache puis écoute le stream en direct
  void initChat(String chatId) async {
    if (_currentChatId == chatId && _messagesStream != null) {
      return;
    }
    _currentChatId = chatId;
    //from cache
    final cached = await repository.getMessagesCache(chatId);
    messages.assignAll(cached);

    // stream Firestore
    _messagesStream = repository.getMessages(chatId);
    _messagesStream!.listen((msgs) {
      messages.assignAll(msgs);
    });
  }

  /// Envoyer un message
  Future<void> sendMessage(MessageModel message) async {
    if (_currentChatId == null) return;
    await repository.sendMessage(
      _currentChatId!,
      message.copyWith(senderName: username),
    );
  }

  /// Créer un chat si besoin
  Future<String> createChat(String uidA, String uidB) async {
    return repository.createChat(uidA, uidB);
  }

  /// Nettoyer le controller si on quitte le chat
  void clearChat() {
    messages.clear();
    _messagesStream = null;
    _currentChatId = null;
  }

  /// Marquer un message comme delivered (reçu par le destinataire)
  void markMessageAsDelivered(MessageModel message) {
    if (_currentChatId == null) return;
    if (message.status == MessageStatus.sent &&
        message.senderId != FirebaseAuth.instance.currentUser!.uid) {
      repository.updateMessageStatus(
        _currentChatId!,
        message.id,
        MessageStatus.delivered,
      );
    }
  }

  /// message seen
  Future<void> markMessageAsSeen(MessageModel message) async {
    if (_currentChatId == null) return;

    if (message.status != MessageStatus.seen &&
        message.senderId != FirebaseAuth.instance.currentUser!.uid) {
      message.status = MessageStatus.seen;
      await repository.updateMessageStatus(
        _currentChatId!,
        message.id,
        MessageStatus.seen,
      );
    }
  }

  /// SEND FILE
  Future<void> sendFile(File file) async {
    if (_currentChatId == null) return;

    const maxSize = 20 * 1024 * 1024; // 20MB
    try {
      if (file.lengthSync() > maxSize) {
        Get.snackbar("Erreur", "File size must be less than 20MB");
        return;
      }
    } catch (e) {
      Get.snackbar("Erreur", "Unable to read file size");
      return;
    }
    final blockedExtensions = [
      'exe', 'bat', 'scr', 'cmd', 'ps1', 'vbs', 'js', 'sh',  // executables
      'dll', 'sys', 'com', 'msi',                              // systeme
    ];
    final fileExtension = file.path.split('.').last.toLowerCase().trim();

    if (blockedExtensions.contains(fileExtension)) {
      Get.snackbar("Error", "This file type is not allowed for security reasons");
      return;
    }
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();

    final tempMessage = MessageModel(
      id: tempId,
      chatId: _currentChatId!,
      senderId: FirebaseAuth.instance.currentUser!.uid,
      senderName: username,
      fileName: file.path.split('/').last,
      fileUrl: null,
      mimeType: lookupMimeType(file.path) ?? 'application/octet-stream',
      status: MessageStatus.sending,
      sentAt: DateTime.now(),
      localFile: file,
    );

    messages.add(tempMessage);
    messages.refresh();

    //  Ecouter la progression depuis le repository
    repository.uploadChatFile(_currentChatId!, file).listen((event) async {
      if (event['status'] == 'uploading') {
        uploadProgress[tempId] = event['progress'];
        uploadProgress.refresh();
      }

      if (event['status'] == 'completed') {
        // 3️ Mise à jour du message existant
        final index = messages.indexWhere((m) => m.id == tempId);
        if (index == -1) return;

        final updated = messages[index].copyWith(
          fileUrl: event['fileUrl'],
          mimeType: event['mimeType'],
          fileSize: event['fileSize'],
          status: MessageStatus.sent,
          localFile: null,
        );

        messages[index] = updated;
        messages.refresh();

        // Envoi final dans Firestore
        await repository.sendMessage(_currentChatId!, updated);
      }

      if (event['status'] == 'error') {
        Get.snackbar("Erreur", "Échec de l'upload du fichier");
        uploadProgress.remove(tempId);
      }
    });
  }

  void loadUserChats(String uid) async {
    // Récupérer le cache
    final cachedChats = await repository.getUserChatsFromCache(uid);
    userChats.assignAll(cachedChats);

    // Lier les streams pour tous les participants autres que l'utilisateur courant
    for (var chat in cachedChats) {
      final otherUid = chat.participantsInfo
          .firstWhere((p) => p.uid != uid)
          .uid;
      if (!userController.users.containsKey(otherUid)) {
        userController.bindUserStream(otherUid);
      }
    }

    // Écouter Firestore pour les updates en temps réel
    repository.getUserChats(uid).listen((chats) {
      userChats.assignAll(chats);

      for (var chat in chats) {
        repository.initUnreadCount(chat);

        final otherUid = chat.participantsInfo
            .firstWhere((p) => p.uid != uid)
            .uid;
        if (!userController.users.containsKey(otherUid)) {
          userController.bindUserStream(otherUid);
        }
      }
    });
  }

  /*void loadUserChats(String uid) async {
     isLoadingChats = true.obs;
    final cachedChats = await repository.getUserChatsFromCache(uid);
    userChats.assignAll(cachedChats);

    repository.getUserChats(uid).listen((chats) {
      userChats.assignAll(chats);
      for (var chat in chats) {
        repository.initUnreadCount(chat);
      }
      isLoadingChats.value = false;
    });
  }*/

  ///search

  List<ChatModel> get filteredChats {
    if (searchQuery.value.isEmpty) return userChats;
    return userChats.where((chat) {
      final myUid = FirebaseAuth.instance.currentUser!.uid;
      final other = chat.participantsInfo.firstWhere((p) => p.uid != myUid);

      return other.name.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          ) ||
          chat.lastMessage.toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          );
    }).toList();
  }

  ///date format
  String formatChatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) {
      return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    }

    if (target == yesterday) {
      return AppLocalizations.of(context)!.yesterday;
      ;
    }

    // jj/mm/aaaa
    return "${target.day.toString().padLeft(2, '0')}/"
        "${target.month.toString().padLeft(2, '0')}/"
        "${target.year}";
  }

  String formatStatusDateTime(DateTime utcDate, {Language? lang}) {
    final currentLang =
        lang ?? Get.find<LanguageController>().currentLanguageEnum;

    final date = utcDate.toLocal();
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    final labels = {
      Language.fr: {'today': 'Auj.', 'yesterday': 'Hier'},
      Language.en: {'today': 'Today', 'yesterday': 'Yesterday'},
      Language.ru: {'today': 'Сег.', 'yesterday': 'Вч.'},
    };

    final seenWord = {
      Language.fr: 'vu',
      Language.en: 'seen',
      Language.ru: 'был(a)',
    };

    // Jour abrégé
    String dayLabel(DateTime d) {
      switch (currentLang) {
        case Language.fr:
          return DateFormat.E('fr_FR').format(d);
        case Language.en:
          return DateFormat.E('en_US').format(d);
        case Language.ru:
          return DateFormat.E('ru_RU').format(d);
      }
    }

    // Format heure (24h pour tous)
    String timeFormat() => DateFormat('HH:mm').format(date);

    // Format date selon langue
    String fullDate() {
      switch (currentLang) {
        case Language.fr:
          return DateFormat('dd/MM/yyyy').format(date);
        case Language.en:
          return DateFormat('MM/dd/yyyy').format(date);
        case Language.ru:
          return DateFormat('dd.MM.yyyy').format(date);
      }
    }

    if (messageDate == today) {
      switch (currentLang) {
        case Language.fr:
          return '${labels[currentLang]!['today']} ${seenWord[currentLang]} à ${timeFormat()}';

        case Language.en:
          return '${labels[currentLang]!['today']} ${seenWord[currentLang]} at ${timeFormat()}';

        case Language.ru:
          return '${labels[currentLang]!['today']} ${seenWord[currentLang]} в ${timeFormat()}';
      }
    }

    if (messageDate == yesterday) {
      switch (currentLang) {
        case Language.fr:
          return '${seenWord[currentLang]} ${labels[currentLang]!['yesterday']} à ${timeFormat()}';

        case Language.en:
          return '${seenWord[currentLang]} ${labels[currentLang]!['yesterday']} at ${timeFormat()}';

        case Language.ru:
          return '${seenWord[currentLang]} ${labels[currentLang]!['yesterday']} в ${timeFormat()}';
      }
    }

    if (now.difference(date).inDays < 7) {
      switch (currentLang) {
        case Language.fr:
          return '${seenWord[currentLang]} ${dayLabel(date)} à ${timeFormat()}';

        case Language.en:
          return '${dayLabel(date)} ${seenWord[currentLang]} at ${timeFormat()}';

        case Language.ru:
          return '${dayLabel(date)} ${seenWord[currentLang]} в ${timeFormat()}';
      }
    }

    switch (currentLang) {
      case Language.fr:
        return '${seenWord[currentLang]} le ${fullDate()} à ${timeFormat()}';

      case Language.en:
        return '${seenWord[currentLang]} on ${fullDate()} at ${timeFormat()}';

      case Language.ru:
        return '${seenWord[currentLang]} ${fullDate()} в ${timeFormat()}';
    }
  }
}
