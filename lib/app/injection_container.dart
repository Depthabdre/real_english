// app/injection_container.dart

import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:real_english/app/app_router.dart';
import 'package:real_english/core/network/network_info.dart';
import 'package:real_english/feature/auth_onboarding/presentation/bloc/auth_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Feature Injection Imports ---
import '../feature/auth_onboarding/auth_injection.dart' as auth_di;
import '../feature/StoryTrails/story_trails_injection.dart' as story_trails_di;
import '../feature/daily_immersion/immersion_injection.dart' as immersion_di;
import '../feature/profile/profile_injection.dart'
    as profile_di; // <--- NEW IMPORT

final sl = GetIt.instance;

Future<void> init() async {
  // --- App Level Dependencies ---

  // Register AppRouter (Singleton)
  sl.registerLazySingleton<AppRouter>(() => AppRouter(sl<AuthBloc>()));

  // 1. Register Network Info
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(InternetConnection()),
  );

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Register HTTP Client globally if not done elsewhere
  // (Optional, as features often register it themselves if missing)
  // sl.registerLazySingleton(() => http.Client());

  // --- Features Initialization ---

  // 1. Auth (Must be first because others need the Token)
  await auth_di.initAuthFeature();

  // 2. Story Trails
  await story_trails_di.initStoryTrailsFeature();

  // 3. Daily Immersion (Shorts)
  await immersion_di.initImmersionFeature();

  // 4. Profile (Growth Garden) --- NEW LINE ---
  await profile_di.initProfileFeature();
}
