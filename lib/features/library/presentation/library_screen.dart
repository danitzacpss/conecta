import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:conecta_app/core/localization/l10n.dart';
import 'package:conecta_app/features/home/domain/entities/media_item.dart';
import 'package:conecta_app/features/profile/presentation/profile_screen.dart';
import 'package:conecta_app/features/gamification/presentation/gamification_screen.dart';
import 'package:conecta_app/shared/widgets/unified_header.dart';

final newLibraryProvider = StateNotifierProvider<LibraryController, LibraryData>(
  (ref) => LibraryController(),
);

class LibraryController extends StateNotifier<LibraryData> {
  LibraryController() : super(LibraryData()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.delayed(const Duration(milliseconds: 250));
    state = LibraryData(
      searchResults: [],
      categories: _getLibraryCategories(),
      playlists: _getMyPlaylists(),
    );
  }

  Future<void> loadInitialData() async {
    await _loadInitialData();
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      // Restaurar el estado inicial
      await _loadInitialData();
      return;
    }

    // Simular búsqueda en biblioteca
    await Future.delayed(const Duration(milliseconds: 300));
    final results = [
      ...state.playlists
          .where((playlist) => playlist.name.toLowerCase().contains(query.toLowerCase()))
          .map((playlist) => LibrarySearchResult(
            title: playlist.name,
            subtitle: '${playlist.songCount} canciones',
            type: 'playlist',
            imageUrl: playlist.imageUrl,
          )),
    ];

    // Agregar resultados simulados adicionales
    if (results.length < 5) {
      results.addAll(List.generate(
        5 - results.length,
        (index) => LibrarySearchResult(
          title: '$query - Resultado ${index + 1}',
          subtitle: 'Artista ${index + 1}',
          type: 'track',
          imageUrl: 'https://picsum.photos/seed/search$index/300/300',
        ),
      ));
    }

    state = state.copyWith(searchResults: results);
  }

  List<LibraryCategory> _getLibraryCategories() {
    return [
      LibraryCategory(
        id: 'songs',
        title: 'Canciones',
        subtitle: '120',
        icon: Icons.favorite,
        color: Colors.pink,
      ),
      LibraryCategory(
        id: 'artists',
        title: 'Artistas',
        subtitle: '45',
        icon: Icons.person,
        color: Colors.blue,
      ),
      LibraryCategory(
        id: 'albums',
        title: 'Álbumes',
        subtitle: '23',
        icon: Icons.album,
        color: Colors.purple,
      ),
      LibraryCategory(
        id: 'subscriptions',
        title: 'Suscripciones',
        subtitle: '8 Radios',
        icon: Icons.radio,
        color: Colors.green,
      ),
      LibraryCategory(
        id: 'vod',
        title: 'VOD Guardados',
        subtitle: '5 Videos',
        icon: Icons.video_library,
        color: Colors.indigo,
      ),
    ];
  }

  List<UserPlaylist> _getMyPlaylists() {
    return [
      UserPlaylist(
        id: '1',
        name: 'Pop para entrenar',
        songCount: 25,
        imageUrl: 'https://picsum.photos/seed/playlist1/300/300',
      ),
      UserPlaylist(
        id: '2',
        name: 'Rock de los 90',
        songCount: 50,
        imageUrl: 'https://picsum.photos/seed/playlist2/300/300',
      ),
      UserPlaylist(
        id: '3',
        name: 'Tardes de relax',
        songCount: 32,
        imageUrl: 'https://picsum.photos/seed/playlist3/300/300',
      ),
      UserPlaylist(
        id: '4',
        name: 'Éxitos latinos',
        songCount: 41,
        imageUrl: 'https://picsum.photos/seed/playlist4/300/300',
      ),
      UserPlaylist(
        id: '5',
        name: 'Jazz nocturno',
        songCount: 28,
        imageUrl: 'https://picsum.photos/seed/playlist5/300/300',
      ),
    ];
  }
}

