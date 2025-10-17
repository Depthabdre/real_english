import 'package:get_it/get_it.dart';
import 'package:real_english/app/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../feature/auth_onboarding/auth_injection.dart' as auth_di;

final sl = GetIt.instance;

Future<void> init() async {
  // --- App Level Dependencies ---
  // Register AppRouter as a singleton so there's only one instance
  sl.registerLazySingleton(() => AppRouter());

  // Core / External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // --- Features ---
  await auth_di.initAuthFeature();
}
