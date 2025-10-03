import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:conecta_app/features/home/domain/entities/media_item.dart';
import 'package:conecta_app/features/scanner/presentation/audio_scanner_modal.dart';
import 'package:conecta_app/features/library/presentation/create_playlist_modal.dart';
import 'package:conecta_app/features/library/presentation/playlist_details_screen.dart';
import 'package:conecta_app/features/library/presentation/artists_screen.dart';
import 'package:conecta_app/features/library/presentation/albums_screen.dart';
import 'package:conecta_app/features/library/presentation/subscriptions_screen.dart';
import 'package:conecta_app/features/library/presentation/saved_vods_screen.dart';
import 'package:conecta_app/features/library/presentation/playlists_screen.dart';
import 'package:conecta_app/features/library/presentation/following_screen.dart';
import 'package:conecta_app/features/player/presentation/view/vod_player_screen.dart';
import 'package:conecta_app/features/radio/presentation/radio_profile_screen.dart';
import 'package:conecta_app/features/library/presentation/providers/liked_songs_provider.dart';

final newLibraryProvider = StateNotifierProvider<LibraryController, LibraryData>(
  (ref) => LibraryController(ref),
);

class LibraryController extends StateNotifier<LibraryData> {
  final Ref ref;

  LibraryController(this.ref) : super(LibraryData()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.delayed(const Duration(milliseconds: 250));
    final likedSongsCount = ref.read(likedSongsProvider).length;
    final followedArtistsCount = ref.read(followedArtistsProvider).length;
    final followingUsersCount = ref.read(followingUsersProvider).length;
    final savedAlbumsCount = ref.read(savedAlbumsProvider).length;
    final playlistsCount = ref.read(playlistsProvider).length;
    final radioSubscriptionsCount = ref.read(subscribedRadiosProvider).length;
    final savedVodsCount = ref.read(savedVodsProvider).length;
    state = LibraryData(
      searchResults: [],
      categories: _getLibraryCategories(likedSongsCount, followedArtistsCount, followingUsersCount, savedAlbumsCount, playlistsCount, radioSubscriptionsCount, savedVodsCount),
      recentItems: _getRecentItems(),
    );
  }

  Future<void> loadInitialData() async {
    await _loadInitialData();
  }

  void updateLikedSongsCount(int count) {
    final followedArtistsCount = ref.read(followedArtistsProvider).length;
    final followingUsersCount = ref.read(followingUsersProvider).length;
    final savedAlbumsCount = ref.read(savedAlbumsProvider).length;
    final playlistsCount = ref.read(playlistsProvider).length;
    final radioSubscriptionsCount = ref.read(subscribedRadiosProvider).length;
    final savedVodsCount = ref.read(savedVodsProvider).length;
    state = state.copyWith(
      categories: _getLibraryCategories(count, followedArtistsCount, followingUsersCount, savedAlbumsCount, playlistsCount, radioSubscriptionsCount, savedVodsCount),
    );
  }

  void updateFollowedArtistsCount(int count) {
    final likedSongsCount = ref.read(likedSongsProvider).length;
    final followingUsersCount = ref.read(followingUsersProvider).length;
    final savedAlbumsCount = ref.read(savedAlbumsProvider).length;
    final playlistsCount = ref.read(playlistsProvider).length;
    final radioSubscriptionsCount = ref.read(subscribedRadiosProvider).length;
    final savedVodsCount = ref.read(savedVodsProvider).length;
    state = state.copyWith(
      categories: _getLibraryCategories(likedSongsCount, count, followingUsersCount, savedAlbumsCount, playlistsCount, radioSubscriptionsCount, savedVodsCount),
    );
  }

  void updateFollowingUsersCount(int count) {
    final likedSongsCount = ref.read(likedSongsProvider).length;
    final followedArtistsCount = ref.read(followedArtistsProvider).length;
    final savedAlbumsCount = ref.read(savedAlbumsProvider).length;
    final playlistsCount = ref.read(playlistsProvider).length;
    final radioSubscriptionsCount = ref.read(subscribedRadiosProvider).length;
    final savedVodsCount = ref.read(savedVodsProvider).length;
    state = state.copyWith(
      categories: _getLibraryCategories(likedSongsCount, followedArtistsCount, count, savedAlbumsCount, playlistsCount, radioSubscriptionsCount, savedVodsCount),
    );
  }

