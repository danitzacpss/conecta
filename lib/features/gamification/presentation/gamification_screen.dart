import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:conecta_app/core/localization/l10n.dart';
import 'package:conecta_app/features/home/presentation/widgets/section_header.dart';
import 'package:conecta_app/features/profile/presentation/profile_screen.dart';
import 'package:conecta_app/shared/widgets/unified_header.dart';
import 'package:conecta_app/features/gamification/presentation/rewards_history_screen.dart';
import 'package:conecta_app/features/radio/presentation/radio_player_screen.dart';

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
        title: 'Reto del Día: Escucha Activa',
        description: 'Escucha 30 mins seguidos y gana +25 pts.',
        icon: Icons.local_fire_department,
        points: 25,
        completed: false,
      ),
    ],
    missions: [
      const Mission(
        title: 'Misión: Creador de Listas',
        description: 'Crea 3 playlists nuevas y obtén +50 pts.',
        icon: Icons.playlist_add,
        points: 50,
        completed: false,
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
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            UnifiedHeader(
              title: 'Recompensas',
              hasScanner: true,
              onScannerTap: () => _showScannerModal(context),
              additionalContent: _buildWelcomeCard(context, theme, data),
            ),
            _buildBody(context, theme, data),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, ThemeData theme, MockGamificationData data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? theme.colorScheme.surface.withOpacity(0.9)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: Icon(
              Icons.person,
              size: 35,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '¡Felicidades, Alex!',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Has acumulado ${data.points} puntos',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: (1500 - data.pointsToNext) / 1500,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nivel ${data.userLevel}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${data.pointsToNext} pts para siguiente nivel',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, MockGamificationData data) {
    return Container(
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recompensas',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _showScannerModal(context),
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.qr_code_scanner, color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
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
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        size: 35,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Nivel ${data.userLevel}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '¡Felicidades, Alex!',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Has acumulado ${data.points} puntos',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: (1500 - data.pointsToNext) / 1500,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${data.pointsToNext} puntos para el siguiente nivel',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
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

  Widget _buildBody(BuildContext context, ThemeData theme, MockGamificationData data) {
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChallengesSection(context, theme, data),
            const SizedBox(height: 24),
            _buildRewardsSection(context, theme, data),
            const SizedBox(height: 24),
            _buildPointsActivitiesSection(context, theme, data),
            const SizedBox(height: 24),
            _buildHistorySection(context, theme, data),
            const SizedBox(height: 100), // Extra space for bottom navigation
          ],
        ),
      ),
    );
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
              onPressed: () {},
              child: Text(
                'Ver todo',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...data.dailyChallenges.map((challenge) => _buildChallengeCard(theme, challenge)),
        ...data.missions.map((mission) => _buildMissionCard(theme, mission)),
      ],
    );
  }

  Widget _buildChallengeCard(ThemeData theme, DailyChallenge challenge) {
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
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              challenge.icon,
              color: Colors.red,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  challenge.description,
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

  Widget _buildMissionCard(ThemeData theme, Mission mission) {
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
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              mission.icon,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  mission.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Ir a compartir'),
          ),
        ],
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
              'Recompensas Disponibles',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Ver todo',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
          children: data.rewards.map((reward) => _buildRewardCard(theme, reward)).toList(),
        ),
      ],
    );
  }

  Widget _buildRewardCard(ThemeData theme, Reward reward) {
    return Container(
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: reward.redeemed
                  ? Colors.grey.withOpacity(0.1)
                  : theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              reward.icon,
              size: 32,
              color: reward.redeemed
                  ? Colors.grey
                  : theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            reward.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '${reward.points} pts',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(reward.redeemed ? 'Canjeado' : 'Canjear'),
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

  Widget _buildHistorySection(BuildContext context, ThemeData theme, MockGamificationData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Historial de Recompensas',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RewardsHistoryScreen(),
                ),
              ),
              child: Text(
                'Ver todo',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...data.rewardsHistory.map((history) => _buildHistoryCard(theme, history)),
      ],
    );
  }

  Widget _buildHistoryCard(ThemeData theme, RewardHistory history) {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  history.date,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${history.points} pts',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.w600,
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
  });

  final String title;
  final String description;
  final IconData icon;
  final int points;
  final bool completed;
}

