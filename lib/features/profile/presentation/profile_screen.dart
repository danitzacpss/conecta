import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:conecta_app/app/theme/app_theme.dart';
import 'package:conecta_app/core/localization/l10n.dart';
import 'package:conecta_app/features/auth/presentation/controllers/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const routePath = '/profile';
  static const routeName = 'profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage('https://i.pravatar.cc/100')),
            title: const Text('Alexa Morales'),
            subtitle: Text(l10n.profileProgress),
            trailing: FilledButton.tonal(
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).signOut(),
              child: const Text('Cerrar sesión'),
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.profilePreferences,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Modo oscuro'),
            value: themeMode == ThemeMode.dark,
            onChanged: (value) {
              ref.read(themeModeProvider.notifier).state =
                  value ? ThemeMode.dark : ThemeMode.light;
            },
          ),
          const Divider(),
          ListTile(
            title: Text(l10n.profileSettings),
            subtitle: const Text('Cuenta, privacidad, suscripciones'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
