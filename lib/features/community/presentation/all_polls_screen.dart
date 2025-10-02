import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:conecta_app/features/scanner/presentation/audio_scanner_modal.dart';

class AllPollsScreen extends ConsumerStatefulWidget {
  const AllPollsScreen({super.key});

  static const routePath = '/polls';
  static const routeName = 'allPolls';

  @override
  ConsumerState<AllPollsScreen> createState() => _AllPollsScreenState();
}

class _AllPollsScreenState extends ConsumerState<AllPollsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedRadioFilter = 'Todas';
  String _selectedStatusFilter = 'Todas';
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
    // Extraer radios únicas de las encuestas
    final radios = _polls.map((p) => p.radioName).toSet().toList()..sort();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterModal(
        selectedRadio: _selectedRadioFilter,
        selectedStatus: _selectedStatusFilter,
        availableRadios: radios,
        onApply: (radio, status) {
          setState(() {
            _selectedRadioFilter = radio;
            _selectedStatusFilter = status;
          });
        },
      ),
    );
  }

  List<Poll> get _polls {
    return [
      const Poll(
        id: 'poll-1',
        title: '¿Cuál es tu género musical favorito?',
        description: 'Ayúdanos a conocer tus preferencias musicales',
        radioName: 'Radio Conecta',
        votes: 1234,
        icon: Icons.poll_rounded,
        color: Color(0xFF42A5F5),
        deadline: 'Termina en 3 días',
        isActive: true,
      ),
      const Poll(
        id: 'poll-2',
        title: 'Mejor artista del mes',
        description: 'Vota por tu artista favorito de este mes',
        radioName: 'Radio Bío-Bío',
        votes: 892,
        icon: Icons.how_to_vote_rounded,
        color: Color(0xFF66BB6A),
        deadline: 'Cierra mañana',
        isActive: true,
      ),
      const Poll(
        id: 'poll-3',
        title: 'Canción del verano 2024',
        description: 'Elige el hit que marcó tu verano',
        radioName: 'Radio Urban FM',
        votes: 2456,
        icon: Icons.music_note_rounded,
        color: Color(0xFFFF7043),
        deadline: 'Termina en 5 días',
        isActive: true,
      ),
      const Poll(
        id: 'poll-4',
        title: '¿Qué tipo de contenido te gustaría escuchar?',
        description: 'Tu opinión nos ayuda a mejorar la programación',
        radioName: 'Radio Conecta',
        votes: 567,
        icon: Icons.radio_rounded,
        color: Color(0xFF9C27B0),
        deadline: 'Termina en 1 semana',
        isActive: true,
      ),
      const Poll(
        id: 'poll-5',
        title: 'Mejor entrevista del año',
        description: 'Vota por la entrevista más memorable',
        radioName: 'Radio Bío-Bío',
        votes: 1890,
        icon: Icons.mic_rounded,
        color: Color(0xFFFF5722),
        deadline: 'Finalizada',
        isActive: false,
      ),
      const Poll(
        id: 'poll-6',
        title: 'Horario preferido para programas en vivo',
        description: 'Ayúdanos a programar los mejores shows',
        radioName: 'Radio Urban FM',
        votes: 743,
        icon: Icons.schedule_rounded,
        color: Color(0xFF00BCD4),
        deadline: 'Termina en 2 días',
        isActive: true,
      ),
    ];
  }

  List<Poll> get _filteredPolls {
    var filtered = _polls;

    // Filtro por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) =>
        p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Filtro por radio
    if (_selectedRadioFilter != 'Todas') {
      filtered = filtered.where((p) => p.radioName == _selectedRadioFilter).toList();
    }

    // Filtro por estado
    if (_selectedStatusFilter != 'Todas') {
      if (_selectedStatusFilter == 'Activas') {
        filtered = filtered.where((p) => p.isActive).toList();
      } else if (_selectedStatusFilter == 'Finalizadas') {
        filtered = filtered.where((p) => !p.isActive).toList();
      }
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasActiveFilters = _selectedRadioFilter != 'Todas' || _selectedStatusFilter != 'Todas';

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
                        'Encuestas',
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
                      hintText: 'Buscar encuestas...',
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
                  label: Text('${(_selectedRadioFilter != 'Todas' ? 1 : 0) + (_selectedStatusFilter != 'Todas' ? 1 : 0)}'),
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
          // Lista de encuestas
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 210),
              itemCount: _filteredPolls.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final poll = _filteredPolls[index];
                return _PollCard(poll: poll);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PollCard extends StatelessWidget {
  const _PollCard({required this.poll});

  final Poll poll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => context.push('/polls-contests'),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: poll.color.withOpacity(0.3),
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
            // Radio y estado
            Row(
              children: [
                // Badge de radio
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: poll.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.radio, size: 14, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        poll.radioName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Badge de estado
                if (!poll.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Finalizada',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Título y descripción
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: poll.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(poll.icon, color: poll.color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        poll.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        poll.description,
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
            // Footer con votos y deadline
            Row(
              children: [
                Icon(Icons.people_rounded, size: 18, color: poll.color),
                const SizedBox(width: 6),
                Text(
                  '${poll.votes} votos',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: poll.color,
                  ),
                ),
                const Spacer(),
                Icon(Icons.access_time_rounded, size: 16, color: theme.hintColor),
                const SizedBox(width: 6),
                Text(
                  poll.deadline,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
    required this.selectedStatus,
    required this.availableRadios,
    required this.onApply,
  });

  final String selectedRadio;
  final String selectedStatus;
  final List<String> availableRadios;
  final Function(String radio, String status) onApply;

  @override
  State<_FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<_FilterModal> {
  late String _tempRadio;
  late String _tempStatus;

  @override
  void initState() {
    super.initState();
    _tempRadio = widget.selectedRadio;
    _tempStatus = widget.selectedStatus;
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
                        _tempStatus = 'Todas';
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
                  // Status Filter
                  Text(
                    'Estado',
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
                        isSelected: _tempStatus == 'Todas',
                        onTap: () => setState(() => _tempStatus = 'Todas'),
                      ),
                      _FilterChip(
                        label: 'Activas',
                        isSelected: _tempStatus == 'Activas',
                        onTap: () => setState(() => _tempStatus = 'Activas'),
                      ),
                      _FilterChip(
                        label: 'Finalizadas',
                        isSelected: _tempStatus == 'Finalizadas',
                        onTap: () => setState(() => _tempStatus = 'Finalizadas'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        widget.onApply(_tempRadio, _tempStatus);
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
              const Icon(
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

class Poll {
  const Poll({
    required this.id,
    required this.title,
    required this.description,
    required this.radioName,
    required this.votes,
    required this.icon,
    required this.color,
    required this.deadline,
    required this.isActive,
  });

  final String id;
  final String title;
  final String description;
  final String radioName;
  final int votes;
  final IconData icon;
  final Color color;
  final String deadline;
  final bool isActive;
}
