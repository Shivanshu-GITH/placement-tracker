import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:in_app_update/in_app_update.dart';

/// Prompts users running an out-of-date build to update, via Google Play's
/// In-App Update API.
///
/// Uses IMMEDIATE mode: when a newer version is live on Play, Google shows a
/// full-screen, blocking update flow, so users can't keep running a stale build.
/// This matters because release-time flags (e.g. whether ads are on) are
/// compiled into each build — an old install would otherwise never pick them up.
///
/// No-ops safely everywhere the API isn't available: web, non-Android, and
/// builds not installed from the Play Store (debug / sideloaded), where the
/// platform call throws. Every failure is swallowed so it can never block or
/// crash launch.
class AppUpdateService {
  const AppUpdateService._();

  static bool _checked = false;

  /// Checks once per app session and triggers an immediate update when one is
  /// available. Safe to call unconditionally on every launch.
  static Future<void> maybePromptImmediateUpdate() async {
    if (_checked) return;
    _checked = true; // set before the first await so re-entrant calls no-op
    if (kIsWeb) return;
    try {
      if (!Platform.isAndroid) return; // Play In-App Updates is Android-only
    } catch (_) {
      return; // Platform unavailable — nothing to do
    }
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable &&
          info.immediateUpdateAllowed) {
        await InAppUpdate.performImmediateUpdate();
      }
    } catch (_) {
      // Not installed from Play (debug/sideloaded), offline, Play Services
      // missing, or the user dismissed the flow — never fatal.
    }
  }
}
