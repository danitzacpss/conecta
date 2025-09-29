import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:conecta_app/core/localization/l10n.dart';
import 'package:conecta_app/features/home/domain/entities/media_item.dart';
import 'package:conecta_app/features/profile/presentation/profile_screen.dart';
import 'package:conecta_app/features/gamification/presentation/gamification_screen.dart';
import 'package:conecta_app/features/radio/presentation/radio_player_screen.dart';
import 'package:conecta_app/shared/widgets/unified_header.dart';

final exploreProvider = StateNotifierProvider<ExploreController, ExploreData>(
  (ref) => ExploreController(),
);

class ExploreController extends StateNotifier<ExploreData> {
  ExploreController() : super(ExploreData()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.delayed(const Duration(milliseconds: 250));
    state = ExploreData(
      selectedCategory: 'Todo',
      categories: ['Todo', 'Radios', 'Música', 'VOD', 'Podcasts'],
      searchResults: [],
      featuredContent: _getFeaturedContent(),
      newReleases: _getNewReleases(),
      recommendedContent: _getRecommendedContent(),
    );
  }

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(searchResults: []);
      return;
    }

    // Simular búsqueda
    await Future.delayed(const Duration(milliseconds: 300));
    final results = List.generate(
      8,
      (index) => ContentItem(
        id: 'search-$index',
        title: '$query - Resultado $index',
        subtitle: 'Artista ${index + 1}',
        imageUrl: 'https://picsum.photos/seed/search$index/300/300',
        type: ContentType.track,
        category: state.selectedCategory,
      ),
    );
    state = state.copyWith(searchResults: results);
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
}

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  static const routePath = '/search';
  static const routeName = 'search';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exploreData = ref.watch(exploreProvider);
    final theme = Theme.of(context);

    // Load data automatically
    Future.microtask(() {
      if (exploreData.featuredContent.isEmpty) {
        // Data will be loaded by the controller automatically
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            UnifiedHeader(
              title: 'Explorar',
              hasSearchBar: true,
              searchHint: 'Buscar música, radios, videos...',
              onSearchChanged: (value) => ref.read(exploreProvider.notifier).search(value),
              hasScanner: true,
              onScannerTap: () => _showScannerModal(context),
            ),
            _buildBody(context, theme, exploreData, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withOpacity(0.8),
            theme.colorScheme.secondary.withOpacity(0.6),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Explorar',
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
              _buildSearchBar(theme, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
        decoration: InputDecoration(
          hintText: 'Buscar música, radios, podcasts...',
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        onChanged: (value) => ref.read(exploreProvider.notifier).search(value),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme, ExploreData data, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data.searchResults.isNotEmpty) ...[
              _buildSearchResults(context, theme, data),
              const SizedBox(height: 24),
            ] else ...[
              _buildCategoryTabs(theme, data, ref),
              const SizedBox(height: 24),
              _buildFeaturedContent(context, theme, data),
              const SizedBox(height: 24),
              _buildNewReleases(context, theme, data),
              const SizedBox(height: 24),
              _buildRecommendedContent(context, theme, data),
            ],
            const SizedBox(height: 100), // Extra space for bottom navigation
          ],
        ),
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
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
          children: data.searchResults.map((item) => _buildContentCard(context, theme, item)).toList(),
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
              child: _buildContentCard(context, theme, filteredContent[index]),
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
              child: _buildContentCard(context, theme, filteredContent[index]),
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
              child: _buildContentCard(context, theme, filteredContent[index]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentCard(BuildContext context, ThemeData theme, ContentItem item) {
    return GestureDetector(
      onTap: () {
        if (item.type == ContentType.radio) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const RadioPlayerScreen(),
            ),
          );
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
            padding: const EdgeInsets.all(12),
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
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
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
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const AudioScannerModal(),
    );
  }
}

class ExploreData {
  ExploreData({
    this.selectedCategory = 'Todo',
    this.categories = const ['Todo', 'Radios', 'Música', 'VOD', 'Podcasts'],
    this.searchResults = const [],
    this.featuredContent = const [],
    this.newReleases = const [],
    this.recommendedContent = const [],
  });

  final String selectedCategory;
  final List<String> categories;
  final List<ContentItem> searchResults;
  final List<ContentItem> featuredContent;
  final List<ContentItem> newReleases;
  final List<ContentItem> recommendedContent;

  ExploreData copyWith({
    String? selectedCategory,
    List<String>? categories,
    List<ContentItem>? searchResults,
    List<ContentItem>? featuredContent,
    List<ContentItem>? newReleases,
    List<ContentItem>? recommendedContent,
  }) {
    return ExploreData(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      categories: categories ?? this.categories,
      searchResults: searchResults ?? this.searchResults,
      featuredContent: featuredContent ?? this.featuredContent,
      newReleases: newReleases ?? this.newReleases,
      recommendedContent: recommendedContent ?? this.recommendedContent,
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
  });

  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final ContentType type;
  final String category;
}

enum ContentType {
  radio,
  track,
  playlist,
  album,
  video,
  podcast,
}
