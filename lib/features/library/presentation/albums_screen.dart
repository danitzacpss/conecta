import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:conecta_app/features/library/presentation/playlist_details_screen.dart';

// Provider para manejar los álbumes guardados
final savedAlbumsProvider = StateNotifierProvider<SavedAlbumsController, List<Album>>(
  (ref) => SavedAlbumsController(),
);

class SavedAlbumsController extends StateNotifier<List<Album>> {
  SavedAlbumsController() : super([]) {
    _loadSavedAlbums();
  }

  void _loadSavedAlbums() {
    // Aquí cargarías los álbumes guardados desde la base de datos o API
    // Por ahora, simulamos algunos álbumes guardados
    state = const [
      Album(
        id: '1',
        name: 'Sunset Dreams',
        artist: 'Ritmo Latino',
        imageUrl: 'https://picsum.photos/seed/album1/300/300',
        year: '2023',
        songCount: 12,
      ),
      Album(
        id: '2',
        name: 'Midnight Vibes',
        artist: 'Aurora Dream',
        imageUrl: 'https://picsum.photos/seed/album2/300/300',
        year: '2022',
        songCount: 10,
      ),
      Album(
        id: '3',
        name: 'Urban Echoes',
        artist: 'Leo Cósmico',
        imageUrl: 'https://picsum.photos/seed/album3/300/300',
        year: '2024',
        songCount: 15,
      ),
      Album(
        id: '4',
        name: 'Summer Nights',
        artist: 'The Nightwalkers',
        imageUrl: 'https://picsum.photos/seed/album4/300/300',
        year: '2023',
        songCount: 14,
      ),
      Album(
        id: '5',
        name: 'Golden Hour',
        artist: 'Solsticio',
        imageUrl: 'https://picsum.photos/seed/album5/300/300',
        year: '2024',
        songCount: 11,
      ),
    ];
  }

  void saveAlbum(Album album) {
    if (!state.any((a) => a.id == album.id)) {
      state = [...state, album];
    }
  }

  void removeAlbum(String albumId) {
    state = state.where((a) => a.id != albumId).toList();
  }

  bool isSaved(String albumId) {
    return state.any((a) => a.id == albumId);
  }
}

class AlbumsScreen extends ConsumerStatefulWidget {
  const AlbumsScreen({super.key});

  static const routePath = '/albums';
  static const routeName = 'albums';

  @override
  ConsumerState<AlbumsScreen> createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends ConsumerState<AlbumsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  String? _selectedArtist;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> _getUniqueArtists(List<Album> albums) {
    final artists = albums.map((album) => album.artist).toSet().toList();
    artists.sort();
    return artists;
  }

  List<Album> _filterAlbums(List<Album> albums) {
    var filtered = albums;

    // Filtrar por artista seleccionado
    if (_selectedArtist != null) {
      filtered = filtered.where((album) => album.artist == _selectedArtist).toList();
    }

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((album) {
        return album.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            album.artist.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  void _showArtistFilter(BuildContext context, ThemeData theme, List<String> artists) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => _ArtistFilterModal(
        artists: artists,
        selectedArtist: _selectedArtist,
        onArtistSelected: (artist) {
          setState(() {
            _selectedArtist = artist;
          });
        },
        onClear: () {
          setState(() {
            _selectedArtist = null;
          });
        },
        theme: theme,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final savedAlbums = ref.watch(savedAlbumsProvider);
    final filteredAlbums = _filterAlbums(savedAlbums);
    final uniqueArtists = _getUniqueArtists(savedAlbums);

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
            title: const Text('Álbumes'),
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
              if (uniqueArtists.isNotEmpty)
                IconButton(
                  onPressed: () => _showArtistFilter(context, theme, uniqueArtists),
                  icon: Icon(
                    Icons.filter_list,
                    color: _selectedArtist != null
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
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

          // Chip de filtro activo
          if (_selectedArtist != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Wrap(
                  spacing: 8,
                  children: [
                    Chip(
                      avatar: const Icon(Icons.person, size: 18),
                      label: Text(_selectedArtist!),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          _selectedArtist = null;
                        });
                      },
                      backgroundColor: theme.colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Lista de álbumes guardados
          if (savedAlbums.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.album_outlined,
                      size: 80,
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tienes álbumes guardados',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Guarda álbumes para escucharlos más tarde',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (filteredAlbums.isEmpty)
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
                      'No se encontraron álbumes',
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
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _buildAlbumCard(theme, filteredAlbums[index]);
                  },
                  childCount: filteredAlbums.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAlbumCard(ThemeData theme, Album album) {
    return GestureDetector(
      onTap: () {
        context.push(
          PlaylistDetailsScreen.routePath,
          extra: {
            'playlistName': album.name,
            'isAlbum': true,
            'isOwner': false,
            'artistName': album.artist,
          },
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del álbum
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  album.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: BoxDecoration(
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
                        Icons.album,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Nombre del álbum
          Text(
            album.name,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 2),

          // Artista
          Text(
            album.artist,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Modal de filtro de artistas
class _ArtistFilterModal extends StatefulWidget {
  final List<String> artists;
  final String? selectedArtist;
  final Function(String) onArtistSelected;
  final VoidCallback onClear;
  final ThemeData theme;

  const _ArtistFilterModal({
    required this.artists,
    required this.selectedArtist,
    required this.onArtistSelected,
    required this.onClear,
    required this.theme,
  });

  @override
  State<_ArtistFilterModal> createState() => _ArtistFilterModalState();
}

class _ArtistFilterModalState extends State<_ArtistFilterModal> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredArtists = [];

  @override
  void initState() {
    super.initState();
    _filteredArtists = widget.artists;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterArtists(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredArtists = widget.artists;
      } else {
        _filteredArtists = widget.artists
            .where((artist) => artist.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: widget.theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    color: widget.theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Filtros',
                      style: widget.theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (widget.selectedArtist != null)
                    TextButton(
                      onPressed: () {
                        widget.onClear();
                        Navigator.pop(context);
                      },
                      child: const Text('Limpiar'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Buscador de artistas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar artista',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: widget.theme.colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                onChanged: _filterArtists,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: _filteredArtists.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48,
                            color: widget.theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No se encontraron artistas',
                            style: widget.theme.textTheme.bodyMedium?.copyWith(
                              color: widget.theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: _filteredArtists.length,
                      itemBuilder: (context, index) {
                        final artist = _filteredArtists[index];
                        final isSelected = widget.selectedArtist == artist;
                        return ListTile(
                          leading: Icon(
                            isSelected ? Icons.check_circle : Icons.person_outline,
                            color: isSelected ? widget.theme.colorScheme.primary : widget.theme.colorScheme.onSurfaceVariant,
                          ),
                          title: Text(
                            artist,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected ? widget.theme.colorScheme.primary : widget.theme.colorScheme.onSurface,
                            ),
                          ),
                          trailing: isSelected
                            ? Icon(
                                Icons.check,
                                color: widget.theme.colorScheme.primary,
                                size: 20,
                              )
                            : null,
                          onTap: () {
                            widget.onArtistSelected(artist);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            ],
          ),
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
          hintText: 'Buscar álbumes',
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

// Modelo de datos para álbum
class Album {
  final String id;
  final String name;
  final String artist;
  final String imageUrl;
  final String year;
  final int songCount;

  const Album({
    required this.id,
    required this.name,
    required this.artist,
    required this.imageUrl,
    required this.year,
    required this.songCount,
  });
}
