import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:real_english/app/injection_container.dart';


import 'data/datasources/auth_local_datasource.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/auth_check.dart';
import 'domain/usecases/forget_password_usecase.dart';
import 'domain/usecases/getme_usecase.dart';
import 'domain/usecases/googlesignin_usecase.dart';
import 'domain/usecases/reset_password_usecase.dart';
import 'domain/usecases/signin_usecase.dart';
import 'domain/usecases/signout_usecase.dart';
import 'domain/usecases/signup_usecase.dart';
import 'domain/usecases/verifyotp_usecase.dart';
import 'presentation/bloc/auth_bloc.dart';

// NO 'sl' definition here anymore.

Future<void> initAuthFeature() async {
  // All these 'sl.register...' calls now refer to the single, global 'sl' instance.

  // --- Presentation Layer ---
  sl.registerFactory(
    () => AuthBloc(
      signInUseCase: sl(),
      signUpUseCase: sl(),
      googleSignInUseCase: sl(),
      forgotPasswordUseCase: sl(),
      verifyOTPUseCase: sl(),
      resetPasswordUseCase: sl(),
      getMeUseCase: sl(),
      checkAuthStatusUseCase: sl(),
      signOutUseCase: sl(),
    ),
  );

  // --- Domain Layer (Use Cases) ---
  sl.registerLazySingleton(() => SignUp(sl()));
  sl.registerLazySingleton(() => SignIn(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => CheckAuthStatus(sl()));
  sl.registerLazySingleton(() => ForgotPassword(sl()));
  sl.registerLazySingleton(() => VerifyOTP(sl()));
  sl.registerLazySingleton(() => ResetPassword(sl()));
  sl.registerLazySingleton(() => GoogleSignIn(sl()));
  sl.registerLazySingleton(() => GetMe(sl()));

  // --- Data Layer ---
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDatasource: sl(), localDatasource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(),
  );
  sl.registerLazySingleton<AuthLocalDatasource>(
    () => AuthLocalDatasourceImpl(secureStorage: sl()),
  );

  // --- External Dependencies ---
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => http.Client());
}
