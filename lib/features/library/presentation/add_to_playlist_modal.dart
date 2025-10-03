import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:conecta_app/features/library/presentation/playlists_screen.dart';
import 'package:conecta_app/features/library/presentation/create_playlist_modal.dart';
import 'package:conecta_app/features/library/presentation/library_screen.dart';

class AddToPlaylistModal extends ConsumerStatefulWidget {
  const AddToPlaylistModal({
    super.key,
    this.songId,
    this.songTitle,
    this.songArtist,
    this.mode = AddToPlaylistMode.addToPlaylist,
  });

  final String? songId;
  final String? songTitle;
  final String? songArtist;
  final AddToPlaylistMode mode;

  @override
  ConsumerState<AddToPlaylistModal> createState() => _AddToPlaylistModalState();
}

enum AddToPlaylistMode {
  addToPlaylist, // Añadir una canción a una playlist
  searchSongs,   // Buscar canciones para añadir a la playlist actual
}

class _AddToPlaylistModalState extends ConsumerState<AddToPlaylistModal> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PlaylistItem> _filterPlaylists(List<PlaylistItem> playlists) {
    // Solo mostrar mis playlists (donde soy owner)
    var myPlaylists = playlists.where((p) => p.isOwner).toList();

    if (_searchQuery.isEmpty) {
      return myPlaylists;
    }
    return myPlaylists.where((playlist) {
      return playlist.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _addToPlaylist(BuildContext context, PlaylistItem playlist) {
    // Aquí se añadiría la canción a la playlist en la base de datos
    // Por ahora solo mostramos confirmación
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${widget.songTitle}" añadida a "${playlist.name}"'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _createNewPlaylist(BuildContext context) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) => const CreatePlaylistModal(),
    );

    if (result != null && mounted) {
      // Crear la playlist con los datos recibidos
      ref.read(newLibraryProvider.notifier).createPlaylist(
        name: result['name'] as String,
        description: result['description'] as String? ?? '',
        isPrivate: result['isPrivate'] as bool? ?? false,
      );

      // Mostrar confirmación
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Playlist "${result['name']}" creada y canción añadida'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allPlaylists = ref.watch(playlistsProvider);
    final filteredPlaylists = _filterPlaylists(allPlaylists);

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
                    Icons.playlist_add,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Añadir a playlist',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.songTitle ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
                decoration: InputDecoration(
                  hintText: 'Buscar playlist',
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

            // Botón crear nueva playlist
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: InkWell(
                onTap: () => _createNewPlaylist(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Crear nueva playlist',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Lista de playlists
            Flexible(
              child: filteredPlaylists.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.queue_music_outlined,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No tienes playlists'
                                : 'No se encontraron playlists',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isEmpty
                                ? 'Crea una para empezar'
                                : 'Intenta con otro término',
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
                      itemCount: filteredPlaylists.length,
                      itemBuilder: (context, index) {
                        final playlist = filteredPlaylists[index];
                        return ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(playlist.imageUrl),
                                fit: BoxFit.cover,
                                onError: (_, __) {},
                              ),
                            ),
                            child: playlist.imageUrl.isEmpty
                                ? Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          theme.colorScheme.primary,
                                          theme.colorScheme.secondary,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.queue_music,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  )
                                : null,
                          ),
                          title: Text(
                            playlist.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${playlist.songCount} canciones',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          trailing: Icon(
                            Icons.add_circle_outline,
                            color: theme.colorScheme.primary,
                          ),
                          onTap: () => _addToPlaylist(context, playlist),
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
