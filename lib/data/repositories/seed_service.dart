import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../database/database.dart';

/// Loads nested content packs (assets/content/v2/) into the generic node tree.
/// Idempotent: skips when already seeded. Also sets a sensible default sheet
/// selection the user can change later in Profile.
class SeedService {
  SeedService(this._db);
  final AppDatabase _db;

  /// Sheets active by default for a brand-new user (editable in Profile).
  static const _defaultActive = {
    'striver-a2z', 'dsa-patterns', 'core-os', 'core-dbms', 'core-cn',
    'core-oop', 'aptitude', 'system-design', 'interview-hr', 'web-dev',
  };
  static const _defaultPrimary = 'striver-a2z';

  Future<void> ensureSeeded() async {
    final indexRaw = await rootBundle.loadString('assets/content/index_v2.json');
    final files =
        ((json.decode(indexRaw) as Map<String, dynamic>)['sheets'] as List)
            .cast<String>();

    final existing = await _db.sheets.count().getSingle();
    if (existing >= files.length) {
      await _ensureProfile();
      await _ensureResources();
      return;
    }

    for (var s = 0; s < files.length; s++) {
      final raw = await rootBundle.loadString('assets/content/${files[s]}');
      await _seedSheet(json.decode(raw) as Map<String, dynamic>, s);
    }
    await _seedDefaultSelection();
    await _ensureProfile();
    await _ensureResources();
  }

  Future<void> _ensureResources() async {
    final raw = await rootBundle.loadString('assets/content/resources.json');
    final list =
        (json.decode(raw) as Map<String, dynamic>)['resources'] as List;
    // Idempotent: insert only resources whose slug isn't already present, so
    // resources added in an app update reach existing users too.
    final existing =
        (await _db.select(_db.resources).get()).map((r) => r.slug).toSet();
    final toAdd = <ResourcesCompanion>[];
    for (var i = 0; i < list.length; i++) {
      final r = list[i] as Map<String, dynamic>;
      final slug = r['slug'] as String;
      if (existing.contains(slug)) continue;
      toAdd.add(ResourcesCompanion.insert(
        slug: slug,
        title: r['title'] as String,
        provider: Value((r['provider'] ?? '') as String),
        description: Value((r['description'] ?? '') as String),
        url: Value((r['url'] ?? '') as String),
        affiliateUrl: Value((r['affiliateUrl'] ?? '') as String),
        type: Value((r['type'] ?? 'link') as String),
        category: Value((r['category'] ?? 'general') as String),
        tier: Value((r['tier'] ?? 'free') as String),
        orderIndex: Value(i),
      ));
    }
    if (toAdd.isNotEmpty) {
      await _db.batch((b) => b.insertAll(_db.resources, toAdd));
    }
  }

  Future<void> _seedSheet(Map<String, dynamic> sheet, int order) async {
    await _db.transaction(() async {
      final slug = sheet['slug'] as String;
      final exists = await (_db.select(_db.sheets)
            ..where((t) => t.slug.equals(slug)))
          .getSingleOrNull();
      if (exists != null) return;

      final sheetId = await _db.into(_db.sheets).insert(
            SheetsCompanion.insert(
              slug: slug,
              title: sheet['title'] as String,
              category: sheet['category'] as String,
              description: Value((sheet['description'] ?? '') as String),
              source: Value((sheet['source'] ?? '') as String),
              orderIndex: Value(order),
            ),
          );

      NodesCompanion companion(
              Map<String, dynamic> n, int? parentId, int depth, int order,
              {required bool isLeaf}) =>
          NodesCompanion.insert(
            sheetId: sheetId,
            parentId: Value(parentId),
            slug: n['slug'] as String,
            title: n['title'] as String,
            kind: Value(isLeaf ? 'leaf' : 'section'),
            leafType: Value((n['leafType'] ?? 'problem') as String),
            difficulty: Value((n['difficulty'] ?? 'medium') as String),
            url: Value((n['url'] ?? '') as String),
            platform: Value((n['platform'] ?? '') as String),
            resourceUrl: Value((n['resourceUrl'] ?? '') as String),
            tags: Value((n['tags'] ?? '') as String),
            companies: Value((n['companies'] ?? '') as String),
            canon: Value((n['canon'] ?? '') as String),
            depth: Value(depth),
            orderIndex: Value(order),
          );

      // Insert sections one-by-one (need their ids for children); batch sibling
      // leaves for speed.
      Future<void> insertNodes(
          List<dynamic> items, int? parentId, int depth) async {
        final leaves = <NodesCompanion>[];
        for (var i = 0; i < items.length; i++) {
          final n = items[i] as Map<String, dynamic>;
          if (n['leaf'] == true) {
            leaves.add(companion(n, parentId, depth, i, isLeaf: true));
          } else {
            final id = await _db
                .into(_db.nodes)
                .insert(companion(n, parentId, depth, i, isLeaf: false));
            if (n['children'] is List) {
              await insertNodes(n['children'] as List, id, depth + 1);
            }
          }
        }
        if (leaves.isNotEmpty) {
          await _db.batch((b) => b.insertAll(_db.nodes, leaves));
        }
      }

      await insertNodes(sheet['tree'] as List, null, 0);
    });
  }

  Future<void> _seedDefaultSelection() async {
    final sheets = await _db.select(_db.sheets).get();
    for (final s in sheets) {
      await _db.into(_db.userSheets).insert(
            UserSheetsCompanion.insert(
              sheetId: Value(s.id),
              active: Value(_defaultActive.contains(s.slug)),
              isPrimary: Value(s.slug == _defaultPrimary),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }

  Future<void> _ensureProfile() async {
    final count = await _db.userProfiles.count().getSingle();
    if (count == 0) {
      await _db.into(_db.userProfiles).insert(const UserProfilesCompanion());
    }
  }
}
