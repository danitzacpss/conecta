import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../firebase_options.dart';
import '../services/notification_service.dart';
import '../services/offline_sync_service.dart';
import 'app.dart';

Future<void> bootstrap() async {
  FirebaseOptions? firebaseOptions;
  try {
    firebaseOptions = DefaultFirebaseOptions.currentPlatform;
  } on UnsupportedError catch (error) {
    debugPrint('Firebase configuration not available for platform: $error');
  }

  if (firebaseOptions != null && _hasValidFirebaseConfig(firebaseOptions)) {
    await Firebase.initializeApp(options: firebaseOptions);
  } else {
    debugPrint('Skipping Firebase initialization; configuration has placeholder values.');
  }

  await Hive.initFlutter();
  await _openHiveBoxes();

  tz.initializeTimeZones();

  final notificationPlugin = FlutterLocalNotificationsPlugin();
  await initializeNotifications(notificationPlugin);

  final offlineSyncService = OfflineSyncService();
  await offlineSyncService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        notificationServiceProvider.overrideWithValue(
          NotificationService(notificationPlugin),
        ),
        offlineSyncServiceProvider.overrideWithValue(offlineSyncService),
      ],
      child: const ConectaApp(),
    ),
  );
}

Future<void> _openHiveBoxes() async {
  await Future.wait([
    Hive.openBox('app_settings'),
    Hive.openBox('downloads'),
    Hive.openBox('offline_queue'),
  ]);
}

bool _hasValidFirebaseConfig(FirebaseOptions options) {
  bool isPlaceholder(String value) => value.isEmpty || value.startsWith('YOUR_');

  final requiredValues = <String>[
    options.apiKey,
    options.appId,
    options.projectId,
    options.messagingSenderId,
  ];

  if (requiredValues.any(isPlaceholder)) {
    return false;
  }

  final storageBucket = options.storageBucket;
  if (storageBucket != null && isPlaceholder(storageBucket)) {
    return false;
  }

  return true;
}
