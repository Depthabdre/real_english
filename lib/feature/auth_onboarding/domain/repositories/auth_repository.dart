import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart'; // You will need to create this file
import '../entities/otp.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failures, void>> signUp({
    required String fullName,
    required String email,
    required String password,
  });

  Future<Either<Failures, User>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failures, User>> googleSignIn();

  Future<Either<Failures, void>> signOut();

  Future<Either<Failures, void>> forgotPassword({required String email});

  Future<Either<Failures, OTP>> verifyOTP({
    required String email,
    required String otpCode,
  });

  Future<Either<Failures, void>> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<Either<Failures, User>> getMe();

  Future<Either<Failures, bool>> isLoggedIn();
}
