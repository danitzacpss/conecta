import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'package:conecta_app/core/localization/l10n.dart';
import 'package:conecta_app/features/home/domain/entities/media_item.dart';
import 'package:conecta_app/services/download_service.dart';

final libraryProvider = FutureProvider<LibraryState>((ref) async {
  final downloadsBox = Hive.box('downloads');
  final downloads = downloadsBox.values
      .whereType<Map>()
      .map((value) => Map<String, dynamic>.from(value))
      .map(MediaItem.fromMap)
      .toList();

  return LibraryState(
    favorites: List.generate(
      4,
      (index) => MediaItem(
        id: 'fav-$index',
        title: 'Favorite #$index',
        artists: ['Artist fav $index'],
        artworkUrl: 'https://picsum.photos/seed/fav$index/400/400',
        type: MediaType.track,
      ),
    ),
    downloads: downloads,
    recent: List.generate(
      6,
      (index) => MediaItem(
        id: 'recent-$index',
        title: 'Recent Track $index',
        artists: ['Artist $index'],
        artworkUrl: 'https://picsum.photos/seed/recent$index/400/400',
        type: MediaType.track,
      ),
    ),
  );
});

class LibraryState {
  LibraryState({
    required this.favorites,
    required this.downloads,
    required this.recent,
  });

  final List<MediaItem> favorites;
  final List<MediaItem> downloads;
  final List<MediaItem> recent;
}

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  static const routePath = '/library';
  static const routeName = 'library';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final libraryState = ref.watch(libraryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.libraryTitle)),
      body: libraryState.when(
        data: (data) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _LibrarySection(
                title: l10n.libraryFavorites, items: data.favorites),
            const SizedBox(height: 24),
            _LibrarySection(
                title: l10n.libraryDownloads, items: data.downloads),
            const SizedBox(height: 24),
            _LibrarySection(title: l10n.libraryRecent, items: data.recent),
          ],
        ),
        error: (error, _) => Center(child: Text(context.l10n.stateError)),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _LibrarySection extends ConsumerWidget {
  const _LibrarySection({required this.title, required this.items});

  final String title;
  final List<MediaItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (items.isEmpty)
          const Text('Sin elementos todavía')
        else
          ...items.map(
            (item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(item.artworkUrl,
                    width: 48, height: 48, fit: BoxFit.cover),
              ),
              title: Text(item.title),
              subtitle: Text(item.artists.join(', ')),
              trailing: IconButton(
                icon: const Icon(Icons.download_for_offline_rounded),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final file = await ref
                      .read(downloadServiceProvider)
                      .downloadMedia(item);
                  final box = Hive.box('downloads');
                  await box.put(item.id, item.toMap());
                  messenger.showSnackBar(
                    SnackBar(content: Text('Descargado en: ${file.path}')),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
