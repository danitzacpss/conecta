import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:conecta_app/features/radio/presentation/artist_profile_screen.dart';

// Provider para manejar los artistas seguidos
final followedArtistsProvider = StateNotifierProvider<FollowedArtistsController, List<Artist>>(
  (ref) => FollowedArtistsController(),
);

class FollowedArtistsController extends StateNotifier<List<Artist>> {
  FollowedArtistsController() : super([]) {
    _loadFollowedArtists();
  }

  void _loadFollowedArtists() {
    // Aquí cargarías los artistas seguidos desde la base de datos o API
    // Por ahora, simulamos algunos artistas seguidos
    state = const [
      Artist(
        id: '1',
        name: 'Ritmo Latino',
        imageUrl: 'https://picsum.photos/seed/artist1/200/200',
        songCount: 12,
      ),
      Artist(
        id: '2',
        name: 'Aurora Dream',
        imageUrl: 'https://picsum.photos/seed/artist2/200/200',
        songCount: 8,
      ),
      Artist(
        id: '3',
        name: 'Leo Cósmico',
        imageUrl: 'https://picsum.photos/seed/artist3/200/200',
        songCount: 15,
      ),
      Artist(
        id: '4',
        name: 'The Nightwalkers',
        imageUrl: 'https://picsum.photos/seed/artist4/200/200',
        songCount: 20,
      ),
      Artist(
        id: '5',
        name: 'Solsticio',
        imageUrl: 'https://picsum.photos/seed/artist5/200/200',
        songCount: 10,
      ),
    ];
  }

  void followArtist(Artist artist) {
    if (!state.any((a) => a.id == artist.id)) {
      state = [...state, artist];
    }
  }

  void unfollowArtist(String artistId) {
    state = state.where((a) => a.id != artistId).toList();
  }

  bool isFollowing(String artistId) {
    return state.any((a) => a.id == artistId);
  }
}

class ArtistsScreen extends ConsumerStatefulWidget {
  const ArtistsScreen({super.key});

  static const routePath = '/artists';
  static const routeName = 'artists';

  @override
  ConsumerState<ArtistsScreen> createState() => _ArtistsScreenState();
}

class _ArtistsScreenState extends ConsumerState<ArtistsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Artist> _filterArtists(List<Artist> artists) {
    if (_searchQuery.isEmpty) {
      return artists;
    }
    return artists.where((artist) {
      return artist.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final followedArtists = ref.watch(followedArtistsProvider);
    final filteredArtists = _filterArtists(followedArtists);

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
            title: const Text('Artistas'),
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

          // Lista de artistas seguidos
          if (followedArtists.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 80,
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No sigues a ningún artista',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Explora y sigue a tus artistas favoritos',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (filteredArtists.isEmpty)
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
                      'No se encontraron artistas',
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
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _buildArtistCard(theme, filteredArtists[index]);
                  },
                  childCount: filteredArtists.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildArtistCard(ThemeData theme, Artist artist) {
    return GestureDetector(
      onTap: () {
        context.push(ArtistProfileScreen.routePath);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Imagen circular del artista
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    artist.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Nombre del artista
          Text(
            artist.name,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 2),

          // Número de canciones
          Text(
            '${artist.songCount} canciones',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
          hintText: 'Buscar artistas',
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

// Modelo de datos para artista
class Artist {
  final String id;
  final String name;
  final String imageUrl;
  final int songCount;

  const Artist({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.songCount,
  });
}
