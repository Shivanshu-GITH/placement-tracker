import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preppilot/data/database/database.dart';
import 'package:preppilot/features/tracker/company_tags.dart';
import 'package:preppilot/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// "By company" used to read the ACTIVE sheets. Company tags live on only two
/// of the seventeen sheets (Apna College and Arsh Goyal) and neither is active
/// by default, so the screen was empty for almost every user, and the list of
/// employers grew and shrank as sheets were toggled.
///
/// It now reads a catalogue-wide pool, deduplicated by canon, with the imported
/// tag damage repaired on the way through.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('tag repair', () {
    test('rejoins employers the importer split on whitespace', () {
      // The halves always co-occur, so a Set collapses them to one name.
      expect(CompanyTags.parse('goldman,sachs'), {'Goldman Sachs'});
      expect(CompanyTags.parse('morgan,stanley'), {'Morgan Stanley'});
      expect(CompanyTags.parse('maq,software'), {'MAQ Software'});
      expect(CompanyTags.parse('ola,cabs'), {'Ola'});
      expect(CompanyTags.parse('oyo,rooms'), {'OYO'});
      expect(CompanyTags.parse('juniper,networks'), {'Juniper Networks'});
      expect(CompanyTags.parse('times,internet'), {'Times Internet'});
      expect(CompanyTags.parse('american,express'), {'American Express'});
      expect(CompanyTags.parse('now,service'), {'ServiceNow'});
    });

    test('keeps an already-intact multi-word name as one company', () {
      expect(CompanyTags.parse('goldman sachs'), {'Goldman Sachs'});
    });

    test('splits rows that use a non-breaking space as the separator', () {
      // Written as escapes so the separator stays visible in the source.
      expect(
          CompanyTags.parse(
              'amazon\u00a0cisco\u00a0hike\u00a0oyo'),
          {'Amazon', 'Cisco', 'Hike', 'OYO'});
    });

    test('drops tags that were never employers', () {
      expect(CompanyTags.parse('interview,qs'), isEmpty);
      expect(CompanyTags.parse('arrays,dynamic,programming'), isEmpty);
      expect(CompanyTags.parse('facebook,interview,microsoft,qs'),
          {'Facebook', 'Microsoft'});
    });

    test('folds typos and stray plus marks into the real name', () {
      expect(CompanyTags.parse('amazoon'), {'Amazon'});
      expect(CompanyTags.parse('amaxon'), {'Amazon'});
      expect(CompanyTags.parse('micorsoft'), {'Microsoft'});
      expect(CompanyTags.parse('samsung+'), {'Samsung'});
      expect(CompanyTags.parse('+atlassian'), {'Atlassian'});
      expect(CompanyTags.parse('amazon+,amazon'), {'Amazon'});
    });

    test('uses the accepted spelling rather than blind title case', () {
      expect(CompanyTags.parse('makemytrip'), {'MakeMyTrip'});
      expect(CompanyTags.parse('vmware'), {'VMware'});
      expect(CompanyTags.parse('ebay'), {'eBay'});
      expect(CompanyTags.parse('d-e-shaw'), {'D. E. Shaw'});
    });

    test('an empty or blank value yields nothing', () {
      expect(CompanyTags.parse(''), isEmpty);
      expect(CompanyTags.parse(' , , '), isEmpty);
    });
  });

  group('the pool over the real catalogue', () {
    late AppDatabase db;
    late ProviderContainer c;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      db = AppDatabase.forTesting(NativeDatabase.memory());
      c = ProviderContainer(overrides: [
        databaseProvider.overrideWith((ref) {
          ref.watch(dbKeyProvider);
          return db;
        }),
      ]);
      addTearDown(c.dispose);
      addTearDown(db.close);
      // The pool reads leafRows, which reads the node and progress STREAMS.
      // Without a listener they never subscribe, so the pool would be empty for
      // want of data rather than for want of the fix.
      c.listen(sheetsProvider, (_, _) {});
      c.listen(userSheetsProvider, (_, _) {});
      c.listen(leafRowsProvider, (_, _) {});
      await c.read(bootstrapProvider.future);
      for (var i = 0; i < 40; i++) {
        await Future<void>.delayed(Duration.zero);
      }
    });

    test('is populated even though no company-tagged sheet is active',
        () async {
      final active = c.read(activeSheetIdsProvider);
      final sheetsById = c.read(sheetsByIdProvider);
      final activeSlugs =
          active.map((id) => sheetsById[id]?.slug).whereType<String>().toSet();
      expect(activeSlugs, isNotEmpty, reason: 'the default selection exists');
      expect(activeSlugs.contains('apna-college'), isFalse);
      expect(activeSlugs.contains('arsh-goyal'), isFalse,
          reason: 'neither tagged sheet is on by default — that was the bug');

      final counts = c.read(companyCountsProvider);
      expect(counts, isNotEmpty,
          reason: 'company prep must not depend on the sheet selection');
      expect(counts['Amazon'], greaterThan(100));
      expect(counts['Microsoft'], greaterThan(100));
      expect(counts['Goldman Sachs'], greaterThan(50));
    });

    test('lists no repaired fragment or non-employer as a company', () {
      final names = c.read(companyCountsProvider).keys.toSet();
      for (final ghost in [
        'Sachs', 'Goldman', 'Stanley', 'Morgan', 'Rooms', 'Software',
        'Cabs', 'Interview', 'Qs', 'Programming', 'Systems', 'Labs',
      ]) {
        expect(names.contains(ghost), isFalse, reason: '$ghost is not a company');
      }
    });

    test('each problem appears once per company despite being in both sheets',
        () {
      final pool = c.read(companyPoolProvider);
      for (final entry in pool.entries) {
        final canons = entry.value.map((r) => r.canon).toList();
        expect(canons.length, canons.toSet().length,
            reason: '${entry.key} lists the same problem twice');
      }
    });

    /// Tags for a problem, gathered from EVERY sheet that carries it.
    Map<String, Set<String>> tagsByCanon() {
      final m = <String, Set<String>>{};
      for (final r in c.read(leafRowsProvider)) {
        if (r.node.companies.isEmpty) continue;
        m
            .putIfAbsent(r.canon, () => <String>{})
            .addAll(CompanyTags.parse(r.node.companies));
      }
      return m;
    }

    test('every pooled problem is filed under a tag one of its sheets gave it',
        () {
      final pool = c.read(companyPoolProvider);
      final tags = tagsByCanon();
      for (final entry in pool.entries) {
        for (final row in entry.value) {
          expect(tags[row.canon], contains(entry.key),
              reason: '${row.canon} is filed under ${entry.key}');
        }
      }
    });

    test('a problem in both sheets keeps the companies from both', () {
      // The two sheets tag the same question differently, so deduplicating on
      // canon must UNION the tags rather than keep whichever sheet was read
      // first — otherwise merging the sheets silently loses companies.
      final rowsByCanon = <String, List<Set<String>>>{};
      for (final r in c.read(leafRowsProvider)) {
        if (r.node.companies.isEmpty) continue;
        rowsByCanon
            .putIfAbsent(r.canon, () => [])
            .add(CompanyTags.parse(r.node.companies));
      }
      final shared = rowsByCanon.entries.where((e) =>
          e.value.length > 1 &&
          e.value.first.difference(e.value.last).isNotEmpty);
      expect(shared, isNotEmpty,
          reason: 'the catalogue really does disagree across sheets');

      final pool = c.read(companyPoolProvider);
      final entry = shared.first;
      final union = entry.value.reduce((a, b) => {...a, ...b});
      for (final company in union) {
        expect(pool[company]?.map((r) => r.canon), contains(entry.key),
            reason: '${entry.key} lost $company when the sheets were merged');
      }
    });

    test('the pool holds only problems, all with a resolvable link', () {
      final pool = c.read(companyPoolProvider);
      final all = {for (final l in pool.values) for (final r in l) r.canon: r};
      expect(all.length, greaterThan(400));
      for (final row in all.values) {
        expect(row.isConcept, isFalse, reason: '${row.canon} is not a problem');
        expect(row.node.url, isNotEmpty, reason: '${row.canon} has no link');
      }
    });
  });
}
