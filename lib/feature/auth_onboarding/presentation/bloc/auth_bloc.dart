import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/auth_check.dart';
import '../../domain/usecases/forget_password_usecase.dart';
import '../../domain/usecases/getme_usecase.dart';
import '../../domain/usecases/googlesignin_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/signin_usecase.dart';
import '../../domain/usecases/signout_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../domain/usecases/verifyotp_usecase.dart';
part 'auth_event.dart';
part  'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignIn signInUseCase;
  final SignUp signUpUseCase;
  final googleSignIn googleSignInUseCase;
  final ForgotPassword forgotPasswordUseCase;
  final VerifyOTP verifyOTPUseCase;
  final ResetPassword resetPasswordUseCase;
  final GetMe getMeUseCase;
  final CheckAuthStatus checkAuthStatusUseCase;
  final SignOut signOutUseCase;

  AuthBloc({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.googleSignInUseCase,
    required this.forgotPasswordUseCase,
    required this.verifyOTPUseCase,
    required this.resetPasswordUseCase,
    required this.getMeUseCase,
    required this.checkAuthStatusUseCase,
    required this.signOutUseCase,
  }) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignInRequested>(_onSignInRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    // This logic will be important for session management later
    final result = await checkAuthStatusUseCase();
    result.fold(
      (failure) => emit(Unauthenticated()), // On error, assume unauthenticated
      (isLoggedIn) {
        if (isLoggedIn) {
          emit(Authenticated());
        } else {
          emit(Unauthenticated());
        }
      },
    );
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signUpUseCase(
      SignUpParams(
        fullName: event.fullName,
        email: event.email,
        password: event.password,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(SignUpSuccessful()),
    );
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signInUseCase(
      SignInParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated()),
    );
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await forgotPasswordUseCase(
      ForgotPasswordParams(email: event.email),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(ForgetPasswordEmailSent()),
    );
  }

  Future<void> _onVerifyOtpRequested(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await verifyOTPUseCase(
      VerifyOTPParams(email: event.email, otpCode: event.otpCode),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (otp) => emit(OTPVerified(otp.resetToken)),
    );
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await resetPasswordUseCase(
      ResetPasswordParams(token: event.token, newPassword: event.newPassword),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(PasswordResetSuccess()),
    );
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signOutUseCase();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(Unauthenticated()),
    );
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    // 1. Immediately emit the loading state to show a spinner in the UI.
    emit(AuthLoading());

    // 2. Call the googleSignInUseCase. This use case doesn't require any parameters.
    //    It will trigger the entire flow:
    //    - Show the native Google account picker.
    //    - Get the ID token.
    //    - Send it to your backend.
    //    - Your backend verifies it and returns your app's user profile and access token.
    //    - The repository saves your access token to secure storage.
    final result = await googleSignInUseCase();

    // 3. Handle the result.
    result.fold(
      // If anything fails (user cancels, network error, backend error), emit the error state.
      (failure) => emit(AuthError(failure.message)),

      // If the entire flow is successful, the user is now logged in.
      // Emit the Authenticated state to navigate the user to the home screen.
      (user) => emit(Authenticated()),
    );
  }
}
