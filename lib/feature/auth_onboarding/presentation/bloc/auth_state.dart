part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

// --- UPDATED: Holds User object now ---
class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object> get props => [user];
}

class Unauthenticated extends AuthState {}

class SignUpSuccessful extends AuthState {}

class ForgetPasswordEmailSent extends AuthState {}

class OTPVerified extends AuthState {
  final String resetToken;
  const OTPVerified(this.resetToken);

  @override
  List<Object> get props => [resetToken];
}

class PasswordResetSuccess extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}
