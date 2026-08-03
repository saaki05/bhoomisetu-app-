import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/failure.dart';
import '../../data/repositories_impl/profile_repository_impl.dart';
import '../../domain/entities/profile_entity.dart';

part 'profile_controller.g.dart';

@riverpod
class ProfileController extends _$ProfileController {
  @override
  Future<ProfileEntity> build() async {
    final result = await ref.watch(profileRepositoryProvider).getProfile();
    return result.fold((failure) => throw failure, (profile) => profile);
  }

  Future<Failure?> save(ProfileUpdate update) async {
    final result = await ref.read(profileRepositoryProvider).updateProfile(update);
    return result.fold((failure) => failure, (profile) {
      state = AsyncData(profile);
      return null;
    });
  }

  Future<Failure?> uploadAvatar({required Uint8List bytes, required String fileName, required String mimeType}) async {
    final result = await ref.read(profileRepositoryProvider).uploadAvatar(
          bytes: bytes,
          fileName: fileName,
          mimeType: mimeType,
        );
    return result.fold((failure) => failure, (profile) {
      state = AsyncData(profile);
      return null;
    });
  }
}
