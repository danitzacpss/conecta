import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:conecta_app/app/widgets/connectivity_banner.dart';
import 'package:conecta_app/core/localization/l10n.dart';
import 'package:conecta_app/features/events/presentation/events_screen.dart';
import 'package:conecta_app/features/gamification/presentation/gamification_screen.dart';
import 'package:conecta_app/features/home/presentation/view/home_screen.dart';
import 'package:conecta_app/features/library/presentation/library_screen.dart';
import 'package:conecta_app/features/profile/presentation/profile_screen.dart';
import 'package:conecta_app/features/search/presentation/search_screen.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      _NavigationItem(
          label: l10n.homeTitle,
          route: HomeScreen.routePath,
          icon: Icons.home_rounded),
      _NavigationItem(
          label: l10n.searchTitle,
          route: SearchScreen.routePath,
          icon: Icons.search_rounded),
      _NavigationItem(
          label: l10n.libraryTitle,
          route: LibraryScreen.routePath,
          icon: Icons.library_music_rounded),
      _NavigationItem(
          label: l10n.gamificationTitle,
          route: GamificationScreen.routePath,
          icon: Icons.emoji_events_rounded),
      _NavigationItem(
          label: l10n.eventsTitle,
          route: EventsScreen.routePath,
          icon: Icons.event_rounded),
      _NavigationItem(
          label: l10n.profileTitle,
          route: ProfileScreen.routePath,
          icon: Icons.person_rounded),
    ];

    final location = GoRouterState.of(context).uri.toString();
    final currentIndex =
        items.indexWhere((item) => location.startsWith(item.route));

    return Scaffold(
      body: Column(
        children: [
          const ConnectivityBanner(),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: NavigationBar(
          height: 68,
          selectedIndex: currentIndex < 0 ? 0 : currentIndex,
          onDestinationSelected: (index) => context.go(items[index].route),
          destinations: [
            for (final item in items)
              NavigationDestination(
                icon: Icon(item.icon),
                label: item.label,
              ),
          ],
        ),
      ),
    );
  }
}

class _NavigationItem {
  const _NavigationItem(
      {required this.label, required this.route, required this.icon});

  final String label;
  final String route;
  final IconData icon;
}
