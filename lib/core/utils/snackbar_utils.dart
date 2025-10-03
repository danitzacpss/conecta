import 'package:flutter/material.dart';

class SnackBarUtils {
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    _showCustomSnackBar(
      context,
      message: message,
      icon: Icons.check_circle_rounded,
      backgroundColor: Colors.green.shade600,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    _showCustomSnackBar(
      context,
      message: message,
      icon: Icons.error_rounded,
      backgroundColor: Colors.red.shade600,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    final theme = Theme.of(context);
    _showCustomSnackBar(
      context,
      message: message,
      icon: Icons.info_rounded,
      backgroundColor: theme.colorScheme.primary,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  static void showCustom(
    BuildContext context,
    String message, {
    IconData? icon,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    final theme = Theme.of(context);
    _showCustomSnackBar(
      context,
      message: message,
      icon: icon,
      backgroundColor: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  static void _showCustomSnackBar(
    BuildContext context, {
    required String message,
    IconData? icon,
    required Color backgroundColor,
    required Duration duration,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        duration: duration,
        action: onAction != null && actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
        elevation: 6,
      ),
    );
  }
}
