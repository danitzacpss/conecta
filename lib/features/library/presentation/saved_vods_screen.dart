import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:conecta_app/features/home/domain/entities/media_item.dart';
import 'package:conecta_app/features/player/presentation/view/vod_player_screen.dart';
import 'package:conecta_app/features/player/presentation/providers/now_playing_provider.dart';

// Provider para manejar los VODs guardados
final savedVodsProvider = StateNotifierProvider<SavedVodsController, List<MediaItem>>(
  (ref) => SavedVodsController(),
);

class SavedVodsController extends StateNotifier<List<MediaItem>> {
  SavedVodsController() : super([]) {
    _loadSavedVods();
  }

  void _loadSavedVods() {
    // Aquí cargarías los VODs guardados desde la base de datos o API
    // Por ahora, simulamos algunos VODs guardados
    state = const [
      MediaItem(
        id: '1',
        title: 'Concierto Especial 2024',
        artists: ['Artista 1'],
        artworkUrl: 'https://picsum.photos/seed/vod1/400/225',
        type: MediaType.video,
        duration: Duration(minutes: 45),
      ),
      MediaItem(
        id: '2',
        title: 'Entrevista Exclusiva',
        artists: ['Artista 2'],
        artworkUrl: 'https://picsum.photos/seed/vod2/400/225',
        type: MediaType.video,
        duration: Duration(minutes: 30),
      ),
      MediaItem(
        id: '3',
        title: 'Festival de Música en Vivo',
        artists: ['Varios Artistas'],
        artworkUrl: 'https://picsum.photos/seed/vod3/400/225',
        type: MediaType.video,
        duration: Duration(hours: 2),
      ),
      MediaItem(
        id: '4',
        title: 'Behind the Scenes',
        artists: ['Artista 3'],
        artworkUrl: 'https://picsum.photos/seed/vod4/400/225',
        type: MediaType.video,
        duration: Duration(minutes: 25),
      ),
      MediaItem(
        id: '5',
        title: 'Sesión Acústica',
        artists: ['Artista 4'],
        artworkUrl: 'https://picsum.photos/seed/vod5/400/225',
        type: MediaType.video,
        duration: Duration(minutes: 35),
      ),
      MediaItem(
        id: '6',
        title: 'Documental Musical',
        artists: ['Artista 5'],
        artworkUrl: 'https://picsum.photos/seed/vod6/400/225',
        type: MediaType.video,
        duration: Duration(hours: 1, minutes: 20),
      ),
    ];
  }

  void saveVod(MediaItem vod) {
    if (!state.any((v) => v.id == vod.id)) {
      state = [...state, vod];
    }
  }

  void removeVod(String vodId) {
    state = state.where((v) => v.id != vodId).toList();
  }

  bool isSaved(String vodId) {
    return state.any((v) => v.id == vodId);
  }
}

class SavedVodsScreen extends ConsumerStatefulWidget {
  const SavedVodsScreen({super.key});

  static const routePath = '/saved-vods';
  static const routeName = 'saved-vods';

  @override
  ConsumerState<SavedVodsScreen> createState() => _SavedVodsScreenState();
}

class _SavedVodsScreenState extends ConsumerState<SavedVodsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MediaItem> _filterVods(List<MediaItem> vods) {
    if (_searchQuery.isEmpty) {
      return vods;
    }
    return vods.where((vod) {
      return vod.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          vod.artists.any((artist) => artist.toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final savedVods = ref.watch(savedVodsProvider);
    final filteredVods = _filterVods(savedVods);

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
            title: const Text('VOD Guardados'),
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

          // Lista de VODs guardados
          if (savedVods.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.video_library_outlined,
                      size: 80,
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tienes VODs guardados',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Guarda videos para verlos más tarde',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (filteredVods.isEmpty)
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
                      'No se encontraron videos',
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
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _VodCard(item: filteredVods[index]),
                    );
                  },
                  childCount: filteredVods.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Card de VOD (similar al de home_screen)
class _VodCard extends ConsumerWidget {
  const _VodCard({required this.item});

  final MediaItem item;

  String _formatDuration(Duration? duration) {
    if (duration == null) return '';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        // Actualizar el nowPlayingProvider con el VOD seleccionado
        ref.read(nowPlayingProvider.notifier).play(item);

        context.push(
          VodPlayerScreen.routePath,
          extra: {
            'videoId': item.id,
            'videoTitle': item.title,
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Imagen de fondo
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: item.artworkUrl,
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
                      Icons.video_library,
                      size: 50,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
            // Gradiente overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
            ),
            // Botón play central
            Positioned.fill(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            // Información del video
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.artists.join(', '),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.duration != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _formatDuration(item.duration),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
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
          hintText: 'Buscar videos',
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
