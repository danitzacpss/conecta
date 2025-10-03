import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:conecta_app/features/home/domain/entities/media_item.dart';
import 'package:conecta_app/features/library/presentation/playlists_screen.dart';

class SearchSongsModal extends ConsumerStatefulWidget {
  final String? playlistId;

  const SearchSongsModal({
    super.key,
    this.playlistId,
  });

  @override
  ConsumerState<SearchSongsModal> createState() => _SearchSongsModalState();
}

class _SearchSongsModalState extends ConsumerState<SearchSongsModal> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Simulamos una lista de canciones disponibles
  List<MediaItem> _getAllSongs() {
    return const [
      MediaItem(
        id: '1',
        title: 'Sol y Arena',
        artists: ['Ritmo Latino'],
        artworkUrl: 'https://picsum.photos/seed/song1/400/400',
        type: MediaType.track,
        duration: Duration(minutes: 3, seconds: 45),
      ),
      MediaItem(
        id: '2',
        title: 'Olas de Neón',
        artists: ['Aurora Dream'],
        artworkUrl: 'https://picsum.photos/seed/song2/400/400',
        type: MediaType.track,
        duration: Duration(minutes: 4, seconds: 20),
      ),
      MediaItem(
        id: '3',
        title: 'Brisa Tropical',
        artists: ['Leo Cósmico'],
        artworkUrl: 'https://picsum.photos/seed/song3/400/400',
        type: MediaType.track,
        duration: Duration(minutes: 3, seconds: 30),
      ),
      MediaItem(
        id: '4',
        title: 'Noche Estrellada',
        artists: ['The Nightwalkers'],
        artworkUrl: 'https://picsum.photos/seed/song4/400/400',
        type: MediaType.track,
        duration: Duration(minutes: 4, seconds: 10),
      ),
      MediaItem(
        id: '5',
        title: 'Amanecer Dorado',
        artists: ['Solsticio'],
        artworkUrl: 'https://picsum.photos/seed/song5/400/400',
        type: MediaType.track,
        duration: Duration(minutes: 3, seconds: 55),
      ),
      MediaItem(
        id: '6',
        title: 'Ritmo de Playa',
        artists: ['Marea Alta'],
        artworkUrl: 'https://picsum.photos/seed/song6/400/400',
        type: MediaType.track,
        duration: Duration(minutes: 3, seconds: 40),
      ),
      MediaItem(
        id: '7',
        title: 'Atardecer',
        artists: ['Horizonte'],
        artworkUrl: 'https://picsum.photos/seed/song7/400/400',
        type: MediaType.track,
        duration: Duration(minutes: 4, seconds: 5),
      ),
      MediaItem(
        id: '8',
        title: 'Palmeras',
        artists: ['Tropical Vibes'],
        artworkUrl: 'https://picsum.photos/seed/song8/400/400',
        type: MediaType.track,
        duration: Duration(minutes: 3, seconds: 25),
      ),
      MediaItem(
        id: '9',
        title: 'Luna Creciente',
        artists: ['Noctambulo'],
        artworkUrl: 'https://picsum.photos/seed/song9/400/400',
        type: MediaType.track,
        duration: Duration(minutes: 4, seconds: 30),
      ),
      MediaItem(
        id: '10',
        title: 'Cielo Azul',
        artists: ['Ventisca'],
        artworkUrl: 'https://picsum.photos/seed/song10/400/400',
        type: MediaType.track,
        duration: Duration(minutes: 3, seconds: 50),
      ),
    ];
  }

  List<MediaItem> _filterSongs() {
    final songs = _getAllSongs();
    if (_searchQuery.isEmpty) {
      return songs;
    }
    return songs.where((song) {
      final title = song.title.toLowerCase();
      final artist = song.artists.join(' ').toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query) || artist.contains(query);
    }).toList();
  }

  void _addSongToPlaylist(BuildContext context, MediaItem song) {
    Navigator.pop(context, song);
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '';
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  bool _isSongInPlaylist(MediaItem song) {
    if (widget.playlistId == null) return false;

    final playlistSongs = ref.watch(playlistSongsProvider);
    final currentSongs = playlistSongs[widget.playlistId] ?? [];

    return currentSongs.any((s) => s.id == song.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredSongs = _filterSongs();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
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

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(
                    Icons.library_music,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Buscar canciones',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Búsqueda
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Buscar por título o artista',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            // Lista de canciones
            Flexible(
              child: filteredSongs.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.music_note_outlined,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No se encontraron canciones',
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
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredSongs.length,
                      itemBuilder: (context, index) {
                        final song = filteredSongs[index];
                        final isAlreadyAdded = _isSongInPlaylist(song);

                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: song.artworkUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 50,
                                height: 50,
                                color: theme.colorScheme.primary.withOpacity(0.1),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: theme.colorScheme.primary,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.music_note,
                                  color: theme.colorScheme.primary,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            song.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isAlreadyAdded
                                ? theme.colorScheme.onSurfaceVariant.withOpacity(0.5)
                                : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            isAlreadyAdded
                              ? 'Ya está en la playlist'
                              : '${song.artists.join(', ')} • ${_formatDuration(song.duration)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isAlreadyAdded
                                ? theme.colorScheme.onSurfaceVariant.withOpacity(0.5)
                                : theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Icon(
                            isAlreadyAdded ? Icons.check_circle : Icons.add_circle_outline,
                            color: isAlreadyAdded
                              ? theme.colorScheme.onSurfaceVariant.withOpacity(0.5)
                              : theme.colorScheme.primary,
                          ),
                          enabled: !isAlreadyAdded,
                          onTap: isAlreadyAdded ? null : () => _addSongToPlaylist(context, song),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
