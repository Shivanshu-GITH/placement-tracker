import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_palette.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/entrance.dart';
import '../../core/widgets/filter_bar.dart';
import '../../data/database/database.dart';
import '../../providers/providers.dart';
import '../ads/ad_config.dart';
import '../ads/native_ad_card.dart';

/// Affiliate disclosure for the Paid tab.
///
/// MUST stay visible without any interaction. Folding it into an info button
/// that opens a dialog is tempting — it takes real space — but a material
/// connection has to be disclosed clearly and conspicuously, and the FTC's
/// Endorsement Guides call out disclosures placed behind a hyperlink, a pop-up
/// or an extra tap as inadequate; Play's deceptive-behaviour policy takes the
/// same line. The space is bought back by shortening the wording instead:
/// affiliate + commission + no extra cost is the whole substance, and the
/// editorial "we only list resources we'd genuinely recommend" sentence that
/// used to follow was never part of the disclosure.
const _disclosure =
    'Some links here are affiliate links — we may earn a commission, '
    'at no extra cost to you.';

IconData _typeIcon(String type) => switch (type) {
      'sheet' => Icons.checklist_rounded,
      'video' => Icons.play_circle_rounded,
      'notes' => Icons.description_rounded,
      'practice' => Icons.code_rounded,
      'cp' => Icons.bolt_rounded,
      'mock' => Icons.record_voice_over_rounded,
      'resume' => Icons.article_rounded,
      'book' => Icons.menu_book_rounded,
      'course' => Icons.school_rounded,
      'platform' => Icons.workspaces_rounded,
      _ => Icons.link_rounded,
    };

class ResourcesScreen extends ConsumerStatefulWidget {
  const ResourcesScreen({super.key});

  @override
  ConsumerState<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends ConsumerState<ResourcesScreen> {
  String _tier = 'free';
  String? _category;

  /// True once the list has scrolled under the filter header.
  bool _scrolled = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final all = ref.watch(resourcesProvider).valueOrNull ?? const [];
    final tierItems = all.where((r) => r.tier == _tier).toList();
    final categories = tierItems.map((r) => r.category).toSet().toList()..sort();
    final items = _category == null
        ? tierItems
        : tierItems.where((r) => r.category == _category).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources'),
        titleTextStyle: theme.textTheme.headlineSmall,
      ),
      body: Column(
        children: [
          ScrolledUnderHeader(
            scrolled: _scrolled,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, 0,
                      AppSpacing.screenH, AppSpacing.sm),
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                          value: 'free',
                          label: Text('Free'),
                          icon: Icon(Icons.public_rounded)),
                      ButtonSegment(
                          value: 'paid',
                          label: Text('Paid'),
                          icon: Icon(Icons.workspace_premium_rounded)),
                    ],
                    selected: {_tier},
                    onSelectionChanged: (s) =>
                        setState(() { _tier = s.first; _category = null; }),
                    showSelectedIcon: false,
                  ),
                ),
                FilterChipBar(
                  children: [
                    _catChip('All', _category == null,
                        () => setState(() => _category = null)),
                    for (final c in categories)
                      _catChip(_label(c), _category == c,
                          () => setState(() => _category = c)),
                  ],
                ),
                if (_tier == 'paid')
                  Container(
                    margin: const EdgeInsets.fromLTRB(AppSpacing.screenH,
                        AppSpacing.sm, AppSpacing.screenH, 0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 18,
                            color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(_disclosure,
                              style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ScrollAwareHeaderController(
                    scrolled: _scrolled,
                    onChanged: (v) => setState(() => _scrolled = v),
                    child: _buildList(items),
                  ),
          ),
        ],
      ),
    );
  }

  /// The resource list, with a native ad slotted in after every 5th item for
  /// non-premium users (an unloaded ad collapses to nothing, so there's no gap).
  Widget _buildList(List<Resource> items) {
    final showAds = AdConfig.enabled && !ref.watch(premiumProvider);
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      rows.add(Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: _ResourceCard(resource: items[i]).entrance(index: i),
      ));
      if (showAds && (i + 1) % 5 == 0 && i != items.length - 1) {
        rows.add(const NativeAdCard());
      }
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH, AppSpacing.md, AppSpacing.screenH, AppSpacing.huge),
      itemCount: rows.length,
      itemBuilder: (context, i) => rows[i],
    );
  }

  Widget _catChip(String label, bool selected, VoidCallback onTap) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            color: selected ? scheme.primary : scheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: selected ? scheme.primary : scheme.outline),
          ),
          child: Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : scheme.onSurface)),
        ),
      ),
    );
  }

  String _label(String c) => switch (c) {
        'dsa' => 'DSA',
        'core' => 'Core CS',
        'aptitude' => 'Aptitude',
        'system' => 'System Design',
        'webdev' => 'Web Dev',
        'interview' => 'Interview',
        'cp' => 'CP',
        _ => 'General',
      };
}

class _ResourceCard extends StatelessWidget {
  const _ResourceCard({required this.resource});
  final Resource resource;

  Future<void> _open(BuildContext context) async {
    final target =
        resource.affiliateUrl.isNotEmpty ? resource.affiliateUrl : resource.url;
    if (target.isEmpty) return;
    final uri = Uri.parse(target);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        await Clipboard.setData(ClipboardData(text: target));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Link copied to clipboard')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent =
        resource.tier == 'paid' ? AppPalette.warning : AppPalette.mint;
    return AppCard(
      onTap: () => _open(context),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(_typeIcon(resource.type), color: accent),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(resource.title,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                    ),
                    if (resource.provider.isNotEmpty)
                      Text(resource.provider,
                          style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
                if (resource.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(resource.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(Icons.open_in_new_rounded,
              size: 18, color: theme.colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}
