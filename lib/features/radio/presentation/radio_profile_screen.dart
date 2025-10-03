import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:conecta_app/features/community/presentation/polls_contests_screen.dart';
import 'package:conecta_app/features/community/presentation/group_chat_screen.dart';
import 'package:conecta_app/features/player/presentation/providers/now_playing_provider.dart';
import 'package:conecta_app/features/player/presentation/view/radio_player_screen.dart';
import 'package:conecta_app/core/widgets/share_modal.dart';
import 'package:conecta_app/core/utils/snackbar_utils.dart';
import 'package:conecta_app/features/events/presentation/event_details_screen.dart';

// Provider para manejar las suscripciones a radios
final subscribedRadiosProvider = StateNotifierProvider<SubscribedRadiosController, List<RadioSubscription>>(
  (ref) => SubscribedRadiosController(),
);

class SubscribedRadiosController extends StateNotifier<List<RadioSubscription>> {
  SubscribedRadiosController() : super([]);

  void subscribeToRadio(RadioSubscription radio) {
    if (!state.any((r) => r.id == radio.id)) {
      state = [...state, radio];
    }
  }

  void unsubscribeFromRadio(String radioId) {
    state = state.where((r) => r.id != radioId).toList();
  }

  bool isSubscribed(String radioId) {
    return state.any((r) => r.id == radioId);
  }
}

class RadioSubscription {
  final String id;
  final String name;
  final String imageUrl;

  const RadioSubscription({
    required this.id,
    required this.name,
    required this.imageUrl,
  });
}

class RadioProfileScreen extends ConsumerStatefulWidget {
  const RadioProfileScreen({super.key});

  static const routePath = '/radio-profile';
  static const routeName = 'radioProfile';

  @override
  ConsumerState<RadioProfileScreen> createState() => _RadioProfileScreenState();
}

