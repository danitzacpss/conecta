import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final rewardsHistoryProvider = Provider<List<RedeemedRewardItem>>((ref) {
  return [
    // Diciembre 2023
    RedeemedRewardItem(
      id: '1',
      title: 'Ticket Concierto',
      description: 'Entrada general canjeada para el concierto de Los Sonidos.',
      date: '15 de Diciembre',
      month: 'Diciembre 2023',
      icon: Icons.confirmation_number,
      color: const Color(0xFFFF6B6B),
      pointsSpent: 2000,
    ),
    RedeemedRewardItem(
      id: '2',
      title: 'Mes Premium',
      description: 'Acceso premium sin anuncios por 30 días.',
      date: '10 de Diciembre',
      month: 'Diciembre 2023',
      icon: Icons.workspace_premium,
      color: const Color(0xFFFFD93D),
      pointsSpent: 1000,
    ),

    // Noviembre 2023
    RedeemedRewardItem(
      id: '3',
      title: '20% Descuento',
      description: 'Cupón de descuento aplicado en la tienda online.',
      date: '28 de Noviembre',
      month: 'Noviembre 2023',
      icon: Icons.discount,
      color: const Color(0xFFF38181),
      pointsSpent: 500,
    ),
    RedeemedRewardItem(
      id: '4',
      title: 'Merch Exclusiva',
      description: 'Camiseta oficial de la radio con diseño exclusivo.',
      date: '18 de Noviembre',
      month: 'Noviembre 2023',
      icon: Icons.shopping_bag,
      color: const Color(0xFF4ECDC4),
      pointsSpent: 1500,
    ),
    RedeemedRewardItem(
      id: '5',
      title: 'Playlist Exclusiva',
      description: 'Acceso a playlist curada por los DJs.',
      date: '5 de Noviembre',
      month: 'Noviembre 2023',
      icon: Icons.playlist_play,
      color: const Color(0xFFAA96DA),
      pointsSpent: 300,
    ),

    // Octubre 2023
    RedeemedRewardItem(
      id: '6',
      title: 'Acceso VOD',
      description: 'Contenido exclusivo on-demand por 7 días.',
      date: '22 de Octubre',
      month: 'Octubre 2023',
      icon: Icons.video_library,
      color: const Color(0xFF95E1D3),
      pointsSpent: 750,
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
    final groupedItems = <String, List<RedeemedRewardItem>>{};
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
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
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
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 210),
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
                    ...items.map((item) => _buildHistoryItem(context, theme, item as RedeemedRewardItem)),
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

  Widget _buildHistoryItem(BuildContext context, ThemeData theme, RedeemedRewardItem item) {
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.stars, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${item.pointsSpent} pts',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.amber,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Canjeado',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RedeemedRewardItem {
  const RedeemedRewardItem({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.month,
    required this.icon,
    required this.color,
    required this.pointsSpent,
  });

  final String id;
  final String title;
  final String description;
  final String date;
  final String month;
  final IconData icon;
  final Color color;
  final int pointsSpent;
}