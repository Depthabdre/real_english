import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../../app/injection_container.dart';
import '../../../core/network/network_info.dart';

// --- Presentation ---
import 'presentation/bloc/story_player_bloc.dart';
import 'presentation/bloc/story_trails_list_bloc.dart';

// --- Domain ---
import 'domain/repositories/story_trails_repository.dart';
import 'domain/usecases/get_story_trail_for_level.dart'; // Correct singular name
import 'domain/usecases/get_story_trail_by_id.dart';
import 'domain/usecases/get_user_learning_profile.dart';
import 'domain/usecases/get_user_story_progress.dart';
import 'domain/usecases/mark_story_trail_completed.dart';
import 'domain/usecases/save_user_story_progress.dart';
import 'domain/usecases/submit_challenge_answer.dart';
import 'domain/usecases/update_user_learning_profile.dart';

// --- Data ---
import 'data/repositories/story_trails_repository_impl.dart';
import 'data/datasources/story_trails_local_datasource.dart';
import 'data/datasources/story_trails_remote_datasource.dart';

// Dependency from another feature
import '../auth_onboarding/data/datasources/auth_local_datasource.dart';

Future<void> initStoryTrailsFeature() async {
  // --- Presentation Layer (BLoCs) ---
  sl.registerFactory(
    () => StoryTrailsListBloc(
      getUserLearningProfileUseCase: sl(),
      getStoryTrailForLevelUseCase: sl(), // Correct singular name
    ),
  );

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
  sl.registerLazySingleton(
    () => GetStoryTrailForLevel(sl()),
  ); // Correct singular name
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
      authLocalDataSource: sl<AuthLocalDatasource>(),
    ),
  );
  sl.registerLazySingleton<StoryTrailsLocalDataSource>(
    () => StoryTrailsLocalDataSourceImpl(),
  );

  // --- Core / External Dependencies ---
  // These checks prevent errors if these are already registered elsewhere.
  if (!sl.isRegistered<http.Client>()) {
    sl.registerLazySingleton(() => http.Client());
  }
  if (!sl.isRegistered<NetworkInfo>()) {
    sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
    sl.registerLazySingleton(() => InternetConnection());
  }
}
