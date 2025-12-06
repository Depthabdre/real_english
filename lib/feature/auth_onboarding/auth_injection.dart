import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:real_english/app/injection_container.dart';
import 'package:real_english/feature/auth_onboarding/domain/usecases/googlesignin_usecase.dart';

import 'data/datasources/auth_local_datasource.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/auth_check.dart';
import 'domain/usecases/forget_password_usecase.dart';
import 'domain/usecases/getme_usecase.dart';
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
  // This ensures the AppRouter and the UI listen to the SAME Bloc.
  sl.registerLazySingleton(
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
  sl.registerLazySingleton(() => googleSignIn(sl()));
  sl.registerLazySingleton(() => GetMe(sl()));

  // --- Data Layer ---
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDatasource: sl(),
      localDatasource: sl(),
      googleSignInInstance: sl(), // Inject GoogleSignIn here as well),
      networkInfo: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(
      client: sl(),
      localDatasource: sl(),
      googleSignInInstance: sl(),
    ),
  );
  sl.registerLazySingleton<AuthLocalDatasource>(
    () => AuthLocalDatasourceImpl(secureStorage: sl()),
  );

  // --- External Dependencies ---
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => http.Client());
  // GoogleSignIn instance with default scopes (email, profile)
  // --- FINAL, SECURE, AND CORRECT REGISTRATION FOR google_sign_in v7.2.0 ---
  // 1. Get the singleton instance provided by the package.

  final googleSignInPackage = GoogleSignIn.instance;

  // 2. Perform the asynchronous initialization.
  await googleSignInPackage.initialize(
    clientId: dotenv.env['ANDROID_CLIENT_ID']!,
    serverClientId: dotenv.env['WEB_CLIENT_ID']!,
  );

  // 3. Register the now-initialized instance as a singleton.
  sl.registerLazySingleton<GoogleSignIn>(() => googleSignInPackage);
}
