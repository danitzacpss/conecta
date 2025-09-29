import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:conecta_app/features/home/domain/entities/media_item.dart';

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
            ),
            progress: 0.35,
            isPlaying: true,
            isLiked: false,
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
}

class NowPlayingState {
  const NowPlayingState({
    required this.item,
    required this.progress,
    required this.isPlaying,
    required this.isLiked,
  });

  final MediaItem item;
  final double progress;
  final bool isPlaying;
  final bool isLiked;

  NowPlayingState copyWith({
    MediaItem? item,
    double? progress,
    bool? isPlaying,
    bool? isLiked,
  }) {
    return NowPlayingState(
      item: item ?? this.item,
      progress: progress ?? this.progress,
      isPlaying: isPlaying ?? this.isPlaying,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
