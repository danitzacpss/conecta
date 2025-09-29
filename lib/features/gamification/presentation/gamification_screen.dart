import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:conecta_app/core/localization/l10n.dart';
import 'package:conecta_app/features/home/presentation/widgets/section_header.dart';

final gamificationProvider = Provider<MockGamificationData>((ref) {
  return MockGamificationData(
    points: 1240,
    activeChallenges: const [
      GamificationChallenge(title: 'Escucha 5 playlists nuevas', progress: 0.6),
      GamificationChallenge(
          title: 'Comparte una lista con amigos', progress: 0.2),
    ],
    badges: const [
      GamificationBadge(name: 'Explorador', unlocked: true),
      GamificationBadge(name: 'Fanático', unlocked: false),
      GamificationBadge(name: 'Coleccionista', unlocked: false),
    ],
    leaderboard: const [
      LeaderboardEntry(name: 'Alexa', points: 1240),
      LeaderboardEntry(name: 'Sam', points: 980),
      LeaderboardEntry(name: 'Vale', points: 860),
    ],
  );
});

class GamificationScreen extends ConsumerWidget {
  const GamificationScreen({super.key});

  static const routePath = '/gamification';
  static const routeName = 'gamification';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(gamificationProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.gamificationTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.gamificationPoints(data.points.toString()),
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: (data.points % 1000) / 1000),
                  const SizedBox(height: 8),
                  Text(
                      'Siguiente recompensa en ${1000 - data.points % 1000} pts'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(title: l10n.gamificationActiveChallenges),
          for (final challenge in data.activeChallenges)
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              title: Text(challenge.title),
              subtitle: LinearProgressIndicator(value: challenge.progress),
              trailing: Text('${(challenge.progress * 100).round()}%'),
            ),
          const SizedBox(height: 24),
          SectionHeader(title: l10n.gamificationBadges),
          Row(
            children: [
              for (final badge in data.badges)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: badge.unlocked
                            ? Colors.purple
                            : Colors.grey.shade300,
                        child: Icon(
                          Icons.shield_rounded,
                          color: badge.unlocked ? Colors.white : Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(badge.name),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          SectionHeader(title: l10n.leaderboardTitle),
          for (var i = 0; i < data.leaderboard.length; i++)
            ListTile(
              leading: CircleAvatar(child: Text('#${i + 1}')),
              title: Text(data.leaderboard[i].name),
              trailing: Text('${data.leaderboard[i].points} pts'),
            ),
        ],
      ),
    );
  }
}

class MockGamificationData {
  MockGamificationData({
    required this.points,
    required this.activeChallenges,
    required this.badges,
    required this.leaderboard,
  });

  final int points;
  final List<GamificationChallenge> activeChallenges;
  final List<GamificationBadge> badges;
  final List<LeaderboardEntry> leaderboard;
}

class GamificationChallenge {
  const GamificationChallenge({required this.title, required this.progress});

  final String title;
  final double progress;
}

class GamificationBadge {
  const GamificationBadge({required this.name, required this.unlocked});

  final String name;
  final bool unlocked;
}

class LeaderboardEntry {
  const LeaderboardEntry({required this.name, required this.points});

  final String name;
  final int points;
}
