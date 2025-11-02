// feature/story_trails/story_trails_injection.dart

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:real_english/feature/StoryTrails/presentation/bloc/story_player_bloc.dart';

import '../../../app/injection_container.dart'; // To access the global 'sl'
import '../../../core/network/network_info.dart';

// Import all layers of the Story Trails feature
// Presentation
import 'presentation/bloc/story_trails_list_bloc.dart';
// TODO: Add StoryPlayerBloc later
// import 'presentation/bloc/story_player_bloc.dart';

// Domain
import 'domain/repositories/story_trails_repository.dart';
import 'domain/usecases/get_story_trails_for_level.dart';
import 'domain/usecases/get_story_trail_by_id.dart';
import 'domain/usecases/get_user_learning_profile.dart';
import 'domain/usecases/get_user_story_progress.dart';
import 'domain/usecases/mark_story_trail_completed.dart';
import 'domain/usecases/save_user_story_progress.dart';
import 'domain/usecases/submit_challenge_answer.dart';
import 'domain/usecases/update_user_learning_profile.dart';

// Data
import 'data/repositories/story_trails_repository_impl.dart';
import 'data/datasources/story_trails_local_datasource.dart';
import 'data/datasources/story_trails_remote_datasource.dart';

// We need a dependency from the Auth feature to get the token
import '../auth_onboarding/data/datasources/auth_local_datasource.dart';

Future<void> initStoryTrailsFeature() async {
  // --- Presentation Layer (BLoCs) ---
  sl.registerFactory(
    () => StoryTrailsListBloc(
      getUserLearningProfileUseCase: sl(),
      getStoryTrailsForLevelUseCase: sl(),
    ),
  );

  // --- ADD THIS REGISTRATION ---
  sl.registerFactory(
    () => StoryPlayerBloc(
      getStoryTrailByIdUseCase: sl(),
      getUserStoryProgressUseCase: sl(),
      submitChallengeAnswerUseCase: sl(),
      saveUserStoryProgressUseCase: sl(),
      markStoryTrailCompletedUseCase: sl(),
    ),
  );

  // --- Domain Layer (Use Cases) ---
  sl.registerLazySingleton(() => GetStoryTrailsForLevel(sl()));
  sl.registerLazySingleton(() => GetStoryTrailById(sl()));
  sl.registerLazySingleton(() => GetUserLearningProfile(sl()));
  sl.registerLazySingleton(() => GetUserStoryProgress(sl()));
  sl.registerLazySingleton(() => MarkStoryTrailCompleted(sl()));
  sl.registerLazySingleton(() => SaveUserStoryProgress(sl()));
  sl.registerLazySingleton(() => SubmitChallengeAnswer(sl()));
  sl.registerLazySingleton(() => UpdateUserLearningProfile(sl()));

  // --- Data Layer ---
  sl.registerLazySingleton<StoryTrailsRepository>(
    () => StoryTrailsRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<StoryTrailsRemoteDataSource>(
    () => StoryTrailsRemoteDataSourceImpl(
      client: sl(),
      // We need the AuthLocalDatasource to get the user's token for API calls
      authLocalDataSource: sl<AuthLocalDatasource>(),
    ),
  );
  sl.registerLazySingleton<StoryTrailsLocalDataSource>(
    () =>
        StoryTrailsLocalDataSourceImpl(), // Hive is used internally and doesn't need injection here
  );

  // --- Core / External Dependencies for this feature ---
  // Note: http.Client is likely already registered in your auth_injection.
  // GetIt is smart enough not to re-register it if it already exists.
  // We can leave these here for completeness or assume they are in a central place.
  if (!sl.isRegistered<http.Client>()) {
    sl.registerLazySingleton(() => http.Client());
  }
  if (!sl.isRegistered<NetworkInfo>()) {
    sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
    // FIX IS HERE: Use the correct class name from the package
    sl.registerLazySingleton(() => InternetConnection());
  }
}
