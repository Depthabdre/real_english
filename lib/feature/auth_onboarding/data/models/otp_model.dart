import '../../domain/entities/otp.dart';

class OtpModel extends OTP {
  const OtpModel({required super.email, required super.resetToken});

  factory OtpModel.fromJson(
    Map<String, dynamic> json, {
    required String email,
  }) {
    return OtpModel(
      email: email, // Passed in since the dummy response won't have it
      resetToken: json['password_reset_token'] ?? '',
    );
  }
}
