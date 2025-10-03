import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:conecta_app/features/library/presentation/playlist_details_screen.dart';
import 'package:conecta_app/features/player/presentation/providers/now_playing_provider.dart';
import 'package:conecta_app/features/home/domain/entities/media_item.dart';
import 'package:conecta_app/core/utils/snackbar_utils.dart';

// Provider para el usuario actual
final currentUserProvider = Provider<CurrentUser>((ref) {
  return const CurrentUser(
    id: 'current_user',
    name: 'Carlos Mendoza',
    username: '@carlosm',
  );
});

class CurrentUser {
  final String id;
  final String name;
  final String username;

  const CurrentUser({
    required this.id,
    required this.name,
    required this.username,
  });
}

// Provider para las canciones de las playlists
final playlistSongsProvider = StateNotifierProvider<PlaylistSongsController, Map<String, List<MediaItem>>>(
  (ref) => PlaylistSongsController(),
);

class PlaylistSongsController extends StateNotifier<Map<String, List<MediaItem>>> {
  PlaylistSongsController() : super({}) {
    _initializeWithDefaultSongs();
  }

  void _initializeWithDefaultSongs() {
    // Inicializar playlists con canciones de ejemplo
    const defaultSongs = [
      MediaItem(
        id: 'default_1',
        title: 'Sol y Arena',
        artists: ['Ritmo Latino'],
        artworkUrl: 'https://picsum.photos/seed/song1/400/400',
        type: MediaType.track,
        duration: Duration(minutes: 3, seconds: 45),
        isDownloaded: true,
      ),
      MediaItem(
        id: 'default_2',
        title: 'Olas de Neón',
        artists: ['Aurora Dream'],
        artworkUrl: 'https://picsum.photos/seed/song2/400/400',
        type: MediaType.track,
        duration: Duration(minutes: 4, seconds: 20),
      ),
      MediaItem(
        id: 'default_3',
        title: 'Brisa Tropical',
        artists: ['Leo Cósmico'],
        artworkUrl: 'https://picsum.photos/seed/song3/400/400',
        type: MediaType.track,
        duration: Duration(minutes: 3, seconds: 30),
        isDownloaded: true,
      ),
    ];

    // Inicializar las primeras 6 playlists con estas canciones
    state = {
      '1': defaultSongs,
      '2': defaultSongs,
      '3': defaultSongs,
      '4': defaultSongs,
      '5': defaultSongs,
      '6': defaultSongs,
    };
  }

  void addSongToPlaylist(String playlistId, MediaItem song) {
    final currentSongs = state[playlistId] ?? [];
    state = {
      ...state,
      playlistId: [...currentSongs, song],
    };
  }

  void removeSongFromPlaylist(String playlistId, String songId) {
    final currentSongs = state[playlistId] ?? [];
    state = {
      ...state,
      playlistId: currentSongs.where((song) => song.id != songId).toList(),
    };
  }

  List<MediaItem> getPlaylistSongs(String playlistId) {
    return state[playlistId] ?? [];
  }
}

// Provider para manejar las playlists
final playlistsProvider = StateNotifierProvider<PlaylistsController, List<PlaylistItem>>(
  (ref) {
    final currentUser = ref.watch(currentUserProvider);
    return PlaylistsController(currentUser.name);
  },
);

class PlaylistsController extends StateNotifier<List<PlaylistItem>> {
  PlaylistsController(String currentUserName) : super([]) {
    _loadPlaylists(currentUserName);
  }

