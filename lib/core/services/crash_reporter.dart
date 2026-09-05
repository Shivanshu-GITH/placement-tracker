import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Wires up Firebase Crashlytics so production crashes are reported.
///
/// It is written to be completely inert until a Firebase project is connected:
/// `Firebase.initializeApp()` throws when there's no `google-services.json`
/// (see the conditional plugin apply in `android/app/build.gradle.kts`), and
/// that's caught here — the app runs exactly as before, just without reporting.
/// So the code can ship now and reporting switches on the moment the config is
/// added, with no further code changes.
///
/// To activate:
///   1. Create a Firebase project and an Android app with applicationId
///      `com.shivanshu.preppilot`.
///   2. Put its `google-services.json` in `android/app/`.
///   3. Rebuild. (`flutterfire configure` automates steps 1–2.)
class CrashReporter {
  CrashReporter._();
  static final CrashReporter instance = CrashReporter._();

  bool _active = false;
  bool get isActive => _active;

  /// Best-effort init. Never throws; safe to await unconditionally in main().
  Future<void> init() async {
    if (kIsWeb) return;
    try {
      if (!(Platform.isAndroid || Platform.isIOS)) return;
    } catch (_) {
      return; // platform unavailable (desktop/test) — nothing to do
    }
    try {
      await Firebase.initializeApp();
      final crashlytics = FirebaseCrashlytics.instance;
      // Only actually upload from release builds; debug crashes are noise.
      await crashlytics.setCrashlyticsCollectionEnabled(kReleaseMode);

      // Framework (build/layout/paint) errors.
      final priorOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        priorOnError?.call(details); // keep the red screen / console log
        crashlytics.recordFlutterFatalError(details);
      };

      // Uncaught async errors outside the framework.
      PlatformDispatcher.instance.onError = (error, stack) {
        crashlytics.recordError(error, stack, fatal: true);
        return true;
      };

      _active = true;
    } catch (_) {
      // No google-services.json (or Firebase unavailable) — reporting stays off.
    }
  }

  /// Manually report a caught, non-fatal error (no-op until active).
  Future<void> recordError(Object error, StackTrace? stack) async {
    if (!_active) return;
    try {
      await FirebaseCrashlytics.instance
          .recordError(error, stack, fatal: false);
    } catch (_) {}
  }
}