class Mission {
  const Mission({
    required this.title,
    required this.description,
    required this.icon,
    required this.points,
    required this.completed,
  });

  final String title;
  final String description;
  final IconData icon;
  final int points;
  final bool completed;
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

class AudioScannerModal extends StatefulWidget {
  const AudioScannerModal({super.key});

  @override
  State<AudioScannerModal> createState() => _AudioScannerModalState();
}

class _AudioScannerModalState extends State<AudioScannerModal> {
  RadioStation? selectedRadio;
  bool isScanning = false;
  bool scanCompleted = false;

  // Simulación de miles de radios
  final List<RadioStation> allRadioStations = [
    // Radios principales
    RadioStation(id: '1', name: 'Conecta Radio', frequency: '105.7 FM', country: 'Chile'),
    RadioStation(id: '2', name: 'Rock FM', frequency: '102.3 FM', country: 'España'),
    RadioStation(id: '3', name: 'Pop Station', frequency: '98.5 FM', country: 'México'),
    RadioStation(id: '4', name: 'Dance Radio', frequency: '107.1 FM', country: 'Argentina'),
    RadioStation(id: '5', name: 'Jazz & Blues', frequency: '104.2 FM', country: 'Estados Unidos'),

    // Más radios simuladas
    RadioStation(id: '6', name: 'Radio Nacional', frequency: '96.7 FM', country: 'España'),
    RadioStation(id: '7', name: 'Los 40 Principales', frequency: '93.9 FM', country: 'España'),
    RadioStation(id: '8', name: 'Cadena SER', frequency: '90.4 FM', country: 'España'),
    RadioStation(id: '9', name: 'Kiss FM', frequency: '102.7 FM', country: 'España'),
    RadioStation(id: '10', name: 'Europa FM', frequency: '91.3 FM', country: 'España'),
    RadioStation(id: '11', name: 'Radio Marca', frequency: '103.2 FM', country: 'España'),
    RadioStation(id: '12', name: 'Onda Cero', frequency: '89.6 FM', country: 'España'),
    RadioStation(id: '13', name: 'COPE', frequency: '100.7 FM', country: 'España'),
    RadioStation(id: '14', name: 'Radio Clásica', frequency: '96.5 FM', country: 'España'),
    RadioStation(id: '15', name: 'Radio 3', frequency: '99.3 FM', country: 'España'),

    // Radios internacionales
    RadioStation(id: '16', name: 'BBC Radio 1', frequency: '97.6 FM', country: 'Reino Unido'),
    RadioStation(id: '17', name: 'NPR', frequency: '88.5 FM', country: 'Estados Unidos'),
    RadioStation(id: '18', name: 'Radio France', frequency: '105.3 FM', country: 'Francia'),
    RadioStation(id: '19', name: 'Radio Cooperativa', frequency: '93.3 FM', country: 'Chile'),
    RadioStation(id: '20', name: 'Radio Mitre', frequency: '790 AM', country: 'Argentina'),
    RadioStation(id: '21', name: 'W Radio', frequency: '99.9 FM', country: 'México'),
    RadioStation(id: '22', name: 'Radio Caracol', frequency: '1260 AM', country: 'Colombia'),
    RadioStation(id: '23', name: 'Radio Globo', frequency: '98.3 FM', country: 'Brasil'),
    RadioStation(id: '24', name: 'Radio Monte Carlo', frequency: '95.1 FM', country: 'Uruguay'),
    RadioStation(id: '25', name: 'Radio Nacional', frequency: '870 AM', country: 'Perú'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(theme),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildScannerSection(theme),
                  const SizedBox(height: 24),
                  _buildRadioSelectorButton(theme),
                  const SizedBox(height: 24),
                  _buildScanButton(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.8),
            theme.colorScheme.secondary.withOpacity(0.6),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Escanear Audio',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Identifica la canción que está sonando',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScannerSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.2),
                  theme.colorScheme.secondary.withOpacity(0.1),
                ],
              ),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              child: Icon(
                isScanning ? Icons.graphic_eq : Icons.mic,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isScanning
              ? 'Escuchando...'
              : scanCompleted
                ? '¡Canción identificada!'
                : 'Presiona para empezar',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (scanCompleted)
            Column(
              children: [
                const SizedBox(height: 8),
                Text(
                  '"Bohemian Rhapsody" - Queen',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Detectado en ${selectedRadio?.name ?? "Radio seleccionada"}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildRadioSelectorButton(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona la radio',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _showRadioSelector(context, theme),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selectedRadio != null
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
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
                    color: selectedRadio != null
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.radio,
                    color: selectedRadio != null
                      ? theme.colorScheme.primary
                      : Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: selectedRadio != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedRadio!.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${selectedRadio!.frequency} • ${selectedRadio!.country}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Toca para seleccionar una radio',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showRadioSelector(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RadioSelectorModal(
        radioStations: allRadioStations,
        selectedRadio: selectedRadio,
        onRadioSelected: (radio) {
          setState(() => selectedRadio = radio);
          Navigator.of(context).pop();
          context.go(RadioPlayerScreen.routePath);
        },
      ),
    );
  }

  Widget _buildScanButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: selectedRadio != null && !isScanning ? _startScan : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isScanning)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            else
              const Icon(Icons.qr_code_scanner, size: 20),
            const SizedBox(width: 8),
            Text(
              isScanning
                ? 'Escaneando...'
                : scanCompleted
                  ? 'Escanear de nuevo'
                  : 'Iniciar escaneo',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startScan() {
    setState(() {
      isScanning = true;
      scanCompleted = false;
    });

    // Simular escaneo
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          isScanning = false;
          scanCompleted = true;
        });
      }
    });
  }
}

