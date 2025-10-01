import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:conecta_app/features/player/presentation/providers/now_playing_provider.dart';

class MusicPlayerScreen extends ConsumerStatefulWidget {
  const MusicPlayerScreen({super.key});

  static const routePath = '/music-player';
  static const routeName = 'music-player';

  @override
  ConsumerState<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends ConsumerState<MusicPlayerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
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
  }

  void _extractDominantColors() {
    // En una implementación real, usarías palette_generator para extraer colores de la imagen
    // Por ahora usamos colores predefinidos que se ven bien
    setState(() {
      _dominantColor = const Color(0xFF1A0F1F);
      _secondaryColor = const Color(0xFF0D0B12);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '0:00';
    final minutes = duration.inMinutes;
    final secs = duration.inSeconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  String _formatProgress(double progress, Duration? duration) {
    if (duration == null) return '0:00';
    final seconds = (progress * duration.inSeconds).round();
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final nowPlaying = ref.watch(nowPlayingProvider);
    final controller = ref.read(nowPlayingProvider.notifier);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

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
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
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
                            'REPRODUCIENDO DESDE',
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

                    Text(
                      'Tu Biblioteca',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Album Art with animation
                    Expanded(
                      child: Center(
                        child: Hero(
                          tag: 'album-art-${nowPlaying.item.id}',
                          child: Container(
                            width: size.width * 0.85,
                            height: size.width * 0.85,
                            margin: const EdgeInsets.symmetric(horizontal: 30),
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
                              child: Image.network(
                                nowPlaying.item.artworkUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.music_note,
                                    size: size.width * 0.4,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Song Info
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          Row(
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
                                    nowPlaying.isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    key: ValueKey(nowPlaying.isLiked),
                                    color: nowPlaying.isLiked ? Colors.green : Colors.white70,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

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
                              value: nowPlaying.progress,
                              min: 0,
                              max: 1,
                              onChanged: (value) {
                                ref.read(nowPlayingProvider.notifier).setProgress(value);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatProgress(nowPlaying.progress, nowPlaying.item.duration),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  _formatDuration(nowPlaying.item.duration),
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

                    const SizedBox(height: 30),

                    // Playback Controls
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: () {
                              ref.read(nowPlayingProvider.notifier).toggleShuffle();
                            },
                            icon: Icon(
                              Icons.shuffle,
                              color: nowPlaying.isShuffled ? Colors.green : Colors.white70,
                            ),
                            iconSize: 24,
                          ),
                          IconButton(
                            onPressed: () {
                              ref.read(nowPlayingProvider.notifier).previous();
                            },
                            icon: const Icon(Icons.skip_previous, color: Colors.white),
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
                                  nowPlaying.isPlaying ? Icons.pause : Icons.play_arrow,
                                  key: ValueKey(nowPlaying.isPlaying),
                                  color: Colors.black,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              ref.read(nowPlayingProvider.notifier).next();
                            },
                            icon: const Icon(Icons.skip_next, color: Colors.white),
                            iconSize: 40,
                          ),
                          IconButton(
                            onPressed: () {
                              ref.read(nowPlayingProvider.notifier).toggleRepeat();
                            },
                            icon: Icon(
                              Icons.repeat,
                              color: nowPlaying.repeatMode != RepeatMode.off
                                  ? Colors.green
                                  : Colors.white70,
                            ),
                            iconSize: 24,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Bottom Actions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.devices, color: Colors.white70),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.playlist_play, color: Colors.white70),
                          ),
                          IconButton(
                            onPressed: () {
                              _showShareModal(context);
                            },
                            icon: const Icon(Icons.share, color: Colors.white70),
                          ),
                          IconButton(
                            onPressed: () {
                              _showQueueModal(context);
                            },
                            icon: const Icon(Icons.queue_music, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
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
              leading: const Icon(Icons.album),
              title: const Text('Ver álbum'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Ver artista'),
              onTap: () {
                Navigator.pop(context);
                // Cerrar el reproductor y navegar al perfil del artista
                context.pop();
                Future.delayed(const Duration(milliseconds: 300), () {
                  context.go('/artist-profile');
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.radio),
              title: const Text('Ir a radio de la canción'),
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
                'Compartir canción',
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

  void _showQueueModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Cola de reproducción',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) => ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[300],
                      child: const Icon(Icons.music_note),
                    ),
                  ),
                  title: Text('Canción ${index + 1}'),
                  subtitle: const Text('Artista'),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {},
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}