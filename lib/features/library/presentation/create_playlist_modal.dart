import 'package:flutter/material.dart';

class CreatePlaylistModal extends StatefulWidget {
  const CreatePlaylistModal({super.key});

  @override
  State<CreatePlaylistModal> createState() => _CreatePlaylistModalState();
}

class _CreatePlaylistModalState extends State<CreatePlaylistModal> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isPrivate = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
        child: Column(
          children: [
            // Handle bar
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Header simple sin gradiente
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.playlist_add,
                        color: Color(0xFF7E57C2),
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Nueva Playlist',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      _nameController.clear();
                      _descriptionController.clear();
                      setState(() => _isPrivate = false);
                    },
                    child: const Text(
                      'Limpiar',
                      style: TextStyle(
                        color: Color(0xFF7E57C2),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          // Contenido
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre de la playlist
                  const Text(
                    'Nombre de la playlist',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Ej. Mis favoritas',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF7E57C2), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 24),
                  // Descripción
                  const Text(
                    'Descripción (opcional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Describe tu playlist...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF7E57C2), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Privacidad (estilo similar a las opciones de filtro)
                  const Text(
                    'Privacidad',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isPrivate = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: !_isPrivate ? const Color(0xFF7E57C2) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: !_isPrivate ? const Color(0xFF7E57C2) : Colors.grey[300]!,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (!_isPrivate)
                                  const Icon(Icons.check, color: Colors.white, size: 20),
                                if (!_isPrivate) const SizedBox(width: 8),
                                Text(
                                  'Pública',
                                  style: TextStyle(
                                    color: !_isPrivate ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isPrivate = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: _isPrivate ? const Color(0xFF7E57C2) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _isPrivate ? const Color(0xFF7E57C2) : Colors.grey[300]!,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isPrivate)
                                  const Icon(Icons.check, color: Colors.white, size: 20),
                                if (_isPrivate) const SizedBox(width: 8),
                                Text(
                                  'Privada',
                                  style: TextStyle(
                                    color: _isPrivate ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 80), // Espacio para el botón
                ],
              ),
            ),
          ),
          // Botón crear
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nameController.text.trim().isEmpty
                    ? null
                    : () {
                        // Retornar los datos de la playlist
                        Navigator.of(context).pop({
                          'name': _nameController.text.trim(),
                          'description': _descriptionController.text.trim(),
                          'isPrivate': _isPrivate,
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7E57C2),
                  disabledBackgroundColor: Colors.grey[300],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Crear Playlist',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          ],
        ),
        ),
      ),
    );
  }
}
