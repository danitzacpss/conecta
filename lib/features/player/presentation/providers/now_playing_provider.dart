import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:conecta_app/features/home/domain/entities/media_item.dart';

enum RepeatMode { off, one, all }

final nowPlayingProvider =
    StateNotifierProvider<NowPlayingController, NowPlayingState>(
  (ref) => NowPlayingController(),
);

class NowPlayingController extends StateNotifier<NowPlayingState> {
  NowPlayingController()
      : super(
          // ignore: prefer_const_constructors
          NowPlayingState(
            item: const MediaItem(
              id: 'initial',
              title: 'Conecta Radio',
              artists: ['Bienvenido'],
              artworkUrl: 'https://picsum.photos/seed/nowplaying/200/200',
              type: MediaType.radio,
              isLive: true,
              duration: Duration(minutes: 3, seconds: 45),
            ),
            progress: 0.35,
            isPlaying: true,
            isLiked: false,
            isShuffled: false,
            repeatMode: RepeatMode.off,
          ),
        );

  void play(MediaItem item) {
    state = state.copyWith(item: item, progress: 0, isPlaying: true);
  }

  void togglePlay() {
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  void toggleLike() {
    state = state.copyWith(isLiked: !state.isLiked);
  }

  void setProgress(double progress) {
    state = state.copyWith(progress: progress.clamp(0, 1));
  }

  void toggleShuffle() {
    state = state.copyWith(isShuffled: !state.isShuffled);
  }

  void toggleRepeat() {
    final nextMode = switch (state.repeatMode) {
      RepeatMode.off => RepeatMode.one,
      RepeatMode.one => RepeatMode.all,
      RepeatMode.all => RepeatMode.off,
    };
    state = state.copyWith(repeatMode: nextMode);
  }

  void next() {
    // Implementar lógica para siguiente canción
    // Por ahora solo simula
    state = state.copyWith(
      item: MediaItem(
        id: 'next-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Siguiente canción',
        artists: ['Artista'],
        artworkUrl: 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/200/200',
        type: MediaType.track,
        duration: const Duration(minutes: 4, seconds: 20),
      ),
      progress: 0,
    );
  }

  void previous() {
    // Implementar lógica para canción anterior
    // Por ahora solo resetea el progreso
    if (state.progress > 0.1) {
      state = state.copyWith(progress: 0);
    } else {
      // Ir a canción anterior
      state = state.copyWith(
        item: MediaItem(
          id: 'prev-${DateTime.now().millisecondsSinceEpoch}',
          title: 'Canción anterior',
          artists: ['Artista'],
          artworkUrl: 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/200/200',
          type: MediaType.track,
          duration: const Duration(minutes: 3, seconds: 15),
        ),
        progress: 0,
      );
    }
  }
}

class NowPlayingState {
  const NowPlayingState({
    required this.item,
    required this.progress,
    required this.isPlaying,
    required this.isLiked,
    this.isShuffled = false,
    this.repeatMode = RepeatMode.off,
  });

  final MediaItem item;
  final double progress;
  final bool isPlaying;
  final bool isLiked;
  final bool isShuffled;
  final RepeatMode repeatMode;

  NowPlayingState copyWith({
    MediaItem? item,
    double? progress,
    bool? isPlaying,
    bool? isLiked,
    bool? isShuffled,
    RepeatMode? repeatMode,
  }) {
    return NowPlayingState(
      item: item ?? this.item,
      progress: progress ?? this.progress,
      isPlaying: isPlaying ?? this.isPlaying,
      isLiked: isLiked ?? this.isLiked,
      isShuffled: isShuffled ?? this.isShuffled,
      repeatMode: repeatMode ?? this.repeatMode,
    );
  }
}
