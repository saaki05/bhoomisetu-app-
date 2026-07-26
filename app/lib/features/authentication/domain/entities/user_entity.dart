import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_role.dart';

part 'user_entity.freezed.dart';

@freezed
abstract class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String id,
    required UserRole role,
    required String fullName,
    String? email,
    String? phone,
    String? avatarUrl,
    String? village,
    String? district,
    String? state,
    required bool isPhoneVerified,
    required bool isEmailVerified,
    required double avgRating,
    required int totalReviews,
  }) = _UserEntity;
}
