import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:conecta_app/features/scanner/presentation/audio_scanner_modal.dart';
import 'package:conecta_app/features/profile/presentation/profile_screen.dart';
import 'package:conecta_app/features/challenges/presentation/achievements_history_screen.dart';

// Provider para manejar el estado de retos
final challengesProvider = StateNotifierProvider<ChallengesController, ChallengesState>(
  (ref) => ChallengesController(),
);

class ChallengesController extends StateNotifier<ChallengesState> {
  ChallengesController() : super(ChallengesState());

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void updateProgress(String challengeId, int newProgress) {
    final progress = {...state.challengeProgress};
    progress[challengeId] = newProgress;
    state = state.copyWith(challengeProgress: progress);
  }

  void claimReward(String challengeId) {
    final claimed = {...state.claimedRewards};
    claimed.add(challengeId);
    state = state.copyWith(claimedRewards: claimed);
  }
}

class ChallengesState {
  final Map<String, int> challengeProgress;
  final Set<String> claimedRewards;
  final String selectedCategory;

  ChallengesState({
    this.challengeProgress = const {},
    this.claimedRewards = const {},
    this.selectedCategory = 'Todos',
  });

  ChallengesState copyWith({
    Map<String, int>? challengeProgress,
    Set<String>? claimedRewards,
    String? selectedCategory,
  }) {
    return ChallengesState(
      challengeProgress: challengeProgress ?? this.challengeProgress,
      claimedRewards: claimedRewards ?? this.claimedRewards,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

class ChallengesScreen extends ConsumerStatefulWidget {
  const ChallengesScreen({super.key});

  static const routePath = '/challenges';
  static const routeName = 'challenges';

  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _streakAnimationController;

  final List<Challenge> _mockChallenges = [
    // Retos Diarios - Activos por defecto
    Challenge(
      id: '1',
      title: 'Escucha 3 canciones',
      description: 'Completas hoy',
      category: 'Diario',
      difficulty: 'Fácil',
      points: 50,
      goal: 3,
      currentProgress: 2,
      iconData: Icons.music_note,
      color: const Color(0xFF4CAF50),
      expiresAt: DateTime.now().add(const Duration(hours: 18)),
      rewards: ['50 pts', '1x Entrada sorteo'],
      isHot: false,
    ),
    Challenge(
      id: '2',
      title: 'Nuevo artista',
      description: 'Descubre música nueva',
      category: 'Diario',
      difficulty: 'Fácil',
      points: 30,
      goal: 1,
      currentProgress: 0,
      iconData: Icons.explore,
      color: const Color(0xFF2196F3),
      expiresAt: DateTime.now().add(const Duration(hours: 20)),
      rewards: ['30 pts', 'Badge 🎵'],
      isHot: false,
    ),
    Challenge(
      id: '3',
      title: 'Vota en encuesta',
      description: 'Tu opinión importa',
      category: 'Diario',
      difficulty: 'Fácil',
      points: 25,
      goal: 1,
      currentProgress: 1,
      iconData: Icons.poll,
      color: const Color(0xFFFF9800),
      expiresAt: DateTime.now().add(const Duration(hours: 3)),
      rewards: ['25 pts'],
      isHot: true,
    ),

    // Retos Semanales
    Challenge(
      id: '4',
      title: 'Maratón Radio 10h',
      description: 'Escucha en vivo',
      category: 'Semanal',
      difficulty: 'Medio',
      points: 200,
      goal: 10,
      currentProgress: 7,
      iconData: Icons.radio,
      color: const Color(0xFF9C27B0),
      expiresAt: DateTime.now().add(const Duration(days: 5)),
      rewards: ['200 pts', '20% OFF eventos', 'Badge 🎧'],
      isHot: false,
    ),
    Challenge(
      id: '5',
      title: '5 géneros diferentes',
      description: 'Explora variedad',
      category: 'Semanal',
      difficulty: 'Medio',
      points: 150,
      goal: 5,
      currentProgress: 3,
      iconData: Icons.library_music,
      color: const Color(0xFFE91E63),
      expiresAt: DateTime.now().add(const Duration(days: 6)),
      rewards: ['150 pts', 'Playlist única'],
      isHot: false,
    ),
    Challenge(
      id: '6',
      title: 'Comenta 5 veces',
      description: 'Sé parte de la comunidad',
      category: 'Semanal',
      difficulty: 'Fácil',
      points: 100,
      goal: 5,
      currentProgress: 4,
      iconData: Icons.chat_bubble,
      color: const Color(0xFF00BCD4),
      expiresAt: DateTime.now().add(const Duration(days: 4)),
      rewards: ['100 pts', 'Badge 💬'],
      isHot: false,
    ),

    // Retos Mensuales
    Challenge(
      id: '7',
      title: '3 eventos del mes',
      description: 'Participa y conecta',
      category: 'Mensual',
      difficulty: 'Difícil',
      points: 500,
      goal: 3,
      currentProgress: 1,
      iconData: Icons.event,
      color: const Color(0xFFFF5722),
      expiresAt: DateTime.now().add(const Duration(days: 25)),
      rewards: ['500 pts', 'Entrada VIP', 'Badge ⭐'],
      isHot: false,
    ),
    Challenge(
      id: '8',
      title: 'Nivel 10 alcanzado',
      description: 'Conviértete en maestro',
      category: 'Mensual',
      difficulty: 'Difícil',
      points: 1000,
      goal: 10,
      currentProgress: 7,
      iconData: Icons.emoji_events,
      color: const Color(0xFFFFC107),
      expiresAt: DateTime.now().add(const Duration(days: 28)),
      rewards: ['1000 pts', 'Premium 1 mes', 'Badge 👑'],
      isHot: true,
    ),

    // Retos Especiales
    Challenge(
      id: '9',
      title: 'Madrugador 6-8 AM',
      description: '3 días seguidos',
      category: 'Especial',
      difficulty: 'Medio',
      points: 300,
      goal: 3,
      currentProgress: 0,
      iconData: Icons.wb_sunny,
      color: const Color(0xFFFFEB3B),
      expiresAt: DateTime.now().add(const Duration(days: 10)),
      rewards: ['300 pts', 'Acceso matutino'],
      isHot: false,
    ),
    Challenge(
      id: '10',
      title: 'Noctámbulo 10PM-2AM',
      description: '5 sesiones nocturnas',
      category: 'Especial',
      difficulty: 'Medio',
      points: 250,
      goal: 5,
      currentProgress: 2,
      iconData: Icons.nightlight_round,
      color: const Color(0xFF3F51B5),
      expiresAt: DateTime.now().add(const Duration(days: 15)),
      rewards: ['250 pts', 'Playlist Night'],
      isHot: false,
    ),

    // Retos Sociales
    Challenge(
      id: '11',
      title: 'Comparte con 3 amigos',
      description: 'Invita amigos a la app',
      category: 'Social',
      difficulty: 'Fácil',
      points: 100,
      goal: 3,
      currentProgress: 0,
      iconData: Icons.share,
      color: const Color(0xFF00BCD4),
      expiresAt: DateTime.now().add(const Duration(days: 7)),
      rewards: ['100 pts', 'Badge Embajador 🎖️'],
      isHot: false,
    ),
    Challenge(
      id: '12',
      title: 'Referidos Premium',
      description: '1 amigo se hace premium',
      category: 'Social',
      difficulty: 'Difícil',
      points: 500,
      goal: 1,
      currentProgress: 0,
      iconData: Icons.card_giftcard,
      color: const Color(0xFF9C27B0),
      expiresAt: DateTime.now().add(const Duration(days: 30)),
      rewards: ['500 pts', 'Premium 7 días', 'Badge VIP 👑'],
      isHot: true,
    ),
    Challenge(
      id: '13',
      title: 'Comparte tu canción',
      description: 'Comparte 5 canciones',
      category: 'Social',
      difficulty: 'Fácil',
      points: 75,
      goal: 5,
      currentProgress: 2,
      iconData: Icons.music_note,
      color: const Color(0xFF4CAF50),
      expiresAt: DateTime.now().add(const Duration(days: 3)),
      rewards: ['75 pts', 'Playlist compartida'],
      isHot: false,
    ),
  ];

  List<String> get _categories {
    return ['Todos', 'Diario', 'Semanal', 'Mensual', 'Especial', 'Social'];
  }

  @override
  void initState() {
    super.initState();
    _streakAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
      // Inicializar progreso
      final controller = ref.read(challengesProvider.notifier);
      for (var challenge in _mockChallenges) {
        controller.updateProgress(challenge.id, challenge.currentProgress);
      }

      _streakAnimationController.repeat();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _streakAnimationController.dispose();
    super.dispose();
  }

  void _showScannerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AudioScannerModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(challengesProvider);

    // Ordenar: casi completados primero, luego por expiración
    final sortedChallenges = List<Challenge>.from(_mockChallenges)
      ..sort((a, b) {
        final aProgress = (state.challengeProgress[a.id] ?? a.currentProgress) / a.goal;
        final bProgress = (state.challengeProgress[b.id] ?? b.currentProgress) / b.goal;

        // Primero los casi completados (80%+)
        if (aProgress >= 0.8 && bProgress < 0.8) return -1;
        if (bProgress >= 0.8 && aProgress < 0.8) return 1;

        // Luego por tiempo de expiración
        return a.expiresAt.compareTo(b.expiresAt);
      });

    final filteredChallenges = state.selectedCategory == 'Todos'
        ? sortedChallenges
        : sortedChallenges.where((c) => c.category == state.selectedCategory).toList();

    // Calcular racha
    final completedToday = filteredChallenges
        .where((c) => c.category == 'Diario')
        .where((c) => (state.challengeProgress[c.id] ?? c.currentProgress) >= c.goal)
        .length;

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? theme.colorScheme.surfaceContainerLow
          : const Color(0xFFF8F7FF),
      body: Column(
        children: [
          // Header con gradiente
          Container(
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
              bottom: false,
              child: Column(
                children: [
                  // Barra de navegación
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/home');
                            }
                          },
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Retos y Misiones',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Historial
                        IconButton(
                          onPressed: () => context.push(AchievementsHistoryScreen.routePath),
                          icon: const CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white24,
                            child: Icon(Icons.history, color: Colors.white, size: 20),
                          ),
                        ),
                        // Racha
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                '7 días',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _showScannerModal(context),
                          icon: const CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white24,
                            child: Icon(Icons.qr_code_scanner, color: Colors.white, size: 20),
                          ),
                        ),
                        IconButton(
                          onPressed: () => context.go(ProfileScreen.routePath),
                          icon: const CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage('https://i.pravatar.cc/80'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Stats rápidas
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: _QuickStat(
                            icon: Icons.check_circle,
                            value: '$completedToday/3',
                            label: 'Hoy',
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickStat(
                            icon: Icons.stars,
                            value: '1.2K',
                            label: 'Puntos',
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickStat(
                            icon: Icons.trending_up,
                            value: 'Nivel 7',
                            label: 'Progreso',
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Categorías
                  SizedBox(
                    height: 50,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = category == state.selectedCategory;
                        return GestureDetector(
                          onTap: () => ref.read(challengesProvider.notifier).selectCategory(category),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : Colors.white,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Contenido scrolleable
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...filteredChallenges.map((challenge) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ChallengeCardCompact(challenge: challenge),
                  )),
                  const SizedBox(height: 160),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _QuickStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeCardCompact extends ConsumerWidget {
  const _ChallengeCardCompact({required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(challengesProvider);
    final currentProgress = state.challengeProgress[challenge.id] ?? challenge.currentProgress;
    final isCompleted = currentProgress >= challenge.goal;
    final isClaimed = state.claimedRewards.contains(challenge.id);
    final progressPercent = (currentProgress / challenge.goal).clamp(0.0, 1.0);
    final isAlmostDone = progressPercent >= 0.8 && !isCompleted;
    final isSocialChallenge = challenge.category == 'Social';

    return GestureDetector(
      onTap: () {
        if (isCompleted && !isClaimed) {
          ref.read(challengesProvider.notifier).claimReward(challenge.id);
          _showRewardDialog(context, challenge);
        } else if (isSocialChallenge && !isCompleted) {
          _showShareDialog(context, challenge, ref);
        } else {
          _showChallengeDetailModal(context, challenge, currentProgress);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: isAlmostDone
              ? Border.all(color: challenge.color, width: 2)
              : null,
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
                    challenge.color.withOpacity(0.1),
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
                          backgroundColor: challenge.color.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(challenge.color),
                          strokeWidth: 4,
                        ),
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isCompleted ? challenge.color : challenge.color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCompleted ? Icons.check : challenge.iconData,
                          color: isCompleted ? Colors.white : challenge.color,
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                challenge.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (challenge.isHot)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.local_fire_department, color: Colors.white, size: 12),
                                    SizedBox(width: 2),
                                    Text(
                                      'HOT',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          challenge.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Progreso
                            Text(
                              '$currentProgress/${challenge.goal}',
                              style: TextStyle(
                                color: challenge.color,
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
                            const Spacer(),
                            // Tiempo restante
                            Icon(
                              Icons.timer,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getTimeRemaining(challenge.expiresAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Estado
                  if (isCompleted && !isClaimed)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.card_giftcard,
                        color: Colors.white,
                        size: 20,
                      ),
                    )
                  else if (isClaimed)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.grey,
                      size: 32,
                    )
                  else if (isSocialChallenge && !isCompleted)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: challenge.color,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.share,
                        color: Colors.white,
                        size: 18,
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

  String _getTimeRemaining(DateTime expiresAt) {
    final now = DateTime.now();
    final difference = expiresAt.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Expirado';
    }
  }

  void _showChallengeDetailModal(BuildContext context, Challenge challenge, int currentProgress) {
    final theme = Theme.of(context);
    final progressPercent = (currentProgress / challenge.goal).clamp(0.0, 1.0);
    final isCompleted = currentProgress >= challenge.goal;

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
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: challenge.color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCompleted ? Icons.check_circle : challenge.iconData,
                      color: challenge.color,
                      size: 56,
                    ),
                  ),
                ],
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
              // Categoría y dificultad
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: challenge.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      challenge.category,
                      style: TextStyle(
                        color: challenge.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(challenge.difficulty).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      challenge.difficulty,
                      style: TextStyle(
                        color: _getDifficultyColor(challenge.difficulty),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (challenge.isHot) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.local_fire_department, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'HOT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
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
                  color: challenge.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: challenge.color.withOpacity(0.3),
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
                            color: challenge.color,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '$currentProgress / ${challenge.goal}',
                          style: TextStyle(
                            color: challenge.color,
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
                        valueColor: AlwaysStoppedAnimation<Color>(challenge.color),
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
                        Text(
                          'Recompensas',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...challenge.rewards.map((reward) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.stars,
                            color: Colors.amber,
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              reward,
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
              const SizedBox(height: 16),
              // Tiempo restante
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Expira en ${_getTimeRemaining(challenge.expiresAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Fácil':
        return Colors.green;
      case 'Medio':
        return Colors.orange;
      case 'Difícil':
        return Colors.red;
      case 'Extremo':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showShareDialog(BuildContext context, Challenge challenge, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
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
            const SizedBox(height: 20),
            Icon(
              Icons.share,
              color: challenge.color,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              challenge.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              challenge.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _ShareButton(
                    icon: Icons.facebook,
                    label: 'Facebook',
                    color: const Color(0xFF1877F2),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Compartiendo en Facebook...')),
                      );
                      // Incrementar progreso
                      final current = ref.read(challengesProvider).challengeProgress[challenge.id] ?? challenge.currentProgress;
                      ref.read(challengesProvider.notifier).updateProgress(challenge.id, current + 1);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ShareButton(
                    icon: Icons.message,
                    label: 'WhatsApp',
                    color: const Color(0xFF25D366),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Compartiendo en WhatsApp...')),
                      );
                      final current = ref.read(challengesProvider).challengeProgress[challenge.id] ?? challenge.currentProgress;
                      ref.read(challengesProvider.notifier).updateProgress(challenge.id, current + 1);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ShareButton(
                    icon: Icons.camera_alt,
                    label: 'Instagram',
                    color: const Color(0xFFE4405F),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Compartiendo en Instagram...')),
                      );
                      final current = ref.read(challengesProvider).challengeProgress[challenge.id] ?? challenge.currentProgress;
                      ref.read(challengesProvider.notifier).updateProgress(challenge.id, current + 1);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
        ),
    );
  }

  void _showRewardDialog(BuildContext context, Challenge challenge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: challenge.color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events,
                color: challenge.color,
                size: 64,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '¡Reto Completado!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              challenge.title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Recompensas',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...challenge.rewards.map((reward) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Text(reward),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: challenge.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('¡Genial!'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Challenge {
  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.points,
    required this.goal,
    required this.currentProgress,
    required this.iconData,
    required this.color,
    required this.expiresAt,
    required this.rewards,
    required this.isHot,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final int points;
  final int goal;
  final int currentProgress;
  final IconData iconData;
  final Color color;
  final DateTime expiresAt;
  final List<String> rewards;
  final bool isHot;
}

class _ShareButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
