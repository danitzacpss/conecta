import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:conecta_app/features/player/presentation/providers/now_playing_provider.dart';

class LiveRadioPlayerScreen extends ConsumerStatefulWidget {
  const LiveRadioPlayerScreen({super.key});

  static const routePath = '/live-radio-player';
  static const routeName = 'live-radio-player';

  @override
  ConsumerState<LiveRadioPlayerScreen> createState() => _LiveRadioPlayerScreenState();
}

class _LiveRadioPlayerScreenState extends ConsumerState<LiveRadioPlayerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Color _dominantColor = Colors.orange;
  Color _secondaryColor = Colors.purple;

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

    // Simular extracción de colores dominantes de la estación
    _extractDominantColors();
  }

  void _extractDominantColors() {
    // En una implementación real, usarías los colores de la marca de la radio
    setState(() {
      _dominantColor = Colors.deepOrange.shade400;
      _secondaryColor = Colors.purple.shade600;
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.circle, color: Colors.white, size: 8),
                                const SizedBox(width: 6),
                                Text(
                                  'EN VIVO',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
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

                    const SizedBox(height: 40),

                    // Radio Station Logo
                    Expanded(
                      child: Center(
                        child: Hero(
                          tag: 'radio-logo-${nowPlaying.item.id}',
                          child: Container(
                            width: size.width * 0.65,
                            height: size.width * 0.65,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.orange.shade700,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 40,
                                  offset: const Offset(0, 25),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.radio,
                                  size: size.width * 0.25,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Radio Station',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Station Info
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          Text(
                            nowPlaying.item.title,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            nowPlaying.item.artists.join(', '),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Ver Perfil',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Playback Controls for Live Radio
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Volume Down
                          IconButton(
                            onPressed: () {
                              // Implementar control de volumen
                            },
                            icon: const Icon(Icons.volume_down, color: Colors.white),
                            iconSize: 32,
                          ),
                          // Previous Station
                          IconButton(
                            onPressed: () {
                              // Cambiar a estación anterior
                              controller.previous();
                            },
                            icon: const Icon(Icons.skip_previous, color: Colors.white),
                            iconSize: 40,
                          ),
                          // Play/Pause
                          GestureDetector(
                            onTap: controller.togglePlay,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  nowPlaying.isPlaying ? Icons.pause : Icons.play_arrow,
                                  key: ValueKey(nowPlaying.isPlaying),
                                  color: _dominantColor,
                                  size: 45,
                                ),
                              ),
                            ),
                          ),
                          // Next Station
                          IconButton(
                            onPressed: () {
                              // Cambiar a siguiente estación
                              controller.next();
                            },
                            icon: const Icon(Icons.skip_next, color: Colors.white),
                            iconSize: 40,
                          ),
                          // Volume Up
                          IconButton(
                            onPressed: () {
                              // Implementar control de volumen
                            },
                            icon: const Icon(Icons.volume_up, color: Colors.white),
                            iconSize: 32,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Quick Actions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _QuickActionButton(
                            icon: Icons.emoji_events,
                            label: 'Concursos',
                            color: Colors.purple,
                            onTap: () {
                              context.push('/polls-contests');
                            },
                          ),
                          _QuickActionButton(
                            icon: Icons.groups,
                            label: 'Chat\nGrupal',
                            color: Colors.green,
                            onTap: () {
                              context.push('/group-chat', extra: {
                                'radioName': nowPlaying.item.title,
                              });
                            },
                          ),
                          _QuickActionButton(
                            icon: Icons.event,
                            label: 'Eventos',
                            color: Colors.pink,
                            onTap: () {
                              context.push('/events');
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Bottom Actions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              _showShareModal(context);
                            },
                            icon: const Icon(Icons.share, color: Colors.white70),
                          ),
                          const SizedBox(width: 30),
                          IconButton(
                            onPressed: controller.toggleLike,
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Icon(
                                nowPlaying.isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                key: ValueKey(nowPlaying.isLiked),
                                color: nowPlaying.isLiked ? Colors.red : Colors.white70,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(width: 30),
                          IconButton(
                            onPressed: () {
                              _showScheduleModal(context);
                            },
                            icon: const Icon(Icons.schedule, color: Colors.white70),
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
              leading: const Icon(Icons.info),
              title: const Text('Acerca de la radio'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Locutores'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Programación'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.contact_phone),
              title: const Text('Contactar'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Sitio web'),
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
                'Compartir radio',
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
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('Código QR'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showScheduleModal(BuildContext context) {
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
                    'Programación del día',
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
                itemCount: 12,
                itemBuilder: (context, index) {
                  final hour = 6 + index;
                  final isNow = hour == 14; // Simular programa actual
                  return Container(
                    color: isNow ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isNow ? Theme.of(context).primaryColor : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${hour.toString().padLeft(2, '0')}:00',
                          style: TextStyle(
                            color: isNow ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        _getProgramName(hour),
                        style: TextStyle(
                          fontWeight: isNow ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(_getProgramHost(hour)),
                      trailing: isNow
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'AL AIRE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getProgramName(int hour) {
    final programs = {
      6: 'Buenos Días',
      8: 'Noticias de la Mañana',
      10: 'Magazine Musical',
      12: 'El Show del Mediodía',
      14: 'Onda Urbana',
      16: 'Tarde de Éxitos',
      18: 'Drive Time',
      20: 'Noche de Clásicos',
    };
    return programs[hour] ?? 'Programación Musical';
  }

  String _getProgramHost(int hour) {
    final hosts = {
      6: 'Con Carlos y María',
      8: 'Con el equipo de noticias',
      10: 'Con DJ Alex',
      12: 'Con Laura Martínez',
      14: 'El Show de la Mañana',
      16: 'Con Roberto Gómez',
      18: 'Con Ana y Pedro',
      20: 'Con DJ Classic',
    };
    return hosts[hour] ?? 'Música continua';
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}