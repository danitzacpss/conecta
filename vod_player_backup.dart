import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:conecta_app/features/player/presentation/providers/now_playing_provider.dart';

// Provider para manejar el estado del reproductor de VOD
final vodPlayerProvider = StateNotifierProvider<VodPlayerController, VodPlayerState>(
  (ref) => VodPlayerController(),
);

class VodPlayerController extends StateNotifier<VodPlayerState> {
  VodPlayerController() : super(VodPlayerState());

  void togglePlay() {
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  void setProgress(double progress) {
    state = state.copyWith(progress: progress.clamp(0, 1));
  }

  void toggleFullscreen() {
    state = state.copyWith(isFullscreen: !state.isFullscreen);
    if (state.isFullscreen) {
      // Cambiar a modo horizontal para pantalla completa
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      // Volver a modo vertical
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  void toggleLike() {
    state = state.copyWith(isLiked: !state.isLiked);
  }

  void seek(double seconds) {
    final newProgress = (state.currentTime + seconds) / state.duration;
    state = state.copyWith(
      progress: newProgress.clamp(0, 1),
      currentTime: (state.currentTime + seconds).clamp(0, state.duration),
    );
  }

  void addComment(String comment) {
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: 'Usuario Actual',
      avatarUrl: 'https://picsum.photos/seed/user/50/50',
      comment: comment,
      timestamp: DateTime.now(),
      likes: 0,
    );
    state = state.copyWith(
      comments: [...state.comments, newComment],
    );
  }

  void likeComment(String commentId) {
    final updatedComments = state.comments.map((comment) {
      if (comment.id == commentId) {
        return comment.copyWith(
          likes: comment.isLiked ? comment.likes - 1 : comment.likes + 1,
          isLiked: !comment.isLiked,
        );
      }
      return comment;
    }).toList();
    state = state.copyWith(comments: updatedComments);
  }
}

class VodPlayerState {
  final bool isPlaying;
  final double progress;
  final double duration;
  final double currentTime;
  final bool isFullscreen;
  final bool isLiked;
  final List<Comment> comments;

  VodPlayerState({
    this.isPlaying = false,
    this.progress = 0.3,
    this.duration = 1800, // 30 minutos en segundos
    this.currentTime = 540, // 9 minutos
    this.isFullscreen = false,
    this.isLiked = false,
    this.comments = const [],
  });

  VodPlayerState copyWith({
    bool? isPlaying,
    double? progress,
    double? duration,
    double? currentTime,
    bool? isFullscreen,
    bool? isLiked,
    List<Comment>? comments,
  }) {
    return VodPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      progress: progress ?? this.progress,
      duration: duration ?? this.duration,
      currentTime: currentTime ?? this.currentTime,
      isFullscreen: isFullscreen ?? this.isFullscreen,
      isLiked: isLiked ?? this.isLiked,
      comments: comments ?? this.comments,
    );
  }
}

class Comment {
  final String id;
  final String username;
  final String avatarUrl;
  final String comment;
  final DateTime timestamp;
  final int likes;
  final bool isLiked;

  Comment({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.comment,
    required this.timestamp,
    required this.likes,
    this.isLiked = false,
  });

