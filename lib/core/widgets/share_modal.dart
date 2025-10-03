import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void showShareModal(
  BuildContext context, {
  required String title,
  required String description,
  Color? iconColor,
  VoidCallback? onFacebookShare,
  VoidCallback? onWhatsAppShare,
  VoidCallback? onInstagramShare,
  VoidCallback? onCopyLink,
}) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Icon(
              Icons.share,
              color: iconColor ?? Theme.of(context).colorScheme.primary,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _ShareButton(
                    icon: Icons.facebook,
                    label: 'Facebook',
                    color: const Color(0xFF1877F2),
                    onTap: () {
                      Navigator.pop(context);
                      onFacebookShare?.call();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ShareButton(
                    icon: Icons.message,
                    label: 'WhatsApp',
                    color: const Color(0xFF25D366),
                    onTap: () {
                      Navigator.pop(context);
                      onWhatsAppShare?.call();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ShareButton(
                    icon: Icons.camera_alt,
                    label: 'Instagram',
                    color: const Color(0xFFE4405F),
                    onTap: () {
                      Navigator.pop(context);
                      onInstagramShare?.call();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onCopyLink?.call();
                },
                icon: const Icon(Icons.link),
                label: const Text('Copiar enlace'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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

class _ShareButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
