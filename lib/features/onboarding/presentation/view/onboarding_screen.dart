import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:conecta_app/app/theme/palette.dart';
import 'package:conecta_app/core/localization/l10n.dart';
import 'package:conecta_app/features/auth/presentation/view/login_screen.dart';
import 'package:conecta_app/features/home/presentation/view/home_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  static const routePath = '/onboarding';
  static const routeName = 'onboarding';

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;
  String? _selectedRadioId;

  static const _radioStations = <_RadioStation>[
    _RadioStation(
      id: 'heart',
      name: 'Radio Corazón',
      description: 'Baladas & pop latino',
      color: Color(0xFFFF8A65),
      icon: Icons.favorite_rounded,
    ),
    _RadioStation(
      id: 'radio1',
      name: 'Radio Uno',
      description: 'Hits actuales',
      color: Color(0xFF7E57C2),
      icon: Icons.graphic_eq_rounded,
    ),
    _RadioStation(
      id: 'radioo',
      name: 'RadioO',
      description: 'Indie y alternativo',
      color: Color(0xFF26A69A),
      icon: Icons.auto_awesome_rounded,
    ),
    _RadioStation(
      id: 'urban',
      name: 'Urban Beat',
      description: 'Hip-hop & trap',
      color: Color(0xFFFFCA28),
      icon: Icons.multitrack_audio_rounded,
    ),
    _RadioStation(
      id: 'classic',
      name: 'Clásica 6',
      description: 'Sinfonías y conciertos',
      color: Color(0xFF5C6BC0),
      icon: Icons.queue_music_rounded,
    ),
    _RadioStation(
      id: 'podcast',
      name: 'Podcast Live',
      description: 'Charlas en directo',
      color: Color(0xFFFF7043),
      icon: Icons.mic_none_rounded,
    ),
  ];

  int get _pageCount => 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handlePageChanged(int page) {
    setState(() => _currentPage = page);
  }

  void _goToNextPage() {
    if (_currentPage < _pageCount - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      _finishOnboarding();
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _skip() {
    _finishOnboarding();
  }

  void _finishOnboarding({_RadioStation? station}) {
    if (!mounted) return;
    context.push(
      LoginScreen.routePath,
      extra: station?.toLoginPayload(),
    );
  }

  void _handlePrimaryAction(AppLocalizations l10n) {
    if (_currentPage == _pageCount - 1) {
      _finishOnboarding();
      return;
    }
    _goToNextPage();
  }

  Future<void> _openRadioSelection(
      BuildContext context, AppLocalizations l10n) async {
    final selected = await showModalBottomSheet<_RadioStation>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _RadioSelectionSheet(
          l10n: l10n,
          stations: _radioStations,
          initialSelectedId: _selectedRadioId,
        );
      },
    );

    if (selected != null) {
      setState(() => _selectedRadioId = selected.id);
      _finishOnboarding(station: selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    final pages = [
      _IntroPage(
        l10n: l10n,
        theme: theme,
        onGetStarted: _goToNextPage,
        onSignIn: () => _finishOnboarding(),
      ),
      _HighlightsPage(l10n: l10n, theme: theme),
      _AccountOptionsPage(
        l10n: l10n,
        theme: theme,
        onSignInListener: () => _finishOnboarding(),
        onSignInStation: () => _openRadioSelection(context, l10n),
        onExploreGuest: () => context.go(HomeScreen.routePath),
      ),
    ];

    final isLastPage = _currentPage == _pageCount - 1;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppPalette.primary, AppPalette.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _handlePageChanged,
                  children: pages,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    _PageIndicator(
                        currentIndex: _currentPage, itemCount: _pageCount),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (_currentPage > 0)
                          TextButton(
                            onPressed: _goToPreviousPage,
                            child: Text(l10n.onboardingBack,
                                style: const TextStyle(color: Colors.white70)),
                          )
                        else
                          TextButton(
                            onPressed: _skip,
                            child: Text(l10n.onboardingSkip,
                                style: const TextStyle(color: Colors.white70)),
                          ),
                        const Spacer(),
                        FilledButton(
                          onPressed: () => _handlePrimaryAction(l10n),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppPalette.primary,
                            minimumSize: const Size(140, 48),
                          ),
                          child: Text(isLastPage
                              ? l10n.onboardingContinue
                              : l10n.onboardingNext),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroPage extends StatelessWidget {
  const _IntroPage({
    required this.l10n,
    required this.theme,
    required this.onGetStarted,
    required this.onSignIn,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final VoidCallback onGetStarted;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.appTitle,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.onboardingHeadline,
                style: theme.textTheme.headlineMedium
                    ?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.onboardingSubheadline,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: Colors.white70, height: 1.4),
              ),
              const SizedBox(height: 36),
              FilledButton(
                onPressed: onGetStarted,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppPalette.primary,
                  minimumSize: const Size.fromHeight(54),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                child: Text(l10n.onboardingGetStarted),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: onSignIn,
                child: Text(
                  l10n.onboardingAlreadyHaveAccount,
                  style: const TextStyle(
                      color: Colors.white70, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HighlightsPage extends StatelessWidget {
  const _HighlightsPage({required this.l10n, required this.theme});

  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final bulletStyle =
        theme.textTheme.bodyMedium?.copyWith(color: Colors.white70);
    final items = [
      _HighlightItem(
        icon: Icons.podcasts_rounded,
        title: l10n.onboardingFeatureLiveRadioTitle,
        description: l10n.onboardingFeatureLiveRadioDescription,
      ),
      _HighlightItem(
        icon: Icons.music_note_rounded,
        title: l10n.onboardingFeatureUnlimitedMusicTitle,
        description: l10n.onboardingFeatureUnlimitedMusicDescription,
      ),
      _HighlightItem(
        icon: Icons.videocam_rounded,
        title: l10n.onboardingFeatureVideoTitle,
        description: l10n.onboardingFeatureVideoDescription,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.onboardingHighlightsTitle,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.onboardingSubheadline,
                style: bulletStyle,
              ),
              const SizedBox(height: 32),
              ...items.map((item) => _HighlightCard(item: item)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountOptionsPage extends StatelessWidget {
  const _AccountOptionsPage({
    required this.l10n,
    required this.theme,
    required this.onSignInListener,
    required this.onSignInStation,
    required this.onExploreGuest,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final VoidCallback onSignInListener;
  final VoidCallback onSignInStation;
  final VoidCallback onExploreGuest;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.onboardingAccountTitle,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.onboardingAccountSubtitle,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: Colors.white70, height: 1.4),
              ),
              const SizedBox(height: 28),
              _OptionCard(
                icon: Icons.person_rounded,
                title: l10n.onboardingAccountOptionListener,
                description: l10n.onboardingAccountOptionListenerDescription,
                onPressed: onSignInListener,
              ),
              const SizedBox(height: 16),
              _OptionCard(
                icon: Icons.radio_rounded,
                title: l10n.onboardingAccountOptionStation,
                description: l10n.onboardingAccountOptionStationDescription,
                onPressed: onSignInStation,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: onExploreGuest,
                child: Text(
                  l10n.onboardingExploreAsGuest,
                  style: const TextStyle(
                      color: Colors.white70, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioSelectionSheet extends StatefulWidget {
  const _RadioSelectionSheet({
    required this.l10n,
    required this.stations,
    required this.initialSelectedId,
  });

  final AppLocalizations l10n;
  final List<_RadioStation> stations;
  final String? initialSelectedId;

  @override
  State<_RadioSelectionSheet> createState() => _RadioSelectionSheetState();
}

class _RadioSelectionSheetState extends State<_RadioSelectionSheet> {
  late TextEditingController _searchController;
  String _query = '';
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedId = widget.initialSelectedId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredStations = widget.stations
        .where(
          (station) =>
              station.name.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();
    final selectedStation = widget.stations
        .where((station) => station.id == _selectedId)
        .firstOrNull;

    return FractionallySizedBox(
      heightFactor: 0.92,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppPalette.primary, AppPalette.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white38,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      widget.l10n.onboardingRadioTitle,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.l10n.onboardingRadioSubtitle,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: Colors.white70, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _searchController,
                      onChanged: (value) =>
                          setState(() => _query = value.trim()),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: widget.l10n.onboardingRadioSearchHint,
                        hintStyle: const TextStyle(color: Colors.white60),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: GridView.builder(
                        itemCount: filteredStations.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.95,
                        ),
                        itemBuilder: (context, index) {
                          final station = filteredStations[index];
                          return _RadioTile(
                            station: station,
                            isSelected: station.id == _selectedId,
                            onTap: () =>
                                setState(() => _selectedId = station.id),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: selectedStation == null
                          ? null
                          : () => Navigator.of(context).pop(selectedStation),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppPalette.primary,
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: Text(
                        selectedStation == null
                            ? widget.l10n.onboardingRadioContinueDisabled
                            : widget.l10n
                                .onboardingRadioContinue(selectedStation.name),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.currentIndex, required this.itemCount});

  final int currentIndex;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < itemCount; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: i == currentIndex ? 32 : 12,
            decoration: BoxDecoration(
              color: i == currentIndex ? Colors.white : Colors.white30,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
      ],
    );
  }
}

class _HighlightItem {
  const _HighlightItem(
      {required this.icon, required this.title, required this.description});

  final IconData icon;
  final String title;
  final String description;
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({required this.item});

  final _HighlightItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white24,
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(item.icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.description,
                  style: const TextStyle(color: Colors.white70, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white24,
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style:
                          const TextStyle(color: Colors.white70, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton.tonal(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppPalette.primary,
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(title),
          ),
        ],
      ),
    );
  }
}

class _RadioTile extends StatelessWidget {
  const _RadioTile(
      {required this.station, required this.isSelected, required this.onTap});

  final _RadioStation station;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isSelected
        ? Colors.white
        : Colors.white.withOpacity(isDark ? 0.12 : 0.85);
    final borderColor =
        isSelected ? station.color : (isDark ? Colors.white24 : Colors.black12);
    final textPrimary = isSelected
        ? (isDark ? Colors.black87 : theme.colorScheme.onSurface)
        : (isDark ? Colors.white : theme.colorScheme.onSurface);
    final muted = isSelected
        ? (isDark ? Colors.black54 : theme.colorScheme.onSurfaceVariant)
        : (isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: isSelected ? 3 : 1.5),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: station.color.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 82,
              width: 82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    station.color,
                    station.color.withOpacity(0.75),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: station.color.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                station.icon,
                color: Colors.white,
                size: 38,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              station.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              station.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: muted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadioStation {
  const _RadioStation({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.icon,
  });

  final String id;
  final String name;
  final String description;
  final Color color;
  final IconData icon;

  Map<String, dynamic> toLoginPayload() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color.value,
      'icon': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'iconFontPackage': icon.fontPackage,
    };
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      return iterator.current;
    }
    return null;
  }
}
