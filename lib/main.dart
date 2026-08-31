import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/services/notification_service.dart';
import 'features/ads/ad_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