  Comment copyWith({
    String? id,
    String? username,
    String? avatarUrl,
    String? comment,
    DateTime? timestamp,
    int? likes,
    bool? isLiked,
  }) {
    return Comment(
      id: id ?? this.id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      comment: comment ?? this.comment,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

class VodPlayerScreen extends ConsumerStatefulWidget {
  const VodPlayerScreen({super.key});

  static const routePath = '/vod-player';
  static const routeName = 'vodPlayer';

  @override
  ConsumerState<VodPlayerScreen> createState() => _VodPlayerScreenState();
}

class _VodPlayerScreenState extends ConsumerState<VodPlayerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Color _dominantColor = Colors.purple;
  Color _secondaryColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();

    // Simular extracción de colores dominantes
    _extractDominantColors();

    // Cargar comentarios de ejemplo
    _loadSampleComments();
  }

  void _extractDominantColors() {
    setState(() {
      _dominantColor = Colors.purple.shade600;
      _secondaryColor = Colors.blue.shade800;
    });
  }

  void _loadSampleComments() {
    final sampleComments = [
      Comment(
        id: '1',
        username: 'María García',
        avatarUrl: 'https://picsum.photos/seed/maria/50/50',
        comment: '¡Excelente entrevista! Me encantó la parte donde habla de su proceso creativo.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        likes: 24,
      ),
      Comment(
        id: '2',
        username: 'Carlos López',
        avatarUrl: 'https://picsum.photos/seed/carlos/50/50',
        comment: 'Muy buenas preguntas del entrevistador 👏',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        likes: 18,
      ),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var comment in sampleComments) {
        ref.read(vodPlayerProvider.notifier).addComment(comment.comment);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _commentController.dispose();
    _scrollController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  String _formatDuration(double seconds) {
    final duration = Duration(seconds: seconds.toInt());
    final minutes = duration.inMinutes;
    final secs = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatCommentTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else {
      return 'Hace ${difference.inDays}d';
    }
  }

  @override
  Widget build(BuildContext context) {
    final vodState = ref.watch(vodPlayerProvider);
    final controller = ref.read(vodPlayerProvider.notifier);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final nowPlaying = ref.watch(nowPlayingProvider);

    // Si está en pantalla completa, mostrar solo el video
    if (vodState.isFullscreen) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: controller.togglePlay,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Video a pantalla completa
              Container(
                color: Colors.black,
                width: size.width,
                height: size.height,
                child: Image.network(
                  nowPlaying.item.artworkUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.black,
                    child: const Icon(
                      Icons.video_library,
                      size: 100,
                      color: Colors.white24,
                    ),
                  ),
                ),
              ),
              // Play/Pause overlay
              AnimatedOpacity(
                opacity: vodState.isPlaying ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    vodState.isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
              // Controls overlay at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => controller.seek(-10),
                          icon: const Icon(Icons.replay_10, color: Colors.white),
                        ),
                        IconButton(
                          onPressed: controller.togglePlay,
                          icon: Icon(
                            vodState.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () => controller.seek(10),
                          icon: const Icon(Icons.forward_10, color: Colors.white),
                        ),
                        Expanded(
                          child: Text(
                            '${_formatDuration(vodState.currentTime)} / ${_formatDuration(vodState.duration)}',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          onPressed: controller.toggleFullscreen,
                          icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Close button at top
              Positioned(
                top: 40,
                left: 16,
                child: IconButton(
                  onPressed: controller.toggleFullscreen,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Vista normal (no pantalla completa)
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _dominantColor.withOpacity(0.8),
              _secondaryColor.withOpacity(0.6),
            ],
          ),
        ),
        child: Column(
          children: [
            // Top safe area
            SizedBox(height: MediaQuery.of(context).padding.top),

            // Main content
            Expanded(
              child: Column(
                children: [
                  // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/home');
                        }
                      },
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _showOptionsMenu(context);
                      },
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Video Player Area - Más grande
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  height: size.height * 0.30, // 30% de la pantalla para evitar overflow
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Video placeholder
                        Container(
                          color: Colors.black,
                          width: double.infinity,
                          child: Image.network(
                            nowPlaying.item.artworkUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[900],
                              child: const Icon(
                                Icons.video_library,
                                size: 80,
                                color: Colors.white24,
                              ),
                            ),
                          ),
                        ),
                        // Controls overlay
                        GestureDetector(
                          onTap: controller.togglePlay,
                          child: Container(
                            color: Colors.transparent,
                            child: Center(
                              child: AnimatedOpacity(
                                opacity: vodState.isPlaying ? 0.0 : 1.0,
                                duration: const Duration(milliseconds: 300),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    vodState.isPlaying ? Icons.pause : Icons.play_arrow,
                                    size: vodState.isFullscreen ? 80 : 60,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Video controls bar at bottom
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.8),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Row(
                              children: [
                                // Seek buttons
                                IconButton(
                                  onPressed: () => controller.seek(-10),
                                  icon: const Icon(Icons.replay_10, color: Colors.white),
                                  iconSize: 28,
                                ),
                                IconButton(
                                  onPressed: controller.togglePlay,
                                  icon: Icon(
                                    vodState.isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                  ),
                                  iconSize: 32,
                                ),
                                IconButton(
                                  onPressed: () => controller.seek(10),
                                  icon: const Icon(Icons.forward_10, color: Colors.white),
                                  iconSize: 28,
                                ),
                                // Time indicator
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(
                                        _formatDuration(vodState.currentTime),
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                      const Text(
                                        ' / ',
                                        style: TextStyle(color: Colors.white54, fontSize: 12),
                                      ),
                                      Text(
                                        _formatDuration(vodState.duration),
                                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                // Fullscreen button
                                IconButton(
                                  onPressed: controller.toggleFullscreen,
                                  icon: Icon(
                                    vodState.isFullscreen
                                      ? Icons.fullscreen_exit
                                      : Icons.fullscreen,
                                    color: Colors.white,
                                  ),
                                  iconSize: 28,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Title and Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nowPlaying.item.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nowPlaying.item.artists.join(', '),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    // Progress Bar
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white30,
                        thumbColor: Colors.white,
                        overlayColor: Colors.white24,
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      ),
                      child: Slider(
                        value: vodState.progress,
                        onChanged: (value) {
                          controller.setProgress(value);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        IconButton(
                          onPressed: controller.toggleLike,
                          icon: Icon(
                            vodState.isLiked ? Icons.favorite : Icons.favorite_border,
                            color: vodState.isLiked ? Colors.red : Colors.white70,
                          ),
                          iconSize: 28,
                        ),
                        Text(
                          'Me gusta',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white60,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          onPressed: () {
                            // Comments are always visible below
                          },
                          icon: Icon(
                            Icons.comment,
                            color: theme.colorScheme.primary,
                          ),
                          iconSize: 28,
                        ),
                        Text(
                          'Comentarios',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white60,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.share_outlined,
                            color: Colors.white70,
                          ),
                          iconSize: 28,
                        ),
                        Text(
                          'Compartir',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white60,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.download_outlined,
                            color: Colors.white70,
                          ),
                          iconSize: 28,
                        ),
                        Text(
                          'Descargar',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white60,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Comments Section - Takes available space but leaves room for input
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Comentarios',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${vodState.comments.length}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Comments list
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: vodState.comments.length,
                          itemBuilder: (context, index) {
                            final comment = vodState.comments[index];
                            return _buildCommentItem(comment, controller, theme);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
                ],
              ),
            ),

            // Comment input at bottom with SafeArea and white background extending to edges
              Container(
                width: double.infinity,
                color: theme.colorScheme.surface,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration: InputDecoration(
                                hintText: 'Añade un comentario...',
                                filled: true,
                                fillColor: theme.colorScheme.surfaceContainerHighest,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              if (_commentController.text.isNotEmpty) {
                                controller.addComment(_commentController.text);
                                _commentController.clear();
                              }
                            },
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // SafeArea only for bottom padding
                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(Comment comment, VodPlayerController controller, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(comment.avatarUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.username,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatCommentTime(comment.timestamp),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.comment,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // TODO: Implement comment like functionality
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            comment.isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: comment.isLiked ? Colors.red : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${comment.likes}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Responder',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.queue_music),
                title: const Text('Añadir a cola'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.playlist_add),
                title: const Text('Añadir a playlist'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Compartir'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Información'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
