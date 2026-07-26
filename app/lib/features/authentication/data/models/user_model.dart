import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  UserModel({
    required this.id,
    required this.role,
    required this.fullName,
    this.email,
    this.phone,
    this.avatarUrl,
    this.village,
    this.district,
    this.state,
    required this.isPhoneVerified,
    required this.isEmailVerified,
    required this.avgRating,
    required this.totalReviews,
    this.roleSelected = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  final String id;
  final String role;
  final String fullName;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final String? village;
  final String? district;
  final String? state;
  final bool isPhoneVerified;
  final bool isEmailVerified;
  final double avgRating;
  final int totalReviews;
  final bool roleSelected;

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserEntity toEntity() => UserEntity(
        id: id,
        role: UserRole.fromApiValue(role),
        fullName: fullName,
        email: email,
        phone: phone,
        avatarUrl: avatarUrl,
        village: village,
        district: district,
        state: state,
        isPhoneVerified: isPhoneVerified,
        isEmailVerified: isEmailVerified,
        avgRating: avgRating,
        totalReviews: totalReviews,
        roleSelected: roleSelected,
      );
}
