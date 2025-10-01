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

  void toggleFullscreen() async {
    state = state.copyWith(isFullscreen: !state.isFullscreen);
    if (state.isFullscreen) {
      // Cambiar a modo horizontal para pantalla completa
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      // Volver a modo vertical con pequeño delay para evitar overflow
      await Future.delayed(const Duration(milliseconds: 100));
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
  Color _dominantColor = const Color(0xFF1A0F1F);
  Color _secondaryColor = const Color(0xFF0D0B12);
  bool _isCommentsExpanded = false;

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

    // Cargar comentarios de ejemplo
    _loadSampleComments();
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
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(seconds: 1),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _dominantColor.withOpacity(0.8),
                  _dominantColor,
                  _secondaryColor,
                  _secondaryColor.withOpacity(0.9),
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Stack(
                  children: [
                    // Main content
                    Column(
                      children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 30),
                          ),
                          Text(
                            'REPRODUCIENDO VIDEO',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _showOptionsModal(context);
                            },
                            icon: const Icon(Icons.more_vert, color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 5),

                    // Video Player Area
                    Hero(
                      tag: 'video-player-${nowPlaying.item.id}',
                      child: Container(
                        width: size.width * 0.85,
                        height: size.width * 0.55,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 40,
                              offset: const Offset(0, 25),
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
                                height: double.infinity,
                                child: Image.network(
                                  nowPlaying.item.artworkUrl,
                                  fit: BoxFit.cover,
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
                              // Play/Pause button
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
                                          size: 60,
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
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
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
                                      ),
                                      // Fullscreen button
                                      IconButton(
                                        onPressed: controller.toggleFullscreen,
                                        icon: const Icon(Icons.fullscreen, color: Colors.white),
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

                    const SizedBox(height: 10),

                    // Video Info
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nowPlaying.item.title,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  nowPlaying.item.artists.join(', '),
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.white70,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: controller.toggleLike,
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Icon(
                                vodState.isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                key: ValueKey(vodState.isLiked),
                                color: vodState.isLiked ? Colors.red : Colors.white70,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Progress Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                              activeTrackColor: Colors.white,
                              inactiveTrackColor: Colors.white24,
                              thumbColor: Colors.white,
                              overlayColor: Colors.white24,
                            ),
                            child: Slider(
                              value: vodState.progress,
                              min: 0,
                              max: 1,
                              onChanged: (value) {
                                controller.setProgress(value);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(vodState.currentTime),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  _formatDuration(vodState.duration),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Playback Controls
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: null,
                            icon: const Icon(
                              Icons.shuffle,
                              color: Colors.white24,
                            ),
                            iconSize: 24,
                          ),
                          IconButton(
                            onPressed: null,
                            icon: const Icon(Icons.skip_previous, color: Colors.white24),
                            iconSize: 40,
                          ),
                          GestureDetector(
                            onTap: controller.togglePlay,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  vodState.isPlaying ? Icons.pause : Icons.play_arrow,
                                  key: ValueKey(vodState.isPlaying),
                                  color: Colors.black,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: null,
                            icon: const Icon(Icons.skip_next, color: Colors.white24),
                            iconSize: 40,
                          ),
                          IconButton(
                            onPressed: null,
                            icon: const Icon(
                              Icons.repeat,
                              color: Colors.white24,
                            ),
                            iconSize: 24,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Bottom Actions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              _showShareModal(context);
                            },
                            icon: const Icon(Icons.share, color: Colors.white70),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.download, color: Colors.white70),
                          ),
                          IconButton(
                            onPressed: () {
                              _showQualityModal(context);
                            },
                            icon: const Icon(Icons.high_quality, color: Colors.white70),
                          ),
                          IconButton(
                            onPressed: () {
                              // Scroll to comments
                              _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            icon: const Icon(Icons.comment, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),

                    // Spacer to push content up
                    Expanded(child: Container()),
                      ],
                    ),

                    // Comments overlay
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isCommentsExpanded = !_isCommentsExpanded;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          height: _isCommentsExpanded
                            ? size.height * 0.7
                            : size.height * 0.30,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1C1E),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(32),
                              topRight: Radius.circular(32),
                            ),
                          ),
                          child: Column(
                            children: [
                              // Handle for dragging
                              Container(
                                width: 40,
                                height: 4,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              // Header with comment count
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Comentarios',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '${vodState.comments.length}',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: Colors.white70,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          _isCommentsExpanded
                                            ? Icons.keyboard_arrow_down
                                            : Icons.keyboard_arrow_up,
                                          color: Colors.white70,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Comments list
                              Expanded(
                                child: ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 80),
                                  itemCount: vodState.comments.length,
                                  itemBuilder: (context, index) {
                                    final comment = vodState.comments[index];
                                    return _buildCommentItem(comment, controller);
                                  },
                                ),
                              ),
                              // Comment input
                              Container(
                                padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.white.withOpacity(0.1),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _commentController,
                                        style: const TextStyle(color: Colors.white),
                                        decoration: InputDecoration(
                                          hintText: 'Añade un comentario...',
                                          hintStyle: const TextStyle(color: Colors.white54),
                                          filled: true,
                                          fillColor: Colors.white.withOpacity(0.1),
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
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.send,
                                          color: Colors.black,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommentItem(Comment comment, VodPlayerController controller) {
    final theme = Theme.of(context);
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
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatCommentTime(comment.timestamp),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.comment,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        controller.likeComment(comment.id);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            comment.isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: comment.isLiked ? Colors.red : Colors.white60,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${comment.likes}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white60,
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
                          color: Colors.white60,
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

  void _showOptionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Información del video'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add),
              title: const Text('Agregar a playlist'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Descargar'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showShareModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Compartir video',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Copiar enlace'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Compartir en redes'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showQualityModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Calidad de video',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.high_quality),
              title: const Text('1080p (Alta)'),
              trailing: const Icon(Icons.check),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.hd),
              title: const Text('720p (Media)'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.sd),
              title: const Text('480p (Baja)'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: const Text('Automático'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
