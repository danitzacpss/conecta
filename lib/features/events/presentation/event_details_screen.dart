import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:conecta_app/core/widgets/share_modal.dart';
import 'package:conecta_app/core/utils/snackbar_utils.dart';

class EventDetailsScreen extends ConsumerStatefulWidget {
  const EventDetailsScreen({
    super.key,
    required this.eventTitle,
    required this.eventDate,
    required this.eventVenue,
    this.artistName,
  });

  static const routePath = '/event-details';
  static const routeName = 'eventDetails';

  final String eventTitle;
  final String eventDate;
  final String eventVenue;
  final String? artistName;

  @override
  ConsumerState<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends ConsumerState<EventDetailsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final isCollapsed = _scrollController.hasClients &&
          _scrollController.offset > (280 - kToolbarHeight - 50);

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
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar con imagen del evento
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.black.withOpacity(0.15),
            elevation: 8,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: Icon(
                Icons.arrow_back,
                color: _isCollapsed ? theme.colorScheme.onSurface : Colors.white,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  showShareModal(
                    context,
                    title: widget.eventTitle,
                    description: 'Compartir evento',
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
                icon: Icon(
                  Icons.share,
                  color: _isCollapsed ? theme.colorScheme.onSurface : Colors.white,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagen del evento
                  Image.network(
                    'https://picsum.photos/seed/event-${widget.eventTitle.hashCode}/800/400',
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
                  // Gradiente oscuro
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

          // Contenido del evento
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título del evento
                  Text(
                    widget.eventTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Artista
                  if (widget.artistName != null)
                    Text(
                      widget.artistName!,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Información del evento
                  _buildInfoSection(
                    theme,
                    icon: Icons.calendar_today,
                    title: 'Fecha',
                    content: widget.eventDate,
                  ),
                  const SizedBox(height: 16),

                  _buildInfoSection(
                    theme,
                    icon: Icons.location_on,
                    title: 'Ubicación',
                    content: widget.eventVenue,
                  ),
                  const SizedBox(height: 16),

                  _buildInfoSection(
                    theme,
                    icon: Icons.access_time,
                    title: 'Horarios',
                    content: 'Puertas: 7:00 PM\nInicio: 8:00 PM\nFin estimado: 11:00 PM',
                  ),
                  const SizedBox(height: 16),

                  _buildInfoSection(
                    theme,
                    icon: Icons.attach_money,
                    title: 'Precio',
                    content: 'General: \$450 MXN\nVIP: \$850 MXN\nPremium: \$1,200 MXN',
                  ),
                  const SizedBox(height: 32),

                  // Descripción del evento
                  Text(
                    'Acerca del evento',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Únete a nosotros para una noche inolvidable llena de música en vivo, energía y momentos especiales. Este evento promete ser una experiencia única que no te puedes perder.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Mapa (placeholder)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ver en mapa',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón de acción
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        SnackBarUtils.showSuccess(
                          context,
                          'Te recordaremos sobre este evento',
                          duration: const Duration(seconds: 2),
                        );
                      },
                      icon: const Icon(Icons.notifications_active),
                      label: const Text('Recordarme'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 200), // Espacio para mini reproductor y nav bar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.onPrimaryContainer,
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
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
