import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:conecta_app/features/library/presentation/artists_screen.dart';
import 'package:conecta_app/core/widgets/share_modal.dart';
import 'package:conecta_app/core/utils/snackbar_utils.dart';
import 'package:conecta_app/features/home/domain/entities/media_item.dart';
import 'package:conecta_app/features/player/presentation/providers/now_playing_provider.dart';
import 'package:conecta_app/features/library/presentation/providers/liked_songs_provider.dart';
import 'package:conecta_app/features/library/presentation/add_to_playlist_modal.dart';
import 'package:conecta_app/features/library/presentation/playlist_details_screen.dart';
import 'package:conecta_app/features/events/presentation/event_details_screen.dart';

class ArtistProfileScreen extends ConsumerStatefulWidget {
  const ArtistProfileScreen({
    super.key,
    this.artistId,
    this.artistName,
  });

  static const routePath = '/artist-profile';
  static const routeName = 'artistProfile';

  final String? artistId;
  final String? artistName;

  @override
  ConsumerState<ArtistProfileScreen> createState() => _ArtistProfileScreenState();
}

class _ArtistProfileScreenState extends ConsumerState<ArtistProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;
  late List<MediaItem> _popularSongs;

  @override
  void initState() {
    super.initState();
    _initializeSongs();
    _scrollController.addListener(() {
      // Detectar si el AppBar está colapsado (cuando el scroll > expandedHeight - toolbar height)
      // expandedHeight = 300, kToolbarHeight ≈ 56
      final isCollapsed = _scrollController.hasClients &&
          _scrollController.offset > (300 - kToolbarHeight - 50);

      if (_isCollapsed != isCollapsed) {
        setState(() {
          _isCollapsed = isCollapsed;
        });
      }
    });
  }

  void _initializeSongs() {
    _popularSongs = [
      MediaItem(
        id: 'song1',
        title: 'Estrella Fugaz',
        artists: [widget.artistName ?? 'Aurora Dream'],
        artworkUrl: 'https://picsum.photos/seed/song1/300/300',
        duration: const Duration(minutes: 3, seconds: 45),
        type: MediaType.track,
        isLiked: false,
        isDownloaded: true,
      ),
      MediaItem(
        id: 'song2',
        title: 'Amanecer Contigo',
        artists: [widget.artistName ?? 'Aurora Dream'],
        artworkUrl: 'https://picsum.photos/seed/song2/300/300',
        duration: const Duration(minutes: 4, seconds: 12),
        type: MediaType.track,
        isLiked: false,
        isDownloaded: false,
      ),
      MediaItem(
        id: 'song3',
        title: 'Luces de la Ciudad',
        artists: [widget.artistName ?? 'Aurora Dream'],
        artworkUrl: 'https://picsum.photos/seed/song3/300/300',
        duration: const Duration(minutes: 3, seconds: 58),
        type: MediaType.track,
        isLiked: false,
        isDownloaded: false,
      ),
    ];
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final artistsController = ref.watch(followedArtistsProvider.notifier);
    final isFollowing = ref.watch(followedArtistsProvider).any(
      (artist) => artist.id == (widget.artistId ?? '1'),
    );

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar con imagen de fondo
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.black.withOpacity(0.15),
            elevation: 8,
            leading: IconButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
              icon: Icon(
                Icons.arrow_back,
                color: _isCollapsed ? theme.colorScheme.onSurface : Colors.white,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                widget.artistName ?? 'Aurora Dream',
                style: TextStyle(
                  color: _isCollapsed ? theme.colorScheme.onSurface : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://picsum.photos/seed/radioProfile/400/600',
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
                    ),
                  ),
                  // Gradiente overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenido principal
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información del artista
                  Row(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.primary,
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            'https://picsum.photos/seed/aurora/200/200',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          'Aurora Dream es una artista que fusiona el dream pop con toques de electrónica, creando paisajes sonoros etéreos y melodías inolvidables.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (isFollowing) {
                              // Dejar de seguir
                              artistsController.unfollowArtist(widget.artistId ?? '1');
                            } else {
                              // Seguir al artista
                              final newArtist = Artist(
                                id: widget.artistId ?? '1',
                                name: widget.artistName ?? 'Aurora Dream',
                                imageUrl: 'https://picsum.photos/seed/aurora/200/200',
                                songCount: 45,
                              );
                              artistsController.followArtist(newArtist);
                            }
                          },
                          icon: Icon(isFollowing ? Icons.notifications_active : Icons.notifications_outlined),
                          label: Text(isFollowing ? 'Siguiendo' : 'Seguir'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFollowing
                                ? theme.colorScheme.surfaceContainerHighest
                                : theme.colorScheme.primary,
                            foregroundColor: isFollowing
                                ? theme.colorScheme.onSurface
                                : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showShareModal(
                              context,
                              title: widget.artistName ?? 'Aurora Dream',
                              description: 'Compartir perfil de artista',
                              iconColor: theme.colorScheme.primary,
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
                          icon: const Icon(Icons.share_outlined),
                          label: const Text('Compartir'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            foregroundColor: theme.colorScheme.onSurface,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Álbumes
                  _buildSection(
                    title: 'Álbumes',
                    child: SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          final albums = [
                            {
                              'title': 'Ecos del Mañana',
                              'year': '2023',
                              'image': 'https://picsum.photos/seed/album1/300/300',
                            },
                            {
                              'title': 'Cielos de Neón',
                              'year': '2021',
                              'image': 'https://picsum.photos/seed/album2/300/300',
                            },
                            {
                              'title': 'Ocean Mind',
                              'year': '2020',
                              'image': 'https://picsum.photos/seed/album3/300/300',
                            },
                          ];
                          final album = albums[index];
                          return _buildAlbumCard(album, theme);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sencillos Populares
                  _buildSection(
                    title: 'Sencillos Populares',
                    child: Column(
                      children: _popularSongs
                          .asMap()
                          .entries
                          .map((entry) => _buildSongListItem(
                                entry.value,
                                entry.key,
                                theme,
                              ))
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Playlists Destacadas
                  _buildSection(
                    title: 'Playlists Destacadas',
                    child: SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 2,
                        itemBuilder: (context, index) {
                          final playlists = [
                            {
                              'title': 'Aurora Dream: Esenciales',
                              'subtitle': 'Playlist',
                              'image': 'https://picsum.photos/seed/playlist1/300/300',
                            },
                            {
                              'title': 'Dream Pop Hits',
                              'subtitle': 'Playlist',
                              'image': 'https://picsum.photos/seed/playlist2/300/300',
                            },
                          ];
                          final playlist = playlists[index];
                          return _buildPlaylistCard(playlist, theme);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Próximos Eventos
                  _buildSection(
                    title: 'Próximos Eventos',
                    child: Column(
                      children: [
                        _buildEventCard(
                          title: 'Gira "Ecos Tour" - Ciudad de México',
                          date: 'JUL\n28',
                          venue: 'Foro Sol, 8:00 PM',
                          theme: theme,
                        ),
                        const SizedBox(height: 12),
                        _buildEventCard(
                          title: 'Festival de Música Indie',
                          date: 'AGO\n15',
                          venue: 'Parque Central, 7:00 PM',
                          theme: theme,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  const SizedBox(height: 160), // Espacio para mini reproductor y nav bar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildAlbumCard(Map<String, String> album, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        context.push(
          '/playlist-details',
          extra: {
            'playlistName': album['title']!,
            'isAlbum': true,
            'isOwner': false,
            'artistName': widget.artistName ?? 'Aurora Dream',
          },
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  album['image']!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.album,
                      size: 60,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              album['title']!,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              album['year']!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongListItem(MediaItem song, int index, ThemeData theme) {
    final nowPlaying = ref.watch(nowPlayingProvider);
    final isCurrentSong = nowPlaying.item.id == song.id;
    final likedSongs = ref.watch(likedSongsProvider);
    final isLiked = likedSongs.any((item) => item.id == song.id);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              song.artworkUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.music_note,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          if (song.isDownloaded)
            Positioned(
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
            ),
        ],
      ),
      title: Text(
        song.title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: isCurrentSong ? theme.colorScheme.primary : null,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artists.join(', '),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              ref.read(likedSongsProvider.notifier).toggleLike(song);
            },
            icon: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? Colors.pink : null,
            ),
          ),
          IconButton(
            onPressed: () {
              _showSongOptionsMenu(song);
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      onTap: () {
        ref.read(nowPlayingProvider.notifier).play(song);
      },
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
                    context.push('/artist-profile');
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
                ListTile(
                  leading: Icon(song.isDownloaded ? Icons.download_done : Icons.download),
                  title: Text(song.isDownloaded ? 'Descargada' : 'Descargar'),
                  enabled: !song.isDownloaded,
                  onTap: song.isDownloaded ? null : () {
                    Navigator.pop(context);
                    // Actualizar el estado de la canción
                    setState(() {
                      final index = _popularSongs.indexWhere((s) => s.id == song.id);
                      if (index != -1) {
                        _popularSongs[index] = _popularSongs[index].copyWith(isDownloaded: true);
                      }
                    });
                    SnackBarUtils.showSuccess(
                      context,
                      'Descargando "${song.title}"...',
                      duration: const Duration(seconds: 2),
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

  Widget _buildPlaylistCard(Map<String, String> playlist, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        context.push(
          PlaylistDetailsScreen.routePath,
          extra: {
            'playlistName': playlist['title']!,
            'isAlbum': false,
            'isOwner': false,
            'ownerName': widget.artistName ?? 'Aurora Dream',
            'description': 'Playlist curada por ${widget.artistName ?? 'Aurora Dream'}',
          },
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  playlist['image']!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.playlist_play,
                      size: 40,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              playlist['title']!,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              playlist['subtitle']!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard({
    required String title,
    required String date,
    required String venue,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: () {
        context.push(
          EventDetailsScreen.routePath,
          extra: {
            'eventTitle': title,
            'eventDate': date.replaceAll('\n', ' '),
            'eventVenue': venue,
            'artistName': widget.artistName ?? 'Aurora Dream',
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  date,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    venue,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}