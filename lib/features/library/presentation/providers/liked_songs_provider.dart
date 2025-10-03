import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:conecta_app/features/home/domain/entities/media_item.dart';

final likedSongsProvider =
    StateNotifierProvider<LikedSongsController, List<MediaItem>>(
  (ref) => LikedSongsController(),
);

class LikedSongsController extends StateNotifier<List<MediaItem>> {
  LikedSongsController() : super([]);

  void toggleLike(MediaItem item) {
    final isCurrentlyLiked = state.any((song) => song.id == item.id);

    if (isCurrentlyLiked) {
      // Remover de favoritos
      state = state.where((song) => song.id != item.id).toList();
    } else {
      // Agregar a favoritos
      final likedItem = item.copyWith(isLiked: true);
      state = [...state, likedItem];
    }
  }

  bool isLiked(String itemId) {
    return state.any((song) => song.id == itemId);
  }

  void removeSong(String itemId) {
    state = state.where((song) => song.id != itemId).toList();
  }
}
