
import 'package:flutter/material.dart';

class CreditsActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? color;
  final Color? textColor;
  final Widget? customContent;
  final VoidCallback? onTap;

  const CreditsActionCard({
    super.key,
    required this.icon,
    required this.title,
    this.color,
    this.textColor,
    this.customContent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                icon,
                size: 36,
                color: textColor ?? colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor ?? colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              if (customContent != null) customContent!,
            ],
          ),
        ),
      ),
    );
  }
}