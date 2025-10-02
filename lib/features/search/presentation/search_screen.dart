import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:conecta_app/core/localization/l10n.dart';
import 'package:conecta_app/features/home/domain/entities/media_item.dart';
import 'package:conecta_app/features/profile/presentation/profile_screen.dart';
import 'package:conecta_app/features/gamification/presentation/gamification_screen.dart';
import 'package:conecta_app/features/radio/presentation/radio_profile_screen.dart';
import 'package:conecta_app/features/scanner/presentation/audio_scanner_modal.dart';
import 'package:conecta_app/features/player/presentation/providers/now_playing_provider.dart';
import 'package:conecta_app/features/player/presentation/view/music_player_screen.dart';
import 'package:conecta_app/features/player/presentation/view/radio_player_screen.dart';
import 'package:conecta_app/features/player/presentation/view/vod_player_screen.dart';
import 'package:conecta_app/features/library/presentation/playlist_details_screen.dart';

final exploreProvider = StateNotifierProvider<ExploreController, ExploreData>(
  (ref) => ExploreController(),
);

class ExploreController extends StateNotifier<ExploreData> {
  ExploreController() : super(ExploreData());

  bool _isInitialized = false;

  Future<void> loadInitialData({String? initialCategory}) async {
    // If already initialized, just update the category if it's different
    if (_isInitialized) {
      if (initialCategory != null && initialCategory != state.selectedCategory) {
        selectCategory(initialCategory);
      }
      return;
    }
    _isInitialized = true;

    await Future.delayed(const Duration(milliseconds: 250));
    state = ExploreData(
      selectedCategory: initialCategory ?? 'Todo',
      categories: ['Todo', 'Radios', 'Música', 'VOD'],
      searchResults: [],
      featuredContent: _getFeaturedContent(),
      newReleases: _getNewReleases(),
      recommendedContent: _getRecommendedContent(),
      popularRadios: _getPopularRadios(),
      newRadios: _getNewRadios(),
      allRadioStations: _getAllRadioStations(),
      musicGenres: _getMusicGenres(),
      trendingMusic: _getTrendingMusic(),
      newMusicReleases: _getNewMusicReleases(),
      vodCategories: _getVodCategories(),
      recordedShows: _getRecordedShows(),
      interviews: _getInterviews(),
      liveConcerts: _getLiveConcerts(),
      documentaries: _getDocumentaries(),
    );
  }

  void selectCategory(String category) {
    // Clear search results when changing category
    state = state.copyWith(
      selectedCategory: category,
      searchResults: [],
    );
  }

  void selectMusicGenre(String genre) {
    // If "Todos" is selected, clear the filter
    if (genre == 'Todos') {
      state = state.copyWith(selectedMusicGenre: '');
    } else {
      // Toggle genre selection
      final newGenre = state.selectedMusicGenre == genre ? '' : genre;
      state = state.copyWith(selectedMusicGenre: newGenre);
    }
  }

  void selectVodCategory(String category) {
    // If "Todos" is selected, clear the filter
    if (category == 'Todos') {
      state = state.copyWith(selectedVodCategory: '');
    } else {
      // Toggle category selection
      final newCategory = state.selectedVodCategory == category ? '' : category;
      state = state.copyWith(selectedVodCategory: newCategory);
    }
  }

  Future<void> search(String query) async {
    // Clear search results immediately when query is empty or only whitespace
    if (query.trim().isEmpty) {
      state = state.copyWith(searchResults: []);
      return;
    }

    // Simular búsqueda basada en la categoría seleccionada
    await Future.delayed(const Duration(milliseconds: 300));

    List<ContentItem> results;

    switch (state.selectedCategory) {
      case 'Radios':
        results = _searchRadios(query);
        break;
      case 'Música':
        results = _searchMusic(query);
        break;
      case 'VOD':
        results = _searchVideos(query);
        break;
      default: // 'Todo'
        results = _searchAll(query);
        break;
    }

    state = state.copyWith(searchResults: results);
  }

  List<ContentItem> _searchRadios(String query) {
    return List.generate(
      6,
      (index) => ContentItem(
        id: 'radio-search-$index',
        title: '$query Radio ${index + 1}',
        subtitle: 'Estación ${index % 2 == 0 ? "FM" : "AM"} • En vivo',
        imageUrl: 'https://picsum.photos/seed/radiosearch$index/300/300',
        type: ContentType.radio,
        category: 'Radios',
      ),
    );
  }

  List<ContentItem> _searchMusic(String query) {
    final types = [ContentType.track, ContentType.playlist, ContentType.album];
    return List.generate(
      8,
      (index) => ContentItem(
        id: 'music-search-$index',
        title: '$query ${index % 3 == 0 ? "Mix" : index % 3 == 1 ? "Track" : "Album"}',
        subtitle: index % 3 == 0
          ? 'Playlist • ${20 + index * 5} canciones'
          : index % 3 == 1
            ? 'Artista ${index + 1}'
            : 'Álbum • ${10 + index} canciones',
        imageUrl: 'https://picsum.photos/seed/musicsearch$index/300/300',
        type: types[index % 3],
        category: 'Música',
      ),
    );
  }

