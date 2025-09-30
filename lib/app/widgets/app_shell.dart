import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:conecta_app/app/widgets/connectivity_banner.dart';
import 'package:conecta_app/core/localization/l10n.dart';
import 'package:conecta_app/features/gamification/presentation/gamification_screen.dart';
import 'package:conecta_app/features/home/presentation/view/home_screen.dart';
import 'package:conecta_app/features/library/presentation/library_screen.dart';
import 'package:conecta_app/features/notifications/presentation/notifications_center_screen.dart';
import 'package:conecta_app/features/player/presentation/providers/now_playing_provider.dart';
import 'package:conecta_app/features/player/presentation/view/music_player_screen.dart';
import 'package:conecta_app/features/player/presentation/view/live_radio_player_screen.dart';
import 'package:conecta_app/features/player/presentation/view/vod_player_screen.dart';
import 'package:conecta_app/features/home/domain/entities/media_item.dart';
import 'package:conecta_app/features/profile/presentation/profile_screen.dart';
import 'package:conecta_app/features/radio/presentation/radio_player_screen.dart';
import 'package:conecta_app/features/search/presentation/search_screen.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      _NavigationItem(
        label: l10n.notificationsTitle,
        route: NotificationsCenterScreen.routePath,
        icon: Icons.notifications_rounded,
      ),
      _NavigationItem(
        label: l10n.gamificationTitle,
        route: GamificationScreen.routePath,
        icon: Icons.emoji_events_rounded,
      ),
      _NavigationItem(
        label: l10n.homeTitle,
        route: HomeScreen.routePath,
        icon: Icons.home_rounded,
        isPrimary: true,
      ),
      _NavigationItem(
        label: l10n.searchTitle,
        route: SearchScreen.routePath,
        icon: Icons.explore_rounded,
      ),
      _NavigationItem(
        label: l10n.libraryTitle,
        route: LibraryScreen.routePath,
        icon: Icons.library_music_rounded,
      ),
    ];

    final location = GoRouterState.of(context).uri.toString();
    final currentIndex =
        items.indexWhere((item) => location.startsWith(item.route));


    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _MiniPlayer(),
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: SafeArea(
              top: false,
              child: NavigationBar(
                height: 70,
                backgroundColor: Theme.of(context).colorScheme.surface,
              selectedIndex: currentIndex < 0 ? 0 : currentIndex,
                onDestinationSelected: (index) => context.go(items[index].route),
                destinations: [
                for (final item in items)
                  NavigationDestination(
                    icon: item.isPrimary
                        ? Container(
                            width: 56,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              item.icon,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                        : Icon(item.icon),
                    label: item.label,
                    selectedIcon: item.isPrimary
                        ? Container(
                            width: 56,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.35),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.home_rounded,
                                color: Colors.white),
                          )
                        : Icon(item.icon),
                  ),
              ],
            ),
          ),
        ),
      ],
      ),
    );
  }
}

class _NavigationItem {
  const _NavigationItem({
    required this.label,
    required this.route,
    required this.icon,
    this.isPrimary = false,
  });

  final String label;
  final String route;
  final IconData icon;
  final bool isPrimary;
}

class _MiniPlayer extends ConsumerWidget {
  const _MiniPlayer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nowPlayingProvider);
    final controller = ref.read(nowPlayingProvider.notifier);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            // Navegar según el tipo de media usando push para mantener el stack
            if (state.item.type == MediaType.radio || state.item.isLive) {
              context.push(LiveRadioPlayerScreen.routePath);
            } else if (state.item.type == MediaType.video) {
              context.push(VodPlayerScreen.routePath);
            } else {
              context.push(MusicPlayerScreen.routePath);
            }
          },
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          state.item.artworkUrl,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 48,
                            height: 48,
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Icon(Icons.account_circle,
                                color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.item.artists.join(', '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.hintColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: controller.toggleLike,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            state.isLiked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: state.isLiked
                                ? theme.colorScheme.primary
                                : theme.iconTheme.color,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: controller.togglePlay,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            state.isPlaying
                                ? Icons.pause_circle_filled_rounded
                                : Icons.play_circle_fill_rounded,
                            size: 32,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 10),
              SizedBox(
                height: 5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withOpacity(0.35),
                      ),
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: state.progress.clamp(0, 1),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF7E57C2), Color(0xFF26C6DA)],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
                ],
              ),
            ),
        ),
      ),
    );
  }
}
