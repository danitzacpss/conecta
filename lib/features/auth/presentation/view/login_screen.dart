import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:conecta_app/core/localization/l10n.dart';
import 'package:conecta_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:conecta_app/features/home/presentation/view/home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.radioStation});

  static const routePath = '/login';
  static const routeName = 'login';

  final Map<String, dynamic>? radioStation;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  RadioLoginStation? _station;

  @override
  void initState() {
    super.initState();
    _syncStationFromWidget();
  }

  @override
  void didUpdateWidget(covariant LoginScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.radioStation != oldWidget.radioStation) {
      _syncStationFromWidget();
    }
  }

  void _syncStationFromWidget() {
    final payload = widget.radioStation;
    setState(() {
      _station = payload == null ? null : RadioLoginStation.fromMap(payload);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.loginTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/onboarding'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_station != null) ...[
                _StationHeader(station: _station!),
                const SizedBox(height: 16),
              ],
              TextFormField(
                decoration: InputDecoration(labelText: l10n.loginEmail),
                keyboardType: TextInputType.emailAddress,
                onSaved: (value) => _email = value?.trim() ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: l10n.loginPassword),
                obscureText: true,
                onSaved: (value) => _password = value?.trim() ?? '',
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: authState.isLoading
                    ? null
                    : () async {
                        _formKey.currentState?.save();
                        final router = GoRouter.of(context);
                        await authController.signInWithEmail(
                            email: _email, password: _password);
                        if (!mounted) return;
                        router.go(HomeScreen.routePath);
                      },
                style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54)),
                child: authState.isLoading
                    ? const CircularProgressIndicator.adaptive()
                    : Text(l10n.loginSignIn),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: authState.isLoading
                    ? null
                    : authController.signInWithGoogle,
                icon: const Icon(Icons.g_mobiledata_rounded),
                label: Text(l10n.loginGoogle),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed:
                    authState.isLoading ? null : authController.signInWithApple,
                icon: const Icon(Icons.apple_rounded),
                label: Text(l10n.loginApple),
              ),
              const SizedBox(height: 24),
              Text(l10n.loginNoAccount),
            ],
          ),
        ),
      ),
    );
  }
}

class RadioLoginStation {
  RadioLoginStation({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.icon,
  });

  factory RadioLoginStation.fromMap(Map<String, dynamic> map) {
    return RadioLoginStation(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      color: Color(map['color'] as int? ?? 0xFF7E57C2),
      icon: IconData(
        map['icon'] as int? ?? Icons.radio.codePoint,
        fontFamily: map['iconFontFamily'] as String? ?? 'MaterialIcons',
        fontPackage: map['iconFontPackage'] as String?,
        matchTextDirection: false,
      ),
    );
  }

  final String id;
  final String name;
  final String description;
  final Color color;
  final IconData icon;
}

class _StationHeader extends StatelessWidget {
  const _StationHeader({required this.station});

  final RadioLoginStation station;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : theme.colorScheme.onSurface;
    final subtitleColor =
        isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant;

    final cardColor = isDark ? Colors.white.withOpacity(0.08) : Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: station.color.withOpacity(0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: station.color.withOpacity(0.25),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 96,
            width: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  station.color,
                  station.color.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(station.icon, color: Colors.white, size: 44),
          ),
          const SizedBox(height: 16),
          Text(
            station.name,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              color: titleColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            station.description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: subtitleColor),
          ),
        ],
      ),
    );
  }
}
