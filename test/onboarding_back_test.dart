import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preppilot/features/leaderboard/leaderboard_backend.dart';
import 'package:preppilot/features/onboarding/onboarding_screen.dart';
import 'package:preppilot/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A guest reaches onboarding from the welcome screen, so its back arrow has to
/// lead back there — otherwise "Continue as guest" is a one-way door and there
/// is no way to switch to "Continue with Google" short of reinstalling.
///
/// Users who did not come in as a guest have nothing behind onboarding, so for
/// them the arrow stays disabled on the first step. (Supabase is not configured
/// under test, so the non-guest case here is exercised as "not a guest" rather
/// than as a live Google session.)
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// Onboarding only reads these four providers while building; overriding them
  /// keeps the database (and Drift's isolate) out of the widget test.
  Future<void> pumpOnboarding(WidgetTester tester, {required bool guest}) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        guestModeProvider.overrideWith((ref) => guest),
        sheetsProvider.overrideWith((ref) => Stream.value(const [])),
        sheetEffortProvider.overrideWithValue(const {}),
        lbIdentityProvider
            .overrideWith((ref) async => const LbIdentity(name: 'You')),
      ],
      child: const MaterialApp(home: OnboardingScreen()),
    ));
    // The steps animate in (flutter_animate); settle so no timer outlives the
    // test.
    await tester.pumpAndSettle();
  }

  Finder backArrow() => find.byIcon(Icons.arrow_back_rounded);

  testWidgets('a guest can go back to the welcome screen from step 1',
      (tester) async {
    await pumpOnboarding(tester, guest: true);

    final button = tester.widget<IconButton>(
      find.ancestor(of: backArrow(), matching: find.byType(IconButton)),
    );
    expect(button.onPressed, isNotNull,
        reason: 'the arrow must be usable on the first step for a guest');

    await tester.tap(backArrow());
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(OnboardingScreen)),
    );
    expect(container.read(guestModeProvider), isFalse,
        reason: 'leaving guest mode is what routes back to the welcome screen');
    expect(container.read(sessionStateProvider), SessionState.needsAuth);
  });

  testWidgets('the arrow stays disabled on step 1 when not a guest',
      (tester) async {
    await pumpOnboarding(tester, guest: false);

    final button = tester.widget<IconButton>(
      find.ancestor(of: backArrow(), matching: find.byType(IconButton)),
    );
    expect(button.onPressed, isNull,
        reason: 'only a guest has the welcome screen behind them');
  });
}
