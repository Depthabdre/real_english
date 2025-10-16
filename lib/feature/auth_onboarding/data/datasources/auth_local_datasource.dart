import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthLocalDatasource {
  Future<void> cacheTokens(String accessToken, String refreshToken);
  Future<Map<String, String?>> getTokens();
  Future<void> clearTokens();
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  final FlutterSecureStorage secureStorage;

  static const String accessTokenKey = 'ACCESS_TOKEN';
  static const String refreshTokenKey = 'REFRESH_TOKEN';

  AuthLocalDatasourceImpl({required this.secureStorage});

  @override
  Future<void> cacheTokens(String accessToken, String refreshToken) async {
    await secureStorage.write(key: accessTokenKey, value: accessToken);
    await secureStorage.write(key: refreshTokenKey, value: refreshToken);
  }

  @override
  Future<Map<String, String?>> getTokens() async {
    final accessToken = await secureStorage.read(key: accessTokenKey);
    final refreshToken = await secureStorage.read(key: refreshTokenKey);
    return {'accessToken': accessToken, 'refreshToken': refreshToken};
  }

  @override
  Future<void> clearTokens() async {
    await secureStorage.delete(key: accessTokenKey);
    await secureStorage.delete(key: refreshTokenKey);
  }
}
