import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:real_english/feature/StoryTrails/domain/entities/story_segment.dart';
import 'package:real_english/feature/auth_onboarding/data/datasources/auth_local_datasource.dart';

import '../../../../core/errors/exception.dart';
import '../models/story_trail_model.dart';
import '../models/story_segment_model.dart';
import '../models/single_choice_challenge_model.dart';
import '../models/choice_model.dart';

// --- ABSTRACT CLASS DEFINITION ---
// This is the contract our repository will depend on.
abstract class StoryTrailsRemoteDataSource {
  /// Fetches a list of [StoryTrailModel] for a given [level] from the remote API.
  /// Throws a [ServerException] for all error codes.
  Future<List<StoryTrailModel>> getStoryTrailsForLevel(int level);

  /// Fetches a single [StoryTrailModel] by its [trailId] from the remote API.
  /// Throws a [ServerException] for all error codes.
  Future<StoryTrailModel> getStoryTrailById(String trailId);
}

// --- DUMMY & REAL IMPLEMENTATION ---

class StoryTrailsRemoteDataSourceImpl implements StoryTrailsRemoteDataSource {
  final http.Client client;
  final AuthLocalDatasource authLocalDataSource; // To get auth tokens

  // ✅ --- CONTROL FLAG ---
  // Set this to `false` to switch to real API calls.
  final bool _useDummyData = true;

  // Base URL for your backend API, following your app's structure.
  final String _baseUrl = "http://10.68.82.123:3000/api/story-trails";

  StoryTrailsRemoteDataSourceImpl({
    required this.client,
    required this.authLocalDataSource,
  });

