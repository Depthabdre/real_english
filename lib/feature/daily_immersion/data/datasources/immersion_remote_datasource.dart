import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/errors/exception.dart';
import '../models/immersion_short_model.dart';
import '../../../auth_onboarding/data/datasources/auth_local_datasource.dart';

abstract class ImmersionRemoteDataSource {
  Future<List<ImmersionShortModel>> getFeed({
    required String category,
    required int limit,
  });
  Future<List<ImmersionShortModel>> getSavedLibrary();
  Future<bool> toggleSaveVideo(String shortId);
  Future<void> markVideoAsWatched(String shortId);
}

class ImmersionRemoteDataSourceImpl implements ImmersionRemoteDataSource {
  final http.Client client;
  final AuthLocalDatasource authLocalDataSource;

  // Replace with your actual IP address
  final String _apiBaseUrl = "http://172.26.158.123:3000";

  ImmersionRemoteDataSourceImpl({
    required this.client,
    required this.authLocalDataSource,
  });

  Future<Map<String, String>> get _getAuthHeaders async {
    final token = await authLocalDataSource.getToken();
    final headers = {'Content-Type': 'application/json; charset=UTF-8'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Helper for error handling (matches your style)
  Exception _handleError(http.Response response) {
    try {
      final errorData = json.decode(response.body);
      return ServerException(
        message: errorData['error'] ?? 'An unknown server error occurred.',
      );
    } catch (e) {
      return ServerException(
        message: 'Failed to parse error response: ${response.statusCode}',
      );
    }
  }

  @override
  Future<List<ImmersionShortModel>> getFeed({
    required String category,
    required int limit,
  }) async {
    final url =
        '$_apiBaseUrl/api/daily-immersion/feed?category=$category&limit=$limit';

    final response = await client.get(
      Uri.parse(url),
      headers: await _getAuthHeaders,
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((e) => ImmersionShortModel.fromJson(e)).toList();
    } else {
      throw _handleError(response);
    }
  }

  @override
  Future<List<ImmersionShortModel>> getSavedLibrary() async {
    final url = '$_apiBaseUrl/api/daily-immersion/saved';

    final response = await client.get(
      Uri.parse(url),
      headers: await _getAuthHeaders,
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((e) => ImmersionShortModel.fromJson(e)).toList();
    } else {
      throw _handleError(response);
    }
  }

  @override
  Future<bool> toggleSaveVideo(String shortId) async {
    final url = '$_apiBaseUrl/api/daily-immersion/$shortId/save';

    final response = await client.post(
      Uri.parse(url),
      headers: await _getAuthHeaders,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['isSaved'] as bool;
    } else {
      throw _handleError(response);
    }
  }

  @override
  Future<void> markVideoAsWatched(String shortId) async {
    final url = '$_apiBaseUrl/api/daily-immersion/$shortId/watch';

    final response = await client.post(
      Uri.parse(url),
      headers: await _getAuthHeaders,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw _handleError(response);
    }
  }
}
