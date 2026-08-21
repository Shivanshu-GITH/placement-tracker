import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preppilot/core/theme/app_theme.dart';
import 'package:preppilot/core/widgets/pill.dart';

void main() {
  test('themes build for both brightnesses', () {
    expect(AppTheme.light().brightness, Brightness.light);
    expect(AppTheme.dark().brightness, Brightness.dark);
  });

  testWidgets('Pill renders its label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: Pill(label: 'Easy', color: Colors.green),
        ),
      ),
    );
    expect(find.text('Easy'), findsOneWidget);
  });
}
