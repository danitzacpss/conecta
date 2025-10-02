import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:conecta_app/features/profile/presentation/profile_screen.dart';

class UnifiedHeader extends StatelessWidget {
  const UnifiedHeader({
    super.key,
    required this.title,
    this.hasSearchBar = false,
    this.searchHint,
    this.onSearchChanged,
    this.hasScanner = true,
    this.onScannerTap,
    this.additionalContent,
  });

  final String title;
  final bool hasSearchBar;
  final String? searchHint;
  final ValueChanged<String>? onSearchChanged;
  final bool hasScanner;
  final VoidCallback? onScannerTap;
  final Widget? additionalContent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: theme.brightness == Brightness.dark
            ? [
                theme.colorScheme.primary.withOpacity(0.3),
                theme.colorScheme.primary.withOpacity(0.6),
              ]
            : [
                theme.colorScheme.primary.withOpacity(0.6),
                theme.colorScheme.primary.withOpacity(1.0),
              ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      if (hasScanner) ...[
                        GestureDetector(
                          onTap: onScannerTap ?? () => _showScannerModal(context),
                          child: const CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white24,
                            child: Icon(Icons.qr_code_scanner, color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      GestureDetector(
                        onTap: () => context.go(ProfileScreen.routePath),
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.person, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (hasSearchBar) ...[
                const SizedBox(height: 20),
                _buildSearchBar(theme),
              ],
              if (additionalContent != null) ...[
                const SizedBox(height: 20),
                additionalContent!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    final searchBarColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.surface.withOpacity(0.9)
        : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: searchBarColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        style: TextStyle(color: theme.colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: searchHint ?? 'Buscar...',
          hintStyle: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: searchBarColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        onChanged: onSearchChanged,
      ),
    );
  }

  void _showScannerModal(BuildContext context) {
    // This should be overridden by the calling widget
    print('Scanner modal not implemented');
  }
}