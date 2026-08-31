import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preppilot/core/theme/app_theme.dart';
import 'package:preppilot/core/widgets/app_card.dart';
import 'package:preppilot/core/widgets/empty_state.dart';
import 'package:preppilot/core/widgets/filter_bar.dart';
import 'package:preppilot/core/widgets/pill.dart';
import 'package:preppilot/core/widgets/progress_ring.dart';
import 'package:preppilot/core/widgets/section_header.dart';

/// Device shapes the app has to survive: a small budget phone, a typical phone,
/// a large phone and a tablet.
const _sizes = <String, Size>{
  'small phone': Size(320, 640),
  'typical phone': Size(411, 891),
  'large phone': Size(480, 1000),
  'tablet': Size(800, 1280),
};

/// System font scales, including the large accessibility settings that are the
/// usual cause of overflow.
const _textScales = <double>[1.0, 1.3, 2.0];

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  required Size size,
  required double textScale,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: size,
        textScaler: TextScaler.linear(textScale),
      ),
      child: MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: child),
      ),
    ),
  );
}

void main() {
  group('adaptive layout', () {
    // A representative slice of the shared building blocks every screen is
    // assembled from. If these survive every size x font-scale combination,
    // the screens built out of them do too.
    final cases = <String, Widget Function()>{
      'filter chip bar': () => FilterChipBar(
            children: [
              for (final label in [
                'All',
                'DSA',
                'Core CS',
                'Competitive Prog',
                'Aptitude & Reasoning',
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Chip(label: Text(label)),
                ),
            ],
          ),
      'scrolled-under header': () => const ScrolledUnderHeader(
            scrolled: true,
            child: SectionHeader(
              title: "Today's plan",
              subtitle: '0/13 done',
              icon: Icons.today_rounded,
            ),
          ),
      'card with long text': () => const AppCard(
            child: Row(
              children: [
                ProgressRing(value: 0.42, size: 62, strokeWidth: 7),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Striver A2Z DSA Course'),
                      Text(
                        'The complete A-to-Z path in learning order: steps, '
                        'patterns and problems.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
      // Pills must reflow rather than sit in a fixed Row — two of them stop
      // fitting side by side on a narrow phone once the font scales up.
      'pill group': () => const Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              Pill(label: '120/455 done', color: Colors.indigo, dense: true),
              Pill(label: '12 revisit', color: Colors.teal, dense: true),
            ],
          ),
      'empty state': () => const EmptyState(
            icon: Icons.flag_rounded,
            title: 'No subjects to plan yet',
            message:
                'Activate the sheets you want to prepare in My Sheets, then set '
                'a target date to get per-subject deadlines and daily targets.',
          ),
    };

    for (final entry in cases.entries) {
      for (final sizeEntry in _sizes.entries) {
        for (final scale in _textScales) {
          testWidgets(
            '${entry.key} fits on ${sizeEntry.key} at ${scale}x text',
            (tester) async {
              await _pump(
                tester,
                entry.value(),
                size: sizeEntry.value,
                textScale: scale,
              );
              // A RenderFlex/RenderBox overflow reports as an exception in
              // tests, so this asserts the layout genuinely fits.
              expect(tester.takeException(), isNull);
            },
          );
        }
      }
    }
  });
}