  void updateSavedAlbumsCount(int count) {
    final likedSongsCount = ref.read(likedSongsProvider).length;
    final followedArtistsCount = ref.read(followedArtistsProvider).length;
    final followingUsersCount = ref.read(followingUsersProvider).length;
    final playlistsCount = ref.read(playlistsProvider).length;
    final radioSubscriptionsCount = ref.read(subscribedRadiosProvider).length;
    final savedVodsCount = ref.read(savedVodsProvider).length;
    state = state.copyWith(
      categories: _getLibraryCategories(likedSongsCount, followedArtistsCount, followingUsersCount, count, playlistsCount, radioSubscriptionsCount, savedVodsCount),
    );
  }

  Future<void> search(String query, {
    required List<Album> albums,
    required List<Artist> artists,
    required List<UserFollow> followingUsers,
    required List<PlaylistItem> playlists,
    required List<RadioSubscription> radioSubscriptions,
    required List<MediaItem> savedVods,
  }) async {
    if (query.isEmpty) {
      // Restaurar el estado inicial
      state = state.copyWith(searchResults: []);
      return;
    }

    await Future.delayed(const Duration(milliseconds: 100));
    final results = <LibrarySearchResult>[];
    final lowerQuery = query.toLowerCase();

    // Obtener el provider de canciones de playlists para contar dinámicamente
    final playlistSongs = ref.read(playlistSongsProvider);

    // Buscar en playlists
    for (final playlist in playlists) {
      if (playlist.name.toLowerCase().contains(lowerQuery)) {
        final actualSongCount = playlistSongs[playlist.id]?.length ?? 0;
        results.add(LibrarySearchResult(
          title: playlist.name,
          subtitle: '$actualSongCount ${actualSongCount == 1 ? 'canción' : 'canciones'}',
          type: 'playlist',
          imageUrl: playlist.imageUrl,
          data: playlist,
        ));
      }
    }

    // Buscar en álbumes
    for (final album in albums) {
      if (album.name.toLowerCase().contains(lowerQuery) ||
          album.artist.toLowerCase().contains(lowerQuery)) {
        results.add(LibrarySearchResult(
          title: album.name,
          subtitle: album.artist,
          type: 'album',
          imageUrl: album.imageUrl,
          data: album,
        ));
      }
    }

    // Buscar en artistas
    for (final artist in artists) {
      if (artist.name.toLowerCase().contains(lowerQuery)) {
        results.add(LibrarySearchResult(
          title: artist.name,
          subtitle: '${artist.songCount} canciones',
          type: 'artist',
          imageUrl: artist.imageUrl,
          data: artist,
        ));
      }
    }

    // Buscar en usuarios seguidos
    for (final user in followingUsers) {
      if (user.name.toLowerCase().contains(lowerQuery) ||
          user.username.toLowerCase().contains(lowerQuery)) {
        results.add(LibrarySearchResult(
          title: user.name,
          subtitle: user.username,
          type: 'user',
          imageUrl: user.avatarUrl,
          data: user,
        ));
      }
    }

    // Buscar en suscripciones de radio
    for (final radio in radioSubscriptions) {
      if (radio.name.toLowerCase().contains(lowerQuery)) {
        results.add(LibrarySearchResult(
          title: radio.name,
          subtitle: 'Radio en vivo',
          type: 'radio',
          imageUrl: radio.imageUrl,
          data: radio,
        ));
      }
    }

    // Buscar en VODs guardados
    for (final vod in savedVods) {
      if (vod.title.toLowerCase().contains(lowerQuery) ||
          vod.artists.any((artist) => artist.toLowerCase().contains(lowerQuery))) {
        results.add(LibrarySearchResult(
          title: vod.title,
          subtitle: vod.artists.join(', '),
          type: 'vod',
          imageUrl: vod.artworkUrl,
          data: vod,
        ));
      }
    }

    state = state.copyWith(searchResults: results);
  }

  void createPlaylist({
    required String name,
    String description = '',
    bool isPrivate = false,
  }) {
    // Crear nueva playlist como item reciente
    final newRecentItem = RecentItem(
      id: 'playlist_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      subtitle: '0 canciones',
      imageUrl: 'https://picsum.photos/seed/${name.hashCode}/300/300',
      type: RecentItemType.playlist,
    );

    // Agregar al inicio de la lista de recientes
    final updatedRecentItems = [newRecentItem, ...state.recentItems];

    state = state.copyWith(recentItems: updatedRecentItems);
  }

