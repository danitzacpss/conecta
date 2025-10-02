import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:conecta_app/features/scanner/presentation/audio_scanner_modal.dart';

class AllContestsScreen extends ConsumerStatefulWidget {
  const AllContestsScreen({super.key});

  static const routePath = '/contests';
  static const routeName = 'allContests';

  @override
  ConsumerState<AllContestsScreen> createState() => _AllContestsScreenState();
}

class _AllContestsScreenState extends ConsumerState<AllContestsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedRadioFilter = 'Todas';
  String _selectedTypeFilter = 'Todos';
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
    // Extraer radios únicas de los concursos
    final radios = _contests.map((c) => c.radioName).toSet().toList()..sort();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterModal(
        selectedRadio: _selectedRadioFilter,
        selectedType: _selectedTypeFilter,
        availableRadios: radios,
        onApply: (radio, type) {
          setState(() {
            _selectedRadioFilter = radio;
            _selectedTypeFilter = type;
          });
        },
      ),
    );
  }

  List<Contest> get _contests {
    return [
      Contest(
        id: 'contest-1',
        title: 'Gana entradas VIP',
        description: 'Participa y gana 2 entradas VIP para el concierto del año',
        radioName: 'Radio Bío-Bío',
        cost: '\$500',
        prize: '2 Entradas VIP',
        icon: Icons.confirmation_number_rounded,
        color: const Color(0xFFFF6B6B),
        deadline: 'Termina en 2 días',
        participants: 234,
        type: 'Entradas',
      ),
      Contest(
        id: 'contest-2',
        title: 'Meet & Greet Exclusivo',
        description: 'Conoce a tu artista favorito en persona',
        radioName: 'Radio Conecta',
        cost: 'Gratis',
        prize: 'Meet & Greet + Foto',
        icon: Icons.star_rounded,
        color: const Color(0xFF7E57C2),
        deadline: '5 ganadores',
        participants: 892,
        type: 'Experiencias',
      ),
      Contest(
        id: 'contest-3',
        title: 'Festival Pass 2024',
        description: 'Acceso completo al festival más grande del año',
        radioName: 'Radio Urban FM',
        cost: '\$1,000',
        prize: 'Pase VIP Festival',
        icon: Icons.festival_rounded,
        color: const Color(0xFF26A69A),
        deadline: 'Hasta el 15 Mayo',
        participants: 567,
        type: 'Entradas',
      ),
      Contest(
        id: 'contest-4',
        title: 'Noche de Premios',
        description: 'Asiste a la entrega de premios como invitado especial',
        radioName: 'Radio Bío-Bío',
        cost: '\$750',
        prize: '2 Invitaciones',
        icon: Icons.emoji_events_rounded,
        color: const Color(0xFFFF6B6B),
        deadline: '10 días restantes',
        participants: 345,
        type: 'Eventos',
      ),
      Contest(
        id: 'contest-5',
        title: 'Backstage Experience',
        description: 'Vive la experiencia detrás del escenario',
        radioName: 'Radio Conecta',
        cost: '\$1,200',
        prize: 'Acceso Backstage',
        icon: Icons.all_inclusive_rounded,
        color: const Color(0xFF7E57C2),
        deadline: 'Termina en 5 días',
        participants: 178,
        type: 'Experiencias',
      ),
      Contest(
        id: 'contest-6',
        title: 'Entradas Dobles',
        description: 'Participa gratis y lleva a un amigo',
        radioName: 'Radio Urban FM',
        cost: 'Gratis',
        prize: '2 Entradas',
        icon: Icons.people_rounded,
        color: const Color(0xFF26A69A),
        deadline: '20 ganadores',
        participants: 1234,
        type: 'Entradas',
      ),
    ];
  }

  List<Contest> get _filteredContests {
    var filtered = _contests;

    // Filtro por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((c) =>
        c.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        c.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Filtro por radio
    if (_selectedRadioFilter != 'Todas') {
      filtered = filtered.where((c) => c.radioName == _selectedRadioFilter).toList();
    }

    // Filtro por tipo
    if (_selectedTypeFilter != 'Todos') {
      filtered = filtered.where((c) => c.type == _selectedTypeFilter).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasActiveFilters = _selectedRadioFilter != 'Todas' || _selectedTypeFilter != 'Todos';

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
                        'Concursos',
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
                      hintText: 'Buscar concursos...',
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
                  label: Text('${(_selectedRadioFilter != 'Todas' ? 1 : 0) + (_selectedTypeFilter != 'Todos' ? 1 : 0)}'),
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
          // Lista de concursos
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 210),
              itemCount: _filteredContests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final contest = _filteredContests[index];
                return _ContestCard(contest: contest);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ContestCard extends StatelessWidget {
  const _ContestCard({required this.contest});

  final Contest contest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => context.push('/contest-details', extra: {'contestId': contest.id}),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: contest.color.withOpacity(0.3),
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
                    color: contest.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.radio, size: 12, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        contest.radioName,
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
                // Participantes
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: contest.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people, size: 12, color: contest.color),
                      const SizedBox(width: 4),
                      Text(
                        '${contest.participants}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: contest.color,
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
                    color: contest.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(contest.icon, color: contest.color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contest.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        contest.description,
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
            // Info inferior
            Row(
              children: [
                // Premio
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Premio',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contest.prize,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: contest.color,
                        ),
                      ),
                    ],
                  ),
                ),
                // Costo
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Participación',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contest.cost,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Deadline
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: contest.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule_rounded, size: 16, color: contest.color),
                  const SizedBox(width: 8),
                  Text(
                    contest.deadline,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: contest.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_rounded, size: 18, color: contest.color),
                ],
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
    required this.selectedType,
    required this.availableRadios,
    required this.onApply,
  });

  final String selectedRadio;
  final String selectedType;
  final List<String> availableRadios;
  final Function(String radio, String type) onApply;

  @override
  State<_FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<_FilterModal> {
  late String _tempRadio;
  late String _tempType;

  @override
  void initState() {
    super.initState();
    _tempRadio = widget.selectedRadio;
    _tempType = widget.selectedType;
  }

  void _showRadioSelector() {
    // Convertir nombres de radios a objetos RadioStation
    final radioStations = widget.availableRadios.map((name) => RadioStation(
      id: name,
      name: name,
      frequency: '', // No tenemos frecuencia en los concursos
      country: '',   // No tenemos país en los concursos
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
                        _tempType = 'Todos';
                      });
                      widget.onApply('Todas', 'Todos');
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
                  // Type Filter
                  Text(
                    'Tipo de concurso',
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
                        label: 'Todos',
                        isSelected: _tempType == 'Todos',
                        onTap: () => setState(() => _tempType = 'Todos'),
                      ),
                      _FilterChip(
                        label: 'Entradas',
                        isSelected: _tempType == 'Entradas',
                        onTap: () => setState(() => _tempType = 'Entradas'),
                      ),
                      _FilterChip(
                        label: 'Experiencias',
                        isSelected: _tempType == 'Experiencias',
                        onTap: () => setState(() => _tempType = 'Experiencias'),
                      ),
                      _FilterChip(
                        label: 'Eventos',
                        isSelected: _tempType == 'Eventos',
                        onTap: () => setState(() => _tempType = 'Eventos'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        widget.onApply(_tempRadio, _tempType);
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

class Contest {
  const Contest({
    required this.id,
    required this.title,
    required this.description,
    required this.radioName,
    required this.cost,
    required this.prize,
    required this.icon,
    required this.color,
    required this.deadline,
    required this.participants,
    required this.type,
  });

  final String id;
  final String title;
  final String description;
  final String radioName;
  final String cost;
  final String prize;
  final IconData icon;
  final Color color;
  final String deadline;
  final int participants;
  final String type; // 'Entradas', 'Experiencias', 'Eventos'
}
