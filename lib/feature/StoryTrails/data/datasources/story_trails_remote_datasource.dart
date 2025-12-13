import 'dart:async';
import 'dart:convert';
// Import for Uint8List
import 'package:http/http.dart' as http;

import '../../../../core/errors/exception.dart';
import '../models/level_completion_status_model.dart'; // Import the new model
import '../models/story_trail_model.dart';

// Dependency from the Auth feature to get the auth token.
import '../../../auth_onboarding/data/datasources/auth_local_datasource.dart';

// --- ABSTRACT CLASS DEFINITION (Updated) ---
abstract class StoryTrailsRemoteDataSource {
  /// Fetches the next available story trail for a given [level] from the remote API.
  /// Returns null if all stories for the level are complete.
  Future<StoryTrailModel?> getStoryTrailForLevel(int level);

  /// Fetches a single [StoryTrailModel] by its [trailId] from the remote API.
  Future<StoryTrailModel> getStoryTrailById(String trailId);

  // --- NEW METHODS ---
  /// Fetches the raw audio data for a given segment from the API.
  Future<String> getAudioForSegment(String audioEndpoint);

  /// Marks a story trail as completed and returns the level-up status from the API.
  Future<LevelCompletionStatusModel> markStoryTrailCompleted(String trailId);
}

// --- REAL IMPLEMENTATION (Updated) ---
class StoryTrailsRemoteDataSourceImpl implements StoryTrailsRemoteDataSource {
  final http.Client client;
  final AuthLocalDatasource authLocalDataSource;

  // --- UPDATED: Set to false to use the real API ---
  final bool _useDummyData = false;

  // --- REFACTORED: A more general base URL for the whole API ---
  final String _apiBaseUrl = "http://10.48.87.123:3000"; // Your machine's IP

  StoryTrailsRemoteDataSourceImpl({
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

  Exception _handleError(http.Response response) {
    try {
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
  Future<StoryTrailModel?> getStoryTrailForLevel(int level) async {
    if (_useDummyData) {
      // Dummy data logic is unchanged if you need to switch back for testing
      return null; // For brevity
    } else {
      print("appis calling jkjaskjfjkj");
      final url = '$_apiBaseUrl/api/story-trails/level/$level/next';
      final response = await client.get(
        Uri.parse(url),
        headers: await _getAuthHeaders,
      );

      // --- UPDATED: Check for 204 when the level is complete ---
      if (response.statusCode == 204) {
        return null;
      } else if (response.statusCode == 200) {
        print("DEBUG JSON RESPONSE: ${response.body}");
        // --- UPDATED: JSON is no longer wrapped in a 'data' object ---
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return StoryTrailModel.fromJson(jsonData);
      } else {
        throw _handleError(response);
      }
    }
  }

  @override
  Future<StoryTrailModel> getStoryTrailById(String trailId) async {
    if (_useDummyData) {
      return _getDummyTrailById(trailId);
    } else {
      final url = '$_apiBaseUrl/api/story-trails/$trailId';
      final response = await client.get(
        Uri.parse(url),
        headers: await _getAuthHeaders,
      );

      if (response.statusCode == 200) {
        // --- UPDATED: JSON is no longer wrapped in a 'data' object ---
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return StoryTrailModel.fromJson(jsonData);
      } else {
        throw _handleError(response);
      }
    }
  }

  // --- NEW METHOD IMPLEMENTATION ---
  @override
  Future<String> getAudioForSegment(String audioEndpoint) async {
    // Note: audioEndpoint might be a partial path like "/api/..." or a full URL depending on logic.
    // We construct the full URL to hit your backend API.
    final url = '$_apiBaseUrl$audioEndpoint';

    final response = await client.get(
      Uri.parse(url),
      headers: await _getAuthHeaders,
    );

    if (response.statusCode == 200) {
      // NEW LOGIC: Parse JSON to get the "audioUrl" field
      final data = json.decode(response.body);
      return data['audioUrl'] as String;
    } else {
      throw _handleError(response);
    }
  }

  // --- NEW METHOD IMPLEMENTATION ---
  @override
  Future<LevelCompletionStatusModel> markStoryTrailCompleted(
    String trailId,
  ) async {
    // This method is online-only.
    final url = '$_apiBaseUrl/api/user-progress/story-trails/$trailId/complete';

    final response = await client.post(
      Uri.parse(url),
      headers: await _getAuthHeaders,
      // The body is empty as per the API spec
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return LevelCompletionStatusModel.fromJson(jsonData);
    } else {
      throw _handleError(response);
    }
  }

  // --- DUMMY DATA HELPERS (Unchanged) ---
  StoryTrailModel _getDummyTrailById(String trailId) {
    // ...
    throw UnimplementedError();
  }
}
