import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:real_english/feature/StoryTrails/domain/entities/story_segment.dart';

import '../../../../core/errors/exception.dart';
import '../models/story_trail_model.dart';
import '../models/story_segment_model.dart';
import '../models/single_choice_challenge_model.dart';
import '../models/choice_model.dart';

// Dependency from the Auth feature to get the auth token.
import '../../../auth_onboarding/data/datasources/auth_local_datasource.dart';

// --- ABSTRACT CLASS DEFINITION (Updated) ---
abstract class StoryTrailsRemoteDataSource {
  /// Fetches the next available story trail for a given [level] from the remote API.
  /// Returns null if all stories for the level are complete.
  Future<StoryTrailModel?> getStoryTrailForLevel(int level);

  /// Fetches a single [StoryTrailModel] by its [trailId] from the remote API.
  Future<StoryTrailModel> getStoryTrailById(String trailId);
}

// --- DUMMY & REAL IMPLEMENTATION (Updated) ---
class StoryTrailsRemoteDataSourceImpl implements StoryTrailsRemoteDataSource {
  final http.Client client;
  final AuthLocalDatasource authLocalDataSource;

  final bool _useDummyData = true;
  final String _baseUrl = "http://10.68.82.123:3000/api/story-trails";

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
      print("🔹 Using Dummy Data for getStoryTrailForLevel(level: $level)");
      await Future.delayed(const Duration(milliseconds: 800));
      return _getDummyTrailForLevel(level);
    } else {
      final response = await client.get(
        Uri.parse(
          '$_baseUrl/level/$level/next',
        ), // API endpoint to get the next uncompleted story
        headers: await _getAuthHeaders,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(
          response.body,
        )['data'];
        return StoryTrailModel.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        // A 404 from this endpoint means the level is complete.
        return null;
      } else {
        throw _handleError(response);
      }
    }
  }

  @override
  Future<StoryTrailModel> getStoryTrailById(String trailId) async {
    if (_useDummyData) {
      print("🔹 Using Dummy Data for getStoryTrailById(id: $trailId)");
      await Future.delayed(const Duration(milliseconds: 500));
      return _getDummyTrailById(trailId);
    } else {
      final response = await client.get(
        Uri.parse('$_baseUrl/$trailId'),
        headers: await _getAuthHeaders,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(
          response.body,
        )['data'];
        return StoryTrailModel.fromJson(jsonData);
      } else {
        throw _handleError(response);
      }
    }
  }

  // --- DUMMY DATA GENERATION HELPERS ---

  StoryTrailModel? _getDummyTrailForLevel(int level) {
    // This dummy logic just returns the first story for a given level.
    // A real implementation would be smarter, but this works for UI development.
    if (level == 1) return _dummyStory1;
    if (level == 2) return _dummyStory2;
    return null;
  }

  StoryTrailModel _getDummyTrailById(String trailId) {
    final allDummyStories = {
      'trail_001': _dummyStory1,
      'trail_002': _dummyStory2,
    };
    if (allDummyStories.containsKey(trailId)) {
      return allDummyStories[trailId]!;
    }
    throw ServerException(message: 'Story trail with ID $trailId not found.');
  }

  // UPDATED Dummy Story 1
  final StoryTrailModel _dummyStory1 = const StoryTrailModel(
    id: 'trail_001',
    title: 'A Morning in the Park',
    description: 'Join Anna on her walk to the park and help her make choices.',
    imageUrl:
        'https://images.unsplash.com/photo-1593980362394-8a4e098a5524?w=400',
    difficultyLevel: 1,
    segments: [
      StorySegmentModel(
        id: 'seg_01',
        type: SegmentType.narration,
        textContent:
            'Anna wakes up early. The sun is shining. She wants to go to the park.',
        imageUrl:
            'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?w=400',
      ),
      StorySegmentModel(
        id: 'seg_02',
        type: SegmentType.choiceChallenge,
        textContent: 'Hmm… should I take my umbrella or my sunglasses?',
        imageUrl:
            'https://images.unsplash.com/photo-1470252649378-9c29740c9fa8?w=400',
        challenge: SingleChoiceChallengeModel(
          id: 'challenge_01',
          prompt: 'Which one should Anna take?',
          choices: [
            ChoiceModel(id: 'choice_01a', text: 'Umbrella', imageUrl: '...'),
            ChoiceModel(id: 'choice_01b', text: 'Sunglasses', imageUrl: '...'),
          ],
          correctAnswerId: 'choice_01b',
          correctFeedback: "Great choice! It's sunny today. Let's go! ☀️",
          incorrectFeedback:
              "Oh no! The sun is shining too bright for an umbrella! 😅",
        ),
      ),
    ],
  );

  // UPDATED Dummy Story 2
  final StoryTrailModel _dummyStory2 = const StoryTrailModel(
    id: 'trail_002',
    title: "Tom's Lost Cat",
    description: "Help Tom find his fluffy cat, Mittens.",
    imageUrl:
        'https://cdn.forumcomm.com/dims4/default/eb8005a/2147483647/strip/true/crop/1170x792+0+0/resize/840x569!/quality/90/?url=https%3A%2F%2Fforum-communications-production-web.s3.us-west-2.amazonaws.com%2Fbrightspot%2Fe2%2Ffb%2Feee044a64e559e99b2c30ac6f908%2Ftom-from-marie.jpg',
    difficultyLevel: 2,
    segments: [],
  );
}