  List<ContentItem> _searchVideos(String query) {
    return List.generate(
      6,
      (index) => ContentItem(
        id: 'video-search-$index',
        title: '$query Video ${index + 1}',
        subtitle: index % 2 == 0
          ? 'Concierto • ${30 + index * 10} min'
          : 'Documental • ${45 + index * 5} min',
        imageUrl: 'https://picsum.photos/seed/videosearch$index/300/300',
        type: ContentType.video,
        category: 'VOD',
      ),
    );
  }

  List<ContentItem> _searchPodcasts(String query) {
    return List.generate(
      6,
      (index) => ContentItem(
        id: 'podcast-search-$index',
        title: '$query Podcast ${index + 1}',
        subtitle: 'Episodio ${100 + index} • ${20 + index * 3} min',
        imageUrl: 'https://picsum.photos/seed/podcastsearch$index/300/300',
        type: ContentType.podcast,
        category: 'Podcasts',
      ),
    );
  }

  List<ContentItem> _searchAll(String query) {
    // Combinar resultados de todas las categorías
    final List<ContentItem> allResults = [];

    // Agregar algunos de cada tipo
    allResults.addAll(_searchRadios(query).take(2));
    allResults.addAll(_searchMusic(query).take(3));
    allResults.addAll(_searchVideos(query).take(2));
    allResults.addAll(_searchPodcasts(query).take(2));

    // Mezclar los resultados
    allResults.shuffle();

    return allResults;
  }

  List<ContentItem> _getFeaturedContent() {
    return [
      ContentItem(
        id: '1',
        title: 'Conecta Radio',
        subtitle: '105.7 FM - En vivo',
        imageUrl: 'https://picsum.photos/seed/radio1/300/300',
        type: ContentType.radio,
        category: 'Radios',
      ),
      ContentItem(
        id: '2',
        title: 'Top Hits 2024',
        subtitle: 'Playlist • 45 canciones',
        imageUrl: 'https://picsum.photos/seed/playlist1/300/300',
        type: ContentType.playlist,
        category: 'Música',
      ),
      ContentItem(
        id: '3',
        title: 'Documentales Musicales',
        subtitle: 'Contenido exclusivo',
        imageUrl: 'https://picsum.photos/seed/video1/300/300',
        type: ContentType.video,
        category: 'VOD',
      ),
      ContentItem(
        id: '4',
        title: 'Podcast Semanal',
        subtitle: 'Episodio #125',
        imageUrl: 'https://picsum.photos/seed/podcast1/300/300',
        type: ContentType.podcast,
        category: 'Podcasts',
      ),
    ];
  }

  List<ContentItem> _getNewReleases() {
    return [
      ContentItem(
        id: '5',
        title: 'Bad Bunny',
        subtitle: 'Nuevo álbum • 2024',
        imageUrl: 'https://picsum.photos/seed/release1/300/300',
        type: ContentType.album,
        category: 'Música',
      ),
      ContentItem(
        id: '6',
        title: 'Rock Clásico',
        subtitle: 'Nueva estación',
        imageUrl: 'https://picsum.photos/seed/radio2/300/300',
        type: ContentType.radio,
        category: 'Radios',
      ),
      ContentItem(
        id: '7',
        title: 'Concierto Queen',
        subtitle: 'Live at Wembley',
        imageUrl: 'https://picsum.photos/seed/video2/300/300',
        type: ContentType.video,
        category: 'VOD',
      ),
      ContentItem(
        id: '8',
        title: 'Taylor Swift',
        subtitle: 'Midnights (Lavender Haze)',
        imageUrl: 'https://picsum.photos/seed/release2/300/300',
        type: ContentType.track,
        category: 'Música',
      ),
    ];
  }

  List<ContentItem> _getRecommendedContent() {
    return [
      ContentItem(
        id: '9',
        title: 'Jazz & Blues',
        subtitle: 'Para relajarte',
        imageUrl: 'https://picsum.photos/seed/rec1/300/300',
        type: ContentType.playlist,
        category: 'Música',
      ),
      ContentItem(
        id: '10',
        title: 'Radio Nacional',
        subtitle: 'Noticias y actualidad',
        imageUrl: 'https://picsum.photos/seed/radio3/300/300',
        type: ContentType.radio,
        category: 'Radios',
      ),
      ContentItem(
        id: '11',
        title: 'Detrás de la Música',
        subtitle: 'Documental series',
        imageUrl: 'https://picsum.photos/seed/video3/300/300',
        type: ContentType.video,
        category: 'VOD',
      ),
      ContentItem(
        id: '12',
        title: 'Historia del Rock',
        subtitle: 'Podcast educativo',
        imageUrl: 'https://picsum.photos/seed/podcast2/300/300',
        type: ContentType.podcast,
        category: 'Podcasts',
      ),
    ];
  }

  List<ContentItem> _getPopularRadios() {
    return [
      ContentItem(
        id: 'radio-pop-1',
        title: 'Radio Planeta',
        subtitle: 'Pop & Hits',
        imageUrl: 'https://picsum.photos/seed/planetaradio/300/300',
        type: ContentType.radio,
        category: 'Radios',
      ),
      ContentItem(
        id: 'radio-pop-2',
        title: 'Ritmo Romántica',
        subtitle: 'Baladas 24/7',
        imageUrl: 'https://picsum.photos/seed/ritmoradio/300/300',
        type: ContentType.radio,
        category: 'Radios',
      ),
      ContentItem(
        id: 'radio-pop-3',
        title: 'Moda FM',
        subtitle: 'Tendencias musicales',
        imageUrl: 'https://picsum.photos/seed/modafm/300/300',
        type: ContentType.radio,
        category: 'Radios',
      ),
    ];
  }

