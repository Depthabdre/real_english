import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exception.dart';
import '../models/user_profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<UserProfileModel> getLastUserProfile();
  Future<void> cacheUserProfile(UserProfileModel profileToCache);
}

const CACHED_USER_PROFILE = 'CACHED_USER_PROFILE';

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final SharedPreferences sharedPreferences;

  ProfileLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserProfileModel> getLastUserProfile() async {
    final jsonString = sharedPreferences.getString(CACHED_USER_PROFILE);
    if (jsonString != null) {
      // Decode the String -> JSON Map -> Model
      return UserProfileModel.fromJson(json.decode(jsonString));
    } else {
      throw CacheException(message: "No cached profile found");
    }
  }

  @override
  Future<void> cacheUserProfile(UserProfileModel profileToCache) {
    return sharedPreferences.setString(
      CACHED_USER_PROFILE,
      // Model -> JSON Map -> String
      json.encode(profileToCache.toJson()),
    );
  }
}
