import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';

/// A horizontally-scrolling strip of filter chips.
///
/// Sizes itself to its content instead of being pinned to a fixed height, so
/// the chips still fit when the user scales their system font up — a fixed
/// `SizedBox(height: 44)` clips the labels at large text sizes.
class FilterChipBar extends StatelessWidget {
  const FilterChipBar({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      child: Row(children: children),
    );
  }
}

/// A pinned header that sits above a scrolling list.
///
/// While the list is at the top the header blends into the page. As soon as
/// content scrolls beneath it, a hairline and a soft shadow fade in, so the
/// list visibly passes *under* the header instead of appearing to share a
/// border with it. Pair with [ScrollAwareHeaderController] on the list.
class ScrolledUnderHeader extends StatelessWidget {
  const ScrolledUnderHeader({
    super.key,
    required this.scrolled,
    required this.child,
  });

  /// Whether the attached list has been scrolled away from the top.
  final bool scrolled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.enter,
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          bottom: BorderSide(
            color: scrolled ? scheme.outlineVariant : Colors.transparent,
          ),
        ),
        boxShadow: scrolled
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : const [],
      ),
      child: child,
    );
  }
}

/// Reports whether the wrapped vertical scrollable is away from the top.
///
/// Ignores horizontal scrollables (a filter chip strip inside the same screen
/// would otherwise fire this too).
class ScrollAwareHeaderController extends StatelessWidget {
  const ScrollAwareHeaderController({
    super.key,
    required this.onChanged,
    required this.scrolled,
    required this.child,
  });

  final ValueChanged<bool> onChanged;
  final bool scrolled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.axis != Axis.vertical) return false;
        final isScrolled = n.metrics.pixels > 2;
        if (isScrolled != scrolled) onChanged(isScrolled);
        return false;
      },
      child: child,
    );
  }
}
