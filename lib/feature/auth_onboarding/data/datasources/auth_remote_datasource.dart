import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:real_english/core/errors/exception.dart';
import '../models/otp_model.dart';
import '../models/user_model.dart';
import 'auth_local_datasource.dart';

// --- ABSTRACT CLASS DEFINITION ---
// This contract includes all necessary auth methods, including logout.
abstract class AuthRemoteDatasource {
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  });

  Future<UserModel> signIn({required String email, required String password});

  Future<void> logout();

  Future<void> forgotPassword({required String email});

  Future<OtpModel> verifyOTP({required String email, required String otpCode});

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<UserModel> getMe();

  /// Authenticates with the backend using a Google ID Token.
  Future<UserModel> googleSignIn({required String idToken});
}

// --- PRODUCTION-QUALITY IMPLEMENTATION ---

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final http.Client client;
  final AuthLocalDatasource localDatasource;
  final GoogleSignIn googleSignInInstance; // Now injected for testability

  // Base URL for your backend API, configured for the Android Emulator.
  final String _baseUrl = "http://10.68.82.123:3000/api/auth";

  AuthRemoteDatasourceImpl({
    required this.client,
    required this.localDatasource,
    required this.googleSignInInstance,
  });

  /// A centralized function to handle API error responses.
  Exception _handleError(http.Response response) {
    try {
      // Our backend sends errors in the format: { "error": "message" }
      final errorData = json.decode(response.body);
      return ServerException(
        message: errorData['error'] ?? 'An unknown server error occurred.',
      );
    } catch (e) {
      return ServerException(
        message: 'Failed to parse error response: ${response.body}',
      );
    }
  }

  @override
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await client
          .post(
            Uri.parse('$_baseUrl/signup'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: json.encode({
              // Keys match the backend: fullName, email, password
              'fullName': fullName,
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 201) {
        throw _handleError(response);
      }
    } on SocketException {
      throw ServerException(
        message: 'No Internet connection. Please check your network.',
      );
    } on TimeoutException {
      throw ServerException(
        message: 'The request timed out. Please try again.',
      );
    }
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client
          .post(
            Uri.parse('$_baseUrl/signin'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: json.encode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final accessToken = data['access_token'];
        final userData = data['user'];

        if (accessToken == null || userData == null) {
          throw ServerException(
            message: 'Authentication failed: Invalid response from server.',
          );
        }

        // Cache the token upon successful login. This is a critical step.
        await localDatasource.cacheToken(accessToken);

        return UserModel.fromJson(userData);
      } else {
        throw _handleError(response);
      }
    } on SocketException {
      throw ServerException(
        message: 'No Internet connection. Please check your network.',
      );
    } on TimeoutException {
      throw ServerException(
        message: 'The request timed out. Please try again.',
      );
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    print('🔹 forgotPassword() called with email: $email'); // Debug print
    try {
      final response = await client
          .post(
            Uri.parse('$_baseUrl/forgot-password'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: json.encode({'email': email}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        final ass = response.body;
        print("the error is $ass");
        throw _handleError(response);
      }
    } on SocketException {
      throw ServerException(
        message: 'No Internet connection. Please check your network.',
      );
    } on TimeoutException {
      throw ServerException(
        message: 'The request timed out. Please try again.',
      );
    }
  }

  @override
  Future<OtpModel> verifyOTP({
    required String email,
    required String otpCode,
  }) async {
    try {
      final response = await client
          .post(
            Uri.parse('$_baseUrl/verify-otp'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: json.encode({
              // Keys match the backend: email, otpCode
              'email': email,
              'otpCode': otpCode,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // The OtpModel's fromJson constructor will look for 'password_reset_token'
        return OtpModel.fromJson(data, email: email);
      } else {
        throw _handleError(response);
      }
    } on SocketException {
      throw ServerException(
        message: 'No Internet connection. Please check your network.',
      );
    } on TimeoutException {
      throw ServerException(
        message: 'The request timed out. Please try again.',
      );
    }
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await client
          .post(
            Uri.parse('$_baseUrl/reset-password'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: json.encode({
              // Keys match the backend: token, newPassword
              'token': token,
              'newPassword': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } on SocketException {
      throw ServerException(
        message: 'No Internet connection. Please check your network.',
      );
    } on TimeoutException {
      throw ServerException(
        message: 'The request timed out. Please try again.',
      );
    }
  }

  @override
  Future<void> logout() async {
    // For a stateless API, logout is a client-side operation.
    // We just clear the cached token.
    try {
      await localDatasource.clearToken();
    } catch (e) {
      throw ServerException(message: 'Failed to clear local session.');
    }
  }

  @override
  Future<UserModel> getMe() async {
    try {
      // 1. Retrieve the token from local storage.
      final token = await localDatasource.getToken();
      if (token == null) {
        throw ServerException(message: 'Authentication token not found.');
      }

      // 2. Make the authenticated GET request.
      final response = await client
          .get(
            Uri.parse('$_baseUrl/me'),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return UserModel.fromJson(json.decode(response.body));
      } else {
        throw _handleError(response);
      }
    } on SocketException {
      throw ServerException(
        message: 'No Internet connection. Please check your network.',
      );
    } on TimeoutException {
      throw ServerException(
        message: 'The request timed out. Please try again.',
      );
    }
  }

  // --- GOOGLE SIGN-IN IMPLEMENTATION ---
  @override
  Future<UserModel> googleSignIn({required String idToken}) async {
    // This implementation is correct. It takes the idToken and sends it to your backend.
    try {
      final response = await client
          .post(
            Uri.parse('$_baseUrl/google-signin'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: json.encode({'token': idToken}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final accessToken = data['access_token'];
        final userData = data['user'];
        if (accessToken == null || userData == null) {
          print('⚠️ Debug: Invalid server response: $data');
          throw ServerException(message: 'Invalid response from server.');
        }
        await localDatasource.cacheToken(accessToken);
        return UserModel.fromJson(userData);
      } else {
        print('❌ Debug: Request failed.');
        print('Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
        throw _handleError(response);
      }
    } on SocketException {
      throw ServerException(message: 'No Internet connection.');
    } on TimeoutException {
      throw ServerException(message: 'The request timed out.');
    }
  }
}
