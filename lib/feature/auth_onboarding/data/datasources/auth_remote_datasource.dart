import '../models/otp_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  });
  Future<UserModel> signIn({required String email, required String password});
  Future<void> forgotPassword({required String email});
  Future<OtpModel> verifyOTP({required String email, required String otpCode});
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });
  Future<UserModel> googleSignIn();
  Future<UserModel> getMe();
}

// --- DUMMY IMPLEMENTATION ---
class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  // No http.Client needed for the dummy implementation

  @override
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    print('Signing up user: $fullName with email: $email');
    // Simulate a network delay
    await Future.delayed(const Duration(seconds: 2));

    // In a real API, you might get an error if the email exists.
    // Here, we just assume it's always successful.
    print('Sign up successful.');
    return;
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    print('Signing in with email: $email');
    await Future.delayed(const Duration(seconds: 2));

    // Return a fake user and fake tokens.
    final dummyUserData = {
      "user": {"id": "user_12345", "full_name": "Test User", "email": email},
      "access_token": "fake_access_token_123456789",
      "refresh_token": "fake_refresh_token_abcdefghi",
    };

    print('Sign in successful. Returning dummy user.');
    return UserModel.fromJson(dummyUserData['user'] as Map<String, dynamic>);
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    print('Sending password reset OTP to: $email');
    await Future.delayed(const Duration(seconds: 2));
    print('OTP sent successfully.');
    return;
  }

  @override
  Future<OtpModel> verifyOTP({
    required String email,
    required String otpCode,
  }) async {
    print('Verifying OTP: $otpCode for email: $email');
    await Future.delayed(const Duration(seconds: 1));

    // Return a dummy OTP model with a fake reset token
    final dummyOtpData = {
      "password_reset_token": "fake_password_reset_token_xyz",
    };
    print('OTP verification successful.');
    return OtpModel.fromJson(dummyOtpData, email: email);
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    print('Resetting password with token: $token');
    await Future.delayed(const Duration(seconds: 2));
    print('Password has been reset successfully.');
    return;
  }

  // --- UNIMPLEMENTED DUMMY METHODS ---
  @override
  Future<UserModel> googleSignIn() async {
    throw UnimplementedError(
      "Google Sign-In is not implemented in the dummy data source yet.",
    );
  }

  @override
  Future<UserModel> getMe() async {
    throw UnimplementedError(
      "GetMe is not implemented in the dummy data source yet.",
    );
  }
}
