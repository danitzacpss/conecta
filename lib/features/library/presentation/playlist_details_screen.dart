import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PlaylistDetailsScreen extends ConsumerStatefulWidget {
  const PlaylistDetailsScreen({
    super.key,
    this.playlistName,
    this.isAlbum = false,
    this.isOwner = true,
    this.ownerName,
    this.artistName,
  });

  static const routePath = '/playlist-details';
  static const routeName = 'playlistDetails';

  final String? playlistName;
  final bool isAlbum;
  final bool isOwner;
  final String? ownerName;
  final String? artistName;

  @override
  ConsumerState<PlaylistDetailsScreen> createState() => _PlaylistDetailsScreenState();
}

class _PlaylistDetailsScreenState extends ConsumerState<PlaylistDetailsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isShuffleOn = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar
          SliverAppBar(
            pinned: false,
            floating: true,
            backgroundColor: theme.colorScheme.surface,
            elevation: 0,
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
                    }
                  });
                },
                icon: Icon(_isSearching ? Icons.close : Icons.search),
              ),
              IconButton(
                onPressed: () {
                  _showOptionsMenu(context);
                },
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),

          // Contenido principal
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Buscador (solo visible cuando está activo)
                  if (_isSearching) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
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
                      onChanged: (value) {
                        // Filtrar canciones
                        setState(() {});
                      },
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Imagen de la playlist
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
                    child: ClipRRect(
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
                    widget.playlistName ?? 'Playlist',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Subtítulo - Artista o Dueño
                  Text(
                    widget.isAlbum
                      ? 'Álbum de ${widget.artistName ?? "Artista Desconocido"}'
                      : 'Playlist de ${widget.ownerName ?? "Usuario"}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Info: canciones y duración
                  Text(
                    '25 canciones • 1 h 30 min',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Botones Play y Shuffle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Botón Play
                      ElevatedButton.icon(
                        onPressed: () {
                          // Reproducir playlist
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Play'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Botón Shuffle
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isShuffleOn = !_isShuffleOn;
                          });
                          // Reproducir en aleatorio
                        },
                        icon: const Icon(Icons.shuffle),
                        label: const Text('Shuffle'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _isShuffleOn
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                          backgroundColor: _isShuffleOn
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          side: BorderSide(
                            color: _isShuffleOn
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Lista de canciones
                  _buildSongTile(
                    number: '1',
                    title: 'Sol y Arena',
                    artist: 'Ritmo Latino',
                    isLiked: true,
                    theme: theme,
                  ),
                  _buildSongTile(
                    number: '2',
                    title: 'Olas de Neón',
                    artist: 'Aurora Dream',
                    isLiked: false,
                    theme: theme,
                  ),
                  _buildSongTile(
                    number: '3',
                    title: 'Brisa Tropical',
                    artist: 'Leo Cósmico',
                    isLiked: false,
                    theme: theme,
                  ),
                  _buildSongTile(
                    number: '4',
                    title: 'Noche Estrellada',
                    artist: 'The Nightwalkers',
                    isLiked: true,
                    theme: theme,
                  ),
                  _buildSongTile(
                    number: '5',
                    title: 'Amanecer Dorado',
                    artist: 'Solsticio',
                    isLiked: false,
                    theme: theme,
                  ),
                  _buildSongTile(
                    number: '6',
                    title: 'Ritmo de Playa',
                    artist: 'Marea Alta',
                    isLiked: false,
                    theme: theme,
                  ),
                  _buildSongTile(
                    number: '7',
                    title: 'Atardecer',
                    artist: 'Horizonte',
                    isLiked: false,
                    theme: theme,
                  ),
                  _buildSongTile(
                    number: '8',
                    title: 'Palmeras',
                    artist: 'Tropical Vibes',
                    isLiked: false,
                    theme: theme,
                  ),

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
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      leading: SizedBox(
        width: 40,
        child: Center(
          child: Text(
            number,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
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
            onPressed: () {
              // Toggle like
            },
            icon: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? Colors.red : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          IconButton(
            onPressed: () {
              _showSongOptionsMenu(title);
            },
            icon: Icon(
              Icons.more_vert,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      onTap: () {
        // Reproducir canción
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
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.download_for_offline),
              title: Text(widget.isAlbum ? 'Descargar todo el álbum' : 'Descargar toda la playlist'),
              subtitle: const Text('25 canciones'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(widget.isAlbum ? 'Descargando álbum...' : 'Descargando playlist...')),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Compartir'),
              onTap: () => Navigator.pop(context),
            ),
            // Solo mostrar opciones de edición si es dueño y no es álbum
            if (!widget.isAlbum && widget.isOwner) ...[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar playlist'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Eliminar playlist'),
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: () => Navigator.pop(context),
              ),
            ],
            // Mostrar para todos (excepto álbumes propios)
            if (!widget.isAlbum || !widget.isOwner)
              ListTile(
                leading: const Icon(Icons.playlist_add),
                title: const Text('Añadir a otra playlist'),
                onTap: () => Navigator.pop(context),
              ),
            // Opción para ir al artista si es álbum
            if (widget.isAlbum)
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Ver artista'),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/artist-profile');
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showSongOptionsMenu(String songTitle) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                songTitle,
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
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.album),
              title: const Text('Ver álbum'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Ver artista'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Compartir'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Descargar'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Quitar de la playlist'),
              textColor: Colors.red,
              iconColor: Colors.red,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
