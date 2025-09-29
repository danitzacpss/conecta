import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final rewardsHistoryProvider = Provider<List<RewardHistoryItem>>((ref) {
  return [
    // Noviembre 2023
    RewardHistoryItem(
      id: '1',
      title: '100 Puntos',
      description: 'Ganados por participar en la encuesta "Género musical favorito".',
      date: '25 de Noviembre',
      month: 'Noviembre 2023',
      icon: Icons.star,
      color: Colors.amber,
      points: 100,
    ),
    RewardHistoryItem(
      id: '2',
      title: 'Insignia "Súper Fan"',
      description: 'Desbloqueada por escuchar más de 20 horas de radio.',
      date: '22 de Noviembre',
      month: 'Noviembre 2023',
      icon: Icons.shield,
      color: Colors.blue,
      points: null,
    ),
    RewardHistoryItem(
      id: '3',
      title: 'Acceso Exclusivo',
      description: 'Acceso anticipado al nuevo podcast "Historias de la Ciudad".',
      date: '18 de Noviembre',
      month: 'Noviembre 2023',
      icon: Icons.all_inclusive,
      color: Colors.green,
      points: null,
    ),
    RewardHistoryItem(
      id: '4',
      title: '50 Puntos',
      description: 'Por completar tu perfil de usuario.',
      date: '15 de Noviembre',
      month: 'Noviembre 2023',
      icon: Icons.star,
      color: Colors.amber,
      points: 50,
    ),
    RewardHistoryItem(
      id: '5',
      title: 'Cupón de Descuento',
      description: '15% de descuento en la tienda de merchandising.',
      date: '10 de Noviembre',
      month: 'Noviembre 2023',
      icon: Icons.local_offer,
      color: Colors.red,
      points: null,
    ),

    // Octubre 2023
    RewardHistoryItem(
      id: '6',
      title: 'Entrada a Concierto',
      description: 'Ganaste una entrada para el concierto de "Los Sonidos".',
      date: '28 de Octubre',
      month: 'Octubre 2023',
      icon: Icons.mic,
      color: Colors.purple,
      points: null,
    ),
    RewardHistoryItem(
      id: '7',
      title: '200 Puntos',
      description: 'Bonificación por alcanzar el nivel 5.',
      date: '20 de Octubre',
      month: 'Octubre 2023',
      icon: Icons.star,
      color: Colors.amber,
      points: 200,
    ),
    RewardHistoryItem(
      id: '8',
      title: 'Acceso VOD Premium',
      description: 'Acceso a contenido premium por 30 días.',
      date: '15 de Octubre',
      month: 'Octubre 2023',
      icon: Icons.video_library,
      color: Colors.indigo,
      points: null,
    ),
  ];
});

class RewardsHistoryScreen extends ConsumerWidget {
  const RewardsHistoryScreen({super.key});

  static const routePath = '/rewards-history';
  static const routeName = 'rewardsHistory';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyItems = ref.watch(rewardsHistoryProvider);
    final theme = Theme.of(context);

    // Agrupar items por mes
    final groupedItems = <String, List<RewardHistoryItem>>{};
    for (final item in historyItems) {
      if (!groupedItems.containsKey(item.month)) {
        groupedItems[item.month] = [];
      }
      groupedItems[item.month]!.add(item);
    }

    final backgroundColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.surfaceContainerLow
        : const Color(0xFFF5F3FF); // Lila muy claro

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Header con gradiente y buscador integrado
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: theme.brightness == Brightness.dark
                  ? [
                      theme.colorScheme.primary.withOpacity(0.2),
                      theme.colorScheme.primary.withOpacity(0.4),
                    ]
                  : [
                      theme.colorScheme.primary.withOpacity(0.3),
                      theme.colorScheme.primary.withOpacity(0.5),
                    ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  children: [
                    // Fila del título y botón atrás
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Historial de Recompensas',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Barra de búsqueda
                    Container(
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? theme.colorScheme.surface.withOpacity(0.9)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Buscar en recompensas',
                          hintStyle: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: theme.brightness == Brightness.dark
                              ? theme.colorScheme.surface.withOpacity(0.9)
                              : Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Lista de historial
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: groupedItems.length,
              itemBuilder: (context, index) {
                final month = groupedItems.keys.elementAt(index);
                final items = groupedItems[month]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header del mes
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        month,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    // Items del mes
                    ...items.map((item) => _buildHistoryItem(context, theme, item)),
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, ThemeData theme, RewardHistoryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.icon,
              color: item.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Contenido
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      item.date,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
                if (item.points != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '+${item.points} puntos',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: item.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RewardHistoryItem {
  const RewardHistoryItem({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.month,
    required this.icon,
    required this.color,
    this.points,
  });

  final String id;
  final String title;
  final String description;
  final String date;
  final String month;
  final IconData icon;
  final Color color;
  final int? points;
}