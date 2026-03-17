import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/notification_repository.dart';
import '../views/chat_page.dart';

class NotificationController extends GetxController {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final NotificationRepository _repository;

  NotificationController(this._repository);

  @override
  void onInit() {
    super.onInit();
    _initLocalNotifications();
    _initOneSignal();
  }

  void _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (payload) {
        debugPrint('Notification clicked: $payload');
      },
    );
  }

  Future<void> sendNotification({
    required List<String> playerId,
    required String title,
    required String body,
  }) async {
    await _repository.sendNotification(
      playerId: playerId,
      title: title,
      body: body,
    );
  }

  void _initOneSignal() async {
    OneSignal.Notifications.requestPermission(true);

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      final notif = event.notification;

      event.preventDefault(); // Empêche la notification native de s'afficher

      _showLocalNotification(notif.title ?? '', notif.body ?? '');

      //otification native OneSignal
      notif.display();
    });

    OneSignal.Notifications.addClickListener((event) {
      final notif = event.notification;
      final data = notif.additionalData;

      if (data != null && data['type'] == 'message') {
        Get.to(
          () => ChatPage(
            myId: FirebaseAuth.instance.currentUser!.uid,
            otherUser: UserModel(
              uid: data['otherUserId'],
              name: data['otherName'],
              email: '',
              isOnline: true,
            ),
            chatId: data['chatId'],
          ),
        );
      }
    });
  }

  Future<void> _showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'channel_id',
          'Channel Name',
          channelDescription: 'Channel description',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails notifDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(0, title, body, notifDetails);
  }
}
