import 'package:get_it/get_it.dart';
// Import http or other packages here as you add them
// import 'package:http/http.dart' as http;

final sl = GetIt.instance;

Future<void> init() async {
  // This is where you will initialize dependencies for each feature.
  // For now, it is empty.

  // EXAMPLE: When you build the 'Authentication' feature, you would add:
  //
  // // Blocs
  // sl.registerFactory(() => AuthBloc(userLogin: sl(), userRegister: sl()));
  //
  // // Usecases
  // sl.registerLazySingleton(() => UserLogin(sl()));
  // sl.registerLazySingleton(() => UserRegister(sl()));
  //
  // // Repositories
  // sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()));
  //
  // // Data sources
  // sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(client: sl()));

  // // Core
  // sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // // External
  // sl.registerLazySingleton(() => http.Client());
  // sl.registerLazySingleton(() => InternetConnectionChecker());
}
