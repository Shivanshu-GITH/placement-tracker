import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/services/crash_reporter.dart';
import 'core/services/notification_service.dart';
import 'features/ads/ad_service.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // Keep the OS launch screen up until _AppRoot knows whether to show
  // onboarding or the shell. Without this it disappears on Flutter's first
  // frame, which is why a second in-app splash used to appear behind it.
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  // Crash reporting first, so failures in the inits below are captured too.
  // Inert until a Firebase google-services.json is added (see CrashReporter).
  await CrashReporter.instance.init();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Initialize the leaderboard backend (safe to skip if unreachable/offline).
  if (AppConfig.hasSupabase) {
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        publishableKey: AppConfig.supabaseAnonKey,
      );
    } catch (_) {}
  }
  // Initialize local notifications (offline; safe to ignore failures).
  try {
    await NotificationService.instance.init();
  } catch (_) {}
  // Initialize AdMob (no-op off-device; never blocks startup).
  await AdService.instance.init();
  runApp(const ProviderScope(child: PrepPilotApp()));
}
