import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import 'animated_counter.dart';
import 'app_card.dart';

/// A compact KPI tile: icon chip + animated number + label.
/// Used in dashboard stat rows and analytics summaries.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    this.suffix = '',
    this.fractionDigits = 0,
    this.onTap,
  });

  final String label;
  final num value;
  final IconData icon;
  final Color accent;
  final String suffix;
  final int fractionDigits;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, size: 20, color: accent),
          ),
          const SizedBox(height: AppSpacing.md),
          AnimatedCounter(
            value: value,
            suffix: suffix,
            fractionDigits: fractionDigits,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
