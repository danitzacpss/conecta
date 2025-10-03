import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:conecta_app/features/home/domain/entities/media_item.dart';
import 'package:conecta_app/features/library/presentation/providers/liked_songs_provider.dart';
import 'package:conecta_app/features/library/presentation/saved_vods_screen.dart';

enum RepeatMode { off, one, all }

final nowPlayingProvider =
    StateNotifierProvider<NowPlayingController, NowPlayingState>(
  (ref) => NowPlayingController(ref),
);

class NowPlayingController extends StateNotifier<NowPlayingState> {
  final Ref ref;

  NowPlayingController(this.ref)
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
            queue: [],
            currentIndex: 0,
          ),
        );

  void play(MediaItem item) {
    final isLiked = ref.read(likedSongsProvider.notifier).isLiked(item.id);
    state = state.copyWith(
      item: item,
      progress: 0,
      isPlaying: true,
      isLiked: isLiked,
    );
  }

  void playQueue(List<MediaItem> queue, int startIndex) {
    if (queue.isEmpty) return;

    // Si shuffle está activo, crear una cola mezclada
    List<MediaItem> finalQueue = queue;
    int finalIndex = startIndex;

    if (state.isShuffled) {
      // Crear una copia de la cola
      finalQueue = List.from(queue);
      // Guardar la canción seleccionada
      final selectedItem = finalQueue[startIndex];
      // Mezclar la cola
      finalQueue.shuffle();
      // Poner la canción seleccionada al inicio
      finalQueue.remove(selectedItem);
      finalQueue.insert(0, selectedItem);
      finalIndex = 0;
    }

    final isLiked = ref.read(likedSongsProvider.notifier).isLiked(finalQueue[finalIndex].id);
    state = state.copyWith(
      queue: finalQueue,
      currentIndex: finalIndex,
      item: finalQueue[finalIndex],
      progress: 0,
      isPlaying: true,
      isLiked: isLiked,
    );
  }

  void togglePlay() {
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  void toggleLike() {
    // Si es un video o podcast, guardar en savedVodsProvider en lugar de likedSongsProvider
    if (state.item.type == MediaType.video || state.item.type == MediaType.podcast) {
      final savedVodsController = ref.read(savedVodsProvider.notifier);
      final isCurrentlySaved = ref.read(savedVodsProvider).any((v) => v.id == state.item.id);

      if (isCurrentlySaved) {
        // Si ya estaba guardado, quitarlo
        savedVodsController.removeVod(state.item.id);
      } else {
        // Si no estaba guardado, guardarlo
        savedVodsController.saveVod(state.item);
      }
    } else {
      // Para canciones normales, usar el provider de canciones favoritas
      ref.read(likedSongsProvider.notifier).toggleLike(state.item);
    }

    // Obtener el nuevo estado de like
    bool newLikedState;
    if (state.item.type == MediaType.video || state.item.type == MediaType.podcast) {
      newLikedState = ref.read(savedVodsProvider).any((v) => v.id == state.item.id);
    } else {
      newLikedState = ref.read(likedSongsProvider.notifier).isLiked(state.item.id);
    }

    final updatedItem = state.item.copyWith(isLiked: newLikedState);

    // Actualizar el item en la cola si existe y el índice es válido
    List<MediaItem> updatedQueue;
    if (state.queue.isNotEmpty && state.currentIndex < state.queue.length && state.currentIndex >= 0) {
      updatedQueue = List<MediaItem>.from(state.queue);
      updatedQueue[state.currentIndex] = updatedItem;
    } else {
      updatedQueue = state.queue;
    }

    state = state.copyWith(
      isLiked: newLikedState,
      item: updatedItem,
      queue: updatedQueue,
    );
  }

  void setProgress(double progress) {
    state = state.copyWith(progress: progress.clamp(0, 1));
  }

  void toggleShuffle() {
    final newShuffleState = !state.isShuffled;

    // Si hay una cola activa, reorganizarla
    if (state.queue.isNotEmpty) {
      List<MediaItem> newQueue = List.from(state.queue);
      final currentItem = state.item;

      if (newShuffleState) {
        // Activar shuffle: mezclar la cola pero mantener la canción actual
        newQueue.shuffle();
        // Asegurar que la canción actual esté en la posición actual
        newQueue.remove(currentItem);
        newQueue.insert(state.currentIndex, currentItem);
      } else {
        // Desactivar shuffle: restaurar el orden original sería complejo,
        // por ahora solo actualizamos el estado
        // En una implementación real, guardarías la cola original
      }

      state = state.copyWith(
        isShuffled: newShuffleState,
        queue: newQueue,
      );
    } else {
      state = state.copyWith(isShuffled: newShuffleState);
    }
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
    // Si hay una cola de reproducción
    if (state.queue.isNotEmpty) {
      int nextIndex = state.currentIndex + 1;

      // Si llegamos al final de la cola
      if (nextIndex >= state.queue.length) {
        // Si repeat all está activo, volver al inicio
        if (state.repeatMode == RepeatMode.all) {
          nextIndex = 0;
        } else {
          // No hacer nada si no hay repeat
          return;
        }
      }

      final isLiked = ref.read(likedSongsProvider.notifier).isLiked(state.queue[nextIndex].id);
      state = state.copyWith(
        currentIndex: nextIndex,
        item: state.queue[nextIndex],
        progress: 0,
        isPlaying: true,
        isLiked: isLiked,
      );
    } else {
      // Comportamiento antiguo si no hay cola
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
  }

  void previous() {
    // Si el progreso es mayor al 10%, reiniciar la canción actual
    if (state.progress > 0.1) {
      state = state.copyWith(progress: 0);
      return;
    }

    // Si hay una cola de reproducción
    if (state.queue.isNotEmpty) {
      int prevIndex = state.currentIndex - 1;

      // Si estamos en la primera canción
      if (prevIndex < 0) {
        // Si repeat all está activo, ir al final
        if (state.repeatMode == RepeatMode.all) {
          prevIndex = state.queue.length - 1;
        } else {
          // Reiniciar la canción actual
          state = state.copyWith(progress: 0);
          return;
        }
      }

      final isLiked = ref.read(likedSongsProvider.notifier).isLiked(state.queue[prevIndex].id);
      state = state.copyWith(
        currentIndex: prevIndex,
        item: state.queue[prevIndex],
        progress: 0,
        isPlaying: true,
        isLiked: isLiked,
      );
    } else {
      // Comportamiento antiguo si no hay cola
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
    this.queue = const [],
    this.currentIndex = 0,
  });

  final MediaItem item;
  final double progress;
  final bool isPlaying;
  final bool isLiked;
  final bool isShuffled;
  final RepeatMode repeatMode;
  final List<MediaItem> queue;
  final int currentIndex;

  NowPlayingState copyWith({
    MediaItem? item,
    double? progress,
    bool? isPlaying,
    bool? isLiked,
    bool? isShuffled,
    RepeatMode? repeatMode,
    List<MediaItem>? queue,
    int? currentIndex,
  }) {
    return NowPlayingState(
      item: item ?? this.item,
      progress: progress ?? this.progress,
      isPlaying: isPlaying ?? this.isPlaying,
      isLiked: isLiked ?? this.isLiked,
      isShuffled: isShuffled ?? this.isShuffled,
      repeatMode: repeatMode ?? this.repeatMode,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}
