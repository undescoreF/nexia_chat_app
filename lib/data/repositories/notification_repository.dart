import '../providers/notification_provider.dart';

class NotificationRepository {
  final NotificationProvider _provider;

  NotificationRepository(this._provider);

  /// Envoie la notification via le provider
  Future<void> sendNotification({
    required List<String> playerId,
    required String title,
    required String body,
  }) async {
    await _provider.sendNotification(
      playerIds: playerId,
      title: title,
      body: body,
    );
  }
}