  List<ContentItem> _getNewRadios() {
    return [
      ContentItem(
        id: 'radio-new-1',
        title: 'Urban Beat',
        subtitle: 'Reggaetón y Trap',
        imageUrl: 'https://picsum.photos/seed/urbanbeat/300/300',
        type: ContentType.radio,
        category: 'Radios',
      ),
      ContentItem(
        id: 'radio-new-2',
        title: 'Indie Wave',
        subtitle: 'Música alternativa',
        imageUrl: 'https://picsum.photos/seed/indiewave/300/300',
        type: ContentType.radio,
        category: 'Radios',
      ),
    ];
  }

  List<ContentItem> _getAllRadioStations() {
    return [
      ContentItem(
        id: 'radio-all-1',
        title: 'Oasis',
        subtitle: 'Rock & Pop',
        imageUrl: 'https://picsum.photos/seed/oasisradio/300/300',
        type: ContentType.radio,
        category: 'Radios',
      ),
      ContentItem(
        id: 'radio-all-2',
        title: 'La Inolvidable',
        subtitle: 'Tus mejores momentos',
        imageUrl: 'https://picsum.photos/seed/inolvidable/300/300',
        type: ContentType.radio,
        category: 'Radios',
      ),
      ContentItem(
        id: 'radio-all-3',
        title: 'Mágica',
        subtitle: 'Discos de Oro en Inglés',
        imageUrl: 'https://picsum.photos/seed/magicaradio/300/300',
        type: ContentType.radio,
        category: 'Radios',
      ),
      ContentItem(
        id: 'radio-all-4',
        title: 'La Zona',
        subtitle: 'Reggaetón, Trap y Rap',
        imageUrl: 'https://picsum.photos/seed/lazona/300/300',
        type: ContentType.radio,
        category: 'Radios',
      ),
      ContentItem(
        id: 'radio-all-5',
        title: 'Studio 92',
        subtitle: 'Dance & Electronic',
        imageUrl: 'https://picsum.photos/seed/studio92/300/300',
        type: ContentType.radio,
        category: 'Radios',
      ),
      ContentItem(
        id: 'radio-all-6',
        title: 'Oxígeno',
        subtitle: 'Classic Rock',
        imageUrl: 'https://picsum.photos/seed/oxigeno/300/300',
        type: ContentType.radio,
        category: 'Radios',
      ),
    ];
  }

  List<String> _getMusicGenres() {
    return ['Todos', 'Pop', 'Rock', 'Latina', 'Urbano', 'Electrónica', 'Jazz', 'Clásica', 'Indie'];
  }

  List<ContentItem> _getTrendingMusic() {
    return [
      ContentItem(
        id: 'trending-1',
        title: 'Vibes del Verano',
        subtitle: 'Playlist',
        imageUrl: 'https://picsum.photos/seed/vibes/300/300',
        type: ContentType.playlist,
        category: 'Música',
        genre: 'Pop',
      ),
      ContentItem(
        id: 'trending-2',
        title: 'Noches de Neón',
        subtitle: 'Álbum',
        imageUrl: 'https://picsum.photos/seed/neon/300/300',
        type: ContentType.album,
        category: 'Música',
        genre: 'Electrónica',
      ),
      ContentItem(
        id: 'trending-3',
        title: 'Esencias',
        subtitle: 'Colección',
        imageUrl: 'https://picsum.photos/seed/esencias/300/300',
        type: ContentType.playlist,
        category: 'Música',
        genre: 'Latina',
      ),
      ContentItem(
        id: 'trending-4',
        title: 'Rock Legends',
        subtitle: 'Greatest Hits',
        imageUrl: 'https://picsum.photos/seed/rock/300/300',
        type: ContentType.playlist,
        category: 'Música',
        genre: 'Rock',
      ),
      ContentItem(
        id: 'trending-5',
        title: 'Urban Nights',
        subtitle: 'Mix 2024',
        imageUrl: 'https://picsum.photos/seed/urban/300/300',
        type: ContentType.playlist,
        category: 'Música',
        genre: 'Urbano',
      ),
    ];
  }

