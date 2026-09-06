import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preppilot/features/planner/planner_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The pace overrides load from shared_preferences asynchronously while the
/// notifier's state starts EMPTY. A pace set inside that window used to be
/// written on top of the empty map — persisting `{thisSlug: pace}` and wiping
/// every other subject's pinned pace — and was then itself overwritten when the
/// load finally landed. Either way the user's paces silently changed under
/// them, which looks exactly like the planner inventing its own numbers.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const key = 'planner_paces_v1';

  ProviderContainer containerWith(Map<String, int> stored) {
    SharedPreferences.setMockInitialValues({key: json.encode(stored)});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    return c;
  }

  Future<Map<String, dynamic>> persisted() async {
    final p = await SharedPreferences.getInstance();
    return json.decode(p.getString(key)!) as Map<String, dynamic>;
  }

  test('a pace set before the store has loaded keeps the other paces', () async {
    final c = containerWith({'dsa': 3, 'os': 5});
    final notifier = c.read(plannerSettingsProvider.notifier);

    // No await between build() and the write: the load is still in flight.
    await notifier.setPace('apt', 2);

    expect(c.read(plannerSettingsProvider), {'dsa': 3, 'os': 5, 'apt': 2});
    expect(await persisted(), {'dsa': 3, 'os': 5, 'apt': 2},
        reason: 'the other subjects must survive on disk too');
  });

  test('a pace set before the load is not overwritten by it', () async {
    final c = containerWith({'dsa': 3});
    final notifier = c.read(plannerSettingsProvider.notifier);

    await notifier.setPace('dsa', 9); // the user changes it immediately
    // Give any in-flight load every chance to land on top of the new value.
    for (var i = 0; i < 20; i++) {
      await Future<void>.delayed(Duration.zero);
    }

    expect(c.read(plannerSettingsProvider)['dsa'], 9,
        reason: 'the newer value the user chose wins');
    expect((await persisted())['dsa'], 9);
  });

  test('clearing a pace before the load removes only that one', () async {
    final c = containerWith({'dsa': 3, 'os': 5});
    final notifier = c.read(plannerSettingsProvider.notifier);

    await notifier.clearPace('dsa');

    expect(c.read(plannerSettingsProvider), {'os': 5});
    expect(await persisted(), {'os': 5});
  });

  test('stored paces are readable once loaded', () async {
    final c = containerWith({'dsa': 3, 'os': 5});
    c.read(plannerSettingsProvider); // trigger build + load
    for (var i = 0; i < 20; i++) {
      await Future<void>.delayed(Duration.zero);
    }
    expect(c.read(plannerSettingsProvider), {'dsa': 3, 'os': 5});
  });

  test('a pace below 1 clears the override rather than pinning zero', () async {
    final c = containerWith({'dsa': 3});
    await c.read(plannerSettingsProvider.notifier).setPace('dsa', 0);
    expect(c.read(plannerSettingsProvider).containsKey('dsa'), isFalse);
  });
}
