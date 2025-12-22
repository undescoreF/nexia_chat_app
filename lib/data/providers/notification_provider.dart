import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationProvider {
  final String appId = dotenv.env['ONESIGNAL_APP_ID']!;
  final String restKey = dotenv.env['ONESIGNAL_REST_KEY']!;
  final String chanel = dotenv.env['CHANEL_ID']!;

  /// Envoie une notification via l’API OneSignal
  Future<void> sendNotification({
    required List<String> playerIds,
    required String title,
    required String body,
  }) async {
    final url = Uri.parse("https://api.onesignal.com/notifications?c=push");

    final payload = {
      "app_id": appId,
      "contents": {"en": body},
      "headings": {"en": title},
      "target_channel": "push",
      "include_subscription_ids": playerIds,
      "android_channel_id": chanel,
      "android_group": "notifications_groupees",
      "small_icon": "icono",
      "isAndroid": true,
    };

    final headers = {
      "Authorization": "Key $restKey",
      "Content-Type": "application/json",
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(payload),
    );
  }
}