  void _loadPlaylists(String currentUserName) {
    // Aquí cargarías las playlists desde la base de datos o API
    // Por ahora, simulamos algunas playlists
    // El songCount se establece en 0 porque será calculado dinámicamente desde playlistSongsProvider
    state = [
      PlaylistItem(
        id: '1',
        name: 'Pop para entrenar',
        songCount: 0,
        imageUrl: 'https://picsum.photos/seed/playlist1/300/300',
        isOwner: true,
        description: 'Las mejores canciones pop para motivarte durante tu entrenamiento',
        ownerName: currentUserName,
      ),
      PlaylistItem(
        id: '2',
        name: 'Rock de los 90',
        songCount: 0,
        imageUrl: 'https://picsum.photos/seed/playlist2/300/300',
        isOwner: true,
        description: 'Clásicos del rock que marcaron una década',
        ownerName: currentUserName,
      ),
      PlaylistItem(
        id: '3',
        name: 'Tardes de relax',
        songCount: 0,
        imageUrl: 'https://picsum.photos/seed/playlist3/300/300',
        isOwner: true,
        description: 'Música perfecta para relajarte después de un largo día',
        ownerName: currentUserName,
      ),
      const PlaylistItem(
        id: '4',
        name: 'Éxitos latinos',
        songCount: 0,
        imageUrl: 'https://picsum.photos/seed/playlist4/300/300',
        isOwner: false,
        description: 'Lo mejor de la música latina actual',
        ownerName: 'DJ Latino',
      ),
      PlaylistItem(
        id: '5',
        name: 'Jazz nocturno',
        songCount: 0,
        imageUrl: 'https://picsum.photos/seed/playlist5/300/300',
        isOwner: true,
        description: 'Jazz suave para noches tranquilas',
        ownerName: currentUserName,
      ),
      const PlaylistItem(
        id: '6',
        name: 'Electrónica 2024',
        songCount: 0,
        imageUrl: 'https://picsum.photos/seed/playlist6/300/300',
        isOwner: false,
        description: 'Los mejores beats electrónicos del año',
        ownerName: 'ElectroMix',
      ),
    ];
  }

  void createPlaylist(PlaylistItem playlist) {
    state = [playlist, ...state];
  }

  void removePlaylist(String playlistId) {
    state = state.where((p) => p.id != playlistId).toList();
  }

  void updatePlaylist(String playlistId, {String? name, String? description}) {
    state = state.map((playlist) {
      if (playlist.id == playlistId) {
        return PlaylistItem(
          id: playlist.id,
          name: name ?? playlist.name,
          songCount: playlist.songCount,
          imageUrl: playlist.imageUrl,
          isOwner: playlist.isOwner,
          description: description ?? playlist.description,
          ownerName: playlist.ownerName,
        );
      }
      return playlist;
    }).toList();
  }
}

class PlaylistItem {
  final String id;
  final String name;
  final int songCount;
  final String imageUrl;
  final bool isOwner;
  final String? description;
  final String? ownerName;

  const PlaylistItem({
    required this.id,
    required this.name,
    required this.songCount,
    required this.imageUrl,
    required this.isOwner,
    this.description,
    this.ownerName,
  });
}

class PlaylistsScreen extends ConsumerStatefulWidget {
  const PlaylistsScreen({super.key});

  static const routePath = '/playlists';
  static const routeName = 'playlists';

  @override
  ConsumerState<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends ConsumerState<PlaylistsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  String? _selectedFilter; // 'mine' o 'others'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PlaylistItem> _filterPlaylists(List<PlaylistItem> playlists) {
    var filtered = playlists;

