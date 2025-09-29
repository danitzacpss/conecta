import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:conecta_app/core/localization/l10n.dart';
import 'package:conecta_app/services/notification_service.dart';
import 'package:conecta_app/features/profile/presentation/profile_screen.dart';

final notificationsProvider = StateNotifierProvider<NotificationsController,
    AsyncValue<NotificationData>>(
  (ref) => NotificationsController(ref.read(notificationServiceProvider)),
);

class NotificationsController
    extends StateNotifier<AsyncValue<NotificationData>> {
  NotificationsController(this._notificationService)
      : super(const AsyncValue.data(NotificationData()));

  final NotificationService _notificationService;

  Future<void> load() async {
    state = const AsyncValue.loading();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    state = AsyncValue.data(
      NotificationData(
        selectedCategory: 'General',
        categories: ['General', 'Concursos', 'Eventos', 'Otros'],
        notifications: [
          // General
          AppNotification(
            id: '1',
            category: 'General',
            title: '¡No te pierdas! El programa',
            subtitle: '"Mañanas de Rock"',
            description: ' está a punto de comenzar.',
            timeAgo: 'Hace 2 minutos',
            icon: Icons.radio,
            color: const Color(0xFF7E57C2),
          ),
          AppNotification(
            id: '2',
            category: 'General',
            title: 'Tu programa favorito,',
            subtitle: '"Noches de Dance"',
            description: ', comienza en 5 minutos.',
            timeAgo: 'Hace 1 día',
            icon: Icons.radio,
            color: const Color(0xFF9C27B0),
          ),
          AppNotification(
            id: '3',
            category: 'General',
            title: 'Nueva playlist disponible:',
            subtitle: '"Éxitos del Verano"',
            description: '. ¡Descúbrela ahora!',
            timeAgo: 'Hace 3 horas',
            icon: Icons.music_note,
            color: const Color(0xFF42A5F5),
          ),
          AppNotification(
            id: '4',
            category: 'General',
            title: 'El programa',
            subtitle: '"Café y Música"',
            description: ' ha terminado. ¡Gracias por escuchar!',
            timeAgo: 'Hace 5 horas',
            icon: Icons.radio,
            color: const Color(0xFF66BB6A),
          ),

          // Concursos
          AppNotification(
            id: '5',
            category: 'Concursos',
            title: '¡Felicidades! Has ganado',
            subtitle: '2 entradas para el Fest.',
            description: ' Reclama tu premio ahora.',
            timeAgo: 'Hace 15 minutos',
            icon: Icons.emoji_events,
            color: const Color(0xFF26C6DA),
          ),
          AppNotification(
            id: '6',
            category: 'Concursos',
            title: 'Última oportunidad para',
            subtitle: 'participar en el concurso y ganar',
            description: ' un viaje a Ibiza.',
            timeAgo: 'Hace 2 días',
            icon: Icons.emoji_events,
            color: const Color(0xFF4CAF50),
          ),
          AppNotification(
            id: '7',
            category: 'Concursos',
            title: 'Nuevo concurso:',
            subtitle: '"Adivina la Canción"',
            description: '. ¡Participa y gana increíbles premios!',
            timeAgo: 'Hace 1 día',
            icon: Icons.quiz,
            color: const Color(0xFFFF9800),
          ),
          AppNotification(
            id: '8',
            category: 'Concursos',
            title: '¡Ganaste el concurso!',
            subtitle: 'Merchandising oficial',
            description: ' te será enviado pronto.',
            timeAgo: 'Hace 3 días',
            icon: Icons.card_giftcard,
            color: const Color(0xFFE91E63),
          ),

          // Eventos
          AppNotification(
            id: '9',
            category: 'Eventos',
            title: 'Recordatorio del evento',
            subtitle: 'Meet & Greet con The Killers',
            description: ' es mañana a las 7 PM.',
            timeAgo: 'Hace 1 hora',
            icon: Icons.event,
            color: const Color(0xFFFF7043),
          ),
          AppNotification(
            id: '10',
            category: 'Eventos',
            title: 'Concierto en vivo:',
            subtitle: 'Los Bunkers',
            description: ' este viernes en el Teatro Nacional.',
            timeAgo: 'Hace 6 horas',
            icon: Icons.mic,
            color: const Color(0xFF7B1FA2),
          ),
          AppNotification(
            id: '11',
            category: 'Eventos',
            title: 'Festival de Jazz',
            subtitle: '2024',
            description: ' comienza el próximo mes. ¡Reserva tu entrada!',
            timeAgo: 'Hace 2 días',
            icon: Icons.music_note,
            color: const Color(0xFFFFB74D),
          ),
          AppNotification(
            id: '12',
            category: 'Eventos',
            title: 'Masterclass gratuita:',
            subtitle: '"Producción Musical"',
            description: ' este sábado a las 10 AM.',
            timeAgo: 'Hace 4 días',
            icon: Icons.school,
            color: const Color(0xFF81C784),
          ),

          // Otros
          AppNotification(
            id: '13',
            category: 'Otros',
            title: 'Actualización de la app',
            subtitle: 'versión 2.1.0',
            description: ' disponible. ¡Descárgala ahora!',
            timeAgo: 'Hace 30 minutos',
            icon: Icons.system_update,
            color: const Color(0xFF5C6BC0),
          ),
          AppNotification(
            id: '14',
            category: 'Otros',
            title: 'Nuevas funciones:',
            subtitle: 'Modo offline',
            description: ' y descarga de programas ya disponibles.',
            timeAgo: 'Hace 1 día',
            icon: Icons.new_releases,
            color: const Color(0xFFAB47BC),
          ),
          AppNotification(
            id: '15',
            category: 'Otros',
            title: 'Mantenimiento programado',
            subtitle: 'del servidor',
            description: ' mañana de 2 AM a 4 AM.',
            timeAgo: 'Hace 12 horas',
            icon: Icons.build,
            color: const Color(0xFFFF8A65),
          ),
          AppNotification(
            id: '16',
            category: 'Otros',
            title: 'Encuesta de satisfacción:',
            subtitle: '¿Cómo calificarías',
            description: ' nuestra app? Tu opinión es importante.',
            timeAgo: 'Hace 3 días',
            icon: Icons.star_rate,
            color: const Color(0xFF4DB6AC),
          ),
        ],
      ),
    );
  }

  void selectCategory(String category) {
    final currentData = state.value;
    if (currentData != null) {
      state = AsyncValue.data(currentData.copyWith(selectedCategory: category));
    }
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
    final notificationData = ref.watch(notificationsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.8),
              theme.colorScheme.secondary.withOpacity(0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, theme),
              Expanded(
                child: notificationData.when(
                  data: (data) => _buildContent(context, theme, data, ref),
                  error: (error, _) => Center(
                    child: Text(
                      context.l10n.stateError,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Notificaciones',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          GestureDetector(
            onTap: () => context.go(ProfileScreen.routePath),
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme, NotificationData data, WidgetRef ref) {
    return Column(
      children: [
        _buildCategoryTabs(theme, data, ref),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: _buildNotificationsList(context, theme, data),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTabs(ThemeData theme, NotificationData data, WidgetRef ref) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: data.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = data.categories[index];
          final isSelected = category == data.selectedCategory;
          return GestureDetector(
            onTap: () => ref.read(notificationsProvider.notifier).selectCategory(category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.25) : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: isSelected ? Border.all(color: Colors.white.withOpacity(0.3)) : null,
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationsList(BuildContext context, ThemeData theme, NotificationData data) {
    final filteredNotifications = data.notifications
        .where((notification) => notification.category == data.selectedCategory)
        .toList();

    if (filteredNotifications.isEmpty) {
      return Center(
        child: Text(
          'No hay notificaciones en esta categoría',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: filteredNotifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final notification = filteredNotifications[index];
        return _NotificationCard(notification: notification);
      },
    );
  }
}

class NotificationData {
  const NotificationData({
    this.selectedCategory = 'General',
    this.categories = const ['General'],
    this.notifications = const [],
  });

  final String selectedCategory;
  final List<String> categories;
  final List<AppNotification> notifications;

  NotificationData copyWith({
    String? selectedCategory,
    List<String>? categories,
    List<AppNotification>? notifications,
  }) {
    return NotificationData(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      categories: categories ?? this.categories,
      notifications: notifications ?? this.notifications,
    );
  }
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.timeAgo,
    required this.icon,
    required this.color,
  });

  final String id;
  final String category;
  final String title;
  final String subtitle;
  final String description;
  final String timeAgo;
  final IconData icon;
  final Color color;
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: notification.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              notification.icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(text: notification.title),
                      TextSpan(
                        text: notification.subtitle,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: notification.description),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notification.timeAgo,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
