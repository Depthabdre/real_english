import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user.dart'; // Ensure this import exists!
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
part 'auth_state.dart';

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
    // UPDATED: Using getMeUseCase to validate session + get user data (Offline or Online)
    // This allows the Splash Screen to populate the User object immediately.
    final result = await getMeUseCase();

    result.fold(
      (failure) => emit(Unauthenticated()),
      (user) => emit(Authenticated(user)), // Pass the user object here
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
      (user) => emit(Authenticated(user)), // UPDATED: Pass the user object
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
    emit(AuthLoading());
    final result = await googleSignInUseCase();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)), // UPDATED: Pass the user object
    );
  }
}
