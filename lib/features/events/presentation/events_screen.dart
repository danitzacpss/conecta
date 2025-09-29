import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:conecta_app/core/localization/l10n.dart';

final eventsProvider = Provider<List<EventSummary>>((ref) {
  return [
    EventSummary(
      id: 'event-1',
      title: 'Sunset Rooftop Live',
      description: 'Radio en vivo con DJs invitados.',
      startDate: DateTime.now().add(const Duration(days: 1)),
    ),
    EventSummary(
      id: 'event-2',
      title: 'Conecta Fest 2025',
      description: 'Festival híbrido con streaming y b2b sets.',
      startDate: DateTime.now().add(const Duration(days: 7)),
    ),
  ];
});

final chatMessagesProvider =
    StateProvider<Map<String, List<ChatMessage>>>((ref) {
  return {
    'event-1': [
      ChatMessage(
          user: 'Alexa',
          content: '¡Nos vemos mañana!',
          timestamp: DateTime.now()),
      ChatMessage(
          user: 'Sam',
          content: '¿Quién toca primero?',
          timestamp: DateTime.now()),
    ],
  };
});

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  static const routePath = '/events';
  static const routeName = 'events';

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  String? selectedEventId;

  @override
  void initState() {
    super.initState();
    final events = ref.read(eventsProvider);
    selectedEventId = events.isEmpty ? null : events.first.id;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final events = ref.watch(eventsProvider);
    final chats = ref.watch(chatMessagesProvider);

    final chatPane = _EventChatContainer(
      eventId: selectedEventId,
      messages: chats[selectedEventId] ?? const [],
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.eventsTitle)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 720;

          if (isCompact) {
            return Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _EventsList(
                      events: events,
                      selectedId: selectedEventId,
                      onSelect: (id) => setState(() => selectedEventId = id),
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: chatPane,
                  ),
                ),
              ],
            );
          }

          return SizedBox(
            height: constraints.maxHeight,
            child: Row(
              children: [
                SizedBox(
                  width: constraints.maxWidth * 0.38,
                  height: constraints.maxHeight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _EventsList(
                      events: events,
                      selectedId: selectedEventId,
                      onSelect: (id) => setState(() => selectedEventId = id),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: chatPane,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EventsList extends StatelessWidget {
  const _EventsList({
    required this.events,
    required this.selectedId,
    required this.onSelect,
  });

  final List<EventSummary> events;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView.separated(
      primary: false,
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final isSelected = selectedId == event.id;
        return ListTile(
          tileColor:
              isSelected ? Theme.of(context).colorScheme.surfaceContainerHighest : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(event.title),
          subtitle: Text(event.description),
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(l10n.eventsUpcoming,
                  style: Theme.of(context).textTheme.bodySmall),
              Text('${event.startDate.day}/${event.startDate.month}'),
            ],
          ),
          onTap: () => onSelect(event.id),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
    );
  }
}

class _EventChatContainer extends ConsumerWidget {
  const _EventChatContainer({
    required this.eventId,
    required this.messages,
  });

  final String? eventId;
  final List<ChatMessage> messages;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    if (eventId == null) {
      return Center(child: Text(l10n.eventsJoinChat));
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surface,
      ),
      padding: const EdgeInsets.all(16),
      child: _EventChat(eventId: eventId!, messages: messages),
    );
  }
}

class _EventChat extends ConsumerStatefulWidget {
  const _EventChat({required this.eventId, required this.messages});

  final String eventId;
  final List<ChatMessage> messages;

  @override
  ConsumerState<_EventChat> createState() => _EventChatState();
}

class _EventChatState extends ConsumerState<_EventChat> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: widget.messages.length,
            itemBuilder: (context, index) {
              final message = widget.messages[index];
              return ListTile(
                title: Text(message.user,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(message.content),
                trailing: Text(
                    '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}'),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: l10n.eventsJoinChat,
                  filled: true,
                  fillColor: colors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: () {
                final text = _controller.text.trim();
                if (text.isEmpty) return;
                final message = ChatMessage(
                  user: 'Tú',
                  content: text,
                  timestamp: DateTime.now(),
                );
                final notifier = ref.read(chatMessagesProvider.notifier);
                notifier.state = {
                  ...notifier.state,
                  widget.eventId: [...widget.messages, message],
                };
                _controller.clear();
              },
              child: Text(l10n.eventsJoinChat),
            ),
          ],
        ),
      ],
    );
  }
}

class EventSummary {
  EventSummary({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
  });

  final String id;
  final String title;
  final String description;
  final DateTime startDate;
}

class ChatMessage {
  ChatMessage({
    required this.user,
    required this.content,
    required this.timestamp,
  });

  final String user;
  final String content;
  final DateTime timestamp;
}
