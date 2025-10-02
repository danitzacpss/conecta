import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:conecta_app/core/localization/l10n.dart';
import 'package:conecta_app/features/home/presentation/widgets/section_header.dart';
import 'package:conecta_app/features/profile/presentation/profile_screen.dart';
import 'package:conecta_app/features/gamification/presentation/rewards_history_screen.dart';
import 'package:conecta_app/features/gamification/presentation/rewards_store_screen.dart';
import 'package:conecta_app/features/radio/presentation/radio_profile_screen.dart';
import 'package:conecta_app/features/scanner/presentation/audio_scanner_modal.dart';
import 'package:conecta_app/features/challenges/presentation/challenges_screen.dart';
import 'package:conecta_app/features/challenges/presentation/achievements_history_screen.dart' as achievements;

final gamificationProvider = Provider<MockGamificationData>((ref) {
  return _createMockData();
});

MockGamificationData _createMockData() {
  return MockGamificationData(
    userLevel: 5,
    points: 1250,
    pointsToNext: 250,
    dailyChallenges: [
      const DailyChallenge(
        title: 'Escucha 3 canciones',
        description: 'Completas hoy',
        icon: Icons.music_note,
        points: 50,
        completed: false,
        progress: 2,
        goal: 3,
      ),
      const DailyChallenge(
        title: 'Vota en encuesta',
        description: 'Tu opinión importa',
        icon: Icons.poll,
        points: 25,
        completed: true,
        progress: 1,
        goal: 1,
      ),
    ],
    missions: [
      const Mission(
        title: 'Misión: Creador de Listas',
        description: 'Crea 3 playlists nuevas y obtén +50 pts.',
        icon: Icons.playlist_add,
        points: 50,
        completed: false,
        progress: 1,
        goal: 3,
      ),
    ],
    rewards: [
      const Reward(
        id: 'ticket_concierto',
        title: 'Ticket Concierto',
        points: 2000,
        icon: Icons.confirmation_number,
        available: true,
        redeemed: false,
      ),
      const Reward(
        id: 'merch_exclusiva',
        title: 'Merch Exclusiva',
        points: 1500,
        icon: Icons.shopping_bag,
        available: true,
        redeemed: false,
      ),
      const Reward(
        id: 'mes_premium',
        title: 'Mes Premium',
        points: 1000,
        icon: Icons.music_note,
        available: true,
        redeemed: false,
      ),
      const Reward(
        id: 'acceso_vod',
        title: 'Acceso VOD',
        points: 750,
        icon: Icons.video_library,
        available: false,
        redeemed: true,
      ),
    ],
    pointsActivities: [
      const PointsActivity(
        title: 'Vota en Encuestas',
        description: '+10 puntos por voto',
        icon: Icons.poll,
        points: 10,
      ),
      const PointsActivity(
        title: 'Participa en Concursos',
        description: '+50 puntos por participar',
        icon: Icons.emoji_events,
        points: 50,
      ),
      const PointsActivity(
        title: 'Comparte contenido',
        description: '+5 puntos por compartir',
        icon: Icons.share,
        points: 5,
      ),
    ],
    rewardsHistory: [
      const RewardHistory(
        title: 'Acceso a contenido VOD',
        date: '12 Nov. 2023',
        points: -750,
      ),
    ],
  );
}

class GamificationScreen extends ConsumerWidget {
  const GamificationScreen({super.key});

