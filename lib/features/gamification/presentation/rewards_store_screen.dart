import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:conecta_app/features/gamification/presentation/rewards_history_screen.dart';

final rewardsStoreProvider = Provider<List<StoreReward>>((ref) {
  return [
    const StoreReward(
      id: 'ticket_concierto',
      title: 'Ticket Concierto',
      description: 'Entrada general para el próximo concierto en vivo',
      points: 2000,
      icon: Icons.confirmation_number,
      category: 'Eventos',
      available: true,
      stock: 10,
      color: Color(0xFFFF6B6B),
    ),
    const StoreReward(
      id: 'merch_exclusiva',
      title: 'Merch Exclusiva',
      description: 'Camiseta oficial de la radio con diseño exclusivo',
      points: 1500,
      icon: Icons.shopping_bag,
      category: 'Merchandising',
      available: true,
      stock: 25,
      color: Color(0xFF4ECDC4),
    ),
    const StoreReward(
      id: 'mes_premium',
      title: 'Mes Premium',
      description: 'Acceso premium sin anuncios por 30 días',
      points: 1000,
      icon: Icons.workspace_premium,
      category: 'Suscripciones',
      available: true,
      stock: null, // Stock ilimitado
      color: Color(0xFFFFD93D),
    ),
    const StoreReward(
      id: 'acceso_vod',
      title: 'Acceso VOD',
      description: 'Contenido exclusivo on-demand por 7 días',
      points: 750,
      icon: Icons.video_library,
      category: 'Contenido',
      available: true,
      stock: null,
      color: Color(0xFF95E1D3),
    ),
    const StoreReward(
      id: 'descuento_20',
      title: '20% Descuento',
      description: 'Cupón de descuento para la tienda online',
      points: 500,
      icon: Icons.discount,
      category: 'Descuentos',
      available: true,
      stock: 50,
      color: Color(0xFFF38181),
    ),
    const StoreReward(
      id: 'playlist_exclusiva',
      title: 'Playlist Exclusiva',
      description: 'Acceso a playlist curada por los DJs',
      points: 300,
      icon: Icons.playlist_play,
      category: 'Contenido',
      available: true,
      stock: null,
      color: Color(0xFFAA96DA),
    ),
    const StoreReward(
      id: 'meet_and_greet',
      title: 'Meet & Greet',
      description: 'Conoce a tu DJ favorito en persona',
      points: 3000,
      icon: Icons.people,
      category: 'Eventos',
      available: false,
      stock: 0,
      color: Color(0xFFFCACA3),
    ),
    const StoreReward(
      id: 'auriculares',
      title: 'Auriculares Premium',
      description: 'Auriculares inalámbricos de alta calidad',
      points: 2500,
      icon: Icons.headphones,
      category: 'Merchandising',
      available: true,
      stock: 5,
      color: Color(0xFF6C5CE7),
    ),
  ];
});

class RewardsStoreScreen extends ConsumerStatefulWidget {
  const RewardsStoreScreen({super.key});

  static const routePath = '/rewards-store';
  static const routeName = 'rewardsStore';

  @override
  ConsumerState<RewardsStoreScreen> createState() => _RewardsStoreScreenState();
}

class _RewardsStoreScreenState extends ConsumerState<RewardsStoreScreen> {
  String _selectedCategory = 'Todos';
  final List<String> _categories = [
    'Todos',
    'Eventos',
    'Merchandising',
    'Suscripciones',
    'Contenido',
    'Descuentos',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allRewards = ref.watch(rewardsStoreProvider);
    final filteredRewards = _selectedCategory == 'Todos'
        ? allRewards
        : allRewards.where((r) => r.category == _selectedCategory).toList();

    final backgroundColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.surfaceContainerLow
        : const Color(0xFFF5F3FF);

    return Scaffold(
      backgroundColor: backgroundColor,
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
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Canjear Puntos',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Historial
                        IconButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const RewardsHistoryScreen(),
                            ),
                          ),
                          icon: const CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white24,
                            child: Icon(Icons.history, color: Colors.white, size: 20),
                          ),
                        ),
                        // Puntos disponibles
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.stars, color: Colors.amber, size: 20),
                              const SizedBox(width: 4),
                              const Text(
                                '1250',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
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
                        final isSelected = category == _selectedCategory;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
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
                                  fontWeight: FontWeight.w700,
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
          // Grid de recompensas
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 210),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: filteredRewards.length,
              itemBuilder: (context, index) {
                return _buildRewardCard(context, theme, filteredRewards[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard(BuildContext context, ThemeData theme, StoreReward reward) {
    final userPoints = 1250; // En producción esto vendría del provider
    final canAfford = userPoints >= reward.points;
    final isOutOfStock = reward.stock != null && reward.stock! <= 0;
    final isAvailable = reward.available && !isOutOfStock;

    return GestureDetector(
      onTap: () => _showRewardDetailModal(context, reward, canAfford),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: !isAvailable
              ? Border.all(color: Colors.grey.withOpacity(0.3))
              : null,
          boxShadow: isAvailable
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ícono
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? reward.color.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      reward.icon,
                      color: isAvailable ? reward.color : Colors.grey,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Título
                  Text(
                    reward.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isAvailable
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Descripción
                  Expanded(
                    child: Text(
                      reward.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Puntos
                  Row(
                    children: [
                      const Icon(Icons.stars, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${reward.points}',
                        style: TextStyle(
                          color: canAfford && isAvailable ? Colors.amber : Colors.grey,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Botón
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isAvailable && canAfford
                          ? () => _showRewardDetailModal(context, reward, canAfford)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAvailable && canAfford
                            ? theme.colorScheme.primary
                            : Colors.grey.withOpacity(0.3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isOutOfStock
                            ? 'Agotado'
                            : !canAfford
                                ? 'Insuficiente'
                                : 'Canjear',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Badge de stock limitado
            if (reward.stock != null && reward.stock! > 0 && reward.stock! <= 10)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${reward.stock} left',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showRewardDetailModal(BuildContext context, StoreReward reward, bool canAfford) {
    final theme = Theme.of(context);
    final isOutOfStock = reward.stock != null && reward.stock! <= 0;
    final isAvailable = reward.available && !isOutOfStock;

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
              // Ícono
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: reward.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  reward.icon,
                  color: reward.color,
                  size: 56,
                ),
              ),
              const SizedBox(height: 16),
              // Título
              Text(
                reward.title,
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
                  color: reward.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  reward.category,
                  style: TextStyle(
                    color: reward.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Descripción
              Text(
                reward.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Costo
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.stars, color: Colors.amber, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '${reward.points} puntos',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              if (reward.stock != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Stock disponible: ${reward.stock}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              // Botón de canjear
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isAvailable && canAfford
                      ? () {
                          Navigator.pop(context);
                          _showConfirmationDialog(context, reward);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAvailable && canAfford
                        ? theme.colorScheme.primary
                        : Colors.grey.withOpacity(0.3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isOutOfStock
                        ? 'Agotado'
                        : !canAfford
                            ? 'Puntos insuficientes'
                            : 'Canjear ahora',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, StoreReward reward) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Confirmar canje?'),
        content: Text(
          '¿Estás seguro de que quieres canjear ${reward.points} puntos por "${reward.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('¡${reward.title} canjeado exitosamente!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}

class StoreReward {
  const StoreReward({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.icon,
    required this.category,
    required this.available,
    required this.color,
    this.stock,
  });

  final String id;
  final String title;
  final String description;
  final int points;
  final IconData icon;
  final String category;
  final bool available;
  final int? stock;
  final Color color;
}
