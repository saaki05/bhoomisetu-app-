import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

part 'auth_remote_datasource.g.dart';

/// Talks directly to the BhoomiSetu backend's `/auth/*` endpoints. Returns
/// models, not entities — mapping to domain entities happens one layer up
/// in [AuthRepositoryImpl] so this class can stay a thin, mockable seam.
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final ApiClient _client;

  Future<AuthResponseModel> register({
    required String fullName,
    required String email,
    String? phone,
    required String password,
    required String role,
  }) {
    return _client.post<AuthResponseModel>(
      ApiConstants.register,
      data: {
        'fullName': fullName,
        'email': email,
        'phone': ?phone,
        'password': password,
        'role': role,
      },
      parser: (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<AuthResponseModel> login({required String email, required String password}) {
    return _client.post<AuthResponseModel>(
      ApiConstants.login,
      data: {'email': email, 'password': password},
      parser: (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<void> requestOtp({required String phone}) {
    return _client.post<void>(ApiConstants.requestOtp, data: {'phone': phone});
  }

  Future<AuthResponseModel> verifyOtp({
    required String phone,
    required String otp,
    String? fullName,
    String? role,
  }) {
    return _client.post<AuthResponseModel>(
      ApiConstants.verifyOtp,
      data: {
        'phone': phone,
        'otp': otp,
        'fullName': ?fullName,
        'role': ?role,
      },
      parser: (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<AuthResponseModel> signInWithGoogle({required String idToken, String? role}) {
    return _client.post<AuthResponseModel>(
      ApiConstants.googleSignIn,
      data: {'idToken': idToken, 'role': ?role},
      parser: (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<void> forgotPassword({required String email}) {
    return _client.post<void>(ApiConstants.forgotPassword, data: {'email': email});
  }

  Future<void> resetPassword({required String recoveryAccessToken, required String newPassword}) {
    return _client.post<void>(
      ApiConstants.resetPassword,
      data: {'recoveryAccessToken': recoveryAccessToken, 'newPassword': newPassword},
    );
  }

  Future<void> logout({required String refreshToken}) {
    return _client.post<void>(ApiConstants.logout, data: {'refreshToken': refreshToken});
  }

  Future<UserModel> me() {
    return _client.get<UserModel>(
      ApiConstants.me,
      parser: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<UserModel> selectRole(String role) {
    return _client.patch<UserModel>(
      ApiConstants.selectRole,
      data: {'role': role},
      parser: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }
}

@Riverpod(keepAlive: true)
AuthRemoteDataSource authRemoteDataSource(AuthRemoteDataSourceRef ref) =>
    AuthRemoteDataSource(ref.watch(apiClientProvider));