  List<ContentItem> _getNewMusicReleases() {
    return [
      ContentItem(
        id: 'new-music-1',
        title: 'Ecos del Mañana',
        subtitle: 'Aurora Dream',
        imageUrl: 'https://picsum.photos/seed/ecos/300/300',
        type: ContentType.track,
        category: 'Música',
        genre: 'Pop',
      ),
      ContentItem(
        id: 'new-music-2',
        title: 'Ritmo Infinito',
        subtitle: 'Leo Cósmico',
        imageUrl: 'https://picsum.photos/seed/ritmo/300/300',
        type: ContentType.track,
        category: 'Música',
        genre: 'Latina',
      ),
      ContentItem(
        id: 'new-music-3',
        title: 'Calles de Cristal',
        subtitle: 'The Nightwalkers',
        imageUrl: 'https://picsum.photos/seed/calles/300/300',
        type: ContentType.album,
        category: 'Música',
        genre: 'Rock',
      ),
      ContentItem(
        id: 'new-music-4',
        title: 'Sueños Digitales',
        subtitle: 'Neon Paradise',
        imageUrl: 'https://picsum.photos/seed/suenos/300/300',
        type: ContentType.track,
        category: 'Música',
        genre: 'Electrónica',
      ),
      ContentItem(
        id: 'new-music-5',
        title: 'Jazz Nocturno',
        subtitle: 'Smooth Collective',
        imageUrl: 'https://picsum.photos/seed/jazz/300/300',
        type: ContentType.album,
        category: 'Música',
        genre: 'Jazz',
      ),
      ContentItem(
        id: 'new-music-6',
        title: 'Trap Kings',
        subtitle: 'Urban Elite',
        imageUrl: 'https://picsum.photos/seed/trap/300/300',
        type: ContentType.track,
        category: 'Música',
        genre: 'Urbano',
      ),
    ];
  }

  List<String> _getVodCategories() {
    return ['Todos', 'Podcasts', 'Conciertos', 'Documentales', 'Entrevistas'];
  }

  List<ContentItem> _getRecordedShows() {
    return [
      ContentItem(
        id: 'show-1',
        title: 'Mañanas con Ale',
        subtitle: 'Ep. 12 - 15/03/24',
        imageUrl: 'https://picsum.photos/seed/mornings/300/300',
        type: ContentType.podcast,
        category: 'VOD',
        vodType: 'Podcasts',
      ),
      ContentItem(
        id: 'show-2',
        title: 'La Noche es Nuestra',
        subtitle: 'Ep. 45 - 14/03/24',
        imageUrl: 'https://picsum.photos/seed/nightshow/300/300',
        type: ContentType.podcast,
        category: 'VOD',
        vodType: 'Podcasts',
      ),
      ContentItem(
        id: 'show-3',
        title: 'Rock Total',
        subtitle: 'Especial Clásicos',
        imageUrl: 'https://picsum.photos/seed/rocktotal/300/300',
        type: ContentType.podcast,
        category: 'VOD',
        vodType: 'Podcasts',
      ),
    ];
  }

  List<ContentItem> _getInterviews() {
    return [
      ContentItem(
        id: 'interview-1',
        title: 'Bad Bunny',
        subtitle: 'El Conejo Malo en cabina',
        imageUrl: 'https://picsum.photos/seed/badbunny/300/300',
        type: ContentType.video,
        category: 'VOD',
        vodType: 'Entrevistas',
      ),
      ContentItem(
        id: 'interview-2',
        title: 'Taylor Swift',
        subtitle: 'The Eras Tour en Latam',
        imageUrl: 'https://picsum.photos/seed/taylor/300/300',
        type: ContentType.video,
        category: 'VOD',
        vodType: 'Entrevistas',
      ),
      ContentItem(
        id: 'interview-3',
        title: 'Bizarrap',
        subtitle: 'Detrás de las Sessions',
        imageUrl: 'https://picsum.photos/seed/bizarrap/300/300',
        type: ContentType.video,
        category: 'VOD',
        vodType: 'Entrevistas',
      ),
    ];
  }

  List<ContentItem> _getLiveConcerts() {
    return [
      ContentItem(
        id: 'concert-1',
        title: 'Festival Vibra Perú 2024',
        subtitle: 'Completo',
        imageUrl: 'https://picsum.photos/seed/vibraperu/300/300',
        type: ContentType.video,
        category: 'VOD',
        vodType: 'Conciertos',
      ),
      ContentItem(
        id: 'concert-2',
        title: 'Grupo 5 en el Nacional',
        subtitle: '50 años',
        imageUrl: 'https://picsum.photos/seed/grupo5/300/300',
        type: ContentType.video,
        category: 'VOD',
        vodType: 'Conciertos',
      ),
      ContentItem(
        id: 'concert-3',
        title: 'Coldplay',
        subtitle: 'Music of the Spheres Tour',
        imageUrl: 'https://picsum.photos/seed/coldplay/300/300',
        type: ContentType.video,
        category: 'VOD',
        vodType: 'Conciertos',
      ),
    ];
  }

