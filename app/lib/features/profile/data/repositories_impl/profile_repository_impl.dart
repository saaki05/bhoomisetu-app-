import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/exceptions/failure.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

part 'profile_repository_impl.g.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remote);
  final ProfileRemoteDataSource _remote;

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    try {
      return Right((await _remote.getProfile()).toEntity());
    } on AppException catch (error) {
      return Left(failureFromException(error));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile(ProfileUpdate update) async {
    try {
      final data = <String, dynamic>{
        'fullName': update.fullName,
        'phone': ?update.phone,
        'bio': ?update.bio,
        'village': ?update.village,
        'district': ?update.district,
        'state': ?update.state,
        'pincode': ?update.pincode,
        'latitude': ?update.latitude,
        'longitude': ?update.longitude,
      };
      return Right((await _remote.updateProfile(data)).toEntity());
    } on AppException catch (error) {
      return Left(failureFromException(error));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> uploadAvatar({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) async {
    try {
      return Right((await _remote.uploadAvatar(bytes: bytes, fileName: fileName, mimeType: mimeType)).toEntity());
    } on AppException catch (error) {
      return Left(failureFromException(error));
    }
  }
}

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(ProfileRepositoryRef ref) =>
    ProfileRepositoryImpl(ref.watch(profileRemoteDataSourceProvider));