  /// A centralized function to get headers with the auth token.
  Future<Map<String, String>> get _getAuthHeaders async {
    final token = await authLocalDataSource.getToken();
    if (token == null) {
      // In a real app, you might want to throw an UnauthenticatedException here
      // or handle it gracefully. For now, we'll proceed without the token.
      return {'Content-Type': 'application/json; charset=UTF-8'};
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  /// A centralized function to handle API error responses.
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
  Future<List<StoryTrailModel>> getStoryTrailsForLevel(int level) async {
    if (_useDummyData) {
      // --- DUMMY DATA IMPLEMENTATION ---
      print("🔹 Using Dummy Data for getStoryTrailsForLevel(level: $level)");
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      return _getDummyTrailsForLevel(level);
    } else {
      // --- REAL API IMPLEMENTATION ---
      // TODO: When your backend is ready, set _useDummyData to false.
      final response = await client.get(
        Uri.parse('$_baseUrl/level/$level'),
        headers: await _getAuthHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body)['data'];
        return jsonList.map((json) => StoryTrailModel.fromJson(json)).toList();
      } else {
        throw _handleError(response);
      }
    }
  }

  @override
  Future<StoryTrailModel> getStoryTrailById(String trailId) async {
    if (_useDummyData) {
      // --- DUMMY DATA IMPLEMENTATION ---
      print("🔹 Using Dummy Data for getStoryTrailById(id: $trailId)");
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      return _getDummyTrailById(trailId);
    } else {
      // --- REAL API IMPLEMENTATION ---
      // TODO: When your backend is ready, set _useDummyData to false.
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

  List<StoryTrailModel> _getDummyTrailsForLevel(int level) {
    if (level == 1) {
      return [
        _dummyStory1,
        StoryTrailModel(
          id: 'trail_002',
          title: "Tom's Lost Cat",
          description: "Help Tom find his fluffy cat, Mittens.",
          imageUrl: 'https://placekitten.com/400/300', // Placeholder image
          difficultyLevel: 1,
          segments: [], // Empty for now to keep it simple
        ),
      ];
    } else if (level == 2) {
      return [
        StoryTrailModel(
          id: 'trail_003',
          title: 'A Trip to the Market',
          description: 'Learn the names of fruits and vegetables.',
          imageUrl:
              'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400',
          difficultyLevel: 2,
          segments: [],
        ),
      ];
    }
    // Return empty list for other levels
    return [];
  }

  StoryTrailModel _getDummyTrailById(String trailId) {
    final allDummyStories = {
      'trail_001': _dummyStory1,
      'trail_002': StoryTrailModel(
        id: 'trail_002',
        title: "Tom's Lost Cat",
        description: "Help Tom find his fluffy cat, Mittens.",
        imageUrl: 'https://placekitten.com/400/300',
        difficultyLevel: 1,
        segments: [], // Empty for now to keep it simple
      ),
      'trail_003': StoryTrailModel(
        id: 'trail_003',
        title: 'A Trip to the Market',
        description: 'Learn the names of fruits and vegetables.',
        imageUrl:
            'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400',
        difficultyLevel: 2,
        segments: [],
      ),
    };

    if (allDummyStories.containsKey(trailId)) {
      return allDummyStories[trailId]!;
    } else {
      // Simulate a "Not Found" error from a real server
      throw ServerException(message: 'Story trail with ID $trailId not found.');
    }
  }

  // A complete dummy story based on our scenario
  final StoryTrailModel _dummyStory1 = const StoryTrailModel(
    id: 'trail_001',
    title: 'A Morning in the Park',
    description: 'Join Anna on her walk to the park and help her make choices.',
    imageUrl:
        'https://cbx-prod.b-cdn.net/COLOURBOX34598934.jpg?width=800&height=800&quality=70', // Placeholder
    difficultyLevel: 1,
    segments: [
      StorySegmentModel(
        id: 'seg_01',
        type: SegmentType.narration,
        audioUrl: 'audio/narration_1.mp3',
        textContent:
            'Anna wakes up early. The sun is shining. She wants to go to the park.',
        imageUrl:
            'https://media.istockphoto.com/id/924465368/photo/child-girl-wakes-up-and-stretches-in-morning-in-bed-and-stretches.jpg?s=612x612&w=0&k=20&c=i2P9ez7plJorgd72pudhWfFHr5zOJlt9jzXMbrgdXmw=',
      ),
      StorySegmentModel(
        id: 'seg_02',
        type: SegmentType.choiceChallenge,
        audioUrl: 'audio/question_1.mp3',
        textContent: 'Hmm… should I take my ☂️ umbrella or my 😎 sunglasses?',
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQUunQdGFtHQSilnd_n1XxwQILozV_pmlq7mQ&s',
        challenge: SingleChoiceChallengeModel(
          id: 'challenge_01',
          prompt: 'Which one should Anna take?',
          choices: [
            ChoiceModel(
              id: 'choice_01a',
              text: 'Umbrella',
              imageUrl: 'icons/umbrella.png',
            ),
            ChoiceModel(
              id: 'choice_01b',
              text: 'Sunglasses',
              imageUrl: 'icons/sunglasses.png',
            ),
          ],
          correctAnswerId: 'choice_01b',
        ),
      ),
      StorySegmentModel(
        id: 'seg_03',
        type: SegmentType.narration,
        audioUrl: 'audio/narration_2.mp3',
        textContent:
            'At the park, Anna sits under a big tree. She eats an apple.',
        imageUrl: 'images/anna_at_park.png',
      ),
      StorySegmentModel(
        id: 'seg_04',
        type: SegmentType.choiceChallenge,
        audioUrl: 'audio/question_2.mp3',
        textContent: 'Which one is sweet — the apple 🍎 or the lemon 🍋?',
        challenge: SingleChoiceChallengeModel(
          id: 'challenge_02',
          prompt: 'Which one is sweet?',
          choices: [
            ChoiceModel(
              id: 'choice_02a',
              text: 'Apple',
              imageUrl: 'icons/apple.png',
            ),
            ChoiceModel(
              id: 'choice_02b',
              text: 'Lemon',
              imageUrl: 'icons/lemon.png',
            ),
          ],
          correctAnswerId: 'choice_02a',
        ),
      ),
    ],
  );
}
