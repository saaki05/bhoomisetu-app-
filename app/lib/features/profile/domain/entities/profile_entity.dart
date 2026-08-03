import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../authentication/domain/entities/user_role.dart';

part 'profile_entity.freezed.dart';

@freezed
abstract class ProfileEntity with _$ProfileEntity {
  const factory ProfileEntity({
    required String id,
    required UserRole role,
    required String fullName,
    String? email,
    String? phone,
    String? avatarUrl,
    String? bio,
    String? village,
    String? district,
    String? state,
    String? pincode,
    required bool isPhoneVerified,
    required bool isEmailVerified,
    required double avgRating,
    required int totalReviews,
    required bool roleSelected,
    String? createdAt,
  }) = _ProfileEntity;
}

@freezed
abstract class ProfileUpdate with _$ProfileUpdate {
  const factory ProfileUpdate({
    required String fullName,
    String? phone,
    String? bio,
    String? village,
    String? district,
    String? state,
    String? pincode,
    double? latitude,
    double? longitude,
  }) = _ProfileUpdate;
}
