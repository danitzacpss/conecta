import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:conecta_app/core/localization/l10n.dart';
import 'package:conecta_app/core/network/connectivity_controller.dart';

class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(connectivityControllerProvider);

    if (!state.hasEverConnected) {
      return const SizedBox.shrink();
    }

    if (state.isOnline) {
      return _Banner(
          text: context.l10n.onlineBanner, color: Colors.green.shade600);
    }

    return _Banner(
        text: context.l10n.offlineBanner, color: Colors.orange.shade800);
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: color,
      child: Text(
        text,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        textAlign: TextAlign.center,
      ),
    );
  }
}
