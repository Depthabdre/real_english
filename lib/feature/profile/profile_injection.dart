import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/injection_container.dart'; // Access to 'sl'

// --- Feature Imports ---

// Presentation
import 'presentation/bloc/profile_bloc.dart';

// Domain (Use Cases)
import 'domain/usecases/get_user_profile.dart';
import 'domain/usecases/update_profile_identity.dart';

// Domain (Repository Interface)
import 'domain/repositories/profile_repository.dart';

// Data (Repository Implementation)
import 'data/repositories/profile_repository_impl.dart';

// Data (Data Sources)
import 'data/datasources/profile_local_datasource.dart';
import 'data/datasources/profile_remote_datasource.dart';

// External Dependencies
import '../../core/network/network_info.dart';
import '../auth_onboarding/data/datasources/auth_local_datasource.dart';

Future<void> initProfileFeature() async {
  // ===============================================================
  // 1. Presentation Layer (BLoCs)
  // ===============================================================
  // Factory: New instance every time the page opens
  sl.registerFactory(
    () => ProfileBloc(getUserProfile: sl(), updateProfileIdentity: sl()),
  );

  // ===============================================================
  // 2. Domain Layer (Use Cases)
  // ===============================================================
  // LazySingleton: Reuse the same instance
  sl.registerLazySingleton(() => GetUserProfile(sl()));
  sl.registerLazySingleton(() => UpdateProfileIdentity(sl()));

  // ===============================================================
  // 3. Data Layer (Repository)
  // ===============================================================
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // ===============================================================
  // 4. Data Layer (Data Sources)
  // ===============================================================

  // Remote Data Source (Needs HTTP Client + Auth Token Source)
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(
      client: sl(),
      authLocalDataSource: sl<AuthLocalDatasource>(),
    ),
  );

  // Local Data Source (Needs SharedPreferences)
  sl.registerLazySingleton<ProfileLocalDataSource>(
    () =>
        ProfileLocalDataSourceImpl(sharedPreferences: sl<SharedPreferences>()),
  );

  // ===============================================================
  // 5. External Safety Check
  // ===============================================================
  if (!sl.isRegistered<http.Client>()) {
    sl.registerLazySingleton(() => http.Client());
  }
}
