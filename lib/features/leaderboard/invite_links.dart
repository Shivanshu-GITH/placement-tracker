import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import 'coding_portfolio_screen.dart';

/// Handles `preppilot://follow/<uid>` invite links: follows the inviter and
/// opens their profile. If the user isn't signed in yet, the invite is stashed
/// and processed once they sign in.
class InviteLinks {
  InviteLinks(this._ref, this._navKey);
  final WidgetRef _ref;
  final GlobalKey<NavigatorState> _navKey;

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;
  String? _pending;

  Future<void> init() async {
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) _handle(initial);
    } catch (_) {}
    _sub = _appLinks.uriLinkStream.listen(_handle, onError: (_) {});
    // Process a stashed invite once the user signs in (listenManual works
    // outside build, unlike ref.listen).
    _ref.listenManual(authUserProvider, (_, next) {
      if (next.valueOrNull != null && _pending != null) {
        final uid = _pending!;
        _pending = null;
        _follow(uid);
      }
    });
  }

  void dispose() => _sub?.cancel();

  void _handle(Uri uri) {
    if (uri.scheme != 'preppilot' || uri.host != 'follow') return;
    final uid = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
    if (uid.isEmpty) return;
    final signedIn = _ref.read(authUserProvider).valueOrNull != null;
    if (!signedIn) {
      _pending = uid;
      return;
    }
    _follow(uid);
  }

  Future<void> _follow(String uid) async {
    final me = _ref.read(authUserProvider).valueOrNull?.id;
    final repo = _ref.read(leaderboardRepositoryProvider);
    if (uid != me) {
      try {
        await repo.follow(uid);
        _ref.invalidate(boardPoolProvider);
      } catch (_) {}
    }
    final nav = _navKey.currentState;
    if (nav == null || !nav.mounted) return;
    if (uid != me) {
      ScaffoldMessenger.maybeOf(nav.context)?.showSnackBar(
          const SnackBar(content: Text('You\'re now following your friend 🎉')));
    }
    nav.push(MaterialPageRoute(
        builder: (_) => CodingPortfolioScreen(userId: uid == me ? null : uid)));
  }
}
