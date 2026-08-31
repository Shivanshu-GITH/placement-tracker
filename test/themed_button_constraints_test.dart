import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:preppilot/core/theme/app_theme.dart';

/// The app theme gives FilledButton/OutlinedButton `minimumSize:
/// Size.fromHeight(54)`, which is `Size(double.infinity, 54)` — an infinite
/// *minimum width*. Those buttons therefore only lay out where the incoming
/// width is bounded. A Flex gives its non-flex children unbounded space on the
/// main axis, so a themed button dropped straight into a Row throws
/// "BoxConstraints forces an infinite width" and its whole subtree renders
/// blank — which is what made the Add-project sheet come up empty.
void main() {
  Widget host(Widget child) => MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: Center(child: child)),
      );

  group('themed buttons and unbounded width', () {
    testWidgets('themed FilledButton in a bare Row throws infinite width',
        (tester) async {
      // A single bad layout cascades into follow-on "was not laid out" errors,
      // which the binding collapses into one opaque summary. Capture the real
      // messages ourselves instead.
      final errors = <String>[];
      final previous = FlutterError.onError;
      FlutterError.onError = (details) => errors.add(details.exceptionAsString());
      await tester.pumpWidget(host(
        Row(children: [
          const Spacer(),
          FilledButton(onPressed: () {}, child: const Text('Save')),
        ]),
      ));
      FlutterError.onError = previous;

      expect(errors, isNotEmpty);
      expect(errors.first, contains('infinite width'));
    });

    testWidgets('as a stretch-column child it lays out (the fix)',
        (tester) async {
      await tester.pumpWidget(host(
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton(onPressed: () {}, child: const Text('Save')),
          ],
        ),
      ));

      expect(tester.takeException(), isNull);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('wrapping in Expanded also bounds it', (tester) async {
      await tester.pumpWidget(host(
        Row(children: [
          const Spacer(),
          Expanded(
            child: FilledButton(onPressed: () {}, child: const Text('Save')),
          ),
        ]),
      ));

      expect(tester.takeException(), isNull);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('a finite minimumSize override makes a Row child safe',
        (tester) async {
      await tester.pumpWidget(host(
        Row(children: [
          const Spacer(),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
            child: const Text('Save'),
          ),
        ]),
      ));

      expect(tester.takeException(), isNull);
      expect(find.text('Save'), findsOneWidget);
    });
  });
}