  static const routePath = '/gamification';
  static const routeName = 'gamification';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(gamificationProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.light
        ? Colors.grey[100]
        : theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header minimalista con SafeArea
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recompensas',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _showScannerModal(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.qr_code_scanner,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Contenido scrolleable que incluye la tarjeta de bienvenida
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildWelcomeCard(context, theme, data),
                  ),
                  _buildBody(context, theme, data),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, ThemeData theme, MockGamificationData data) {
    final progressPercent = (data.points % 1000) / 1000; // Progreso al siguiente nivel

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.8),
            theme.colorScheme.secondary.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Nivel y avatar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nivel Actual',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${data.userLevel}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          '/ 100',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.military_tech,
                  size: 48,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Puntos actuales
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tus Puntos',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.stars, color: Colors.amber, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        '${data.points}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Al siguiente nivel',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${data.pointsToNext} pts',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Barra de progreso
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Progreso',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progressPercent,
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.amber, Colors.orange],
                        ),
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Badges rápidos
          Row(
            children: [
              Expanded(
                child: _buildQuickBadge(
                  icon: Icons.emoji_events,
                  label: '47 Retos',
                  color: Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickBadge(
                  icon: Icons.workspace_premium,
                  label: '4 Logros',
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickBadge(
                  icon: Icons.local_fire_department,
                  label: '7 días',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme, MockGamificationData data) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBadgesPreviewSection(context, theme, data),
          const SizedBox(height: 24),
          _buildChallengesSection(context, theme, data),
          const SizedBox(height: 24),
          _buildRewardsSection(context, theme, data),
          const SizedBox(height: 24),
          _buildPointsActivitiesSection(context, theme, data),
          const SizedBox(height: 180), // Espacio para mini reproductor y nav bar
        ],
      ),
    );
  }

  Widget _buildBadgesPreviewSection(BuildContext context, ThemeData theme, MockGamificationData data) {
    return Consumer(
      builder: (context, ref, child) {
        final history = ref.watch(achievements.achievementsHistoryProvider);
        final recentBadges = history.badges.take(4).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Logros Recientes',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/achievements-history'),
                  child: Text(
                    'Ver todos',
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recentBadges.length,
                itemBuilder: (context, index) {
                  final badge = recentBadges[index];
                  return _buildBadgePreviewCard(
                    context: context,
                    theme: theme,
                    badge: badge,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBadgePreviewCard({
    required BuildContext context,
    required ThemeData theme,
    required achievements.Badge badge,
  }) {
    final rarityColor = _getRarityColor(badge.rarity);
    final badgeColor = badge.isUnlocked ? badge.color : Colors.grey;

    return GestureDetector(
      onTap: () => _showBadgeDetailModal(context, badge),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: badge.isUnlocked
              ? theme.colorScheme.surface
              : theme.colorScheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: badge.isUnlocked
              ? null
              : Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
          boxShadow: badge.isUnlocked
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    badge.iconData,
                    color: badgeColor,
                    size: 28,
                  ),
                ),
                if (!badge.isUnlocked)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      color: Colors.black38,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              badge.name,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: badge.isUnlocked
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: rarityColor.withOpacity(badge.isUnlocked ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge.rarity,
                style: TextStyle(
                  color: badge.isUnlocked
                      ? rarityColor
                      : rarityColor.withOpacity(0.5),
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetailModal(BuildContext context, achievements.Badge badge) {
    final isLocked = !badge.isUnlocked;
    final rewards = _getBadgeRewards(badge.rarity);

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              // Ícono del badge
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isLocked
                          ? Colors.grey.withOpacity(0.2)
                          : badge.color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      badge.iconData,
                      color: isLocked ? Colors.grey : badge.color,
                      size: 56,
                    ),
                  ),
                  if (isLocked)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Colors.black38,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // Nombre del badge
              Text(
                badge.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Rareza
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRarityColor(badge.rarity).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge.rarity,
                  style: TextStyle(
                    color: _getRarityColor(badge.rarity),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Descripción
              Text(
                badge.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Recompensas
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isLocked ? Icons.lock_outline : Icons.card_giftcard,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isLocked ? 'Recompensas al desbloquear' : 'Recompensas obtenidas',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...rewards.map((reward) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            reward['icon'] as IconData,
                            color: Colors.amber,
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              reward['text'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
              if (isLocked) ...[
                const SizedBox(height: 16),
                Text(
                  'Completa el desafío para desbloquear este logro',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (!isLocked && badge.earnedAt != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Desbloqueado el ${badge.earnedAt!.day}/${badge.earnedAt!.month}/${badge.earnedAt!.year}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getBadgeRewards(String rarity) {
    switch (rarity) {
      case 'Legendario':
        return [
          {'icon': Icons.stars, 'text': '+500 XP'},
          {'icon': Icons.card_giftcard, 'text': '+1000 puntos'},
          {'icon': Icons.workspace_premium, 'text': 'Acceso VIP a eventos'},
          {'icon': Icons.local_fire_department, 'text': 'Racha protegida x3'},
        ];
      case 'Épico':
        return [
          {'icon': Icons.stars, 'text': '+300 XP'},
          {'icon': Icons.card_giftcard, 'text': '+500 puntos'},
          {'icon': Icons.discount, 'text': '20% descuento en eventos'},
          {'icon': Icons.emoji_events, 'text': 'Multiplicador 1.5x puntos'},
        ];
      case 'Raro':
        return [
          {'icon': Icons.stars, 'text': '+150 XP'},
          {'icon': Icons.card_giftcard, 'text': '+250 puntos'},
          {'icon': Icons.playlist_play, 'text': 'Playlist exclusiva'},
        ];
      case 'Común':
      default:
        return [
          {'icon': Icons.stars, 'text': '+50 XP'},
          {'icon': Icons.card_giftcard, 'text': '+100 puntos'},
        ];
    }
  }

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'Común':
        return Colors.grey;
      case 'Raro':
        return Colors.blue;
      case 'Épico':
        return Colors.purple;
      case 'Legendario':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  Widget _buildChallengesSection(BuildContext context, ThemeData theme, MockGamificationData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Retos y Misiones',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: () => context.push(ChallengesScreen.routePath),
              child: Text(
                'Ver todo',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...data.dailyChallenges.map((challenge) => _buildChallengeCard(context, theme, challenge)),
        ...data.missions.map((mission) => _buildMissionCard(context, theme, mission)),
      ],
    );
  }

  Widget _buildChallengeCard(BuildContext context, ThemeData theme, DailyChallenge challenge) {
    final progressPercent = (challenge.progress / challenge.goal).clamp(0.0, 1.0);
    final isCompleted = challenge.progress >= challenge.goal;

    return GestureDetector(
      onTap: () => _showDailyChallengeDetailModal(context, challenge),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
        children: [
          // Progreso de fondo
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: LinearProgressIndicator(
                value: progressPercent,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.red.withOpacity(0.1),
                ),
                minHeight: double.infinity,
              ),
            ),
          ),
          // Contenido
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Ícono circular con progreso
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: CircularProgressIndicator(
                        value: progressPercent,
                        backgroundColor: Colors.red.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                        strokeWidth: 4,
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isCompleted ? Colors.red : Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCompleted ? Icons.check : challenge.icon,
                        color: isCompleted ? Colors.white : Colors.red,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        challenge.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Progreso
                          Text(
                            '${challenge.progress}/${challenge.goal}',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Puntos
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.stars, color: Colors.amber, size: 12),
                                const SizedBox(width: 2),
                                Text(
                                  '${challenge.points}',
                                  style: const TextStyle(
                                    color: Colors.amber,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Estado
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.card_giftcard,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildMissionCard(BuildContext context, ThemeData theme, Mission mission) {
    final progressPercent = (mission.progress / mission.goal).clamp(0.0, 1.0);
    final isCompleted = mission.progress >= mission.goal;

    return GestureDetector(
      onTap: () => _showMissionDetailModal(context, mission),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
        children: [
          // Progreso de fondo
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: LinearProgressIndicator(
                value: progressPercent,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary.withOpacity(0.1),
                ),
                minHeight: double.infinity,
              ),
            ),
          ),
          // Contenido
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Ícono circular con progreso
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: CircularProgressIndicator(
                        value: progressPercent,
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                        strokeWidth: 4,
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isCompleted ? theme.colorScheme.primary : theme.colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCompleted ? Icons.check : mission.icon,
                        color: isCompleted ? Colors.white : theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mission.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mission.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Progreso
                          Text(
                            '${mission.progress}/${mission.goal}',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Puntos
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.stars, color: Colors.amber, size: 12),
                                const SizedBox(width: 2),
                                Text(
                                  '${mission.points}',
                                  style: const TextStyle(
                                    color: Colors.amber,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Estado
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.card_giftcard,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  void _showDailyChallengeDetailModal(BuildContext context, DailyChallenge challenge) {
    final theme = Theme.of(context);
    final progressPercent = (challenge.progress / challenge.goal).clamp(0.0, 1.0);
    final isCompleted = challenge.progress >= challenge.goal;
    final challengeColor = Colors.red;

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              // Ícono del reto
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: challengeColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle : challenge.icon,
                  color: challengeColor,
                  size: 56,
                ),
              ),
              const SizedBox(height: 16),
              // Título
              Text(
                challenge.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Categoría
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: challengeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Reto Diario',
                  style: TextStyle(
                    color: challengeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Descripción
              Text(
                challenge.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Progreso
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: challengeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: challengeColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progreso',
                          style: TextStyle(
                            color: challengeColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${challenge.progress} / ${challenge.goal}',
                          style: TextStyle(
                            color: challengeColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progressPercent,
                        backgroundColor: Colors.white.withOpacity(0.5),
                        valueColor: AlwaysStoppedAnimation<Color>(challengeColor),
                        minHeight: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Recompensas
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.card_giftcard,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            const Icon(Icons.stars, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '${challenge.points} pts',
                              style: const TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMissionDetailModal(BuildContext context, Mission mission) {
    final theme = Theme.of(context);
    final progressPercent = (mission.progress / mission.goal).clamp(0.0, 1.0);
    final isCompleted = mission.progress >= mission.goal;

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              // Ícono de la misión
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle : mission.icon,
                  color: theme.colorScheme.primary,
                  size: 56,
                ),
              ),
              const SizedBox(height: 16),
              // Título
              Text(
                mission.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Categoría
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Misión',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Descripción
              Text(
                mission.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Progreso
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progreso',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${mission.progress} / ${mission.goal}',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progressPercent,
                        backgroundColor: Colors.white.withOpacity(0.5),
                        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                        minHeight: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Recompensas
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.card_giftcard,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            const Icon(Icons.stars, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '${mission.points} pts',
                              style: const TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardsSection(BuildContext context, ThemeData theme, MockGamificationData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Canjear Puntos',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RewardsStoreScreen(),
                ),
              ),
              child: Text(
                'Ver todo',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: data.rewards.length,
            itemBuilder: (context, index) {
              return _buildRewardCard(theme, data.rewards[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRewardCard(ThemeData theme, Reward reward) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: reward.redeemed
                  ? Colors.grey.withOpacity(0.1)
                  : theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              reward.icon,
              size: 28,
              color: reward.redeemed
                  ? Colors.grey
                  : theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            reward.title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.stars, color: Colors.amber, size: 14),
              const SizedBox(width: 4),
              Text(
                '${reward.points}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.amber,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: reward.redeemed ? null : () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: reward.redeemed
                    ? Colors.grey.withOpacity(0.3)
                    : theme.colorScheme.primary,
                foregroundColor: reward.redeemed
                    ? Colors.grey
                    : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                reward.redeemed ? 'Canjeado' : 'Canjear',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsActivitiesSection(BuildContext context, ThemeData theme, MockGamificationData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Cómo ganar más puntos?',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...data.pointsActivities.map((activity) => _buildPointsActivityCard(theme, activity)),
      ],
    );
  }

  Widget _buildPointsActivityCard(ThemeData theme, PointsActivity activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              activity.icon,
              color: theme.colorScheme.secondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  activity.description,
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

  void _showScannerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AudioScannerModal(),
    );
  }
}

class MockGamificationData {
  MockGamificationData({
    required this.userLevel,
    required this.points,
    required this.pointsToNext,
    required this.dailyChallenges,
    required this.missions,
    required this.rewards,
    required this.pointsActivities,
    required this.rewardsHistory,
  });

  final int userLevel;
  final int points;
  final int pointsToNext;
  final List<DailyChallenge> dailyChallenges;
  final List<Mission> missions;
  final List<Reward> rewards;
  final List<PointsActivity> pointsActivities;
  final List<RewardHistory> rewardsHistory;
}

class DailyChallenge {
  const DailyChallenge({
    required this.title,
    required this.description,
    required this.icon,
    required this.points,
    required this.completed,
    this.progress = 0,
    this.goal = 1,
  });

  final String title;
  final String description;
  final IconData icon;
  final int points;
  final bool completed;
  final int progress;
  final int goal;
}

class Mission {
  const Mission({
    required this.title,
    required this.description,
    required this.icon,
    required this.points,
    required this.completed,
    this.progress = 0,
    this.goal = 1,
  });

  final String title;
  final String description;
  final IconData icon;
  final int points;
  final bool completed;
  final int progress;
  final int goal;
}

class Reward {
  const Reward({
    required this.id,
    required this.title,
    required this.points,
    required this.icon,
    required this.available,
    required this.redeemed,
  });

  final String id;
  final String title;
  final int points;
  final IconData icon;
  final bool available;
  final bool redeemed;
}

class PointsActivity {
  const PointsActivity({
    required this.title,
    required this.description,
    required this.icon,
    required this.points,
  });

  final String title;
  final String description;
  final IconData icon;
  final int points;
}

class RewardHistory {
  const RewardHistory({
    required this.title,
    required this.date,
    required this.points,
  });

  final String title;
  final String date;
  final int points;
}

