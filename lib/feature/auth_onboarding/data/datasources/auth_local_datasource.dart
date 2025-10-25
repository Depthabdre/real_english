import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// --- ABSTRACT CLASS DEFINITION (SIMPLIFIED) ---
// The contract is updated to handle a single token for simplicity and clarity.

abstract class AuthLocalDatasource {
  /// Caches the given access token securely.
  Future<void> cacheToken(String token);

  /// Retrieves the cached access token.
  /// Returns `null` if no token is found.
  Future<String?> getToken();

  /// Clears the cached access token.
  Future<void> clearToken();
}

// --- IMPLEMENTATION (SIMPLIFIED) ---

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  final FlutterSecureStorage secureStorage;

  // We only need one key now.
  static const String accessTokenKey = 'ACCESS_TOKEN';

  AuthLocalDatasourceImpl({required this.secureStorage});

  @override
  Future<void> cacheToken(String token) async {
    // Writes a single access token to secure storage.
    await secureStorage.write(key: accessTokenKey, value: token);
  }

  @override
  Future<String?> getToken() async {
    // Reads the single access token from secure storage.
    return await secureStorage.read(key: accessTokenKey);
  }

  @override
  Future<void> clearToken() async {
    // Deletes the single access token from secure storage.
    await secureStorage.delete(key: accessTokenKey);
  }
}