class _RadioProfileScreenState extends ConsumerState<RadioProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final isCollapsed = _scrollController.hasClients &&
          _scrollController.offset > (300 - kToolbarHeight - 50);

      if (_isCollapsed != isCollapsed) {
        setState(() {
          _isCollapsed = isCollapsed;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nowPlayingState = ref.watch(nowPlayingProvider);
    final theme = Theme.of(context);
    final radioController = ref.watch(subscribedRadiosProvider.notifier);
    final isSubscribed = ref.watch(subscribedRadiosProvider).any(
      (radio) => radio.id == 'radio_pop_1',
    );

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar con imagen de fondo de la radio
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.black.withOpacity(0.15),
            elevation: 8,
            leading: IconButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
              icon: Icon(
                Icons.arrow_back,
                color: _isCollapsed ? theme.colorScheme.onSurface : Colors.white,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                nowPlayingState.item.title,
                style: TextStyle(
                  color: _isCollapsed ? theme.colorScheme.onSurface : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagen de fondo de la radio
                  Image.network(
                    'https://picsum.photos/seed/radioBackground/400/600',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Gradiente overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenido principal
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información de la radio - Layout horizontal similar al perfil del artista
                  Row(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.primary,
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            'https://picsum.photos/seed/radiologo/200/200',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.radio,
                                size: 50,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          'Sumérgete en el universo de Radio Pop, donde cada canción es una explosión de energía. La mejor selección de éxitos actuales y clásicos que te harán vibrar.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Botón de reproducir
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref.read(nowPlayingProvider.notifier).togglePlay();
                      },
                      icon: Icon(
                        nowPlayingState.isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 28,
                      ),
                      label: Text(
                        nowPlayingState.isPlaying ? 'Pausar' : 'Reproducir Radio',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botones de seguir y compartir
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (isSubscribed) {
                              // Desuscribirse
                              radioController.unsubscribeFromRadio('radio_pop_1');
                              SnackBarUtils.showInfo(
                                context,
                                'Ya no sigues a ${nowPlayingState.item.title}',
                                duration: const Duration(seconds: 2),
                              );
                            } else {
                              // Suscribirse
                              final newRadio = RadioSubscription(
                                id: 'radio_pop_1',
                                name: nowPlayingState.item.title,
                                imageUrl: 'https://picsum.photos/seed/radiologo/200/200',
                              );
                              radioController.subscribeToRadio(newRadio);
                              SnackBarUtils.showSuccess(
                                context,
                                'Suscrito a ${nowPlayingState.item.title}',
                                duration: const Duration(seconds: 2),
                              );
                            }
                          },
                          icon: Icon(isSubscribed ? Icons.notifications_active : Icons.notifications_outlined),
                          label: Text(isSubscribed ? 'Suscrito' : 'Suscribirse'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSubscribed
                                ? theme.colorScheme.surfaceContainerHighest
                                : theme.colorScheme.primary,
                            foregroundColor: isSubscribed
                                ? theme.colorScheme.onSurface
                                : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showShareModal(
                              context,
                              title: nowPlayingState.item.title,
                              description: 'Compartir radio',
                              iconColor: theme.colorScheme.primary,
                              onFacebookShare: () {
                                SnackBarUtils.showSuccess(
                                  context,
                                  'Compartiendo en Facebook...',
                                  duration: const Duration(seconds: 2),
                                );
                              },
                              onWhatsAppShare: () {
                                SnackBarUtils.showSuccess(
                                  context,
                                  'Compartiendo en WhatsApp...',
                                  duration: const Duration(seconds: 2),
                                );
                              },
                              onInstagramShare: () {
                                SnackBarUtils.showSuccess(
                                  context,
                                  'Compartiendo en Instagram...',
                                  duration: const Duration(seconds: 2),
                                );
                              },
                              onCopyLink: () {
                                SnackBarUtils.showSuccess(
                                  context,
                                  'Enlace copiado al portapapeles',
                                  duration: const Duration(seconds: 2),
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.share_outlined),
                          label: const Text('Compartir'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            foregroundColor: theme.colorScheme.onSurface,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  // Redes Sociales
                  _buildSocialSection(theme),
                  const SizedBox(height: 32),
                  // Comunidad e Interacción
                  _buildCommunitySection(context, theme, nowPlayingState),
                  const SizedBox(height: 32),
                  // Próximos Eventos
                  _buildEventsSection(theme),
                  const SizedBox(height: 32),
                  const SizedBox(height: 160), // Espacio para mini reproductor y nav bar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }




  Widget _buildSocialSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Redes Sociales',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSocialButton('WhatsApp', Icons.chat, Colors.green, theme),
            _buildSocialButton('Facebook', Icons.facebook, Colors.blue, theme),
            _buildSocialButton('Instagram', Icons.camera_alt, Colors.purple, theme),
            _buildSocialButton('X', Icons.close, Colors.black, theme),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSocialButton('YouTube', Icons.play_circle_fill, Colors.red, theme),
            _buildSocialButton('Sitio Web', Icons.language, Colors.grey[600]!, theme),
            const SizedBox(width: 80), // Espacios vacíos para mantener alineación
            const SizedBox(width: 80),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(String label, IconData icon, Color color, ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCommunitySection(BuildContext context, ThemeData theme, NowPlayingState nowPlayingState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comunidad e Interacción',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        _buildCommunityCard(
          context: context,
          icon: Icons.poll,
          title: 'Encuestas y Concursos',
          subtitle: 'Participa y gana!',
          theme: theme,
          onTap: () => context.push(PollsContestsScreen.routePath),
        ),
        const SizedBox(height: 12),
        _buildCommunityCard(
          context: context,
          icon: Icons.chat_bubble,
          title: 'Chat Grupal y Reacciones en Vivo',
          subtitle: 'Comenta tu transmisión',
          theme: theme,
          onTap: () => context.pushNamed(
            GroupChatScreen.routeName,
            extra: {'radioName': nowPlayingState.item.title},
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required ThemeData theme,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: theme.colorScheme.onSurfaceVariant,
            size: 16,
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildEventsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Próximos Eventos',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildEventCard(
          title: 'Festival de Música Electrónica',
          date: 'DIC\n25',
          venue: 'Arena Central, 8:00 PM',
          theme: theme,
        ),
        const SizedBox(height: 12),
        _buildEventCard(
          title: 'Acústico con Local Artists',
          date: 'DIC\n28',
          venue: 'Foro Indie, 9:00 PM',
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildEventCard({
    required String title,
    required String date,
    required String venue,
    required ThemeData theme,
  }) {
    final nowPlayingState = ref.watch(nowPlayingProvider);

    return GestureDetector(
      onTap: () {
        context.push(
          EventDetailsScreen.routePath,
          extra: {
            'eventTitle': title,
            'eventDate': date.replaceAll('\n', ' '),
            'eventVenue': venue,
            'artistName': nowPlayingState.item.title,
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  date,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    venue,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}