    // Filtrar por tipo (mis playlists u otras)
    if (_selectedFilter == 'mine') {
      filtered = filtered.where((p) => p.isOwner).toList();
    } else if (_selectedFilter == 'others') {
      filtered = filtered.where((p) => !p.isOwner).toList();
    }

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((playlist) {
        return playlist.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  void _showFilterModal(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => _FilterModal(
        selectedFilter: _selectedFilter,
        onFilterSelected: (filter) {
          setState(() {
            _selectedFilter = filter;
          });
        },
        onClear: () {
          setState(() {
            _selectedFilter = null;
          });
        },
        theme: theme,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final playlists = ref.watch(playlistsProvider);
    final filteredPlaylists = _filterPlaylists(playlists);

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
            title: const Text('Playlists'),
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
              IconButton(
                onPressed: () => _showFilterModal(context, theme),
                icon: Icon(
                  Icons.filter_list,
                  color: _selectedFilter != null
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
          if (_selectedFilter != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Wrap(
                  spacing: 8,
                  children: [
                    Chip(
                      avatar: Icon(
                        _selectedFilter == 'mine' ? Icons.person : Icons.people,
                        size: 18,
                      ),
                      label: Text(_selectedFilter == 'mine' ? 'Mis Playlists' : 'Otras Playlists'),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          _selectedFilter = null;
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

          // Lista de playlists
          if (playlists.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.queue_music_outlined,
                      size: 80,
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tienes playlists',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crea una playlist para organizar tu música',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (filteredPlaylists.isEmpty)
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
                      'No se encontraron playlists',
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
                      child: _PlaylistCard(playlist: filteredPlaylists[index]),
                    );
                  },
                  childCount: filteredPlaylists.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Card de playlist
class _PlaylistCard extends ConsumerWidget {
  const _PlaylistCard({required this.playlist});

  final PlaylistItem playlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Obtener el número real de canciones desde el provider
    final playlistSongs = ref.watch(playlistSongsProvider);
    final actualSongCount = playlistSongs[playlist.id]?.length ?? 0;

    return GestureDetector(
      onTap: () {
        context.push(
          PlaylistDetailsScreen.routePath,
          extra: {
            'playlistId': playlist.id,
            'playlistName': playlist.name,
            'isAlbum': false,
            'isOwner': playlist.isOwner,
            'ownerName': playlist.ownerName ?? 'Usuario',
            'description': playlist.description,
          },
        );
      },
      child: Container(
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
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                playlist.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.queue_music,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$actualSongCount ${actualSongCount == 1 ? 'canción' : 'canciones'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                // Reproducir la primera canción de la playlist
                final firstSong = MediaItem(
                  id: '${playlist.id}_1',
                  title: 'Canción 1 de ${playlist.name}',
                  artists: ['Artista'],
                  artworkUrl: playlist.imageUrl,
                  type: MediaType.track,
                  duration: const Duration(minutes: 3, seconds: 30),
                );

                ref.read(nowPlayingProvider.notifier).play(firstSong);

                SnackBarUtils.showSuccess(
                  context,
                  'Reproduciendo ${playlist.name}',
                  duration: const Duration(seconds: 2),
                );
              },
              child: Container(
                width: 40,
                height: 40,
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
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 24,
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
          hintText: 'Buscar playlists',
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

// Modal de filtro
class _FilterModal extends StatelessWidget {
  final String? selectedFilter;
  final Function(String?) onFilterSelected;
  final VoidCallback onClear;
  final ThemeData theme;

  const _FilterModal({
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.onClear,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
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
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Filtros',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (selectedFilter != null)
                      TextButton(
                        onPressed: () {
                          onClear();
                          Navigator.pop(context);
                        },
                        child: const Text('Limpiar'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(
                  selectedFilter == 'mine' ? Icons.check_circle : Icons.person_outline,
                  color: selectedFilter == 'mine' ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                ),
                title: Text(
                  'Mis Playlists',
                  style: TextStyle(
                    fontWeight: selectedFilter == 'mine' ? FontWeight.w600 : FontWeight.normal,
                    color: selectedFilter == 'mine' ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                  ),
                ),
                trailing: selectedFilter == 'mine'
                    ? Icon(
                        Icons.check,
                        color: theme.colorScheme.primary,
                        size: 20,
                      )
                    : null,
                onTap: () {
                  onFilterSelected('mine');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  selectedFilter == 'others' ? Icons.check_circle : Icons.people_outline,
                  color: selectedFilter == 'others' ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                ),
                title: Text(
                  'Otras Playlists',
                  style: TextStyle(
                    fontWeight: selectedFilter == 'others' ? FontWeight.w600 : FontWeight.normal,
                    color: selectedFilter == 'others' ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                  ),
                ),
                trailing: selectedFilter == 'others'
                    ? Icon(
                        Icons.check,
                        color: theme.colorScheme.primary,
                        size: 20,
                      )
                    : null,
                onTap: () {
                  onFilterSelected('others');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
