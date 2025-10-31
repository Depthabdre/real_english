import 'package:dartz/dartz.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/errors/exception.dart'; // You will need to create this file
import '../../../../core/errors/failures.dart';
import '../../domain/entities/otp.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;
  final AuthLocalDatasource localDatasource;
  final GoogleSignIn googleSignInInstance;

  AuthRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
    required this.googleSignInInstance,
  });

  @override
  Future<Either<Failures, void>> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      await remoteDatasource.signUp(
        fullName: fullName,
        email: email,
        password: password,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failures, User>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDatasource.signIn(
        email: email,
        password: password,
      );
      // NOTE: In a real app, you would get tokens from the response and cache them here.
      // For the dummy implementation, we can just cache fake tokens.
      await localDatasource.cacheToken('fake_access_token');
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failures, void>> forgotPassword({required String email}) async {
    try {
      await remoteDatasource.forgotPassword(email: email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failures, OTP>> verifyOTP({
    required String email,
    required String otpCode,
  }) async {
    try {
      final otp = await remoteDatasource.verifyOTP(
        email: email,
        otpCode: otpCode,
      );
      return Right(otp);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failures, void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await remoteDatasource.resetPassword(
        token: token,
        newPassword: newPassword,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failures, bool>> isLoggedIn() async {
    try {
      final token = await localDatasource.getToken();
      final bool loggedIn = token?.isNotEmpty ?? false;
      return Right(loggedIn);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failures, void>> signOut() async {
    try {
      await localDatasource.clearToken();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  // --- UNIMPLEMENTED METHODS ---
  @override
  Future<Either<Failures, User>> getMe() {
    // TODO: implement getMe
    throw UnimplementedError();
  }

  // --- GOOGLE SIGN-IN IMPLEMENTATION (CORRECTED) ---
  @override
  Future<Either<Failures, User>> googleSignIn() async {
    try {
      // Step 1: Trigger the native Google Sign-In UI flow.
      // THE FIX IS HERE: The method is .authenticate()
      final GoogleSignInAccount googleUser = await googleSignInInstance
          .authenticate();

      // Step 2: Get the authentication tokens.
      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        return Left(
          ServerFailure(message: 'Failed to retrieve Google ID token.'),
        );
      }

      // Step 3: Send the token to your backend.
      final user = await remoteDatasource.googleSignIn(idToken: idToken);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on GoogleSignInException catch (e) {
      print('Google Sign-In Error: ${e.toString()}');
      return Left(
        ServerFailure(message: 'Google Sign-In Error'),
      );
    } catch (e) {
      return Left(
        ServerFailure(message: 'An unexpected error occurred: ${e.toString()}'),
      );
    }
  }
}
