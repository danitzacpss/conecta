import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Provider para manejar los usuarios seguidos
final followingUsersProvider = StateNotifierProvider<FollowingUsersController, List<UserFollow>>(
  (ref) => FollowingUsersController(),
);

class FollowingUsersController extends StateNotifier<List<UserFollow>> {
  FollowingUsersController() : super([]) {
    _loadFollowingUsers();
  }

  void _loadFollowingUsers() {
    // Aquí cargarías los usuarios seguidos desde la base de datos o API
    state = const [
      UserFollow(
        id: '1',
        name: 'María González',
        username: '@mariag',
        avatarUrl: 'https://i.pravatar.cc/150?u=maria',
        playlistCount: 12,
        followerCount: 245,
      ),
      UserFollow(
        id: '2',
        name: 'Carlos Ruiz',
        username: '@carlosr',
        avatarUrl: 'https://i.pravatar.cc/150?u=carlos',
        playlistCount: 8,
        followerCount: 189,
      ),
      UserFollow(
        id: '3',
        name: 'Ana Martínez',
        username: '@anam',
        avatarUrl: 'https://i.pravatar.cc/150?u=ana',
        playlistCount: 15,
        followerCount: 512,
      ),
      UserFollow(
        id: '4',
        name: 'DJ MixMaster',
        username: '@djmix',
        avatarUrl: 'https://i.pravatar.cc/150?u=djmix',
        playlistCount: 24,
        followerCount: 1240,
      ),
      UserFollow(
        id: '5',
        name: 'Laura Beats',
        username: '@laurabeats',
        avatarUrl: 'https://i.pravatar.cc/150?u=laura',
        playlistCount: 18,
        followerCount: 892,
      ),
      UserFollow(
        id: '6',
        name: 'Pedro Sound',
        username: '@pedrosound',
        avatarUrl: 'https://i.pravatar.cc/150?u=pedro',
        playlistCount: 10,
        followerCount: 334,
      ),
    ];
  }

  void followUser(UserFollow user) {
    if (!state.any((u) => u.id == user.id)) {
      state = [...state, user];
    }
  }

  void unfollowUser(String userId) {
    state = state.where((u) => u.id != userId).toList();
  }

  bool isFollowing(String userId) {
    return state.any((u) => u.id == userId);
  }
}

class UserFollow {
  final String id;
  final String name;
  final String username;
  final String avatarUrl;
  final int playlistCount;
  final int followerCount;

  const UserFollow({
    required this.id,
    required this.name,
    required this.username,
    required this.avatarUrl,
    required this.playlistCount,
    required this.followerCount,
  });
}

class FollowingScreen extends ConsumerStatefulWidget {
  const FollowingScreen({super.key});

  static const routePath = '/following';
  static const routeName = 'following';

  @override
  ConsumerState<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends ConsumerState<FollowingScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UserFollow> _filterUsers(List<UserFollow> users) {
    if (_searchQuery.isEmpty) {
      return users;
    }
    return users.where((user) {
      return user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.username.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final followingUsers = ref.watch(followingUsersProvider);
    final filteredUsers = _filterUsers(followingUsers);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: theme.colorScheme.surface,
            elevation: 0,
            surfaceTintColor: theme.colorScheme.surface,
            shadowColor: Colors.black.withOpacity(0.1),
            forceElevated: true,
            leading: IconButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
              icon: const Icon(Icons.arrow_back),
            ),
            title: const Text('Siguiendo'),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                      _searchQuery = '';
                    }
                  });
                },
                icon: Icon(_isSearching ? Icons.close : Icons.search),
              ),
            ],
          ),

          // Buscador fijo (solo visible cuando está activo)
          if (_isSearching)
            SliverPersistentHeader(
              pinned: true,
              delegate: _SearchBarDelegate(
                searchController: _searchController,
                theme: theme,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

          // Grid de usuarios seguidos
          if (followingUsers.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 80,
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No sigues a nadie aún',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Descubre usuarios y sus playlists',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (filteredUsers.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 80,
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No se encontraron usuarios',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Intenta con otro término de búsqueda',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 210),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _UserCard(user: filteredUsers[index]);
                  },
                  childCount: filteredUsers.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Card de usuario
class _UserCard extends ConsumerWidget {
  const _UserCard({required this.user});

  final UserFollow user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        context.push(
          '/user-profile',
          extra: {
            'userId': user.id,
            'userName': user.name,
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(user.avatarUrl),
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              ),
            ),
            const SizedBox(height: 12),

            // Nombre
            Text(
              user.name,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            // Username
            Text(
              user.username,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat(theme, user.playlistCount.toString(), 'Playlists'),
                Container(
                  width: 1,
                  height: 24,
                  color: theme.colorScheme.outlineVariant,
                ),
                _buildStat(theme, _formatCount(user.followerCount), 'Seguidores'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(ThemeData theme, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}

// Delegate para mantener el buscador fijo
class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController searchController;
  final ThemeData theme;
  final Function(String) onChanged;

  _SearchBarDelegate({
    required this.searchController,
    required this.theme,
    required this.onChanged,
  });

  @override
  double get minExtent => 72;

  @override
  double get maxExtent => 72;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      alignment: Alignment.center,
      child: TextField(
        controller: searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Buscar usuarios',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onChanged: onChanged,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