class RadioSelectorModal extends StatefulWidget {
  const RadioSelectorModal({
    super.key,
    required this.radioStations,
    required this.selectedRadio,
    required this.onRadioSelected,
  });

  final List<RadioStation> radioStations;
  final RadioStation? selectedRadio;
  final Function(RadioStation) onRadioSelected;

  @override
  State<RadioSelectorModal> createState() => _RadioSelectorModalState();
}

class _RadioSelectorModalState extends State<RadioSelectorModal> {
  final TextEditingController _searchController = TextEditingController();
  List<RadioStation> filteredRadios = [];

  @override
  void initState() {
    super.initState();
    filteredRadios = widget.radioStations;
    _searchController.addListener(_filterRadios);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterRadios);
    _searchController.dispose();
    super.dispose();
  }

  void _filterRadios() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredRadios = widget.radioStations.where((radio) {
        return radio.name.toLowerCase().contains(query) ||
               radio.country.toLowerCase().contains(query) ||
               radio.frequency.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(theme),
          _buildSearchBar(theme),
          Expanded(
            child: _buildRadioList(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.8),
            theme.colorScheme.secondary.withOpacity(0.6),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.radio,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seleccionar Radio',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Busca entre miles de emisoras',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar radio, país o frecuencia...',
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                },
                icon: Icon(
                  Icons.clear,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: theme.colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildRadioList(ThemeData theme) {
    if (filteredRadios.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron radios',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta con otro término de búsqueda',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filteredRadios.length,
      itemBuilder: (context, index) {
        final radio = filteredRadios[index];
        final isSelected = widget.selectedRadio?.id == radio.id;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => widget.onRadioSelected(radio),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                  ? theme.colorScheme.primary.withOpacity(0.1)
                  : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                  width: 2,
                ),
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
                      color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.radio,
                      color: isSelected
                        ? Colors.white
                        : theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          radio.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '${radio.frequency} • ${radio.country}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class RadioStation {
  const RadioStation({
    required this.id,
    required this.name,
    required this.frequency,
    required this.country,
  });

  final String id;
  final String name;
  final String frequency;
  final String country;
}
