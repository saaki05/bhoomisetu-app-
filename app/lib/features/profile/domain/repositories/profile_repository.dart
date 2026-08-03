import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import '../../../../core/exceptions/failure.dart';
import '../entities/profile_entity.dart';

abstract interface class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> getProfile();
  Future<Either<Failure, ProfileEntity>> updateProfile(ProfileUpdate update);
  Future<Either<Failure, ProfileEntity>> uploadAvatar({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  });
}
