import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:conecta_app/core/localization/l10n.dart';
import 'package:conecta_app/services/notification_service.dart';

final notificationsProvider = StateNotifierProvider<NotificationsController,
    AsyncValue<List<AppNotification>>>(
  (ref) => NotificationsController(ref.read(notificationServiceProvider)),
);

class NotificationsController
    extends StateNotifier<AsyncValue<List<AppNotification>>> {
  NotificationsController(this._notificationService)
      : super(const AsyncValue.data([]));

  final NotificationService _notificationService;

  Future<void> load() async {
    state = const AsyncValue.loading();
    await Future<void>.delayed(const Duration(milliseconds: 400));
    state = AsyncValue.data(
      [
        AppNotification(
          id: '1',
          title: 'Reto desbloqueado',
          body: 'Completaste el reto Diario Chill.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
        ),
      ],
    );
  }

  Future<void> requestPermissions() async {
    await _notificationService.requestPermissions();
  }
}

class NotificationsCenterScreen extends ConsumerWidget {
  const NotificationsCenterScreen({super.key});

  static const routePath = '/notifications';
  static const routeName = 'notifications';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        actions: [
          IconButton(
            onPressed: () =>
                ref.read(notificationsProvider.notifier).requestPermissions(),
            icon: const Icon(Icons.notifications_active_rounded),
          ),
        ],
      ),
      body: notifications.when(
        data: (items) => items.isEmpty
            ? Center(child: Text(l10n.notificationsEmpty))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final notification = items[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      title: Text(notification.title),
                      subtitle: Text(notification.body),
                      trailing: Text(
                          '${notification.createdAt.hour}:${notification.createdAt.minute.toString().padLeft(2, '0')}'),
                    ),
                  );
                },
              ),
        error: (error, _) => Center(child: Text(context.l10n.stateError)),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ref.read(notificationsProvider.notifier).load();
        },
        icon: const Icon(Icons.refresh_rounded),
        label: Text(l10n.actionRetry),
      ),
    );
  }
}

class AppNotification {
  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
}
