import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories_impl/auth_repository_impl.dart';

part 'biometric_login_provider.g.dart';

/// Whether the login screen should offer a "Log in with biometrics" button:
/// true only when the device has usable biometric hardware AND the user
/// previously opted in via Settings. Modeled as a provider (watched from
/// `build()`) rather than an imperative `initState` + `setState` so it
/// never races with in-flight widget-tree rebuilds.
@riverpod
Future<bool> biometricLoginAvailable(BiometricLoginAvailableRef ref) async {
  final repository = ref.watch(authRepositoryProvider);
  if (!await repository.isBiometricAvailable) return false;
  return repository.isBiometricLoginEnabled;
}
