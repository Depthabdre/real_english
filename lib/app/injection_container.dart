// app/injection_container.dart

import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:real_english/app/app_router.dart';
import 'package:real_english/core/network/network_info.dart';
import 'package:real_english/feature/auth_onboarding/presentation/bloc/auth_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../feature/auth_onboarding/auth_injection.dart' as auth_di;
// --- ADD THIS IMPORT ---
import '../feature/StoryTrails/story_trails_injection.dart' as story_trails_di;

final sl = GetIt.instance;

Future<void> init() async {
  // --- App Level Dependencies ---
  // app/injection_container.dart

  // Register AppRouter (Singleton)
  sl.registerLazySingleton<AppRouter>(() => AppRouter(sl<AuthBloc>()));
  // 1. Register Network Info
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(InternetConnection()),
  );

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // --- Features ---
  // Initialize all your features here. The order can matter if one
  // feature's registration depends on another's (like ours does).
  // Initialize Auth first since Story Trails depends on it.
  await auth_di.initAuthFeature();
  // --- ADD THIS LINE ---
  await story_trails_di.initStoryTrailsFeature();
}
