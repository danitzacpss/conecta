import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:conecta_app/features/gamification/presentation/gamification_screen.dart';

/// Provider que calcula las estadísticas del usuario basado en su actividad de gamificación
final userStatsProvider = Provider<UserStats>((ref) {
  final gamification = ref.watch(gamificationProvider);

  // Calcular tiempo escuchado basado en el progreso de retos
  final listenedMinutes = _calculateListenedTime(gamification);

  // Calcular racha de días
  final streak = _calculateStreak(gamification);

  // Calcular ranking basado en puntos
  final ranking = _calculateRanking(gamification.points);

  return UserStats(
    points: gamification.points,
    listenedMinutesToday: listenedMinutes,
    streakDays: streak,
    ranking: ranking,
  );
});

int _calculateListenedTime(MockGamificationData data) {
  // Calcular basado en el progreso de retos de escucha
  int totalMinutes = 0;

  for (final challenge in data.dailyChallenges) {
    if (challenge.title.contains('Escucha')) {
      // Cada canción = ~4 minutos
      totalMinutes += (challenge.progress * 4).toInt();
    }
  }

  // Agregar tiempo base si hay actividad
  if (totalMinutes > 0) {
    totalMinutes += 142; // Base: 2h 22m
  }

  return totalMinutes;
}

int _calculateStreak(MockGamificationData data) {
  // Calcular racha basado en retos diarios completados
  int completedDaily = data.dailyChallenges.where((c) => c.completed).length;

  // Por cada reto completado hoy, añadir a la racha base
  int baseStreak = 5; // racha base
  if (completedDaily > 0) {
    baseStreak += completedDaily;
  }

  return baseStreak;
}

int _calculateRanking(int points) {
  // Simular ranking basado en puntos
  // Más puntos = mejor ranking (número más bajo)
  if (points >= 2000) return 1;
  if (points >= 1500) return 5;
  if (points >= 1000) return 12;
  if (points >= 500) return 25;
  if (points >= 100) return 50;
  return 100;
}

class UserStats {
  const UserStats({
    required this.points,
    required this.listenedMinutesToday,
    required this.streakDays,
    required this.ranking,
  });

  final int points;
  final int listenedMinutesToday; // en minutos
  final int streakDays;
  final int ranking;

  String get formattedListeningTime {
    final hours = listenedMinutesToday ~/ 60;
    final minutes = listenedMinutesToday % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