  List<LibraryCategory> _getLibraryCategories(int likedSongsCount, int followedArtistsCount, int followingUsersCount, int savedAlbumsCount, int playlistsCount, int radioSubscriptionsCount, int savedVodsCount) {
    return [
      LibraryCategory(
        id: 'songs',
        title: 'Canciones',
        subtitle: '$likedSongsCount',
        icon: Icons.favorite,
        color: Colors.pink,
      ),
      LibraryCategory(
        id: 'artists',
        title: 'Artistas',
        subtitle: '$followedArtistsCount',
        icon: Icons.person,
        color: Colors.blue,
      ),
      LibraryCategory(
        id: 'following',
        title: 'Siguiendo',
        subtitle: '$followingUsersCount',
        icon: Icons.people,
        color: Colors.teal,
      ),
      LibraryCategory(
        id: 'albums',
        title: 'Álbumes',
        subtitle: '$savedAlbumsCount',
        icon: Icons.album,
        color: Colors.purple,
      ),
      LibraryCategory(
        id: 'playlists',
        title: 'Playlists',
        subtitle: '$playlistsCount',
        icon: Icons.queue_music,
        color: Colors.orange,
      ),
      LibraryCategory(
        id: 'subscriptions',
        title: 'Radios',
        subtitle: '$radioSubscriptionsCount',
        icon: Icons.radio,
        color: Colors.green,
      ),
      LibraryCategory(
        id: 'vod',
        title: 'VOD Guardados',
        subtitle: '$savedVodsCount',
        icon: Icons.video_library,
        color: Colors.indigo,
      ),
    ];
  }

  List<RecentItem> _getRecentItems() {
    return [
      RecentItem(
        id: '1',
        name: 'Pop para entrenar',
        subtitle: '25 canciones',
        imageUrl: 'https://picsum.photos/seed/playlist1/300/300',
        type: RecentItemType.playlist,
      ),
      RecentItem(
        id: '2',
        name: 'Radio Milenium',
        subtitle: 'Radio en vivo',
        imageUrl: 'https://picsum.photos/seed/radio1/300/300',
        type: RecentItemType.radio,
      ),
      RecentItem(
        id: '3',
        name: 'Sunset Dreams',
        subtitle: 'Ritmo Latino • Álbum',
        imageUrl: 'https://picsum.photos/seed/album1/300/300',
        type: RecentItemType.album,
      ),
      RecentItem(
        id: '4',
        name: 'Rock de los 90',
        subtitle: '50 canciones',
        imageUrl: 'https://picsum.photos/seed/playlist2/300/300',
        type: RecentItemType.playlist,
      ),
      RecentItem(
        id: '5',
        name: 'Concierto Especial 2024',
        subtitle: 'Video • 45 min',
        imageUrl: 'https://picsum.photos/seed/vod1/400/225',
        type: RecentItemType.vod,
      ),
    ];
  }
}

class LibraryData {
  LibraryData({
    this.searchResults = const [],
    this.categories = const [],
    this.recentItems = const [],
  });

  final List<LibrarySearchResult> searchResults;
  final List<LibraryCategory> categories;
  final List<RecentItem> recentItems;

