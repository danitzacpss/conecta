import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:conecta_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:conecta_app/features/auth/presentation/view/login_screen.dart';
import 'package:conecta_app/features/challenges/presentation/challenges_screen.dart';
import 'package:conecta_app/features/challenges/presentation/achievements_history_screen.dart';
import 'package:conecta_app/features/community/presentation/all_contests_screen.dart';
import 'package:conecta_app/features/community/presentation/all_polls_screen.dart';
import 'package:conecta_app/features/community/presentation/contest_details_screen.dart';
import 'package:conecta_app/features/community/presentation/group_chat_screen.dart';
import 'package:conecta_app/features/community/presentation/polls_contests_screen.dart';
import 'package:conecta_app/features/events/presentation/events_screen.dart';
import 'package:conecta_app/features/events/presentation/all_events_screen.dart';
import 'package:conecta_app/features/gamification/presentation/gamification_screen.dart';
import 'package:conecta_app/features/home/presentation/view/home_screen.dart';
import 'package:conecta_app/features/library/presentation/library_screen.dart';
import 'package:conecta_app/features/library/presentation/playlist_details_screen.dart';
import 'package:conecta_app/features/notifications/presentation/notifications_center_screen.dart';
import 'package:conecta_app/features/notifications/presentation/notification_detail_screen.dart';
import 'package:conecta_app/features/onboarding/presentation/view/onboarding_screen.dart';
import 'package:conecta_app/features/player/presentation/view/now_playing_screen.dart';
import 'package:conecta_app/features/player/presentation/view/music_player_screen.dart';
import 'package:conecta_app/features/player/presentation/view/radio_player_screen.dart';
import 'package:conecta_app/features/player/presentation/view/vod_player_screen.dart';
import 'package:conecta_app/features/profile/presentation/profile_screen.dart';
import 'package:conecta_app/features/radio/presentation/radio_profile_screen.dart';
import 'package:conecta_app/features/radio/presentation/artist_profile_screen.dart';
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
            builder: (context, state) {
              final category = state.uri.queryParameters['category'];
              return SearchScreen(initialCategory: category);
            },
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
            path: ChallengesScreen.routePath,
            name: ChallengesScreen.routeName,
            builder: (context, state) => const ChallengesScreen(),
          ),
          GoRoute(
            path: AchievementsHistoryScreen.routePath,
            name: AchievementsHistoryScreen.routeName,
            builder: (context, state) => const AchievementsHistoryScreen(),
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
            path: PollsContestsScreen.routePath,
            name: PollsContestsScreen.routeName,
            builder: (context, state) => const PollsContestsScreen(),
          ),
          GoRoute(
            path: AllContestsScreen.routePath,
            name: AllContestsScreen.routeName,
            builder: (context, state) => const AllContestsScreen(),
          ),
          GoRoute(
            path: AllPollsScreen.routePath,
            name: AllPollsScreen.routeName,
            builder: (context, state) => const AllPollsScreen(),
          ),
          GoRoute(
            path: AllEventsScreen.routePath,
            name: AllEventsScreen.routeName,
            builder: (context, state) => const AllEventsScreen(),
          ),
          GoRoute(
            path: ContestDetailsScreen.routePath,
            name: ContestDetailsScreen.routeName,
            builder: (context, state) => const ContestDetailsScreen(),
          ),
          GoRoute(
            path: GroupChatScreen.routePath,
            name: GroupChatScreen.routeName,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final radioName = extra?['radioName'] as String?;
              return GroupChatScreen(radioName: radioName);
            },
          ),
          GoRoute(
            path: RadioProfileScreen.routePath,
            name: RadioProfileScreen.routeName,
            builder: (context, state) => const RadioProfileScreen(),
          ),
          GoRoute(
            path: ArtistProfileScreen.routePath,
            name: ArtistProfileScreen.routeName,
            builder: (context, state) => const ArtistProfileScreen(),
          ),
          GoRoute(
            path: PlaylistDetailsScreen.routePath,
            name: PlaylistDetailsScreen.routeName,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return PlaylistDetailsScreen(
                playlistName: extra?['playlistName'] as String?,
                isAlbum: extra?['isAlbum'] as bool? ?? false,
                isOwner: extra?['isOwner'] as bool? ?? true,
                ownerName: extra?['ownerName'] as String?,
                artistName: extra?['artistName'] as String?,
              );
            },
          ),
          GoRoute(
            path: NotificationDetailScreen.routePath,
            name: NotificationDetailScreen.routeName,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return NotificationDetailScreen(
                title: extra?['title'] as String? ?? '',
                subtitle: extra?['subtitle'] as String? ?? '',
                description: extra?['description'] as String? ?? '',
                timeAgo: extra?['timeAgo'] as String? ?? '',
                category: extra?['category'] as String? ?? '',
                icon: extra?['icon'] as IconData? ?? Icons.notifications,
                color: extra?['color'] as Color? ?? Colors.blue,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: MusicPlayerScreen.routePath,
        name: MusicPlayerScreen.routeName,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const MusicPlayerScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      GoRoute(
        path: RadioPlayerScreen.routePath,
        name: RadioPlayerScreen.routeName,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const RadioPlayerScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      GoRoute(
        path: VodPlayerScreen.routePath,
        name: VodPlayerScreen.routeName,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const VodPlayerScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        ),
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
