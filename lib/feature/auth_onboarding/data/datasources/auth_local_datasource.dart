import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// Import your User entity
import '../models/user_model.dart'; // Import your UserModel

abstract class AuthLocalDatasource {
  Future<void> cacheToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();

  // --- NEW METHODS ---
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getLastUser();
  Future<void> clearUser();
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  final FlutterSecureStorage secureStorage;

  static const String accessTokenKey = 'ACCESS_TOKEN';
  static const String userDataKey = 'USER_DATA'; // New key for user JSON

  AuthLocalDatasourceImpl({required this.secureStorage});

  @override
  Future<void> cacheToken(String token) async {
    await secureStorage.write(key: accessTokenKey, value: token);
  }

  @override
  Future<String?> getToken() async {
    return await secureStorage.read(key: accessTokenKey);
  }

  @override
  Future<void> clearToken() async {
    await secureStorage.delete(key: accessTokenKey);
  }

  // --- NEW IMPLEMENTATION ---

  @override
  Future<void> cacheUser(UserModel user) async {
    final String userJson = json.encode(user.toJson());
    await secureStorage.write(key: userDataKey, value: userJson);
  }

  @override
  Future<UserModel?> getLastUser() async {
    final String? userJson = await secureStorage.read(key: userDataKey);
    if (userJson != null) {
      try {
        return UserModel.fromJson(json.decode(userJson));
      } catch (e) {
        return null; // Handle corrupted data
      }
    }
    return null;
  }

  @override
  Future<void> clearUser() async {
    await secureStorage.delete(key: userDataKey);
  }
}
