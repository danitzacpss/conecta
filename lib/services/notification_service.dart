import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

final notificationServiceProvider = Provider<NotificationService>(
  (ref) =>
      throw UnimplementedError('NotificationService has not been initialized'),
);

Future<void> initializeNotifications(
  FlutterLocalNotificationsPlugin plugin,
) async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings();
  const initializationSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await plugin.initialize(initializationSettings);

  if (Firebase.apps.isNotEmpty) {
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
  }
}

class NotificationService {
  NotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> requestPermissions() async {
    final status = await Permission.notification.request();
    if (!status.isGranted) {
      return;
    }
    if (Firebase.apps.isNotEmpty) {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> showInAppNotification({
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'in_app_channel',
        'In App Notifications',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(title.hashCode, title, body, details);
  }
}
