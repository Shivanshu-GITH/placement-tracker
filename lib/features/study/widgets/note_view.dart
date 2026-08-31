import 'package:flutter/material.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_palette.dart';
import '../study_models.dart';

/// Renders a list of [NoteBlock]s as fully themed, consistent widgets.
///
/// Text fields support two inline markers: `**bold**` and `` `code` ``.
class NoteView extends StatelessWidget {
  const NoteView({super.key, required this.blocks});
  final List<NoteBlock> blocks;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final b in blocks)
          Padding(
            padding: EdgeInsets.only(bottom: _gapAfter(b.type)),
            child: _block(context, b),
          ),
      ],
    );
  }

  double _gapAfter(BlockType t) =>
      t == BlockType.heading ? AppSpacing.sm : AppSpacing.lg;

  Widget _block(BuildContext context, NoteBlock b) {
    switch (b.type) {
      case BlockType.heading:
        return _Heading(text: b.text);
      case BlockType.paragraph:
        return _Paragraph(text: b.text);
      case BlockType.points:
        return _BulletList(items: b.items, numbered: false);
      case BlockType.steps:
        return _BulletList(items: b.items, numbered: true);
      case BlockType.code:
        return _CodeBlock(code: b.text, lang: b.lang);
      case BlockType.table:
        return _NoteTable(headers: b.headers, rows: b.rows);
      case BlockType.callout:
        return _Callout(style: b.calloutStyle, title: b.title, text: b.text);
    }
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 4,
            height: 18,
            margin: const EdgeInsets.only(right: AppSpacing.sm),
            decoration: BoxDecoration(
              gradient: AppPalette.brandGradient,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text.rich(
      _inline(context, text,
          base: theme.textTheme.bodyMedium!.copyWith(height: 1.5)),
    );
  }
}

class _BulletList extends StatelessWidget {
  const _BulletList({required this.items, required this.numbered});
  final List<String> items;
  final bool numbered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.textTheme.bodyMedium!.copyWith(height: 1.45);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 1, right: AppSpacing.sm),
                  width: numbered ? 20 : 18,
                  alignment: Alignment.centerLeft,
                  child: numbered
                      ? Text('${i + 1}.',
                          style: base.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppPalette.indigo))
                      : Icon(Icons.circle,
                          size: 6, color: theme.colorScheme.primary),
                ),
                Expanded(child: Text.rich(_inline(context, items[i], base: base))),
              ],
            ),
          ),
      ],
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.code, required this.lang});
  final String code;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final bg = dark ? const Color(0xFF12121C) : const Color(0xFF1B1B29);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (lang.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
              child: Text(lang.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1)),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              code,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontFamilyFallback: ['Courier New', 'monospace'],
                color: Color(0xFFE6E6F0),
                fontSize: 12.5,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteTable extends StatelessWidget {
  const _NoteTable({required this.headers, required this.rows});
  final List<String> headers;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = theme.colorScheme.outline.withValues(alpha: 0.6);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 2 * AppSpacing.screenH),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: border),
          ),
          child: Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            border: TableBorder(
              horizontalInside: BorderSide(color: border),
              verticalInside: BorderSide(color: border),
            ),
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
                children: [
                  for (final h in headers) _cell(context, h, header: true),
                ],
              ),
              for (final r in rows)
                TableRow(children: [
                  for (var c = 0; c < headers.length; c++)
                    _cell(context, c < r.length ? r[c] : ''),
                ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cell(BuildContext context, String text, {bool header = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Text.rich(
        _inline(context, text,
            base: theme.textTheme.bodySmall!.copyWith(
                height: 1.4,
                fontWeight: header ? FontWeight.w800 : FontWeight.w400)),
      ),
    );
  }
}

class _Callout extends StatelessWidget {
  const _Callout(
      {required this.style, required this.title, required this.text});
  final CalloutStyle style;
  final String title;
  final String text;

  ({Color color, IconData icon, String fallbackTitle}) get _spec {
    switch (style) {
      case CalloutStyle.warn:
        return (
          color: AppPalette.warning,
          icon: Icons.warning_amber_rounded,
          fallbackTitle: 'Watch out'
        );
      case CalloutStyle.info:
        return (
          color: AppPalette.info,
          icon: Icons.info_outline_rounded,
          fallbackTitle: 'Note'
        );
      case CalloutStyle.key:
        return (
          color: AppPalette.indigo,
          icon: Icons.vpn_key_rounded,
          fallbackTitle: 'Key idea'
        );
      case CalloutStyle.tip:
        return (
          color: AppPalette.mint,
          icon: Icons.lightbulb_outline_rounded,
          fallbackTitle: 'Interview tip'
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = _spec;
    final head = title.isEmpty ? s.fallbackTitle : title;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: s.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border(left: BorderSide(color: s.color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(s.icon, size: 16, color: s.color),
              const SizedBox(width: 6),
              Text(head,
                  style: theme.textTheme.labelMedium?.copyWith(
                      color: s.color, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 6),
          Text.rich(_inline(context, text,
              base: theme.textTheme.bodySmall!.copyWith(height: 1.45))),
        ],
      ),
    );
  }
}

/// Parses `**bold**` and `` `code` `` inside [text] into styled spans.
TextSpan _inline(BuildContext context, String text, {required TextStyle base}) {
  final theme = Theme.of(context);
  final spans = <TextSpan>[];
  final pattern = RegExp(r'\*\*(.+?)\*\*|`(.+?)`');
  var index = 0;
  for (final m in pattern.allMatches(text)) {
    if (m.start > index) {
      spans.add(TextSpan(text: text.substring(index, m.start), style: base));
    }
    if (m.group(1) != null) {
      spans.add(TextSpan(
          text: m.group(1),
          style: base.copyWith(fontWeight: FontWeight.w800)));
    } else if (m.group(2) != null) {
      spans.add(TextSpan(
        text: m.group(2),
        style: base.copyWith(
          fontFamily: 'monospace',
          fontFamilyFallback: const ['Courier New', 'monospace'],
          color: AppPalette.indigo,
          backgroundColor: theme.colorScheme.surfaceContainerHighest
              .withValues(alpha: 0.6),
          fontSize: (base.fontSize ?? 14) - 0.5,
        ),
      ));
    }
    index = m.end;
  }
  if (index < text.length) {
    spans.add(TextSpan(text: text.substring(index), style: base));
  }
  return TextSpan(children: spans);
}
