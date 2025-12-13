import 'package:http/http.dart' as http;

import '../../app/injection_container.dart'; // Access to 'sl'

// --- Feature Imports ---
// Presentation
import 'presentation/bloc/immersion_bloc.dart';

// Domain (Use Cases)
import 'domain/usecases/get_immersion_feed.dart';
import 'domain/usecases/get_saved_library.dart';
import 'domain/usecases/mark_video_watched.dart';
import 'domain/usecases/toggle_save_video.dart';

// Domain (Repository Interface)
import 'domain/repositories/immersion_repository.dart';

// Data (Repository Implementation)
import 'data/repositories/immersion_repository_impl.dart';

// Data (Data Sources)
import 'data/datasources/immersion_remote_datasource.dart';

// External Dependency (Auth Token)
import '../auth_onboarding/data/datasources/auth_local_datasource.dart';

Future<void> initImmersionFeature() async {
  // ===============================================================
  // 1. Presentation Layer (BLoCs)
  // ===============================================================
  // Factory: We want a fresh BLoC instance every time the page opens.
  sl.registerFactory(
    () => ImmersionBloc(
      getImmersionFeed: sl(),
      toggleSaveVideo: sl(),
      markVideoWatched: sl(),
    ),
  );

  // ===============================================================
  // 2. Domain Layer (Use Cases)
  // ===============================================================
  // LazySingleton: Logic is stateless, so we reuse the same instance.
  sl.registerLazySingleton(() => GetImmersionFeed(sl()));
  sl.registerLazySingleton(() => ToggleSaveVideo(sl()));
  sl.registerLazySingleton(() => MarkVideoWatched(sl()));
  sl.registerLazySingleton(() => GetSavedLibrary(sl()));

  // ===============================================================
  // 3. Data Layer (Repository)
  // ===============================================================
  sl.registerLazySingleton<ImmersionRepository>(
    () => ImmersionRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // ===============================================================
  // 4. Data Layer (Data Sources)
  // ===============================================================
  sl.registerLazySingleton<ImmersionRemoteDataSource>(
    () => ImmersionRemoteDataSourceImpl(
      client: sl(),
      // We inject AuthLocalDatasource to get the Bearer Token for API calls
      authLocalDataSource: sl<AuthLocalDatasource>(),
    ),
  );

  // ===============================================================
  // 5. External/Core Checks
  // ===============================================================
  // (Optional safety check, though usually handled in main injection)
  if (!sl.isRegistered<http.Client>()) {
    sl.registerLazySingleton(() => http.Client());
  }
}
