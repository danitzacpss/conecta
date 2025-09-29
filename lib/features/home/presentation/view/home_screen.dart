import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:conecta_app/core/localization/l10n.dart';
import 'package:conecta_app/features/home/domain/entities/media_item.dart';
import 'package:conecta_app/features/home/presentation/controllers/home_controller.dart';
import 'package:conecta_app/features/home/presentation/widgets/section_header.dart';
import 'package:conecta_app/features/home/presentation/widgets/horizontal_media_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const routePath = '/home';
  static const routeName = 'home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeControllerProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: CircleAvatar(
              backgroundImage: NetworkImage('https://i.pravatar.cc/80'),
            ),
          ),
        ],
      ),
      body: state.when(
        data: (content) => RefreshIndicator(
          onRefresh: () => ref.read(homeControllerProvider.notifier).load(),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              if (content.heroChallenge != null)
                _HeroChallengeCard(highlight: content.heroChallenge!),
              const SizedBox(height: 20),
              Text(
                l10n.homeGreeting('Alexa'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              _SearchField(hintText: l10n.searchPlaceholder),
              const SizedBox(height: 28),
              if (content.challenges.isNotEmpty) ...[
                SectionHeader(title: l10n.homeChallenges),
                const SizedBox(height: 12),
                _ChallengeCarousel(actions: content.challenges),
                const SizedBox(height: 28),
              ],
              if (content.contests.isNotEmpty) ...[
                SectionHeader(title: l10n.homeContests),
                const SizedBox(height: 12),
                _ContestGrid(actions: content.contests),
                const SizedBox(height: 28),
              ],
              if (content.events.isNotEmpty) ...[
                SectionHeader(title: l10n.homeEvents),
                const SizedBox(height: 12),
                _EventTimeline(events: content.events),
                const SizedBox(height: 28),
              ],
              if (content.radioChats.isNotEmpty) ...[
                SectionHeader(title: l10n.homeRadioChats),
                const SizedBox(height: 12),
                _HomeActionStrip(actions: content.radioChats),
                const SizedBox(height: 28),
              ],
              if (content.liveRadios.isNotEmpty) ...[
                SectionHeader(title: l10n.homeLiveRadios),
                const SizedBox(height: 12),
                SizedBox(
                  height: 140,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: content.liveRadios.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final item = content.liveRadios[index];
                      return _LiveRadioCard(item: item);
                    },
                  ),
                ),
                const SizedBox(height: 28),
              ],
              if (content.vodReleases.isNotEmpty) ...[
                SectionHeader(title: l10n.homeVodHighlights),
                const SizedBox(height: 12),
                SizedBox(
                  height: 170,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: content.vodReleases.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final item = content.vodReleases[index];
                      return HorizontalMediaCard(item: item);
                    },
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ],
          ),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.l10n.stateError),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () =>
                    ref.read(homeControllerProvider.notifier).load(),
                child: Text(context.l10n.actionRetry),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _HeroChallengeCard extends StatelessWidget {
  const _HeroChallengeCard({required this.highlight});

  final HomeHighlight highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            highlight.color,
            highlight.color.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: highlight.color.withOpacity(0.35),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(highlight.icon, color: Colors.white, size: 38),
          const SizedBox(height: 18),
          Text(
            highlight.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            highlight.subtitle,
            style: theme.textTheme.bodyLarge
                ?.copyWith(color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: highlight.progress,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${(highlight.progress * 100).round()}% completado',
                style:
                    theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
              const Spacer(),
              Text(
                '${highlight.daysLeft} días restantes',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: highlight.color,
              minimumSize: const Size(140, 44),
            ),
            child: Text(highlight.actionLabel),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.hintText});

  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _ChallengeCarousel extends StatelessWidget {
  const _ChallengeCarousel({required this.actions});

  final List<HomeAction> actions;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final action = actions[index];
          return _ChallengeCard(action: action);
        },
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.action});

  final HomeAction action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = action.color;

    return Container(
      width: 240,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [baseColor, baseColor.withOpacity(0.65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: baseColor.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(action.icon, color: Colors.white, size: 26),
          const SizedBox(height: 12),
          Text(
            action.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            action.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white70,
              height: 1.3,
            ),
          ),
          const Spacer(),
          if (action.progress != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: action.progress!.clamp(0, 1),
                minHeight: 6,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              action.meta ?? '',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            action.actionLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContestGrid extends StatelessWidget {
  const _ContestGrid({required this.actions});

  final List<HomeAction> actions;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return _ContestCard(action: action);
      },
    );
  }
}

class _ContestCard extends StatelessWidget {
  const _ContestCard({required this.action});

  final HomeAction action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: action.color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(action.icon, color: action.color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  action.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            action.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
          ),
          const Spacer(),
          if (action.meta != null) ...[
            Text(
              action.meta!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: action.color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            action.actionLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: action.color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventTimeline extends StatelessWidget {
  const _EventTimeline({required this.events});

  final List<HomeEvent> events;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        for (final event in events) ...[
          _EventTile(event: event, theme: theme),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event, required this.theme});

  final HomeEvent event;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final cardColor = theme.colorScheme.surface;
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: event.color.withOpacity(0.35), width: 1.5),
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: event.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  event.date,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: event.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Icon(event.icon, color: event.color),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  event.subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.3),
                ),
                const SizedBox(height: 6),
                Text(
                  event.location,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: event.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.tonal(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: event.color.withOpacity(0.12),
              foregroundColor: event.color,
            ),
            child: Text(event.actionLabel),
          ),
        ],
      ),
    );
  }
}

class _HomeActionStrip extends StatelessWidget {
  const _HomeActionStrip({required this.actions});

  final List<HomeAction> actions;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final action = actions[index];
          return _HomeActionCard(action: action);
        },
      ),
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  const _HomeActionCard({required this.action});

  final HomeAction action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = action.color;
    final background =
        isDark ? theme.colorScheme.surface.withOpacity(0.85) : Colors.white;

    return Container(
      width: 210,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: baseColor.withOpacity(0.35), width: 2),
        boxShadow: [
          BoxShadow(
            color: baseColor.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  baseColor,
                  baseColor.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(action.icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 14),
          Text(
            action.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              color: isDark ? Colors.white : theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            action.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color:
                  isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
              height: 1.3,
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              action.actionLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: baseColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveRadioCard extends StatelessWidget {
  const _LiveRadioCard({required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        image: DecorationImage(
          image: CachedNetworkImageProvider(item.artworkUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
            color: Colors.black.withOpacity(0.45),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Row(
                children: [
                  Icon(Icons.wifi_tethering, size: 14, color: Colors.white70),
                  SizedBox(width: 6),
                  Text('LIVE', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
