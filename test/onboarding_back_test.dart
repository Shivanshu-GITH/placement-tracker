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

  /// The Android back gesture, as the framework delivers it.
  Future<void> systemBack(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }

  ProviderContainer containerOf(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(OnboardingScreen)));

  /// PopScope is generic, so find.byType(PopScope) matches nothing. Take the
  /// nearest one wrapping the screen's Scaffold — ours.
  bool canPopOf(WidgetTester tester) {
    final finder = find.ancestor(
      of: find.byType(Scaffold),
      matching: find.byWidgetPredicate((w) => w is PopScope),
    );
    return ((tester.widgetList(finder).first) as PopScope).canPop;
  }

  testWidgets('system back on a later step returns to the previous one',
      (tester) async {
    // Onboarding is the root screen, so there is no route to pop: back used to
    // leave the app from ANY step, discarding everything entered so far.
    await pumpOnboarding(tester, guest: true);
    // Walk to the last step, where the button label changes.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Generate my roadmap'), findsOneWidget);
    expect(canPopOf(tester), isFalse,
        reason: 'back is handled in-app while there are steps behind');

    await systemBack(tester);

    expect(find.text('Generate my roadmap'), findsNothing,
        reason: 'back stepped to the previous page');
    expect(containerOf(tester).read(guestModeProvider), isTrue,
        reason: 'stepping back must not drop the guest session');
  });

  testWidgets('system back on step 1 as a guest returns to the welcome screen',
      (tester) async {
    await pumpOnboarding(tester, guest: true);

    await systemBack(tester);

    expect(containerOf(tester).read(guestModeProvider), isFalse,
        reason: 'same destination the back arrow reaches');
  });

  testWidgets('system back on step 1 leaves the app when not a guest',
      (tester) async {
    // Nothing sits behind onboarding for a signed-in user, so the gesture must
    // fall through to the platform rather than being swallowed.
    await pumpOnboarding(tester, guest: false);

    expect(canPopOf(tester), isTrue);
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
