import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:conecta_app/features/scanner/presentation/audio_scanner_modal.dart';

class AllEventsScreen extends ConsumerStatefulWidget {
  const AllEventsScreen({super.key});

  static const routePath = '/all-events';
  static const routeName = 'allEvents';

  @override
  ConsumerState<AllEventsScreen> createState() => _AllEventsScreenState();
}

class _AllEventsScreenState extends ConsumerState<AllEventsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedRadioFilter = 'Todas';
  String _selectedCategoryFilter = 'Todas';
  String _searchQuery = '';

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
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterModal() {
    // Extraer radios únicas de los eventos
    final radios = _events.map((e) => e.radioName).toSet().toList()..sort();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterModal(
        selectedRadio: _selectedRadioFilter,
        selectedCategory: _selectedCategoryFilter,
        availableRadios: radios,
        onApply: (radio, category) {
          setState(() {
            _selectedRadioFilter = radio;
            _selectedCategoryFilter = category;
          });
        },
      ),
    );
  }

  List<Event> get _events {
    return [
      Event(
        id: 'event-1',
        title: 'Sunset Rooftop Live',
        description: 'Radio en vivo con DJs invitados desde nuestra terraza',
        radioName: 'Radio Conecta',
        location: 'Terraza Conecta Radio',
        icon: Icons.music_note_rounded,
        color: const Color(0xFF7E57C2),
        date: 'Mañana 18:00',
        attendees: 87,
        capacity: 150,
        category: 'Música en vivo',
      ),
      Event(
        id: 'event-2',
        title: 'Conecta Fest 2025',
        description: 'Festival híbrido con streaming en vivo y sets b2b de los mejores artistas',
        radioName: 'Radio Bío-Bío',
        location: 'Centro Cultural',
        icon: Icons.festival_rounded,
        color: const Color(0xFFFF6B6B),
        date: '15 Mayo',
        attendees: 3420,
        capacity: 5000,
        category: 'Festival',
      ),
      Event(
        id: 'event-3',
        title: 'Taller de Producción Musical',
        description: 'Aprende las bases de producción musical con nuestros expertos',
        radioName: 'Radio Urban FM',
        location: 'Estudio Conecta',
        icon: Icons.mic_rounded,
        color: const Color(0xFF26A69A),
        date: 'Viernes 10:00',
        attendees: 18,
        capacity: 20,
        category: 'Taller',
      ),
      Event(
        id: 'event-4',
        title: 'Noche de Jazz',
        description: 'Una velada íntima con lo mejor del jazz en vivo',
        radioName: 'Radio Conecta',
        location: 'Jazz Club Downtown',
        icon: Icons.piano_rounded,
        color: const Color(0xFF7E57C2),
        date: '20 Mayo 20:00',
        attendees: 45,
        capacity: 80,
        category: 'Música en vivo',
      ),
      Event(
        id: 'event-5',
        title: 'Meet & Greet: The Killers',
        description: 'Conoce a la banda, sesión de fotos y autógrafos',
        radioName: 'Radio Bío-Bío',
        location: 'Backstage Conecta Radio',
        icon: Icons.star_rounded,
        color: const Color(0xFFFF6B6B),
        date: '30 Mayo 16:00',
        attendees: 30,
        capacity: 30,
        category: 'Meet & Greet',
      ),
      Event(
        id: 'event-6',
        title: 'Concierto Acústico',
        description: 'Una noche especial con artistas locales en formato acústico',
        radioName: 'Radio Urban FM',
        location: 'Teatro Municipal',
        icon: Icons.headset_rounded,
        color: const Color(0xFF26A69A),
        date: '8 Junio 19:00',
        attendees: 120,
        capacity: 200,
        category: 'Música en vivo',
      ),
    ];
  }

  List<Event> get _filteredEvents {
    var filtered = _events;

    // Filtro por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((e) =>
        e.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        e.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Filtro por radio
    if (_selectedRadioFilter != 'Todas') {
      filtered = filtered.where((e) => e.radioName == _selectedRadioFilter).toList();
    }

    // Filtro por categoría
    if (_selectedCategoryFilter != 'Todas') {
      filtered = filtered.where((e) => e.category == _selectedCategoryFilter).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasActiveFilters = _selectedRadioFilter != 'Todas' || _selectedCategoryFilter != 'Todas';

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.light
          ? Colors.grey[100]
          : theme.scaffoldBackgroundColor,
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          context.go('/home');
                        }
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                  ],
                ),
              ),
            ),
          ),
          // Buscador y filtros
          Container(
            color: theme.colorScheme.surface,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Buscar eventos...',
                      prefixIcon: Icon(Icons.search, color: theme.hintColor),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: theme.hintColor),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Badge(
                  isLabelVisible: hasActiveFilters,
                  label: Text('${(_selectedRadioFilter != 'Todas' ? 1 : 0) + (_selectedCategoryFilter != 'Todas' ? 1 : 0)}'),
                  child: IconButton(
                    onPressed: _showFilterModal,
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.all(12),
                    ),
                    icon: const Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Lista de eventos
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 210),
              itemCount: _filteredEvents.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final event = _filteredEvents[index];
                return _EventCard(event: event);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFull = event.attendees >= event.capacity;

    return GestureDetector(
      onTap: () {
        // Navegar a detalles del evento
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: event.color.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Badge de Radio
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: event.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.radio, size: 12, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        event.radioName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Asistentes
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: event.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people, size: 12, color: event.color),
                      const SizedBox(width: 4),
                      Text(
                        '${event.attendees}/${event.capacity}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: event.color,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Título y descripción
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: event.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(event.icon, color: event.color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        event.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Info de ubicación
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: event.color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event.location,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Fecha y estado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: event.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: event.color),
                  const SizedBox(width: 8),
                  Text(
                    event.date,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: event.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (isFull)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'LLENO',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    )
                  else
                    Icon(Icons.arrow_forward_rounded, size: 18, color: event.color),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Barra de progreso
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: event.attendees / event.capacity,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isFull ? Colors.red : event.color,
                ),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterModal extends StatefulWidget {
  const _FilterModal({
    required this.selectedRadio,
    required this.selectedCategory,
    required this.availableRadios,
    required this.onApply,
  });

  final String selectedRadio;
  final String selectedCategory;
  final List<String> availableRadios;
  final Function(String radio, String category) onApply;

  @override
  State<_FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<_FilterModal> {
  late String _tempRadio;
  late String _tempCategory;

  @override
  void initState() {
    super.initState();
    _tempRadio = widget.selectedRadio;
    _tempCategory = widget.selectedCategory;
  }

  void _showRadioSelector() {
    // Convertir nombres de radios a objetos RadioStation
    final radioStations = widget.availableRadios.map((name) => RadioStation(
      id: name,
      name: name,
      frequency: '',
      country: '',
    )).toList();

    // Encontrar la radio seleccionada actual
    RadioStation? selectedRadio;
    if (_tempRadio != 'Todas') {
      selectedRadio = radioStations.firstWhere(
        (r) => r.name == _tempRadio,
        orElse: () => radioStations.first,
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RadioSelectorModal(
        radioStations: radioStations,
        selectedRadio: selectedRadio,
        onRadioSelected: (radio) {
          setState(() => _tempRadio = radio.name);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.tune_rounded,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Filtros',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _tempRadio = 'Todas';
                        _tempCategory = 'Todas';
                      });
                      widget.onApply('Todas', 'Todas');
                    },
                    child: Text(
                      'Limpiar',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Radio Filter
                  Text(
                    'Radio',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _showRadioSelector,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _tempRadio != 'Todas'
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _tempRadio != 'Todas'
                                  ? theme.colorScheme.primary.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.radio,
                              color: _tempRadio != 'Todas'
                                  ? theme.colorScheme.primary
                                  : theme.hintColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _tempRadio == 'Todas' ? 'Todas las radios' : _tempRadio,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: _tempRadio != 'Todas' ? FontWeight.w600 : FontWeight.w500,
                                color: _tempRadio != 'Todas'
                                    ? theme.colorScheme.onSurface
                                    : theme.hintColor,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: theme.hintColor,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Category Filter
                  Text(
                    'Categoría',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FilterChip(
                        label: 'Todas',
                        isSelected: _tempCategory == 'Todas',
                        onTap: () => setState(() => _tempCategory = 'Todas'),
                      ),
                      _FilterChip(
                        label: 'Música en vivo',
                        isSelected: _tempCategory == 'Música en vivo',
                        onTap: () => setState(() => _tempCategory = 'Música en vivo'),
                      ),
                      _FilterChip(
                        label: 'Festival',
                        isSelected: _tempCategory == 'Festival',
                        onTap: () => setState(() => _tempCategory = 'Festival'),
                      ),
                      _FilterChip(
                        label: 'Taller',
                        isSelected: _tempCategory == 'Taller',
                        onTap: () => setState(() => _tempCategory = 'Taller'),
                      ),
                      _FilterChip(
                        label: 'Meet & Greet',
                        isSelected: _tempCategory == 'Meet & Greet',
                        onTap: () => setState(() => _tempCategory = 'Meet & Greet'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        widget.onApply(_tempRadio, _tempCategory);
                        Navigator.pop(context);
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Aplicar filtros',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
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
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(
                Icons.check_circle_rounded,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? Colors.white
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Event {
  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.radioName,
    required this.location,
    required this.icon,
    required this.color,
    required this.date,
    required this.attendees,
    required this.capacity,
    required this.category,
  });

  final String id;
  final String title;
  final String description;
  final String radioName;
  final String location;
  final IconData icon;
  final Color color;
  final String date;
  final int attendees;
  final int capacity;
  final String category;
}

// Modelos auxiliares para el selector de radio
class RadioStation {
  const RadioStation({
    required this.id,
    required this.name,
    required this.frequency,
    required this.country,
  });

  final String id;
  final String name;
  final String frequency;
  final String country;
}

class RadioSelectorModal extends StatelessWidget {
  const RadioSelectorModal({
    super.key,
    required this.radioStations,
    required this.selectedRadio,
    required this.onRadioSelected,
  });

  final List<RadioStation> radioStations;
  final RadioStation? selectedRadio;
  final Function(RadioStation) onRadioSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.radio,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Seleccionar Radio',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListView.builder(
              shrinkWrap: true,
              itemCount: radioStations.length,
              itemBuilder: (context, index) {
                final radio = radioStations[index];
                final isSelected = radio.id == selectedRadio?.id;
                return ListTile(
                  leading: Icon(
                    Icons.radio,
                    color: isSelected ? theme.colorScheme.primary : theme.hintColor,
                  ),
                  title: Text(
                    radio.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                      : null,
                  onTap: () => onRadioSelected(radio),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
