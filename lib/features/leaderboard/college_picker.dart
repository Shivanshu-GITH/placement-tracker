import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// One engineering college: display name + location. [value] is the canonical
/// string stored for the leaderboard — identical for every student at the same
/// college, and unique across colleges (name + district + state).
class College {
  const College(this.name, this.city, this.state);
  final String name;
  final String city;
  final String state;

  String get sub => [city, state].where((e) => e.isNotEmpty).join(', ');
  String get value => [name, city, state].where((e) => e.isNotEmpty).join(', ');
  String get _search => '$name $city $state'.toLowerCase();
}

/// Loads and caches the bundled canonical list of Indian engineering colleges.
/// Using a fixed list (rather than free text) keeps the college leaderboard
/// coherent: every student at one college stores the exact same string.
class CollegeDirectory {
  CollegeDirectory._();
  static List<College>? _cache;

  static Future<List<College>> load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/content/colleges.json');
    final list = (jsonDecode(raw) as List)
        .map((e) => College(
              (e['n'] ?? '') as String,
              (e['c'] ?? '') as String,
              (e['s'] ?? '') as String,
            ))
        .toList();
    _cache = list;
    return list;
  }
}

/// Opens a searchable college picker. Returns the chosen canonical name, an
/// empty string if the user cleared the selection, or null if dismissed.
Future<String?> showCollegePicker(BuildContext context,
    {String? current}) async {
  final all = await CollegeDirectory.load();
  if (!context.mounted) return null;
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => _CollegePickerSheet(all: all, current: current),
  );
}

class _CollegePickerSheet extends StatefulWidget {
  const _CollegePickerSheet({required this.all, this.current});
  final List<College> all;
  final String? current;

  @override
  State<_CollegePickerSheet> createState() => _CollegePickerSheetState();
}

class _CollegePickerSheetState extends State<_CollegePickerSheet> {
  final _searchCtl = TextEditingController();
  late List<College> _filtered = widget.all;

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  void _onQuery(String q) {
    final query = q.trim().toLowerCase();
    setState(() {
      _filtered = query.isEmpty
          ? widget.all
          : widget.all
              .where((c) => c._search.contains(query))
              .toList(growable: false);
    });
  }

  Future<void> _enterManually() async {
    final ctl = TextEditingController(text: _searchCtl.text.trim());
    final String? typed;
    try {
      typed = await showDialog<String>(
        context: context,
        builder: (dctx) => AlertDialog(
          title: const Text('Enter your college'),
          content: TextField(
            controller: ctl,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration:
                const InputDecoration(hintText: 'College / University name'),
            onSubmitted: (v) => Navigator.pop(dctx, v.trim()),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dctx),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(dctx, ctl.text.trim()),
                child: const Text('Use this')),
          ],
        ),
      );
    } finally {
      ctl.dispose();
    }
    if (typed != null && typed.isNotEmpty && mounted) {
      Navigator.pop(context, typed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: SizedBox(
        height: media.size.height * 0.75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _searchCtl,
                autofocus: true,
                onChanged: _onQuery,
                decoration: InputDecoration(
                  hintText: 'Search your college…',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            // "Not listed" + clear-selection row.
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: _enterManually,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('My college isn\'t listed'),
                  ),
                ),
                if (widget.current != null && widget.current!.isNotEmpty)
                  TextButton(
                    onPressed: () => Navigator.pop(context, ''),
                    child: const Text('Clear'),
                  ),
              ],
            ),
            const Divider(height: 1),
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No match. Tap “My college isn\'t listed” to add it.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filtered.length,
                      itemBuilder: (c, i) {
                        final college = _filtered[i];
                        final selected = college.value == widget.current;
                        return ListTile(
                          dense: true,
                          title: Text(college.name),
                          subtitle:
                              college.sub.isEmpty ? null : Text(college.sub),
                          trailing: selected
                              ? Icon(Icons.check,
                                  color: theme.colorScheme.primary)
                              : null,
                          onTap: () => Navigator.pop(context, college.value),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