  List<ContentItem> _getDocumentaries() {
    return [
      ContentItem(
        id: 'doc-1',
        title: 'La historia del Rock Peruano',
        subtitle: 'Serie completa',
        imageUrl: 'https://picsum.photos/seed/rockperu/300/300',
        type: ContentType.video,
        category: 'VOD',
        vodType: 'Documentales',
      ),
      ContentItem(
        id: 'doc-2',
        title: 'La Cumbia que mueve al mundo',
        subtitle: 'Documental',
        imageUrl: 'https://picsum.photos/seed/cumbia/300/300',
        type: ContentType.video,
        category: 'VOD',
        vodType: 'Documentales',
      ),
      ContentItem(
        id: 'doc-3',
        title: 'El Reggaeton',
        subtitle: 'Del barrio al mundo',
        imageUrl: 'https://picsum.photos/seed/reggaeton/300/300',
        type: ContentType.video,
        category: 'VOD',
        vodType: 'Documentales',
      ),
    ];
  }
}

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({this.initialCategory, super.key});

  final String? initialCategory;

  static const routePath = '/search';
  static const routeName = 'search';

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  @override
  void initState() {
    super.initState();
    // Load initial data with category if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exploreProvider.notifier).loadInitialData(
        initialCategory: widget.initialCategory,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final exploreData = ref.watch(exploreProvider);
    final theme = Theme.of(context);

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
                      'Explorar',
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
              child: _buildBody(context, theme, exploreData, ref),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSearchBar(ThemeData theme, WidgetRef ref, String selectedCategory) {
    return _SearchBar(theme: theme, ref: ref, selectedCategory: selectedCategory);
  }

  Widget _buildBody(BuildContext context, ThemeData theme, ExploreData data, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(theme, ref, data.selectedCategory),
          const SizedBox(height: 20),
          if (data.searchResults.isNotEmpty) ...[
              _buildSearchResults(context, theme, data),
              const SizedBox(height: 24),
            ] else if (data.selectedCategory == 'Radios') ...[
              _buildCategoryTabs(theme, data, ref),
              const SizedBox(height: 24),
              _buildRadiosView(context, theme, data),
              const SizedBox(height: 180), // Espacio para mini reproductor y nav bar
            ] else if (data.selectedCategory == 'Música') ...[
              _buildCategoryTabs(theme, data, ref),
              const SizedBox(height: 24),
              _buildMusicView(context, theme, data, ref),
              const SizedBox(height: 180), // Espacio para mini reproductor y nav bar
            ] else if (data.selectedCategory == 'VOD') ...[
              _buildCategoryTabs(theme, data, ref),
              const SizedBox(height: 24),
              _buildVodView(context, theme, data, ref),
              const SizedBox(height: 180), // Espacio para mini reproductor y nav bar
            ] else ...[
              _buildCategoryTabs(theme, data, ref),
              const SizedBox(height: 24),
              _buildFeaturedContent(context, theme, data),
              const SizedBox(height: 24),
              _buildNewReleases(context, theme, data),
              const SizedBox(height: 24),
              _buildRecommendedContent(context, theme, data),
              const SizedBox(height: 180), // Espacio para mini reproductor y nav bar
            ],
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(ThemeData theme, ExploreData data, WidgetRef ref) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: data.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = data.categories[index];
          final isSelected = category == data.selectedCategory;
          return GestureDetector(
            onTap: () => ref.read(exploreProvider.notifier).selectCategory(category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected
                    ? Colors.white
                    : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, ThemeData theme, ExploreData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resultados de búsqueda',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        GridView.count(
          padding: const EdgeInsets.only(top: 8),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.0,
          children: data.searchResults.map((item) => _buildContentCard(context, theme, item, ref)).toList(),
        ),
      ],
    );
  }

  Widget _buildFeaturedContent(BuildContext context, ThemeData theme, ExploreData data) {
    final filteredContent = data.selectedCategory == 'Todo'
        ? data.featuredContent
        : data.featuredContent
            .where((item) => item.category == data.selectedCategory)
            .toList();

    if (filteredContent.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Destacados',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Ver todo',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filteredContent.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) => SizedBox(
              width: 150,
              child: _buildContentCard(context, theme, filteredContent[index], ref),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewReleases(BuildContext context, ThemeData theme, ExploreData data) {
    final filteredContent = data.selectedCategory == 'Todo'
        ? data.newReleases
        : data.newReleases
            .where((item) => item.category == data.selectedCategory)
            .toList();

    if (filteredContent.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Nuevos lanzamientos',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Ver todo',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filteredContent.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) => SizedBox(
              width: 150,
              child: _buildContentCard(context, theme, filteredContent[index], ref),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedContent(BuildContext context, ThemeData theme, ExploreData data) {
    final filteredContent = data.selectedCategory == 'Todo'
        ? data.recommendedContent
        : data.recommendedContent
            .where((item) => item.category == data.selectedCategory)
            .toList();

    if (filteredContent.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Contenido que te puede gustar',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Ver todo',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filteredContent.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) => SizedBox(
              width: 150,
              child: _buildContentCard(context, theme, filteredContent[index], ref),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentCard(BuildContext context, ThemeData theme, ContentItem item, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        if (item.type == ContentType.playlist || item.type == ContentType.album) {
          // Navegar a la vista de detalles de playlist/álbum
          context.push(
            PlaylistDetailsScreen.routePath,
            extra: {'playlistId': item.id, 'playlistName': item.title},
          );
        } else if (item.type == ContentType.radio) {
          // Actualizar el nowPlayingProvider con la radio seleccionada
          ref.read(nowPlayingProvider.notifier).play(
            MediaItem(
              id: item.id,
              title: item.title,
              artists: [item.subtitle],
              artworkUrl: item.imageUrl,
              type: MediaType.radio,
              isLive: true,
            ),
          );
          // Navegar al reproductor de radio en vivo
          context.push(RadioPlayerScreen.routePath);
        } else if (item.type == ContentType.video) {
          // Navegar al reproductor de VOD
          context.push(
            VodPlayerScreen.routePath,
            extra: {'videoId': item.id, 'videoTitle': item.title},
          );
        } else if (item.type == ContentType.track) {
          // Actualizar el nowPlayingProvider con la canción seleccionada
          ref.read(nowPlayingProvider.notifier).play(
            MediaItem(
              id: item.id,
              title: item.title,
              artists: [item.subtitle],
              artworkUrl: item.imageUrl,
              type: MediaType.track,
              duration: const Duration(minutes: 3, seconds: 30),
            ),
          );
          // Navegar al reproductor de música
          context.push(MusicPlayerScreen.routePath);
        } else if (item.type == ContentType.podcast) {
          // Los podcasts son programas de radio grabados, usar reproductor de música
          ref.read(nowPlayingProvider.notifier).play(
            MediaItem(
              id: item.id,
              title: item.title,
              artists: [item.subtitle],
              artworkUrl: item.imageUrl,
              type: MediaType.track, // Tratarlo como audio
              duration: const Duration(minutes: 45), // Duración típica de un podcast
            ),
          );
          // Navegar al reproductor de música
          context.push(MusicPlayerScreen.routePath);
        }
      },
      child: Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                image: DecorationImage(
                  image: NetworkImage(item.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge (only show in "Todo" view)
                      Consumer(
                        builder: (context, ref, child) {
                          final selectedCategory = ref.watch(exploreProvider.select((data) => data.selectedCategory));
                          if (selectedCategory != 'Todo') return const SizedBox.shrink();

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.category,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                      // Type icon
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getIconForType(item.type),
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildVodView(BuildContext context, ThemeData theme, ExploreData data, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // VOD Category Filters - Similar to music genres
        Text(
          'Categorías',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: data.vodCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final category = data.vodCategories[index];
              final isSelected = category == 'Todos'
                  ? data.selectedVodCategory.isEmpty
                  : data.selectedVodCategory == category;

              final colors = {
                'Todos': const Color(0xFFE0E0E0),
                'Podcasts': const Color(0xFFB3E5FC),
                'Conciertos': const Color(0xFFFFCCBC),
                'Documentales': const Color(0xFFD1C4E9),
                'Entrevistas': const Color(0xFFC8E6C9),
              };

              return GestureDetector(
                onTap: () => ref.read(exploreProvider.notifier).selectVodCategory(category),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : colors[category] ?? Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? Border.all(color: theme.colorScheme.primary.withOpacity(0.5), width: 2)
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (category == 'Todos' && isSelected)
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 32),

        // Show filtered content based on selection
        // Programas de radio grabados
        if (data.selectedVodCategory.isEmpty || data.selectedVodCategory == 'Podcasts') ...[
          Text(
            'Programas de radio grabados',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: data.recordedShows.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) => SizedBox(
                width: 150,
                child: _buildContentCard(context, theme, data.recordedShows[index], ref),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],

        // Entrevistas
        if (data.selectedVodCategory.isEmpty || data.selectedVodCategory == 'Entrevistas') ...[
          Text(
            'Entrevistas',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: data.interviews.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) => SizedBox(
                width: 150,
                child: _buildContentCard(context, theme, data.interviews[index], ref),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],

        // Conciertos en vivo
        if (data.selectedVodCategory.isEmpty || data.selectedVodCategory == 'Conciertos') ...[
          Text(
            'Conciertos en vivo',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: data.liveConcerts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) => SizedBox(
                width: 150,
                child: _buildContentCard(context, theme, data.liveConcerts[index], ref),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],

        // Documentales
        if (data.selectedVodCategory.isEmpty || data.selectedVodCategory == 'Documentales') ...[
          Text(
            'Documentales',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: data.documentaries.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) => SizedBox(
                width: 150,
                child: _buildContentCard(context, theme, data.documentaries[index], ref),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMusicView(BuildContext context, ThemeData theme, ExploreData data, WidgetRef ref) {
    // Filter content by selected genre
    final filteredTrending = data.selectedMusicGenre.isEmpty
        ? data.trendingMusic
        : data.trendingMusic.where((item) => item.genre == data.selectedMusicGenre).toList();

    final filteredNewReleases = data.selectedMusicGenre.isEmpty
        ? data.newMusicReleases
        : data.newMusicReleases.where((item) => item.genre == data.selectedMusicGenre).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Géneros section
        Text(
          'Géneros',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: data.musicGenres.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final genre = data.musicGenres[index];
              final isSelected = genre == 'Todos'
                  ? data.selectedMusicGenre.isEmpty
                  : data.selectedMusicGenre == genre;

              final colors = {
                'Todos': const Color(0xFFE0E0E0),
                'Pop': const Color(0xFFF8BBD0),
                'Rock': const Color(0xFFD1C4E9),
                'Latina': const Color(0xFFB2DFDB),
                'Urbano': const Color(0xFFFFCCBC),
                'Electrónica': const Color(0xFFC5CAE9),
                'Jazz': const Color(0xFFFFE0B2),
                'Clásica': const Color(0xFFF0F4C3),
                'Indie': const Color(0xFFE1BEE7),
              };

              return GestureDetector(
                onTap: () {
                  ref.read(exploreProvider.notifier).selectMusicGenre(genre);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : colors[genre] ?? Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? Border.all(color: theme.colorScheme.primary.withOpacity(0.5), width: 2)
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (genre == 'Todos' && isSelected)
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      Text(
                        genre,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 32),

        // Show "No results" message if everything is filtered out
        if (data.selectedMusicGenre.isNotEmpty && filteredTrending.isEmpty && filteredNewReleases.isEmpty) ...[
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(
                    Icons.music_off,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay música disponible en ${data.selectedMusicGenre}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        // Tendencias section
        if (filteredTrending.isNotEmpty) ...[
          Text(
            'Tendencias',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filteredTrending.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final item = filteredTrending[index];
                return _buildTrendingCard(context, theme, item);
              },
            ),
          ),
          const SizedBox(height: 32),
        ],

        // Nuevos Lanzamientos section
        if (filteredNewReleases.isNotEmpty) ...[
          Text(
            'Nuevos Lanzamientos',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ...filteredNewReleases.map((item) =>
            _buildMusicListTile(context, theme, item),
          ),
        ],
      ],
    );
  }

  Widget _buildTrendingCard(BuildContext context, ThemeData theme, ContentItem item) {
    return Consumer(
      builder: (context, ref, child) => GestureDetector(
        onTap: () {
          // Actualizar el nowPlayingProvider con la música seleccionada
          ref.read(nowPlayingProvider.notifier).play(
            MediaItem(
              id: item.id,
              title: item.title,
              artists: [item.subtitle],
              artworkUrl: item.imageUrl,
              type: MediaType.track,
              duration: const Duration(minutes: 3, seconds: 30),
            ),
          );
          // Navegar al reproductor de música
          context.push(MusicPlayerScreen.routePath);
        },
      child: SizedBox(
        width: 140,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(item.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item.subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildMusicListTile(BuildContext context, ThemeData theme, ContentItem item) {
    return Consumer(
      builder: (context, ref, child) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: () {
            // Actualizar el nowPlayingProvider con la música seleccionada
            ref.read(nowPlayingProvider.notifier).play(
              MediaItem(
                id: item.id,
                title: item.title,
                artists: [item.subtitle],
                artworkUrl: item.imageUrl,
                type: MediaType.track,
                duration: const Duration(minutes: 3, seconds: 30),
              ),
            );
            // Navegar al reproductor de música
            context.push(MusicPlayerScreen.routePath);
          },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(item.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  // Add to favorites
                },
                icon: Icon(
                  Icons.favorite_border,
                  color: theme.colorScheme.primary,
                ),
              ),
              IconButton(
                onPressed: () {
                  // More options
                },
                icon: Icon(
                  Icons.more_vert,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildRadiosView(BuildContext context, ThemeData theme, ExploreData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Populares section
        if (data.popularRadios.isNotEmpty) ...[
          Text(
            'Populares',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: data.popularRadios.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final radio = data.popularRadios[index];
                return _buildCircularRadioCard(context, theme, radio);
              },
            ),
          ),
          const SizedBox(height: 32),
        ],

        // Nuevas Radios section
        if (data.newRadios.isNotEmpty) ...[
          Text(
            'Nuevas Radios',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ...data.newRadios.map((radio) =>
            _buildRadioListTile(context, theme, radio),
          ),
          const SizedBox(height: 32),
        ],

        // Todas las Estaciones section
        if (data.allRadioStations.isNotEmpty) ...[
          Text(
            'Todas las Estaciones',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ...data.allRadioStations.map((radio) =>
            _buildRadioListTile(context, theme, radio),
          ),
        ],
      ],
    );
  }

  Widget _buildCircularRadioCard(BuildContext context, ThemeData theme, ContentItem radio) {
    return Consumer(
      builder: (context, ref, child) => GestureDetector(
        onTap: () {
          // Actualizar el nowPlayingProvider con la radio seleccionada
          ref.read(nowPlayingProvider.notifier).play(
            MediaItem(
              id: radio.id,
              title: radio.title,
              artists: [radio.subtitle],
              artworkUrl: radio.imageUrl,
              type: MediaType.radio,
              isLive: true,
            ),
          );
          // Navegar al reproductor de radio en vivo
          context.push(RadioPlayerScreen.routePath);
        },
        child: Column(
          children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
                width: 3,
              ),
              image: DecorationImage(
                image: NetworkImage(radio.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            child: Text(
              radio.title,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildRadioListTile(BuildContext context, ThemeData theme, ContentItem radio) {
    return Consumer(
      builder: (context, ref, child) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: () {
            // Actualizar el nowPlayingProvider con la radio seleccionada
            ref.read(nowPlayingProvider.notifier).play(
              MediaItem(
                id: radio.id,
                title: radio.title,
                artists: [radio.subtitle],
                artworkUrl: radio.imageUrl,
                type: MediaType.radio,
                isLive: true,
              ),
            );
            // Navegar al reproductor de radio en vivo
            context.push(RadioPlayerScreen.routePath);
          },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(radio.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      radio.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      radio.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  // Solo actualizar el nowPlayingProvider, sin navegar
                  ref.read(nowPlayingProvider.notifier).play(
                    MediaItem(
                      id: radio.id,
                      title: radio.title,
                      artists: [radio.subtitle],
                      artworkUrl: radio.imageUrl,
                      type: MediaType.radio,
                      isLive: true,
                    ),
                  );
                  // No navegar, solo activar la reproducción en el mini player
                },
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  IconData _getIconForType(ContentType type) {
    switch (type) {
      case ContentType.radio:
        return Icons.radio;
      case ContentType.track:
        return Icons.music_note;
      case ContentType.playlist:
        return Icons.queue_music;
      case ContentType.album:
        return Icons.album;
      case ContentType.video:
        return Icons.play_circle;
      case ContentType.podcast:
        return Icons.podcasts;
    }
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

class ExploreData {
  ExploreData({
    this.selectedCategory = 'Todo',
    this.categories = const ['Todo', 'Radios', 'Música', 'VOD'],
    this.searchResults = const [],
    this.featuredContent = const [],
    this.newReleases = const [],
    this.recommendedContent = const [],
    this.popularRadios = const [],
    this.newRadios = const [],
    this.allRadioStations = const [],
    this.musicGenres = const [],
    this.trendingMusic = const [],
    this.newMusicReleases = const [],
    this.selectedMusicGenre = '',
    this.vodCategories = const [],
    this.recordedShows = const [],
    this.interviews = const [],
    this.liveConcerts = const [],
    this.documentaries = const [],
    this.selectedVodCategory = '',
  });

  final String selectedCategory;
  final List<String> categories;
  final List<ContentItem> searchResults;
  final List<ContentItem> featuredContent;
  final List<ContentItem> newReleases;
  final List<ContentItem> recommendedContent;
  final List<ContentItem> popularRadios;
  final List<ContentItem> newRadios;
  final List<ContentItem> allRadioStations;
  final List<String> musicGenres;
  final List<ContentItem> trendingMusic;
  final List<ContentItem> newMusicReleases;
  final String selectedMusicGenre;
  final List<String> vodCategories;
  final List<ContentItem> recordedShows;
  final List<ContentItem> interviews;
  final List<ContentItem> liveConcerts;
  final List<ContentItem> documentaries;
  final String selectedVodCategory;

  ExploreData copyWith({
    String? selectedCategory,
    List<String>? categories,
    List<ContentItem>? searchResults,
    List<ContentItem>? featuredContent,
    List<ContentItem>? newReleases,
    List<ContentItem>? recommendedContent,
    List<ContentItem>? popularRadios,
    List<ContentItem>? newRadios,
    List<ContentItem>? allRadioStations,
    List<String>? musicGenres,
    List<ContentItem>? trendingMusic,
    List<ContentItem>? newMusicReleases,
    String? selectedMusicGenre,
    List<String>? vodCategories,
    List<ContentItem>? recordedShows,
    List<ContentItem>? interviews,
    List<ContentItem>? liveConcerts,
    List<ContentItem>? documentaries,
    String? selectedVodCategory,
  }) {
    return ExploreData(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      categories: categories ?? this.categories,
      searchResults: searchResults ?? this.searchResults,
      featuredContent: featuredContent ?? this.featuredContent,
      newReleases: newReleases ?? this.newReleases,
      recommendedContent: recommendedContent ?? this.recommendedContent,
      popularRadios: popularRadios ?? this.popularRadios,
      newRadios: newRadios ?? this.newRadios,
      allRadioStations: allRadioStations ?? this.allRadioStations,
      musicGenres: musicGenres ?? this.musicGenres,
      trendingMusic: trendingMusic ?? this.trendingMusic,
      newMusicReleases: newMusicReleases ?? this.newMusicReleases,
      selectedMusicGenre: selectedMusicGenre ?? this.selectedMusicGenre,
      vodCategories: vodCategories ?? this.vodCategories,
      recordedShows: recordedShows ?? this.recordedShows,
      interviews: interviews ?? this.interviews,
      liveConcerts: liveConcerts ?? this.liveConcerts,
      documentaries: documentaries ?? this.documentaries,
      selectedVodCategory: selectedVodCategory ?? this.selectedVodCategory,
    );
  }
}

class ContentItem {
  const ContentItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.type,
    required this.category,
    this.genre,
    this.vodType,
  });

  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final ContentType type;
  final String category;
  final String? genre;
  final String? vodType;
}

enum ContentType {
  radio,
  track,
  playlist,
  album,
  video,
  podcast,
}

class _SearchBar extends ConsumerStatefulWidget {
  const _SearchBar({required this.theme, required this.ref, required this.selectedCategory});

  final ThemeData theme;
  final WidgetRef ref;
  final String selectedCategory;

  @override
  ConsumerState<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<_SearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    widget.ref.read(exploreProvider.notifier).search('');
  }

  String _getSearchHint(String category) {
    switch (category) {
      case 'Radios':
        return 'Buscar estaciones de radio...';
      case 'Música':
        return 'Buscar canciones, artistas, álbumes...';
      case 'VOD':
        return 'Buscar videos, conciertos, documentales...';
      default:
        return 'Buscar música, radios, videos...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _controller,
        style: TextStyle(color: widget.theme.colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: _getSearchHint(widget.selectedCategory),
          hintStyle: TextStyle(
            color: widget.theme.colorScheme.onSurfaceVariant,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: widget.theme.colorScheme.onSurfaceVariant,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: widget.theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: _clearSearch,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: widget.theme.colorScheme.surfaceContainerHighest,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        onChanged: (value) {
          setState(() {}); // To update the clear button visibility
          widget.ref.read(exploreProvider.notifier).search(value);
        },
      ),
    );
  }
}
