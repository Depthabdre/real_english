import 'dart:io'; // Needed for File
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart'; // Adjust path to your core errors
import '../entities/user_profile.dart';

abstract class ProfileRepository {
  /// Fetches the full Garden State (Tree, Streak, Identity).
  Future<Either<Failures, UserProfile>> getUserProfile();

  /// Updates the user's Name and/or Avatar.
  /// [imageFile] is the local file selected from the gallery.
  /// Returns the updated [UserProfile] to immediately refresh the UI.
  Future<Either<Failures, UserProfile>> updateProfileIdentity({
    String? fullName,
    File? imageFile,
  });
}
