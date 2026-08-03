import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/profile_model.dart';

part 'profile_remote_datasource.g.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._apiClient);
  final ApiClient _apiClient;

  Future<ProfileModel> getProfile() => _apiClient.get(
        ApiConstants.profile,
        parser: (json) => ProfileModel.fromJson(Map<String, dynamic>.from(json as Map)),
      );

  Future<ProfileModel> updateProfile(Map<String, dynamic> data) => _apiClient.patch(
        ApiConstants.profile,
        data: data,
        parser: (json) => ProfileModel.fromJson(Map<String, dynamic>.from(json as Map)),
      );

  Future<ProfileModel> uploadAvatar({required Uint8List bytes, required String fileName, required String mimeType}) {
    return _apiClient.post(
      '${ApiConstants.profile}/avatar',
      data: FormData.fromMap({'image': MultipartFile.fromBytes(bytes, filename: fileName, contentType: DioMediaType.parse(mimeType))}),
      parser: (json) => ProfileModel.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }
}

@Riverpod(keepAlive: true)
ProfileRemoteDataSource profileRemoteDataSource(ProfileRemoteDataSourceRef ref) =>
    ProfileRemoteDataSource(ref.watch(apiClientProvider));
