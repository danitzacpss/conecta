import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:conecta_app/features/community/presentation/contest_details_screen.dart';

// Provider para manejar el estado de encuestas y concursos
final pollsContestsProvider = StateNotifierProvider<PollsContestsController, PollsContestsState>(
  (ref) => PollsContestsController(),
);

class PollsContestsController extends StateNotifier<PollsContestsState> {
  PollsContestsController() : super(PollsContestsState());

  void selectPollOption(String pollId, String option) {
    state = state.copyWith(
      selectedOptions: {
        ...state.selectedOptions,
        pollId: option,
      },
    );
  }

  void submitPoll(String pollId) {
    // Aquí enviarías la respuesta al servidor
    print('Votando por: ${state.selectedOptions[pollId]} en encuesta $pollId');
  }

  void selectProgram(String program) {
    state = state.copyWith(selectedProgram: program);
  }

  void submitSuggestion() {
    // Aquí enviarías la sugerencia al servidor
    print('Enviando sugerencia para programa: ${state.selectedProgram}');
  }
}

class PollsContestsState {
  final Map<String, String> selectedOptions;
  final String? selectedProgram;
  final String searchQuery;

  PollsContestsState({
    this.selectedOptions = const {},
    this.selectedProgram,
    this.searchQuery = '',
  });

  PollsContestsState copyWith({
    Map<String, String>? selectedOptions,
    String? selectedProgram,
    String? searchQuery,
  }) {
    return PollsContestsState(
      selectedOptions: selectedOptions ?? this.selectedOptions,
      selectedProgram: selectedProgram ?? this.selectedProgram,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class PollsContestsScreen extends ConsumerStatefulWidget {
  const PollsContestsScreen({super.key});

  static const routePath = '/polls-contests';
  static const routeName = 'pollsContests';

  @override
  ConsumerState<PollsContestsScreen> createState() => _PollsContestsScreenState();
}

class _PollsContestsScreenState extends ConsumerState<PollsContestsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Auto scroll to top when screen loads
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(pollsContestsProvider);
    final controller = ref.read(pollsContestsProvider.notifier);

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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            } else {
                              context.go('/radio-player');
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
                            'Encuestas y Concursos',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Barra de búsqueda
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Buscar encuestas o concursos',
                          hintStyle: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Contenido principal
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encuestas Activas
                  Text(
                    'Encuestas Activas',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Encuesta 1: Género Musical
                  _buildPollCard(
                    context: context,
                    theme: theme,
                    pollId: 'poll1',
                    title: '¿Cuál es tu género musical favorito?',
                    description: 'Tu opinión nos ayudará a mejorar la programación.',
                    options: ['Pop', 'Rock', 'Urbano'],
                    selectedOption: state.selectedOptions['poll1'],
                    onOptionSelected: (option) => controller.selectPollOption('poll1', option),
                    onSubmit: () => controller.submitPoll('poll1'),
                  ),
                  const SizedBox(height: 16),

                  // Encuesta 2: Programa favorito
                  _buildProgramSuggestionCard(
                    context: context,
                    theme: theme,
                    title: '¿Qué programa te gustaría que vuelva?',
                    description: 'Queremos traer de vuelta tus programas favoritos.',
                    selectedProgram: state.selectedProgram,
                    onProgramSelected: controller.selectProgram,
                    onSubmit: controller.submitSuggestion,
                  ),
                  const SizedBox(height: 32),

                  // Concursos Disponibles
                  Text(
                    'Concursos Disponibles',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Concurso 1: Entradas
                  _buildContestCard(
                    context: context,
                    theme: theme,
                    image: 'https://picsum.photos/seed/ticket/400/200',
                    title: 'Gana entradas para el concierto del año',
                    participants: '2 Entradas VIP',
                    deadline: 'Finaliza el 30 de Noviembre',
                    onTap: () => context.push(ContestDetailsScreen.routePath),
                  ),
                  const SizedBox(height: 16),

                  // Concurso 2: Kit Exclusivo
                  _buildContestCard(
                    context: context,
                    theme: theme,
                    image: 'https://picsum.photos/seed/kit/400/200',
                    title: 'Kit Exclusivo de Radio Pop',
                    participants: 'Premio valorado en \$150',
                    deadline: 'Finaliza el 5 de Diciembre',
                    onTap: () => context.push(ContestDetailsScreen.routePath),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPollCard({
    required BuildContext context,
    required ThemeData theme,
    required String pollId,
    required String title,
    required String description,
    required List<String> options,
    String? selectedOption,
    required Function(String) onOptionSelected,
    required VoidCallback onSubmit,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
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
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ...options.map((option) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: RadioListTile<String>(
              value: option,
              groupValue: selectedOption,
              onChanged: (value) => onOptionSelected(value!),
              title: Text(option),
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          )),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: selectedOption != null ? onSubmit : null,
                borderRadius: BorderRadius.circular(24),
                child: Center(
                  child: Text(
                    'Votar',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramSuggestionCard({
    required BuildContext context,
    required ThemeData theme,
    required String title,
    required String description,
    String? selectedProgram,
    required Function(String) onProgramSelected,
    required VoidCallback onSubmit,
  }) {
    final programs = [
      'Mañanas con Energía',
      'Tardes de Música',
      'Rock en tu Idioma',
      'Noches de Jazz',
      'Retro Mix',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
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
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedProgram,
              hint: const Text('Selecciona un programa'),
              underline: const SizedBox(),
              items: programs.map((program) => DropdownMenuItem(
                value: program,
                child: Text(program),
              )).toList(),
              onChanged: (value) => onProgramSelected(value!),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.secondary,
                  theme.colorScheme.primary,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: selectedProgram != null ? onSubmit : null,
                borderRadius: BorderRadius.circular(24),
                child: Center(
                  child: Text(
                    'Enviar sugerencia',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContestCard({
    required BuildContext context,
    required ThemeData theme,
    required String image,
    required String title,
    required String participants,
    required String deadline,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
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
          // Imagen del concurso
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                image: DecorationImage(
                  image: NetworkImage(image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.card_giftcard,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      participants,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      deadline,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      side: BorderSide(color: theme.colorScheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Ver detalles'),
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