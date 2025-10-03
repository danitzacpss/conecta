import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:conecta_app/features/player/presentation/providers/now_playing_provider.dart';
import 'package:conecta_app/features/home/domain/entities/media_item.dart';
import 'package:conecta_app/features/library/presentation/search_songs_modal.dart';
import 'package:conecta_app/features/library/presentation/add_to_playlist_modal.dart';
import 'package:conecta_app/features/library/presentation/providers/liked_songs_provider.dart';
import 'package:conecta_app/core/utils/snackbar_utils.dart';
import 'package:conecta_app/core/widgets/share_modal.dart';
import 'package:conecta_app/features/library/presentation/playlists_screen.dart';

// Provider para manejar las canciones descargadas
final downloadedSongsProvider = StateNotifierProvider<DownloadedSongsNotifier, Set<String>>((ref) {
  return DownloadedSongsNotifier();
});

class DownloadedSongsNotifier extends StateNotifier<Set<String>> {
  DownloadedSongsNotifier() : super({});

  void downloadSong(String songId) {
    state = {...state, songId};
  }

  void downloadMultipleSongs(List<String> songIds) {
    state = {...state, ...songIds};
  }

  bool isDownloaded(String songId) {
    return state.contains(songId);
  }
}

class PlaylistDetailsScreen extends ConsumerStatefulWidget {
  const PlaylistDetailsScreen({
    super.key,
    this.playlistId,
    this.playlistName,
    this.isAlbum = false,
    this.isOwner = true,
    this.ownerName,
    this.artistName,
    this.isLikedSongs = false,
    this.description,
  });

  static const routePath = '/playlist-details';
  static const routeName = 'playlistDetails';

  final String? playlistId;
  final String? playlistName;
  final bool isAlbum;
  final bool isOwner;
  final String? ownerName;
  final String? artistName;
  final bool isLikedSongs;
  final String? description;

  @override
  ConsumerState<PlaylistDetailsScreen> createState() => _PlaylistDetailsScreenState();
}