class LibraryData {
  LibraryData({
    this.searchResults = const [],
    this.categories = const [],
    this.playlists = const [],
  });

  final List<LibrarySearchResult> searchResults;
  final List<LibraryCategory> categories;
  final List<UserPlaylist> playlists;

  LibraryData copyWith({
    List<LibrarySearchResult>? searchResults,
    List<LibraryCategory>? categories,
    List<UserPlaylist>? playlists,
  }) {
    return LibraryData(
      searchResults: searchResults ?? this.searchResults,
      categories: categories ?? this.categories,
      playlists: playlists ?? this.playlists,
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

    // Asegurar que los datos iniciales estén cargados
    Future.microtask(() {
      if (libraryData.categories.isEmpty && libraryData.playlists.isEmpty && libraryData.searchResults.isEmpty) {
        ref.read(newLibraryProvider.notifier).loadInitialData();
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header con gradiente
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: theme.brightness == Brightness.dark
                    ? [
                        theme.colorScheme.primary.withOpacity(0.3),
                        theme.colorScheme.primary.withOpacity(0.6),
                      ]
                    : [
                        theme.colorScheme.primary.withOpacity(0.6),
                        theme.colorScheme.primary.withOpacity(1.0),
                      ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    children: [
                      // Fila del título y botones
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Biblioteca',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => _showScannerModal(context),
                                child: const CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.white24,
                                  child: Icon(Icons.qr_code_scanner, color: Colors.white, size: 20),
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () => context.go(ProfileScreen.routePath),
                                child: const CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.white24,
                                  child: Icon(Icons.person, color: Colors.white, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Barra de búsqueda
                      Container(
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                              ? theme.colorScheme.surface.withOpacity(0.9)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
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
                            fillColor: theme.brightness == Brightness.dark
                                ? theme.colorScheme.surface.withOpacity(0.9)
                                : Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                          onChanged: (value) => ref.read(newLibraryProvider.notifier).search(value),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Contenido principal INMEDIATAMENTE después del header
            if (libraryData.searchResults.isNotEmpty)
              _buildSearchResults(context, theme, libraryData)
            else ...[
              _buildCreatePlaylistButton(context, theme),
              _buildMainContent(context, theme, libraryData),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCreatePlaylistButton(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: InkWell(
        onTap: () {
          // TODO: Implementar creación de playlist
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Crear nueva playlist')),
          );
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
          _buildMyPlaylists(context, theme, data),
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
          ...data.searchResults.map((result) => _buildSearchResultItem(theme, result)),
          const SizedBox(height: 100), // Extra space for bottom navigation
        ],
      ),
    );
  }


  Widget _buildSearchResultItem(ThemeData theme, LibrarySearchResult result) {
    return Container(
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
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              result.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
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
                ),
                Text(
                  result.subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.play_arrow,
            color: theme.colorScheme.primary,
          ),
        ],
      ),
    );
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
              Expanded(child: _buildCategoryCard(theme, row[0])),
              const SizedBox(width: 12),
              if (row.length > 1)
                Expanded(child: _buildCategoryCard(theme, row[1]))
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        )
      ).toList(),
    );
  }

  Widget _buildCategoryCard(ThemeData theme, LibraryCategory category) {
    return Container(
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
    );
  }

  Widget _buildMyPlaylists(BuildContext context, ThemeData theme, LibraryData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mis Playlists',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        ...data.playlists.map((playlist) => _buildPlaylistItem(theme, playlist)),
      ],
    );
  }

  Widget _buildPlaylistItem(ThemeData theme, UserPlaylist playlist) {
    return Container(
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
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              playlist.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
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
                  '${playlist.songCount} canciones',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  void _showScannerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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

class UserPlaylist {
  const UserPlaylist({
    required this.id,
    required this.name,
    required this.songCount,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final int songCount;
  final String imageUrl;
}

class LibrarySearchResult {
  const LibrarySearchResult({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.imageUrl,
  });

  final String title;
  final String subtitle;
  final String type;
  final String imageUrl;
}
