import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:conecta_app/features/library/presentation/following_screen.dart';
import 'package:conecta_app/core/widgets/share_modal.dart';
import 'package:conecta_app/core/utils/snackbar_utils.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({
    super.key,
    this.userId,
    this.userName,
  });

  static const routePath = '/user-profile';
  static const routeName = 'userProfile';

  final String? userId;
  final String? userName;

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
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
    final theme = Theme.of(context);
    final followingController = ref.watch(followingUsersProvider.notifier);
    final isFollowing = ref.watch(followingUsersProvider).any(
      (user) => user.id == widget.userId,
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar con imagen de fondo
          SliverAppBar(
            expandedHeight: 300,
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
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                widget.userName ?? 'Usuario',
                style: TextStyle(
                  color: _isCollapsed ? theme.colorScheme.onSurface : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagen de portada
                  Image.network(
                    'https://picsum.photos/seed/user-cover/800/400',
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
                  // Información del usuario (avatar + estadísticas)
                  Row(
                    children: [
                      // Avatar
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
                            'https://i.pravatar.cc/200?u=${widget.userId ?? "user"}',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Estadísticas
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(theme, '12', 'Playlists'),
                                _buildStatItem(theme, '245', 'Seguidores'),
                                _buildStatItem(theme, '189', 'Siguiendo'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (isFollowing) {
                              // Dejar de seguir
                              followingController.unfollowUser(widget.userId ?? '');
                            } else {
                              // Seguir al usuario
                              final newUser = UserFollow(
                                id: widget.userId ?? '',
                                name: widget.userName ?? 'Usuario',
                                username: '@${widget.userName?.toLowerCase().replaceAll(' ', '') ?? 'user'}',
                                avatarUrl: 'https://i.pravatar.cc/200?u=${widget.userId ?? "user"}',
                                playlistCount: 12,
                                followerCount: 245,
                              );
                              followingController.followUser(newUser);
                            }
                          },
                          icon: Icon(isFollowing ? Icons.notifications_active : Icons.notifications_outlined),
                          label: Text(isFollowing ? 'Siguiendo' : 'Seguir'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFollowing
                                ? theme.colorScheme.surfaceContainerHighest
                                : theme.colorScheme.primary,
                            foregroundColor: isFollowing
                                ? theme.colorScheme.onSurface
                                : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
                              title: widget.userName ?? 'Usuario',
                              description: 'Compartir perfil de usuario',
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
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Sección: Playlists públicas
                  Text(
                    'Playlists públicas',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Lista de playlists
                  _buildPlaylistItem(
                    theme,
                    'Mis favoritos 2024',
                    '32 canciones',
                    'https://picsum.photos/seed/playlist1/100/100',
                  ),
                  const SizedBox(height: 12),
                  _buildPlaylistItem(
                    theme,
                    'Vibes de verano',
                    '45 canciones',
                    'https://picsum.photos/seed/playlist2/100/100',
                  ),
                  const SizedBox(height: 12),
                  _buildPlaylistItem(
                    theme,
                    'Workout intenso',
                    '28 canciones',
                    'https://picsum.photos/seed/playlist3/100/100',
                  ),

                  const SizedBox(height: 200), // Espacio para reproductor/nav
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(ThemeData theme, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaylistItem(
    ThemeData theme,
    String name,
    String info,
    String imageUrl,
  ) {
    return GestureDetector(
      onTap: () {
        // Navegar a los detalles de la playlist
        context.push('/playlist-details');
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.queue_music,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    info,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
