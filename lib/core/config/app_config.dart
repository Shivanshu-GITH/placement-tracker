/// App-wide configuration. The Supabase URL + publishable/anon key are public
/// by design (client-side access is guarded by Row-Level Security), so they are
/// safe to ship in the app.
class AppConfig {
  AppConfig._();

  static const String supabaseUrl = 'https://woiqebmvjqglblflfjcz.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_mGWNIi3VmVvKid2uxb-pnw_vK3u4EaI';

  /// Google OAuth Web client id (used as the serverClientId for native Google
  /// Sign-In; also registered in Supabase's Google provider allowed client IDs).
  static const String googleServerClientId =
      '659178440289-utjo4hcalaclg8rpf3vcrii6p84fnso5.apps.googleusercontent.com';

  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
