import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Provider para el historial de logros
final achievementsHistoryProvider = Provider<AchievementsHistory>((ref) {
  return AchievementsHistory(
    completedChallenges: [
      CompletedChallenge(
        id: '1',
        title: 'Escucha 3 canciones',
        category: 'Diario',
        completedAt: DateTime.now().subtract(const Duration(hours: 2)),
        pointsEarned: 50,
        rewards: ['50 pts', '1x Entrada sorteo'],
        iconData: Icons.music_note,
        color: const Color(0xFF4CAF50),
      ),
      CompletedChallenge(
        id: '2',
        title: 'Vota en encuesta',
        category: 'Diario',
        completedAt: DateTime.now().subtract(const Duration(hours: 5)),
        pointsEarned: 25,
        rewards: ['25 pts'],
        iconData: Icons.poll,
        color: const Color(0xFFFF9800),
      ),
      CompletedChallenge(
        id: '3',
        title: 'Nuevo artista',
        category: 'Diario',
        completedAt: DateTime.now().subtract(const Duration(days: 1)),
        pointsEarned: 30,
        rewards: ['30 pts', 'Badge 🎵'],
        iconData: Icons.explore,
        color: const Color(0xFF2196F3),
      ),
      CompletedChallenge(
        id: '4',
        title: 'Comenta 5 veces',
        category: 'Semanal',
        completedAt: DateTime.now().subtract(const Duration(days: 2)),
        pointsEarned: 100,
        rewards: ['100 pts', 'Badge 💬'],
        iconData: Icons.chat_bubble,
        color: const Color(0xFF00BCD4),
      ),
      CompletedChallenge(
        id: '5',
        title: '5 géneros diferentes',
        category: 'Semanal',
        completedAt: DateTime.now().subtract(const Duration(days: 5)),
        pointsEarned: 150,
        rewards: ['150 pts', 'Playlist única'],
        iconData: Icons.library_music,
        color: const Color(0xFFE91E63),
      ),
      CompletedChallenge(
        id: '6',
        title: 'Maratón Radio 10h',
        category: 'Semanal',
        completedAt: DateTime.now().subtract(const Duration(days: 8)),
        pointsEarned: 200,
        rewards: ['200 pts', '20% OFF eventos', 'Badge 🎧'],
        iconData: Icons.radio,
        color: const Color(0xFF9C27B0),
      ),
      CompletedChallenge(
        id: '7',
        title: '3 eventos del mes',
        category: 'Mensual',
        completedAt: DateTime.now().subtract(const Duration(days: 15)),
        pointsEarned: 500,
        rewards: ['500 pts', 'Entrada VIP', 'Badge ⭐'],
        iconData: Icons.event,
        color: const Color(0xFFFF5722),
      ),
    ],
    badges: [
      Badge(
        id: 'explorer',
        name: 'Explorador',
        description: 'Descubriste 10 artistas nuevos',
        iconData: Icons.explore,
        earnedAt: DateTime.now().subtract(const Duration(days: 3)),
        color: const Color(0xFF2196F3),
        rarity: 'Común',
        isUnlocked: true,
      ),
      Badge(
        id: 'social',
        name: 'Sociable',
        description: 'Comentaste en 20 programas',
        iconData: Icons.chat_bubble,
        earnedAt: DateTime.now().subtract(const Duration(days: 7)),
        color: const Color(0xFF00BCD4),
        rarity: 'Común',
        isUnlocked: true,
      ),
      Badge(
        id: 'listener',
        name: 'Oyente Fiel',
        description: 'Escuchaste 50 horas de radio',
        iconData: Icons.headphones,
        earnedAt: DateTime.now().subtract(const Duration(days: 12)),
        color: const Color(0xFF9C27B0),
        rarity: 'Raro',
        isUnlocked: true,
      ),
      Badge(
        id: 'event_goer',
        name: 'Asistente',
        description: 'Participaste en 5 eventos',
        iconData: Icons.event,
        earnedAt: DateTime.now().subtract(const Duration(days: 20)),
        color: const Color(0xFFFF5722),
        rarity: 'Épico',
        isUnlocked: true,
      ),
      // Badges bloqueados
      Badge(
        id: 'night_owl',
        name: 'Búho Nocturno',
        description: 'Escucha 20 horas entre 10PM-2AM',
        iconData: Icons.nightlight_round,
        color: const Color(0xFF3F51B5),
        rarity: 'Raro',
        isUnlocked: false,
      ),
      Badge(
        id: 'early_bird',
        name: 'Madrugador',
        description: 'Escucha 15 horas entre 6AM-8AM',
        iconData: Icons.wb_sunny,
        color: const Color(0xFFFFEB3B),
        rarity: 'Raro',
        isUnlocked: false,
      ),
      Badge(
        id: 'super_fan',
        name: 'Super Fan',
        description: 'Asiste a 20 eventos en vivo',
        iconData: Icons.star,
        color: const Color(0xFFFF9800),
        rarity: 'Épico',
        isUnlocked: false,
      ),
      Badge(
        id: 'legend',
        name: 'Leyenda',
        description: 'Alcanza el nivel 50',
        iconData: Icons.workspace_premium,
        color: const Color(0xFFFFD700),
        rarity: 'Legendario',
        isUnlocked: false,
      ),
      Badge(
        id: 'influencer',
        name: 'Influencer',
        description: 'Comparte con 50 amigos',
        iconData: Icons.share,
        color: const Color(0xFF00BCD4),
        rarity: 'Épico',
        isUnlocked: false,
      ),
      Badge(
        id: 'collector',
        name: 'Coleccionista',
        description: 'Completa 100 retos',
        iconData: Icons.collections,
        color: const Color(0xFF9C27B0),
        rarity: 'Épico',
        isUnlocked: false,
      ),
    ],
    totalPointsEarned: 12850,
    longestStreak: 15,
    currentStreak: 7,
    totalChallengesCompleted: 47,
    currentLevel: 7,
  );
});

