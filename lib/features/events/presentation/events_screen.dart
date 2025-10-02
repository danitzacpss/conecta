import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:conecta_app/features/scanner/presentation/audio_scanner_modal.dart';
import 'package:conecta_app/features/profile/presentation/profile_screen.dart';

// Provider para manejar el estado de eventos
final eventsProvider = StateNotifierProvider<EventsController, EventsState>(
  (ref) => EventsController(),
);

class EventsController extends StateNotifier<EventsState> {
  EventsController() : super(EventsState());

  void toggleInterest(String eventId) {
    final interested = {...state.interestedEvents};
    if (interested.contains(eventId)) {
      interested.remove(eventId);
    } else {
      interested.add(eventId);
    }
    state = state.copyWith(interestedEvents: interested);
  }

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }
}

class EventsState {
  final Set<String> interestedEvents;
  final String selectedCategory;

  EventsState({
    this.interestedEvents = const {},
    this.selectedCategory = 'Todos',
  });

  EventsState copyWith({
    Set<String>? interestedEvents,
    String? selectedCategory,
  }) {
    return EventsState(
      interestedEvents: interestedEvents ?? this.interestedEvents,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  static const routePath = '/events';
  static const routeName = 'events';

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  final ScrollController _scrollController = ScrollController();

  final List<EventSummary> _mockEvents = [
    EventSummary(
      id: '1',
      title: 'Sunset Rooftop Live',
      description: 'Radio en vivo con DJs invitados desde nuestra terraza. Disfruta de música electrónica mientras ves el atardecer.',
      location: 'Terraza Conecta Radio',
      startDate: DateTime.now().add(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 1, hours: 4)),
      category: 'Música en vivo',
      imageUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819',
      capacity: 150,
      attendees: 87,
    ),
    EventSummary(
      id: '2',
      title: 'Conecta Fest 2025',
      description: 'Festival híbrido con streaming en vivo y sets b2b de los mejores artistas del momento.',
      location: 'Centro Cultural (Streaming disponible)',
      startDate: DateTime.now().add(const Duration(days: 7)),
      endDate: DateTime.now().add(const Duration(days: 9)),
      category: 'Festival',
      imageUrl: 'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3',
      capacity: 5000,
      attendees: 3420,
    ),
    EventSummary(
      id: '3',
      title: 'Taller de Producción Musical',
      description: 'Aprende las bases de producción musical con nuestros expertos. Incluye sesión práctica con software profesional.',
      location: 'Estudio Conecta',
      startDate: DateTime.now().add(const Duration(days: 3)),
      endDate: DateTime.now().add(const Duration(days: 3, hours: 3)),
      category: 'Taller',
      imageUrl: 'https://images.unsplash.com/photo-1598488035139-bdbb2231ce04',
      capacity: 20,
      attendees: 18,
    ),
    EventSummary(
      id: '4',
      title: 'Noche de Jazz',
      description: 'Una velada íntima con lo mejor del jazz en vivo. Bar abierto y ambiente relajado.',
      location: 'Jazz Club Downtown',
      startDate: DateTime.now().add(const Duration(days: 5)),
      endDate: DateTime.now().add(const Duration(days: 5, hours: 5)),
      category: 'Música en vivo',
      imageUrl: 'https://images.unsplash.com/photo-1415201364774-f6f0bb35f28f',
      capacity: 80,
      attendees: 45,
    ),
    EventSummary(
      id: '5',
      title: 'Meet & Greet: The Killers',
      description: 'Conoce a la banda, sesión de fotos y autógrafos. Cupos limitados para oyentes VIP.',
      location: 'Backstage Conecta Radio',
      startDate: DateTime.now().add(const Duration(days: 14)),
      endDate: DateTime.now().add(const Duration(days: 14, hours: 2)),
      category: 'Meet & Greet',
      imageUrl: 'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4',
      capacity: 30,
      attendees: 30,
    ),
  ];

  List<String> get _categories {
    final cats = {'Todos', ..._mockEvents.map((e) => e.category)};
    return cats.toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showScannerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AudioScannerModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(eventsProvider);

    final filteredEvents = state.selectedCategory == 'Todos'
        ? _mockEvents
        : _mockEvents.where((e) => e.category == state.selectedCategory).toList();

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? theme.colorScheme.surfaceContainerLow
          : const Color(0xFFF8F7FF),
      body: Column(
        children: [
          // Header con gradiente
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.8),
                  theme.colorScheme.secondary.withOpacity(0.6),
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Barra de navegación
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/home');
                            }
                          },
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Eventos',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showScannerModal(context),
                          icon: const CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white24,
                            child: Icon(Icons.qr_code_scanner, color: Colors.white, size: 20),
                          ),
                        ),
                        IconButton(
                          onPressed: () => context.go(ProfileScreen.routePath),
                          icon: const CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage('https://i.pravatar.cc/80'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Categorías
                  SizedBox(
                    height: 50,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = category == state.selectedCategory;
                        return GestureDetector(
                          onTap: () => ref.read(eventsProvider.notifier).selectCategory(category),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : Colors.white,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Contenido scrolleable
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...filteredEvents.map((event) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _EventCard(event: event),
                  )),
                  const SizedBox(height: 160), // Espacio para mini reproductor y nav bar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends ConsumerWidget {
  const _EventCard({required this.event});

  final EventSummary event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(eventsProvider);
    final isInterested = state.interestedEvents.contains(event.id);

    return GestureDetector(
      onTap: () {
        // Navegar a detalles del evento
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.event,
                      size: 64,
                      color: theme.colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                ),
                // Badge de categoría
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Botón de interés
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => ref.read(eventsProvider.notifier).toggleInterest(event.id),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isInterested ? Icons.star : Icons.star_border,
                        color: isInterested ? Colors.amber : theme.colorScheme.onSurface,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Contenido
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    event.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Fecha y hora
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(event.startDate),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Ubicación
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.location,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Descripción
                  Text(
                    event.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  // Capacidad y asistentes
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${event.attendees}/${event.capacity} asistentes',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Barra de progreso
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: event.attendees / event.capacity,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              event.attendees >= event.capacity
                                  ? Colors.red
                                  : theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Botón de acción
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: event.attendees >= event.capacity
                          ? null
                          : () {
                              // Registrarse al evento
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('¡Te has registrado en "${event.title}"!'),
                                  backgroundColor: theme.colorScheme.primary,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                      icon: Icon(
                        event.attendees >= event.capacity
                            ? Icons.event_busy
                            : Icons.event_available,
                      ),
                      label: Text(
                        event.attendees >= event.capacity
                            ? 'Evento lleno'
                            : 'Registrarse',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: event.attendees >= event.capacity
                            ? theme.colorScheme.surfaceContainerHighest
                            : theme.colorScheme.primary,
                        foregroundColor: event.attendees >= event.capacity
                            ? theme.colorScheme.onSurfaceVariant
                            : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    final weekdays = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];

    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} • ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class EventSummary {
  EventSummary({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.category,
    required this.imageUrl,
    required this.capacity,
    required this.attendees,
  });

  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final String category;
  final String imageUrl;
  final int capacity;
  final int attendees;
}
