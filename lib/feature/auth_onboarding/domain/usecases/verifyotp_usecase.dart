import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/otp.dart';
import '../repositories/auth_repository.dart';

class VerifyOTP {
  final AuthRepository repository;

  VerifyOTP(this.repository);

  Future<Either<Failures, OTP>> call(VerifyOTPParams params) async {
    return await repository.verifyOTP(
      email: params.email,
      otpCode: params.otpCode,
    );
  }
}

class VerifyOTPParams extends Equatable {
  final String email;
  final String otpCode;

  const VerifyOTPParams({required this.email, required this.otpCode});

  @override
  List<Object?> get props => [email, otpCode];
}
