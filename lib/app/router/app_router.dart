import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:conecta_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:conecta_app/features/auth/presentation/view/login_screen.dart';
import 'package:conecta_app/features/community/presentation/contest_details_screen.dart';
import 'package:conecta_app/features/community/presentation/polls_contests_screen.dart';
import 'package:conecta_app/features/events/presentation/events_screen.dart';
import 'package:conecta_app/features/gamification/presentation/gamification_screen.dart';
import 'package:conecta_app/features/home/presentation/view/home_screen.dart';
import 'package:conecta_app/features/library/presentation/library_screen.dart';
import 'package:conecta_app/features/notifications/presentation/notifications_center_screen.dart';
import 'package:conecta_app/features/onboarding/presentation/view/onboarding_screen.dart';
import 'package:conecta_app/features/player/presentation/view/now_playing_screen.dart';
import 'package:conecta_app/features/profile/presentation/profile_screen.dart';
import 'package:conecta_app/features/radio/presentation/radio_player_screen.dart';
import 'package:conecta_app/features/search/presentation/search_screen.dart';
import 'package:conecta_app/app/widgets/app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: OnboardingScreen.routePath,
    routes: [
      GoRoute(
        path: OnboardingScreen.routePath,
        name: OnboardingScreen.routeName,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: LoginScreen.routePath,
        name: LoginScreen.routeName,
        builder: (context, state) {
          final extra = state.extra;
          Map<String, dynamic>? payload;
          if (extra is Map<String, dynamic>) {
            payload = extra;
          }
          return LoginScreen(radioStation: payload);
        },
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: HomeScreen.routePath,
            name: HomeScreen.routeName,
            builder: (context, state) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'now-playing',
                name: NowPlayingScreen.routeName,
                builder: (context, state) => const NowPlayingScreen(),
              ),
            ],
          ),
          GoRoute(
            path: SearchScreen.routePath,
            name: SearchScreen.routeName,
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: LibraryScreen.routePath,
            name: LibraryScreen.routeName,
            builder: (context, state) => const LibraryScreen(),
          ),
          GoRoute(
            path: GamificationScreen.routePath,
            name: GamificationScreen.routeName,
            builder: (context, state) => const GamificationScreen(),
          ),
          GoRoute(
            path: EventsScreen.routePath,
            name: EventsScreen.routeName,
            builder: (context, state) => const EventsScreen(),
          ),
          GoRoute(
            path: NotificationsCenterScreen.routePath,
            name: NotificationsCenterScreen.routeName,
            builder: (context, state) => const NotificationsCenterScreen(),
          ),
          GoRoute(
            path: ProfileScreen.routePath,
            name: ProfileScreen.routeName,
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: RadioPlayerScreen.routePath,
            name: RadioPlayerScreen.routeName,
            builder: (context, state) => const RadioPlayerScreen(),
          ),
          GoRoute(
            path: PollsContestsScreen.routePath,
            name: PollsContestsScreen.routeName,
            builder: (context, state) => const PollsContestsScreen(),
          ),
          GoRoute(
            path: ContestDetailsScreen.routePath,
            name: ContestDetailsScreen.routeName,
            builder: (context, state) => const ContestDetailsScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final loggingIn = state.matchedLocation == LoginScreen.routePath;
      final onboarding = state.matchedLocation == OnboardingScreen.routePath;

      if (authState.status == AuthStatus.unknown) {
        return null;
      }

      if (!isAuthenticated) {
        if (!loggingIn && !onboarding) {
          return OnboardingScreen.routePath;
        }
        return null;
      }

      if ((loggingIn || onboarding) && isAuthenticated) {
        return HomeScreen.routePath;
      }

      return null;
    },
    debugLogDiagnostics: false,
  );
});

final _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellNavigator');
