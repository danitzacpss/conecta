import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:conecta_app/features/radio/presentation/radio_profile_screen.dart';

class AudioScannerModal extends StatefulWidget {
  const AudioScannerModal({super.key});

  @override
  State<AudioScannerModal> createState() => _AudioScannerModalState();
}

class _AudioScannerModalState extends State<AudioScannerModal> {
  RadioStation? selectedRadio;
  bool isScanning = false;
  bool scanCompleted = false;

  // Simulación de miles de radios
  final List<RadioStation> allRadioStations = [
    // Radios principales
    RadioStation(id: '1', name: 'Conecta Radio', frequency: '105.7 FM', country: 'Chile'),
    RadioStation(id: '2', name: 'Rock FM', frequency: '102.3 FM', country: 'España'),
    RadioStation(id: '3', name: 'Pop Station', frequency: '98.5 FM', country: 'México'),
    RadioStation(id: '4', name: 'Dance Radio', frequency: '107.1 FM', country: 'Argentina'),
    RadioStation(id: '5', name: 'Jazz & Blues', frequency: '104.2 FM', country: 'Estados Unidos'),

    // Más radios simuladas
    RadioStation(id: '6', name: 'Radio Nacional', frequency: '96.7 FM', country: 'España'),
    RadioStation(id: '7', name: 'Los 40 Principales', frequency: '93.9 FM', country: 'España'),
    RadioStation(id: '8', name: 'Cadena SER', frequency: '90.4 FM', country: 'España'),
    RadioStation(id: '9', name: 'Kiss FM', frequency: '102.7 FM', country: 'España'),
    RadioStation(id: '10', name: 'Europa FM', frequency: '91.3 FM', country: 'España'),
    RadioStation(id: '11', name: 'Radio Marca', frequency: '103.2 FM', country: 'España'),
    RadioStation(id: '12', name: 'Onda Cero', frequency: '89.6 FM', country: 'España'),
    RadioStation(id: '13', name: 'COPE', frequency: '100.7 FM', country: 'España'),
    RadioStation(id: '14', name: 'Radio Clásica', frequency: '96.5 FM', country: 'España'),
    RadioStation(id: '15', name: 'Radio 3', frequency: '99.3 FM', country: 'España'),

    // Radios internacionales
    RadioStation(id: '16', name: 'BBC Radio 1', frequency: '97.6 FM', country: 'Reino Unido'),
    RadioStation(id: '17', name: 'NPR', frequency: '88.5 FM', country: 'Estados Unidos'),
    RadioStation(id: '18', name: 'Radio France', frequency: '105.3 FM', country: 'Francia'),
    RadioStation(id: '19', name: 'Radio Cooperativa', frequency: '93.3 FM', country: 'Chile'),
    RadioStation(id: '20', name: 'Radio Mitre', frequency: '790 AM', country: 'Argentina'),
    RadioStation(id: '21', name: 'W Radio', frequency: '99.9 FM', country: 'México'),
    RadioStation(id: '22', name: 'Radio Caracol', frequency: '1260 AM', country: 'Colombia'),
    RadioStation(id: '23', name: 'Radio Globo', frequency: '98.3 FM', country: 'Brasil'),
    RadioStation(id: '24', name: 'Radio Monte Carlo', frequency: '95.1 FM', country: 'Uruguay'),
    RadioStation(id: '25', name: 'Radio Nacional', frequency: '870 AM', country: 'Perú'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(theme),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildScannerSection(theme),
                  const SizedBox(height: 24),
                  _buildRadioSelectorButton(theme),
                  const SizedBox(height: 24),
                  _buildScanButton(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.8),
            theme.colorScheme.secondary.withOpacity(0.6),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Escanear Audio',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Identifica la canción que está sonando',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScannerSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
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
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.2),
                  theme.colorScheme.secondary.withOpacity(0.1),
                ],
              ),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              child: Icon(
                isScanning ? Icons.graphic_eq : Icons.mic,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isScanning
              ? 'Escuchando...'
              : scanCompleted
                ? '¡Canción identificada!'
                : 'Presiona para empezar',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (scanCompleted)
            Column(
              children: [
                const SizedBox(height: 8),
                Text(
                  '"Bohemian Rhapsody" - Queen',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Detectado en ${selectedRadio?.name ?? "Radio seleccionada"}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildRadioSelectorButton(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona la radio',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _showRadioSelector(context, theme),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selectedRadio != null
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selectedRadio != null
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.radio,
                    color: selectedRadio != null
                      ? theme.colorScheme.primary
                      : Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: selectedRadio != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedRadio!.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${selectedRadio!.frequency} • ${selectedRadio!.country}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Toca para seleccionar una radio',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showRadioSelector(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RadioSelectorModal(
        radioStations: allRadioStations,
        selectedRadio: selectedRadio,
        onRadioSelected: (radio) {
          setState(() => selectedRadio = radio);
          Navigator.of(context).pop();
          context.push(RadioProfileScreen.routePath);
        },
      ),
    );
  }

  Widget _buildScanButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: selectedRadio != null && !isScanning ? _startScan : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isScanning)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            else
              const Icon(Icons.qr_code_scanner, size: 20),
            const SizedBox(width: 8),
            Text(
              isScanning
                ? 'Escaneando...'
                : scanCompleted
                  ? 'Escanear de nuevo'
                  : 'Iniciar escaneo',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startScan() {
    setState(() {
      isScanning = true;
      scanCompleted = false;
    });

    // Simular escaneo
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          isScanning = false;
          scanCompleted = true;
        });
      }
    });
  }
}

// RadioStation y RadioSelectorModal también necesitan estar aquí
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

class RadioSelectorModal extends StatefulWidget {
  const RadioSelectorModal({
    super.key,
    required this.radioStations,
    this.selectedRadio,
    required this.onRadioSelected,
  });

  final List<RadioStation> radioStations;
  final RadioStation? selectedRadio;
  final Function(RadioStation) onRadioSelected;

  @override
  State<RadioSelectorModal> createState() => _RadioSelectorModalState();
}

class _RadioSelectorModalState extends State<RadioSelectorModal> {
  String searchQuery = '';
  List<RadioStation> filteredRadios = [];

  @override
  void initState() {
    super.initState();
    filteredRadios = widget.radioStations;
  }

  void _filterRadios(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredRadios = widget.radioStations;
      } else {
        filteredRadios = widget.radioStations.where((radio) {
          return radio.name.toLowerCase().contains(query.toLowerCase()) ||
                 radio.country.toLowerCase().contains(query.toLowerCase()) ||
                 radio.frequency.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Selecciona una Radio',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                // Barra de búsqueda
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar radio...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                  onChanged: _filterRadios,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Lista de radios
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filteredRadios.length,
              itemBuilder: (context, index) {
                final radio = filteredRadios[index];
                final isSelected = widget.selectedRadio?.id == radio.id;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => widget.onRadioSelected(radio),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                          ? theme.colorScheme.primary.withOpacity(0.1)
                          : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                ? theme.colorScheme.primary.withOpacity(0.2)
                                : theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.radio,
                              color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  radio.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${radio.frequency} • ${radio.country}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: theme.colorScheme.primary,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Text(
              '${filteredRadios.length} radios disponibles',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}