  LibraryData copyWith({
    List<LibrarySearchResult>? searchResults,
    List<LibraryCategory>? categories,
    List<RecentItem>? recentItems,
  }) {
    return LibraryData(
      searchResults: searchResults ?? this.searchResults,
      categories: categories ?? this.categories,
      recentItems: recentItems ?? this.recentItems,
    );
  }
}

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  static const routePath = '/library';
  static const routeName = 'library';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryData = ref.watch(newLibraryProvider);
    final theme = Theme.of(context);

    // Watch all library providers for search
    final savedAlbums = ref.watch(savedAlbumsProvider);
    final followedArtists = ref.watch(followedArtistsProvider);
    final followingUsers = ref.watch(followingUsersProvider);
    final playlists = ref.watch(playlistsProvider);
    final radioSubscriptions = ref.watch(subscribedRadiosProvider);
    final savedVods = ref.watch(savedVodsProvider);

    // Watch liked songs to update the count
    final likedSongs = ref.watch(likedSongsProvider);

    // Asegurar que los datos iniciales estén cargados
    Future.microtask(() {
      if (libraryData.categories.isEmpty) {
        ref.read(newLibraryProvider.notifier).loadInitialData();
      } else {
        // Update liked songs count when it changes
        ref.read(newLibraryProvider.notifier).updateLikedSongsCount(likedSongs.length);
        // Update followed artists count when it changes
        ref.read(newLibraryProvider.notifier).updateFollowedArtistsCount(followedArtists.length);
        // Update following users count when it changes
        ref.read(newLibraryProvider.notifier).updateFollowingUsersCount(followingUsers.length);
        // Update saved albums count when it changes
        ref.read(newLibraryProvider.notifier).updateSavedAlbumsCount(savedAlbums.length);
      }
    });

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.light
        ? Colors.grey[100]
        : theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header minimalista con SafeArea
          Container(
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
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Biblioteca',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _showScannerModal(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.qr_code_scanner,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Contenido principal
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Buscar en tu biblioteca...',
                          hintStyle: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                        onChanged: (value) => ref.read(newLibraryProvider.notifier).search(
                          value,
                          albums: savedAlbums,
                          artists: followedArtists,
                          followingUsers: followingUsers,
                          playlists: playlists,
                          radioSubscriptions: radioSubscriptions,
                          savedVods: savedVods,
                        ),
                      ),
                    ),
                  ),
                  if (libraryData.searchResults.isNotEmpty)
                    _buildSearchResults(context, theme, libraryData)
                  else ...[
                    _buildCreatePlaylistButton(context, theme, ref),
                    _buildMainContent(context, theme, libraryData),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatePlaylistButton(BuildContext context, ThemeData theme, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: InkWell(
        onTap: () async {
          final result = await showModalBottomSheet<Map<String, dynamic>>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            useRootNavigator: true,
            builder: (context) => const CreatePlaylistModal(),
          );

          if (result != null && context.mounted) {
            // Crear la playlist con los datos recibidos
            ref.read(newLibraryProvider.notifier).createPlaylist(
              name: result['name'] as String,
              description: result['description'] as String? ?? '',
              isPrivate: result['isPrivate'] as bool? ?? false,
            );

            // Mostrar confirmación
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Playlist "${result['name']}" creada exitosamente'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.1),
                theme.colorScheme.secondary.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.3),
              width: 2,
              style: BorderStyle.solid,
            ),
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
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Crear nueva playlist',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Añade tus canciones favoritas',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, ThemeData theme, LibraryData data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoriesGrid(context, theme, data),
          const SizedBox(height: 32),
          _buildRecentItems(context, theme, data),
          const SizedBox(height: 180), // Espacio para mini reproductor y nav bar
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, ThemeData theme, LibraryData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resultados de búsqueda',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          if (data.searchResults.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No se encontraron resultados',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...data.searchResults.map((result) => _buildSearchResultItem(context, theme, result)),
          const SizedBox(height: 180), // Espacio para mini reproductor y nav bar
        ],
      ),
    );
  }


  Widget _buildSearchResultItem(BuildContext context, ThemeData theme, LibrarySearchResult result) {
    IconData icon;
    bool isCircular = false;

    switch (result.type) {
      case 'artist':
        icon = Icons.person;
        isCircular = true;
        break;
      case 'user':
        icon = Icons.person_outline;
        isCircular = true;
        break;
      case 'album':
        icon = Icons.album;
        break;
      case 'playlist':
        icon = Icons.queue_music;
        break;
      case 'radio':
        icon = Icons.radio;
        isCircular = true;
        break;
      case 'vod':
        icon = Icons.video_library;
        break;
      default:
        icon = Icons.music_note;
    }

    return GestureDetector(
      onTap: () => _handleSearchResultTap(context, result),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
              borderRadius: BorderRadius.circular(isCircular ? 25 : 12),
              child: CachedNetworkImage(
                imageUrl: result.imageUrl,
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
                    borderRadius: BorderRadius.circular(isCircular ? 25 : 12),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.primary,
                    size: 24,
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
                    result.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    result.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _handleSearchResultTap(BuildContext context, LibrarySearchResult result) {
    switch (result.type) {
      case 'playlist':
        final playlist = result.data as PlaylistItem;
        context.push(
          PlaylistDetailsScreen.routePath,
          extra: {
            'playlistName': playlist.name,
            'isAlbum': false,
            'isOwner': playlist.isOwner,
            'ownerName': playlist.ownerName ?? 'Usuario',
            'description': playlist.description,
          },
        );
        break;
      case 'album':
        final album = result.data as Album;
        context.push(
          PlaylistDetailsScreen.routePath,
          extra: {
            'playlistName': album.name,
            'isAlbum': true,
            'isOwner': false,
            'artistName': album.artist,
          },
        );
        break;
      case 'artist':
        context.push('/artist-profile');
        break;
      case 'user':
        final user = result.data as UserFollow;
        context.push(
          '/user-profile',
          extra: {
            'userId': user.id,
            'userName': user.name,
          },
        );
        break;
      case 'radio':
        context.push(RadioProfileScreen.routePath);
        break;
      case 'vod':
        final vod = result.data as MediaItem;
        context.push(
          VodPlayerScreen.routePath,
          extra: {
            'videoId': vod.id,
            'videoTitle': vod.title,
          },
        );
        break;
    }
  }

  Widget _buildCategoriesGrid(BuildContext context, ThemeData theme, LibraryData data) {
    if (data.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    // Organizar categorías en filas de 2
    List<List<LibraryCategory>> rows = [];
    for (int i = 0; i < data.categories.length; i += 2) {
      rows.add(data.categories.skip(i).take(2).toList());
    }

    return Column(
      children: rows.map((row) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(child: _buildCategoryCard(context, theme, row[0])),
              const SizedBox(width: 12),
              if (row.length > 1)
                Expanded(child: _buildCategoryCard(context, theme, row[1]))
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        )
      ).toList(),
    );
  }

  Widget _buildCategoryCard(BuildContext context, ThemeData theme, LibraryCategory category) {
    return GestureDetector(
      onTap: () {
        if (category.id == 'songs') {
          context.push(
            PlaylistDetailsScreen.routePath,
            extra: {'isLikedSongs': true},
          );
        } else if (category.id == 'artists') {
          context.push(ArtistsScreen.routePath);
        } else if (category.id == 'albums') {
          context.push(AlbumsScreen.routePath);
        } else if (category.id == 'subscriptions') {
          context.push(SubscriptionsScreen.routePath);
        } else if (category.id == 'vod') {
          context.push(SavedVodsScreen.routePath);
        } else if (category.id == 'playlists') {
          context.push(PlaylistsScreen.routePath);
        } else if (category.id == 'following') {
          context.push(FollowingScreen.routePath);
        }
        // TODO: Agregar navegación para otras categorías
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: category.color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: category.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: category.color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                category.icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (category.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      category.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentItems(BuildContext context, ThemeData theme, LibraryData data) {
    final recentItems = data.recentItems;

    if (recentItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recientes',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        ...recentItems.map((item) => _buildRecentItem(context, theme, item)),
      ],
    );
  }

  Widget _buildRecentItem(BuildContext context, ThemeData theme, RecentItem item) {
    IconData typeIcon;
    switch (item.type) {
      case RecentItemType.radio:
        typeIcon = Icons.radio;
        break;
      case RecentItemType.album:
        typeIcon = Icons.album;
        break;
      case RecentItemType.vod:
        typeIcon = Icons.video_library;
        break;
      case RecentItemType.playlist:
      default:
        typeIcon = Icons.queue_music;
    }

    return GestureDetector(
      onTap: () {
        switch (item.type) {
          case RecentItemType.playlist:
            context.push(
              PlaylistDetailsScreen.routePath,
              extra: {
                'playlistName': item.name,
                'isAlbum': false,
                'isOwner': true,
                'ownerName': 'Usuario',
              },
            );
            break;
          case RecentItemType.album:
            context.push(
              PlaylistDetailsScreen.routePath,
              extra: {
                'playlistName': item.name,
                'isAlbum': true,
                'isOwner': false,
                'artistName': item.subtitle.split(' • ').first,
              },
            );
            break;
          case RecentItemType.radio:
            context.push(RadioProfileScreen.routePath);
            break;
          case RecentItemType.vod:
            context.push(
              VodPlayerScreen.routePath,
              extra: {
                'videoId': item.id,
                'videoTitle': item.name,
              },
            );
            break;
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
              borderRadius: BorderRadius.circular(item.type == RecentItemType.radio ? 30 : 12),
              child: CachedNetworkImage(
                imageUrl: item.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 60,
                  height: 60,
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(item.type == RecentItemType.radio ? 30 : 12),
                  ),
                  child: Icon(
                    typeIcon,
                    color: theme.colorScheme.primary,
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
                    item.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _showScannerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AudioScannerModal(),
    );
  }
}

class LibraryCategory {
  const LibraryCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}

enum RecentItemType {
  playlist,
  album,
  radio,
  vod,
}

class RecentItem {
  const RecentItem({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.imageUrl,
    required this.type,
  });

  final String id;
  final String name;
  final String subtitle;
  final String imageUrl;
  final RecentItemType type;
}

class LibrarySearchResult {
  const LibrarySearchResult({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.imageUrl,
    this.data,
  });

  final String title;
  final String subtitle;
  final String type;
  final String imageUrl;
  final dynamic data; // Stores the original object for navigation
}
