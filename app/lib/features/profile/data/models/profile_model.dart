import 'package:json_annotation/json_annotation.dart';

import '../../../authentication/domain/entities/user_role.dart';
import '../../domain/entities/profile_entity.dart';

part 'profile_model.g.dart';

@JsonSerializable(createToJson: false)
class ProfileModel {
  ProfileModel({
    required this.id,
    required this.role,
    required this.fullName,
    this.email,
    this.phone,
    this.avatarUrl,
    this.bio,
    this.village,
    this.district,
    this.state,
    this.pincode,
    required this.isPhoneVerified,
    required this.isEmailVerified,
    required this.avgRating,
    required this.totalReviews,
    required this.roleSelected,
    this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => _$ProfileModelFromJson(json);

  final String id;
  final UserRole role;
  final String fullName;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final String? bio;
  final String? village;
  final String? district;
  final String? state;
  final String? pincode;
  final bool isPhoneVerified;
  final bool isEmailVerified;
  final double avgRating;
  final int totalReviews;
  final bool roleSelected;
  final String? createdAt;

  ProfileEntity toEntity() => ProfileEntity(
        id: id,
        role: role,
        fullName: fullName,
        email: email,
        phone: phone,
        avatarUrl: avatarUrl,
        bio: bio,
        village: village,
        district: district,
        state: state,
        pincode: pincode,
        isPhoneVerified: isPhoneVerified,
        isEmailVerified: isEmailVerified,
        avgRating: avgRating,
        totalReviews: totalReviews,
        roleSelected: roleSelected,
        createdAt: createdAt,
      );
}
