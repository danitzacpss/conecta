import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:conecta_app/core/localization/l10n.dart';
import 'package:conecta_app/features/home/domain/entities/media_item.dart';

final searchControllerProvider =
    StateNotifierProvider<SearchController, AsyncValue<List<MediaItem>>>(
  (ref) => SearchController(),
);

class SearchController extends StateNotifier<AsyncValue<List<MediaItem>>> {
  SearchController() : super(const AsyncValue.data([]));

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    await Future<void>.delayed(const Duration(milliseconds: 400));
    state = AsyncValue.data(
      List.generate(
        6,
        (index) => MediaItem(
          id: 'search-$index',
          title: '$query result $index',
          artists: ['Artist $index'],
          artworkUrl: 'https://picsum.photos/seed/search$index/300/300',
          type: MediaType.track,
          duration: const Duration(minutes: 3),
        ),
      ),
    );
  }
}

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  static const routePath = '/search';
  static const routeName = 'search';

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final results = ref.watch(searchControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.searchTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: l10n.searchPlaceholder,
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) =>
                  ref.read(searchControllerProvider.notifier).search(value),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: results.when(
                data: (items) => ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(item.artworkUrl,
                            width: 48, height: 48, fit: BoxFit.cover),
                      ),
                      title: Text(item.title),
                      subtitle: Text(item.artists.join(', ')),
                      trailing: const Icon(Icons.play_arrow_rounded),
                    );
                  },
                ),
                error: (error, _) =>
                    Center(child: Text(context.l10n.stateError)),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
