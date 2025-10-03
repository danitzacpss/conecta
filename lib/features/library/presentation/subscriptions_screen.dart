import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:conecta_app/features/home/domain/entities/media_item.dart';
import 'package:conecta_app/features/player/presentation/providers/now_playing_provider.dart';
import 'package:conecta_app/features/radio/presentation/radio_profile_screen.dart';

class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({super.key});

  static const routePath = '/subscriptions';
  static const routeName = 'subscriptions';

  @override
  ConsumerState<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RadioSubscription> _filterRadios(List<RadioSubscription> radios) {
    if (_searchQuery.isEmpty) {
      return radios;
    }
    return radios.where((radio) {
      return radio.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subscriptions = ref.watch(subscribedRadiosProvider);
    final filteredRadios = _filterRadios(subscriptions);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: theme.colorScheme.surface,
            elevation: 0,
            surfaceTintColor: theme.colorScheme.surface,
            shadowColor: Colors.black.withOpacity(0.1),
            forceElevated: true,
            leading: IconButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
              icon: const Icon(Icons.arrow_back),
            ),
            title: const Text('Suscripciones'),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                      _searchQuery = '';
                    }
                  });
                },
                icon: Icon(_isSearching ? Icons.close : Icons.search),
              ),
            ],
          ),

          // Buscador fijo (solo visible cuando está activo)
          if (_isSearching)
            SliverPersistentHeader(
              pinned: true,
              delegate: _SearchBarDelegate(
                searchController: _searchController,
                theme: theme,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

          // Grid de radios suscritas
          if (subscriptions.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.radio_outlined,
                      size: 80,
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tienes suscripciones',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Suscríbete a radios para verlas aquí',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (filteredRadios.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 80,
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
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 210),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _LiveRadioCard(item: filteredRadios[index]);
                  },
                  childCount: filteredRadios.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Card de radio en vivo (similar al de home_screen)
class _LiveRadioCard extends ConsumerWidget {
  const _LiveRadioCard({required this.item});

  final RadioSubscription item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final nowPlayingState = ref.read(nowPlayingProvider);

    return GestureDetector(
      onTap: () {
        // Reproducir la radio (usamos el item actual de nowPlaying)
        ref.read(nowPlayingProvider.notifier).play(nowPlayingState.item);
        context.push(RadioProfileScreen.routePath);
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        clipBehavior: Clip.none,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Círculo de la radio con animación
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Sombra circular de fondo
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 25,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
                // Anillo exterior animado (efecto pulsante)
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.35),
                      width: 3,
                    ),
                  ),
                ),
                // Círculo de imagen
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: item.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: theme.colorScheme.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        child: Icon(
                          Icons.radio,
                          size: 35,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                // Badge LIVE
                Positioned(
                  top: 0,
                  right: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.4),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Nombre de la radio
            Text(
              item.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Delegate para mantener el buscador fijo
class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController searchController;
  final ThemeData theme;
  final Function(String) onChanged;

  _SearchBarDelegate({
    required this.searchController,
    required this.theme,
    required this.onChanged,
  });

  @override
  double get minExtent => 72;

  @override
  double get maxExtent => 72;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
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
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      alignment: Alignment.center,
      child: TextField(
        controller: searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Buscar radios',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onChanged: onChanged,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
