import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:conecta_app/features/player/presentation/providers/now_playing_provider.dart';
import 'package:conecta_app/features/community/presentation/polls_contests_screen.dart';
import 'package:conecta_app/features/community/presentation/group_chat_screen.dart';

class RadioPlayerScreen extends ConsumerStatefulWidget {
  const RadioPlayerScreen({super.key});

  static const routePath = '/radio-player';
  static const routeName = 'radioPlayer';

  @override
  ConsumerState<RadioPlayerScreen> createState() => _RadioPlayerScreenState();
}

class _RadioPlayerScreenState extends ConsumerState<RadioPlayerScreen>
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

    _extractDominantColors();
  }

  void _extractDominantColors() {
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
                          Column(
                            children: [
                              Text(
                                'REPRODUCIENDO EN VIVO',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'EN VIVO',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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

                    const SizedBox(height: 20),

                    // Radio Station Logo
                    Expanded(
                      child: Center(
                        child: Hero(
                          tag: 'radio-art-${nowPlaying.item.id}',
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
                                    Icons.radio,
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

                    // Radio Info
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
                                      'Transmitiendo en vivo 24/7',
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: Colors.white70,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // Cerrar el reproductor y navegar a Perfil de Radio
                                        context.pop();
                                        Future.delayed(const Duration(milliseconds: 300), () {
                                          context.go('/radio-profile');
                                        });
                                      },
                                      icon: const Icon(Icons.person, size: 18),
                                      label: const Text('Ver perfil'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white.withOpacity(0.15),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
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

                    // Playback Controls
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: null,
                            icon: const Icon(Icons.shuffle, color: Colors.white30),
                            iconSize: 24,
                          ),
                          IconButton(
                            onPressed: null,
                            icon: const Icon(Icons.skip_previous, color: Colors.white30),
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
                            onPressed: null,
                            icon: const Icon(Icons.skip_next, color: Colors.white30),
                            iconSize: 40,
                          ),
                          IconButton(
                            onPressed: null,
                            icon: const Icon(Icons.repeat, color: Colors.white30),
                            iconSize: 24,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Quick Actions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildQuickActionButton(
                            context: context,
                            icon: Icons.emoji_events,
                            label: 'Concursos',
                            onTap: () {
                              // Cerrar el reproductor y navegar a Concursos
                              context.pop();
                              Future.delayed(const Duration(milliseconds: 300), () {
                                context.go(PollsContestsScreen.routePath);
                              });
                            },
                          ),
                          _buildQuickActionButton(
                            context: context,
                            icon: Icons.chat_bubble,
                            label: 'Chat',
                            onTap: () {
                              // Cerrar el reproductor y navegar a Chat
                              final radioName = nowPlaying.item.title;
                              context.pop();
                              Future.delayed(const Duration(milliseconds: 300), () {
                                context.goNamed(
                                  GroupChatScreen.routeName,
                                  extra: {'radioName': radioName},
                                );
                              });
                            },
                          ),
                          _buildQuickActionButton(
                            context: context,
                            icon: Icons.calendar_today,
                            label: 'Eventos',
                            onTap: () => _showEventsModal(context),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Bottom Actions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              _showVolumeModal(context);
                            },
                            icon: const Icon(Icons.volume_up, color: Colors.white70),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.devices, color: Colors.white70),
                          ),
                          IconButton(
                            onPressed: () {
                              _showShareModal(context);
                            },
                            icon: const Icon(Icons.share, color: Colors.white70),
                          ),
                          IconButton(
                            onPressed: () {
                              _showTimerModal(context);
                            },
                            icon: const Icon(Icons.timer, color: Colors.white70),
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

  Widget _buildQuickActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
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
              leading: const Icon(Icons.info_outline),
              title: const Text('Información de la estación'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Notificaciones'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add),
              title: const Text('Añadir a favoritos'),
              onTap: () {
                Navigator.pop(context);
                ref.read(nowPlayingProvider.notifier).toggleLike();
              },
            ),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('Reportar problema'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showShareModal(BuildContext context) {
    final nowPlaying = ref.read(nowPlayingProvider);
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Compartir ${nowPlaying.item.title}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Copiar enlace'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enlace copiado')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Compartir en redes'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('Mostrar código QR'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showVolumeModal(BuildContext context) {
    double volume = 0.7;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Control de volumen',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.volume_down),
                  Expanded(
                    child: Slider(
                      value: volume,
                      min: 0,
                      max: 1,
                      onChanged: (value) {
                        setState(() => volume = value);
                      },
                    ),
                  ),
                  const Icon(Icons.volume_up),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '${(volume * 100).round()}%',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTimerModal(BuildContext context) {
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
                'Temporizador de apagado',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              title: const Text('15 minutos'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Temporizador configurado: 15 minutos')),
                );
              },
            ),
            ListTile(
              title: const Text('30 minutos'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Temporizador configurado: 30 minutos')),
                );
              },
            ),
            ListTile(
              title: const Text('1 hora'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Temporizador configurado: 1 hora')),
                );
              },
            ),
            ListTile(
              title: const Text('Cancelar temporizador'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Temporizador cancelado')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEventsModal(BuildContext context) {
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
                    'Próximos eventos',
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 5,
                itemBuilder: (context, index) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.event, color: Colors.green),
                    ),
                    title: Text('Evento especial ${index + 1}'),
                    subtitle: Text('${25 + index} de Diciembre, 8:00 PM'),
                    trailing: IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Recordatorio activado')),
                        );
                      },
                    ),
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