class _PlaylistDetailsScreenState extends ConsumerState<PlaylistDetailsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isSaved = false; // Si la playlist está guardada en biblioteca
  bool _autoDownloadEnabled = false; // Si la descarga automática está activada
  String _searchQuery = '';

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getSongsList() {
    final songs = _getPlaylistSongs();
    return songs.asMap().entries.map((entry) {
      final index = entry.key;
      final song = entry.value;
      return {
        'number': '${index + 1}',
        'title': song.title,
        'artist': song.artists.join(', '),
        'isLiked': ref.watch(likedSongsProvider).any((likedSong) => likedSong.id == song.id),
        'index': index,
      };
    }).toList();
  }

  List<Map<String, dynamic>> _filterSongs() {
    final songs = _getSongsList();
    if (_searchQuery.isEmpty) {
      return songs;
    }
    return songs.where((song) {
      final title = song['title'] as String;
      final artist = song['artist'] as String;
      final query = _searchQuery.toLowerCase();
      return title.toLowerCase().contains(query) || artist.toLowerCase().contains(query);
    }).toList();
  }

  int _getSongCount() {
    return _getPlaylistSongs().length;
  }

  String _getTotalDuration() {
    final songs = _getPlaylistSongs();
    if (songs.isEmpty) return '0 min';

    int totalSeconds = 0;
    for (final song in songs) {
      if (song.duration != null) {
        totalSeconds += song.duration!.inSeconds;
      }
    }

    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours h ${minutes > 0 ? '$minutes min' : ''}';
    } else {
      return '$minutes min';
    }
  }

  List<MediaItem> _getPlaylistSongs() {
    if (widget.isLikedSongs) {
      return ref.watch(likedSongsProvider);
    }

    // Obtener canciones del provider si tenemos playlistId
    if (widget.playlistId != null) {
      final playlistSongs = ref.watch(playlistSongsProvider);
      return playlistSongs[widget.playlistId!] ?? [];
    }

    // Para álbumes sin playlistId, devolver canciones de ejemplo
    if (widget.isAlbum) {
      return const [
        MediaItem(
          id: 'album_song_1',
          title: 'Canción del Álbum 1',
          artists: ['Artista'],
          artworkUrl: 'https://picsum.photos/seed/album1/400/400',
          type: MediaType.track,
          duration: Duration(minutes: 3, seconds: 45),
        ),
        MediaItem(
          id: 'album_song_2',
          title: 'Canción del Álbum 2',
          artists: ['Artista'],
          artworkUrl: 'https://picsum.photos/seed/album2/400/400',
          type: MediaType.track,
          duration: Duration(minutes: 4, seconds: 12),
        ),
        MediaItem(
          id: 'album_song_3',
          title: 'Canción del Álbum 3',
          artists: ['Artista'],
          artworkUrl: 'https://picsum.photos/seed/album3/400/400',
          type: MediaType.track,
          duration: Duration(minutes: 3, seconds: 28),
        ),
      ];
    }

    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    // Obtener la playlist actualizada desde el provider si existe
    final playlists = ref.watch(playlistsProvider);
    final currentPlaylist = widget.playlistId != null
        ? playlists.firstWhere(
            (p) => p.id == widget.playlistId,
            orElse: () => PlaylistItem(
              id: widget.playlistId ?? '',
              name: widget.playlistName ?? 'Playlist',
              songCount: _getSongCount(),
              imageUrl: '',
              isOwner: widget.isOwner,
              description: widget.description,
            ),
          )
        : null;

    final displayName = currentPlaylist?.name ?? widget.playlistName;
    final displayDescription = currentPlaylist?.description ?? widget.description;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        controller: _scrollController,
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
              // Solo mostrar menú de opciones si NO es "Canciones que me gustan"
              if (!widget.isLikedSongs)
                IconButton(
                  onPressed: () {
                    _showOptionsMenu(context);
                  },
                  icon: const Icon(Icons.more_vert),
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

          // Contenido principal
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Imagen de la playlist o ícono de canciones que me gustan
                  Container(
                    width: size.width * 0.45,
                    height: size.width * 0.45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: widget.isLikedSongs
                        ? Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.pink.shade300,
                                  Colors.pink.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.favorite,
                                size: size.width * 0.2,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              'https://picsum.photos/seed/playlist1/400/400',
                              fit: BoxFit.cover,
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
                                    Icons.music_note,
                                    size: 80,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),

                  const SizedBox(height: 24),

                  // Título de la playlist
                  Text(
                    widget.isLikedSongs
                        ? 'Canciones que me gustan'
                        : (displayName ?? 'Playlist'),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Subtítulo - Artista o Dueño (clickeable)
                  if (!widget.isLikedSongs)
                    GestureDetector(
                      onTap: () {
                        if (widget.isAlbum) {
                          // Navegar al perfil del artista
                          context.push('/artist-profile');
                        } else {
                          // Navegar al perfil del usuario creador
                          context.push('/user-profile');
                        }
                      },
                      child: Text(
                        widget.isAlbum
                          ? widget.artistName ?? "Artista Desconocido"
                          : widget.ownerName ?? "Usuario",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  if (!widget.isLikedSongs) const SizedBox(height: 4),

                  // Descripción (solo para playlists)
                  if (!widget.isAlbum && !widget.isLikedSongs && displayDescription != null && displayDescription.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        displayDescription,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  if (!widget.isLikedSongs && (displayDescription == null || displayDescription.isEmpty))
                    const SizedBox(height: 8),

                  // Info: canciones y duración
                  Text(
                    _getSongCount() > 0
                      ? '${_getSongCount()} ${_getSongCount() == 1 ? 'canción' : 'canciones'} • ${_getTotalDuration()}'
                      : 'Sin canciones',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // Botones de acciones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Botón Play
                      Container(
                        decoration: BoxDecoration(
                          color: _getSongCount() > 0
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: _getSongCount() > 0 ? () {
                            // Reproducir toda la playlist desde la primera canción
                            final controller = ref.read(nowPlayingProvider.notifier);
                            controller.playQueue(_getPlaylistSongs(), 0);
                          } : null,
                          icon: const Icon(Icons.play_arrow),
                          color: _getSongCount() > 0 ? Colors.white : Colors.grey,
                          iconSize: 32,
                          tooltip: 'Reproducir',
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Botón Shuffle
                      Container(
                        decoration: BoxDecoration(
                          color: _getSongCount() > 0
                            ? (ref.watch(nowPlayingProvider).isShuffled
                                ? theme.colorScheme.primary
                                : theme.colorScheme.surfaceContainerHighest)
                            : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: _getSongCount() > 0 ? () {
                            final controller = ref.read(nowPlayingProvider.notifier);
                            controller.toggleShuffle();
                          } : null,
                          icon: const Icon(Icons.shuffle),
                          color: _getSongCount() > 0
                            ? (ref.watch(nowPlayingProvider).isShuffled
                                ? Colors.white
                                : theme.colorScheme.onSurface)
                            : Colors.grey,
                          iconSize: 24,
                          tooltip: 'Aleatorio',
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Botón Descarga Automática
                      Container(
                        decoration: BoxDecoration(
                          color: _getSongCount() > 0
                            ? (_autoDownloadEnabled
                                ? theme.colorScheme.primary
                                : theme.colorScheme.surfaceContainerHighest)
                            : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: _getSongCount() > 0 ? () {
                            setState(() {
                              _autoDownloadEnabled = !_autoDownloadEnabled;
                            });
                            if (_autoDownloadEnabled) {
                              SnackBarUtils.showSuccess(
                                context,
                                'Descarga automática activada',
                                duration: const Duration(seconds: 2),
                              );
                            } else {
                              SnackBarUtils.showInfo(
                                context,
                                'Descarga automática desactivada',
                                duration: const Duration(seconds: 2),
                              );
                            }
                          } : null,
                          icon: Icon(_autoDownloadEnabled
                            ? Icons.download_done
                            : Icons.download_for_offline_outlined),
                          color: _getSongCount() > 0
                            ? (_autoDownloadEnabled
                                ? Colors.white
                                : theme.colorScheme.onSurface)
                            : Colors.grey,
                          iconSize: 24,
                          tooltip: _autoDownloadEnabled ? 'Descarga automática activada' : 'Activar descarga automática',
                        ),
                      ),

                      // Botón Añadir canciones (solo para propias playlists)
                      if (widget.isOwner && !widget.isLikedSongs && !widget.isAlbum) ...[
                        const SizedBox(width: 16),

                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () async {
                              // Mostrar modal para buscar y añadir canciones
                              final result = await showModalBottomSheet<MediaItem>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                useRootNavigator: true,
                                builder: (context) => SearchSongsModal(
                                  playlistId: widget.playlistId,
                                ),
                              );

                              if (result != null && mounted && widget.playlistId != null) {
                                // Añadir la canción a la playlist
                                ref.read(playlistSongsProvider.notifier).addSongToPlaylist(
                                  widget.playlistId!,
                                  result,
                                );

                                SnackBarUtils.showSuccess(
                                  context,
                                  '"${result.title}" añadida a la playlist',
                                  duration: const Duration(seconds: 2),
                                );
                              }
                            },
                            icon: const Icon(Icons.add),
                            color: Colors.white,
                            iconSize: 24,
                            tooltip: 'Añadir canciones',
                          ),
                        ),
                      ],

                      if (!widget.isLikedSongs && !widget.isOwner) ...[
                        const SizedBox(width: 16),

                        // Botón Guardar
                        Container(
                          decoration: BoxDecoration(
                            color: _isSaved
                                ? theme.colorScheme.primary
                                : theme.colorScheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () {
                              final wasNotSaved = !_isSaved;
                              setState(() {
                                _isSaved = !_isSaved;
                              });
                              if (_isSaved) {
                                SnackBarUtils.showSuccess(
                                  context,
                                  widget.isAlbum ? 'Álbum guardado en tu biblioteca' : 'Playlist guardada en tu biblioteca',
                                  actionLabel: 'Ver',
                                  onAction: () {
                                    context.go('/library');
                                  },
                                );
                              } else {
                                SnackBarUtils.showInfo(
                                  context,
                                  widget.isAlbum ? 'Álbum eliminado de tu biblioteca' : 'Playlist eliminada de tu biblioteca',
                                );
                              }
                            },
                            icon: Icon(_isSaved
                              ? Icons.bookmark
                              : Icons.bookmark_add_outlined),
                            color: _isSaved
                                ? Colors.white
                                : theme.colorScheme.onSurface,
                            iconSize: 24,
                            tooltip: _isSaved ? 'Guardado' : 'Guardar',
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Lista de canciones o estado vacío
                  if (_filterSongs().isEmpty && widget.isLikedSongs)
                    _buildEmptyState(theme)
                  else
                    ..._filterSongs().map((song) => _buildSongTile(
                      number: song['number'] as String,
                      title: song['title'] as String,
                      artist: song['artist'] as String,
                      isLiked: song['isLiked'] as bool,
                      theme: theme,
                      index: song['index'] as int,
                    )),

                  const SizedBox(height: 200), // Espacio para mini reproductor y nav bar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongTile({
    required String number,
    required String title,
    required String artist,
    required bool isLiked,
    required ThemeData theme,
    required int index,
  }) {
    final songs = _getPlaylistSongs();
    final currentSong = index < songs.length ? songs[index] : null;

    // Obtener el estado real de "me gusta" desde el provider
    final likedSongs = ref.watch(likedSongsProvider);
    final actualIsLiked = currentSong != null
      ? likedSongs.any((song) => song.id == currentSong.id)
      : isLiked;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      leading: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: currentSong != null
              ? Image.network(
                  currentSong.artworkUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 48,
                      height: 48,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.music_note,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                )
              : Container(
                  width: 48,
                  height: 48,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.music_note,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
          ),
          // Indicador de descarga
          if (currentSong != null)
            Consumer(
              builder: (context, ref, child) {
                final isDownloaded = ref.watch(downloadedSongsProvider).contains(currentSong.id) || currentSong.isDownloaded;
                if (!isDownloaded) return const SizedBox.shrink();
                return Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.download_done,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        artist,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: currentSong != null ? () {
              // Toggle like en el provider
              ref.read(likedSongsProvider.notifier).toggleLike(currentSong);

              // Mostrar snackbar
              final isNowLiked = ref.read(likedSongsProvider.notifier).isLiked(currentSong.id);
              if (isNowLiked) {
                SnackBarUtils.showSuccess(
                  context,
                  'Agregado a tus canciones favoritas',
                  duration: const Duration(seconds: 2),
                );
              } else {
                SnackBarUtils.showInfo(
                  context,
                  'Eliminado de tus canciones favoritas',
                  duration: const Duration(seconds: 2),
                );
              }
            } : null,
            icon: Icon(
              actualIsLiked ? Icons.favorite : Icons.favorite_border,
              color: actualIsLiked ? Colors.red : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          IconButton(
            onPressed: currentSong != null ? () {
              _showSongOptionsMenu(currentSong);
            } : null,
            icon: Icon(
              Icons.more_vert,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      onTap: () {
        // Reproducir canción desde esta posición en la cola
        final controller = ref.read(nowPlayingProvider.notifier);
        controller.playQueue(_getPlaylistSongs(), index);
      },
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
            // Solo mostrar opción de descargar si NO es "Canciones que me gustan"
            if (!widget.isLikedSongs) ...[
              ListTile(
                leading: const Icon(Icons.download_for_offline),
                title: Text(widget.isAlbum ? 'Descargar todo el álbum' : 'Descargar toda la playlist'),
                subtitle: Text('${_getSongCount()} canciones'),
                onTap: () {
                  Navigator.pop(context);
                  final songs = _getPlaylistSongs();
                  final downloadController = ref.read(downloadedSongsProvider.notifier);

                  // Descargar todas las canciones
                  downloadController.downloadMultipleSongs(
                    songs.map((song) => song.id).toList(),
                  );

                  SnackBarUtils.showSuccess(
                    context,
                    widget.isAlbum
                        ? '${songs.length} canciones descargadas del álbum'
                        : '${songs.length} canciones descargadas de la playlist',
                    duration: const Duration(seconds: 2),
                  );
                },
              ),
              const Divider(),
            ],
            // Solo mostrar opción de compartir si NO es "Canciones que me gustan"
            if (!widget.isLikedSongs)
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Compartir'),
                onTap: () {
                  Navigator.pop(context);
                  showShareModal(
                    context,
                    title: widget.playlistName ?? (widget.isAlbum ? 'Álbum' : 'Playlist'),
                    description: widget.isAlbum ? 'Compartir álbum' : 'Compartir playlist',
                    iconColor: Theme.of(context).colorScheme.primary,
                    onFacebookShare: () {
                      SnackBarUtils.showSuccess(
                        context,
                        'Compartiendo en Facebook...',
                        duration: const Duration(seconds: 2),
                      );
                    },
                    onWhatsAppShare: () {
                      SnackBarUtils.showSuccess(
                        context,
                        'Compartiendo en WhatsApp...',
                        duration: const Duration(seconds: 2),
                      );
                    },
                    onInstagramShare: () {
                      SnackBarUtils.showSuccess(
                        context,
                        'Compartiendo en Instagram...',
                        duration: const Duration(seconds: 2),
                      );
                    },
                    onCopyLink: () {
                      SnackBarUtils.showSuccess(
                        context,
                        'Enlace copiado al portapapeles',
                        duration: const Duration(seconds: 2),
                      );
                    },
                  );
                },
              ),
            // Solo mostrar opciones de edición si es dueño, no es álbum y no es canciones que me gustan
            if (!widget.isAlbum && widget.isOwner && !widget.isLikedSongs) ...[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar playlist'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditPlaylistDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Eliminar playlist'),
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  // Mostrar diálogo de confirmación
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Eliminar playlist'),
                      content: Text('¿Estás seguro de que deseas eliminar "${widget.playlistName}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            SnackBarUtils.showSuccess(
                              context,
                              'Playlist eliminada',
                            );
                            // Volver a la pantalla anterior
                            if (context.canPop()) {
                              context.pop();
                            }
                          },
                          child: const Text(
                            'Eliminar',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
            // Opción para ir al artista si es álbum
            if (widget.isAlbum)
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Ver artista'),
                onTap: () {
                  Navigator.pop(context);
                  context.push(
                    '/artist-profile',
                    extra: {
                      'artistName': widget.artistName ?? 'Artista',
                    },
                  );
                },
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSongOptionsMenu(MediaItem song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                song.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.playlist_add),
              title: const Text('Agregar a playlist'),
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  useRootNavigator: true,
                  builder: (context) => AddToPlaylistModal(
                    songId: song.id,
                    songTitle: song.title,
                    songArtist: song.artists.join(', '),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.album),
              title: const Text('Ver álbum'),
              onTap: () {
                Navigator.pop(context);
                context.push(
                  PlaylistDetailsScreen.routePath,
                  extra: {
                    'isAlbum': true,
                    'playlistName': 'Álbum de ${song.artists.first}',
                    'artistName': song.artists.first,
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Ver artista'),
              onTap: () {
                Navigator.pop(context);
                context.push(
                  '/artist-profile',
                  extra: {
                    'artistName': song.artists.first,
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Compartir'),
              onTap: () {
                Navigator.pop(context);
                showShareModal(
                  context,
                  title: song.title,
                  description: 'Compartir ${song.artists.join(", ")}',
                  iconColor: Theme.of(context).colorScheme.primary,
                  onFacebookShare: () {
                    SnackBarUtils.showSuccess(
                      context,
                      'Compartiendo en Facebook...',
                      duration: const Duration(seconds: 2),
                    );
                  },
                  onWhatsAppShare: () {
                    SnackBarUtils.showSuccess(
                      context,
                      'Compartiendo en WhatsApp...',
                      duration: const Duration(seconds: 2),
                    );
                  },
                  onInstagramShare: () {
                    SnackBarUtils.showSuccess(
                      context,
                      'Compartiendo en Instagram...',
                      duration: const Duration(seconds: 2),
                    );
                  },
                  onCopyLink: () {
                    SnackBarUtils.showSuccess(
                      context,
                      'Enlace copiado al portapapeles',
                      duration: const Duration(seconds: 2),
                    );
                  },
                );
              },
            ),
            Consumer(
              builder: (context, ref, child) {
                final isDownloaded = ref.watch(downloadedSongsProvider).contains(song.id);
                return ListTile(
                  leading: Icon(isDownloaded ? Icons.download_done : Icons.download),
                  title: Text(isDownloaded ? 'Descargada' : 'Descargar'),
                  enabled: !isDownloaded,
                  onTap: isDownloaded ? null : () {
                    Navigator.pop(context);
                    final downloadController = ref.read(downloadedSongsProvider.notifier);
                    downloadController.downloadSong(song.id);

                    SnackBarUtils.showSuccess(
                      context,
                      '"${song.title}" descargada',
                      duration: const Duration(seconds: 2),
                    );
                  },
                );
              },
            ),
            if (widget.isOwner && !widget.isLikedSongs)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Quitar de la playlist'),
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  SnackBarUtils.showInfo(
                    context,
                    '"${song.title}" eliminada de la playlist',
                    duration: const Duration(seconds: 2),
                  );
                  // TODO: Implementar eliminación real
                },
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No tienes canciones favoritas',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Presiona el ícono de corazón en el reproductor para agregar canciones a tus favoritos',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPlaylistDialog() {
    final theme = Theme.of(context);

    // Obtener los valores actuales desde el provider
    final playlists = ref.read(playlistsProvider);
    final currentPlaylist = widget.playlistId != null
        ? playlists.firstWhere(
            (p) => p.id == widget.playlistId,
            orElse: () => PlaylistItem(
              id: widget.playlistId ?? '',
              name: widget.playlistName ?? 'Playlist',
              songCount: 0,
              imageUrl: '',
              isOwner: widget.isOwner,
              description: widget.description,
            ),
          )
        : null;

    final nameController = TextEditingController(text: currentPlaylist?.name ?? widget.playlistName);
    final descriptionController = TextEditingController(text: currentPlaylist?.description ?? widget.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar playlist'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la playlist',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (widget.playlistId != null) {
                // Actualizar la playlist en el provider
                ref.read(playlistsProvider.notifier).updatePlaylist(
                  widget.playlistId!,
                  name: nameController.text,
                  description: descriptionController.text,
                );
              }
              Navigator.pop(context);
              SnackBarUtils.showSuccess(
                context,
                'Playlist "${nameController.text}" actualizada',
              );
            },
            child: const Text('Guardar'),
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
          hintText: 'Buscar en la playlist',
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
