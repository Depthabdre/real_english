import 'package:equatable/equatable.dart';

class OTP extends Equatable {
  final String email;
  final String resetToken;

  const OTP({required this.email, required this.resetToken});

  @override
  List<Object?> get props => [email, resetToken];
}
