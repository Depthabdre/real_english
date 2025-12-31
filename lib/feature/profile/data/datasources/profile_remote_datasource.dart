import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../core/errors/exception.dart';
import '../../../auth_onboarding/data/datasources/auth_local_datasource.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile();

  Future<UserProfileModel> updateProfile({String? fullName, File? imageFile});
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final http.Client client;
  final AuthLocalDatasource authLocalDataSource;

  // Your Backend IP
  final String _apiBaseUrl = "http://192.168.107.123:3000/api/profile";

  ProfileRemoteDataSourceImpl({
    required this.client,
    required this.authLocalDataSource,
  });

  @override
  Future<UserProfileModel> getUserProfile() async {
    final token = await authLocalDataSource.getToken();
    final response = await client.get(
      Uri.parse('$_apiBaseUrl/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      // Backend returns: { "status": "success", "data": { ... } }
      return UserProfileModel.fromJson(decoded['data']);
    } else {
      throw ServerException(message: _parseError(response.body));
    }
  }

  @override
  Future<UserProfileModel> updateProfile({
    String? fullName,
    File? imageFile,
  }) async {
    final uri = Uri.parse('$_apiBaseUrl/me');
    final token = await authLocalDataSource.getToken();

    // 1. Prepare Multipart Request (PATCH)
    var request = http.MultipartRequest('PATCH', uri);

    // 2. Add Headers
    request.headers['Authorization'] = 'Bearer $token';

    // 3. Add Text Fields
    if (fullName != null && fullName.isNotEmpty) {
      request.fields['fullName'] = fullName;
    }

    // 4. Add File (if present)
    if (imageFile != null) {
      // 'avatar' matches the upload.single('avatar') in your Backend Route
      request.files.add(
        await http.MultipartFile.fromPath('avatar', imageFile.path),
      );
    }

    // 5. Send Request
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // --- THE FIX IS HERE ---
        // Your backend returns: { "status": "success", "message": "Profile updated successfully" }
        // It does NOT return the new data.
        // So, we must manually fetch the fresh profile to see the changes.
        print("✅ Update success. Fetching fresh profile...");
        return await getUserProfile();
      } else {
        throw ServerException(message: _parseError(response.body));
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  String _parseError(String body) {
    try {
      return json.decode(body)['error'] ?? "Unknown Server Error";
    } catch (_) {
      return "Unknown Server Error";
    }
  }
}
