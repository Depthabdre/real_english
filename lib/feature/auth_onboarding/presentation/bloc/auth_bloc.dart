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
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignIn signInUseCase;
  final SignUp signUpUseCase;
  final GoogleSignIn googleSignInUseCase;
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
    // Implement Google Sign-In logic when ready
    emit(AuthLoading());
    await Future.delayed(Duration(seconds: 2));
    emit(const AuthError("Google Sign-In is not implemented yet."));
  }
}