class AchievementsHistoryScreen extends ConsumerStatefulWidget {
  const AchievementsHistoryScreen({super.key});

  static const routePath = '/achievements-history';
  static const routeName = 'achievementsHistory';

  @override
  ConsumerState<AchievementsHistoryScreen> createState() => _AchievementsHistoryScreenState();
}

class _AchievementsHistoryScreenState extends ConsumerState<AchievementsHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final history = ref.watch(achievementsHistoryProvider);

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? theme.colorScheme.surfaceContainerLow
          : const Color(0xFFF8F7FF),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 420,
              floating: false,
              pinned: true,
              backgroundColor: theme.colorScheme.primary,
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              title: Text(
                'Historial de Logros',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.8),
                        theme.colorScheme.secondary.withOpacity(0.6),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        const SizedBox(height: 60),
                  // Nivel del usuario
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
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
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${history.currentLevel}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 36,
                                          fontWeight: FontWeight.w900,
                                          height: 1,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Padding(
                                        padding: EdgeInsets.only(bottom: 4),
                                        child: Text(
                                          '/ 100',
                                          style: TextStyle(
                                            color: Colors.white60,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.military_tech,
                                  color: Colors.amber,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Progreso al nivel 8',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Stack(
                                      children: [
                                        Container(
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                        FractionallySizedBox(
                                          widthFactor: 0.65,
                                          child: Container(
                                            height: 8,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [Colors.amber, Colors.orange],
                                              ),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                '650/1000 XP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Estadísticas generales
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.emoji_events,
                            value: '${history.totalChallengesCompleted}',
                            label: 'Completados',
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.local_fire_department,
                            value: '${history.longestStreak}',
                            label: 'Racha Máx',
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.stars,
                            value: '${(history.totalPointsEarned / 1000).toStringAsFixed(1)}K',
                            label: 'Puntos',
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ),
                      ],
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: Colors.white,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'Retos'),
                      Tab(text: 'Logros'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildChallengesTab(theme, history),
            _buildBadgesTab(theme, history),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengesTab(ThemeData theme, AchievementsHistory history) {
    // Agrupar por periodo
    final now = DateTime.now();
    final today = history.completedChallenges.where((c) {
      return c.completedAt.year == now.year &&
          c.completedAt.month == now.month &&
          c.completedAt.day == now.day;
    }).toList();

    final thisWeek = history.completedChallenges.where((c) {
      final diff = now.difference(c.completedAt).inDays;
      return diff > 0 && diff <= 7;
    }).toList();

    final thisMonth = history.completedChallenges.where((c) {
      final diff = now.difference(c.completedAt).inDays;
      return diff > 7 && diff <= 30;
    }).toList();

    final older = history.completedChallenges.where((c) {
      final diff = now.difference(c.completedAt).inDays;
      return diff > 30;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (today.isNotEmpty) ...[
            _SectionHeader(title: 'Hoy', count: today.length),
            const SizedBox(height: 12),
            ...today.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CompletedChallengeCard(challenge: c),
            )),
            const SizedBox(height: 24),
          ],
          if (thisWeek.isNotEmpty) ...[
            _SectionHeader(title: 'Esta semana', count: thisWeek.length),
            const SizedBox(height: 12),
            ...thisWeek.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CompletedChallengeCard(challenge: c),
            )),
            const SizedBox(height: 24),
          ],
          if (thisMonth.isNotEmpty) ...[
            _SectionHeader(title: 'Este mes', count: thisMonth.length),
            const SizedBox(height: 12),
            ...thisMonth.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CompletedChallengeCard(challenge: c),
            )),
            const SizedBox(height: 24),
          ],
          if (older.isNotEmpty) ...[
            _SectionHeader(title: 'Anteriores', count: older.length),
            const SizedBox(height: 12),
            ...older.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CompletedChallengeCard(challenge: c),
            )),
          ],
          const SizedBox(height: 160),
        ],
      ),
    );
  }

  Widget _buildBadgesTab(ThemeData theme, AchievementsHistory history) {
    final unlockedBadges = history.badges.where((b) => b.isUnlocked).toList();
    final lockedBadges = history.badges.where((b) => !b.isUnlocked).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Desbloqueados
        Row(
          children: [
            Text(
              'Desbloqueados',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${unlockedBadges.length}',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate((unlockedBadges.length / 2).ceil(), (rowIndex) {
          final startIndex = rowIndex * 2;
          final endIndex = (startIndex + 2).clamp(0, unlockedBadges.length);
          final rowBadges = unlockedBadges.sublist(startIndex, endIndex);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: _BadgeCard(badge: rowBadges[0]),
                ),
                if (rowBadges.length > 1) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _BadgeCard(badge: rowBadges[1]),
                  ),
                ] else
                  const Expanded(child: SizedBox()),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        // Bloqueados
        Row(
          children: [
            Text(
              'Por desbloquear',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${lockedBadges.length}',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate((lockedBadges.length / 2).ceil(), (rowIndex) {
          final startIndex = rowIndex * 2;
          final endIndex = (startIndex + 2).clamp(0, lockedBadges.length);
          final rowBadges = lockedBadges.sublist(startIndex, endIndex);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: _BadgeCard(badge: rowBadges[0]),
                ),
                if (rowBadges.length > 1) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _BadgeCard(badge: rowBadges[1]),
                  ),
                ] else
                  const Expanded(child: SizedBox()),
              ],
            ),
          );
        }),
        const SizedBox(height: 200),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _CompletedChallengeCard extends StatelessWidget {
  final CompletedChallenge challenge;

  const _CompletedChallengeCard({required this.challenge});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
      child: Row(
        children: [
          // Ícono completado
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: challenge.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              challenge.iconData,
              color: challenge.color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        challenge.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: challenge.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        challenge.category,
                        style: TextStyle(
                          color: challenge.color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(challenge.completedAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Recompensas
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: challenge.rewards.map((reward) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.amber.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.card_giftcard,
                          size: 12,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          reward,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.amber,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inHours < 24) {
      return 'Hace ${diff.inHours}h';
    } else if (diff.inDays < 7) {
      return 'Hace ${diff.inDays}d';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _BadgeCard extends StatelessWidget {
  final Badge badge;

  const _BadgeCard({required this.badge});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLocked = !badge.isUnlocked;

    return GestureDetector(
      onTap: () => _showBadgeDetailModal(context, badge),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isLocked
              ? theme.colorScheme.surface.withOpacity(0.5)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: isLocked
              ? Border.all(color: theme.colorScheme.outline.withOpacity(0.3), width: 1)
              : null,
          boxShadow: isLocked ? [] : [
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
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isLocked
                      ? Colors.grey.withOpacity(0.2)
                      : badge.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  badge.iconData,
                  color: isLocked
                      ? Colors.grey
                      : badge.color,
                  size: 40,
                ),
              ),
              if (isLocked)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            badge.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: isLocked
                  ? theme.colorScheme.onSurfaceVariant
                  : null,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getRarityColor(badge.rarity).withOpacity(isLocked ? 0.1 : 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badge.rarity,
              style: TextStyle(
                color: isLocked
                    ? _getRarityColor(badge.rarity).withOpacity(0.5)
                    : _getRarityColor(badge.rarity),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            badge.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isLocked
                  ? theme.colorScheme.onSurfaceVariant.withOpacity(0.5)
                  : theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (!isLocked) ...[
            const SizedBox(height: 8),
            Text(
              _formatDate(badge.earnedAt!),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
      ),
    );
  }

  void _showBadgeDetailModal(BuildContext context, Badge badge) {
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class AchievementsHistory {
  final List<CompletedChallenge> completedChallenges;
  final List<Badge> badges;
  final int totalPointsEarned;
  final int longestStreak;
  final int currentStreak;
  final int totalChallengesCompleted;
  final int currentLevel;

  AchievementsHistory({
    required this.completedChallenges,
    required this.badges,
    required this.totalPointsEarned,
    required this.longestStreak,
    required this.currentStreak,
    required this.totalChallengesCompleted,
    required this.currentLevel,
  });
}

class CompletedChallenge {
  final String id;
  final String title;
  final String category;
  final DateTime completedAt;
  final int pointsEarned;
  final List<String> rewards;
  final IconData iconData;
  final Color color;

  CompletedChallenge({
    required this.id,
    required this.title,
    required this.category,
    required this.completedAt,
    required this.pointsEarned,
    required this.rewards,
    required this.iconData,
    required this.color,
  });
}

class Badge {
  final String id;
  final String name;
  final String description;
  final IconData iconData;
  final DateTime? earnedAt;
  final Color color;
  final String rarity;
  final bool isUnlocked;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconData,
    this.earnedAt,
    required this.color,
    required this.rarity,
    this.isUnlocked = false,
  });
}
