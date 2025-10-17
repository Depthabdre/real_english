import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthEvent {}

class SignUpRequested extends AuthEvent {
  final String fullName;
  final String email;
  final String password;

  const SignUpRequested({
    required this.fullName,
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [fullName, email, password];
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class GoogleSignInRequested extends AuthEvent {}

class SignOutRequested extends AuthEvent {}

class ForgotPasswordRequested extends AuthEvent {
  final String email;
  const ForgotPasswordRequested({required this.email});

  @override
  List<Object> get props => [email];
}

class VerifyOtpRequested extends AuthEvent {
  final String email;
  final String otpCode;
  const VerifyOtpRequested({required this.email, required this.otpCode});

  @override
  List<Object> get props => [email, otpCode];
}

class ResetPasswordRequested extends AuthEvent {
  final String token;
  final String newPassword;
  const ResetPasswordRequested({
    required this.token,
    required this.newPassword,
  });

  @override
  List<Object> get props => [token, newPassword];
}
