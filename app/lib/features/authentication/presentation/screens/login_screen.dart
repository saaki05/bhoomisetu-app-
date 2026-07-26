import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/repositories_impl/auth_repository_impl.dart';
import '../providers/auth_controller.dart';
import '../providers/biometric_login_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final failure = await ref.read(authControllerProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (failure != null) {
      context.showSnackBar(failure.message, isError: true);
    }
  }

  Future<void> _loginWithBiometrics() async {
    final repo = ref.read(authRepositoryProvider);
    final success = await repo.authenticateWithBiometrics();
    if (!success || !mounted) return;
    // Biometrics only unlock a session that's already cached locally; the
    // controller's build() already restored it, so just re-trigger a build.
    ref.invalidate(authControllerProvider);
  }

  Future<void> _continueWithGoogle() async {
    setState(() => _isSubmitting = true);
    final failure = await ref.read(authControllerProvider.notifier).signInWithGoogle();
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (failure != null) {
      context.showSnackBar(failure.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final biometricEnabled = ref.watch(biometricLoginAvailableProvider).valueOrNull ?? false;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg, vertical: AppConstants.spaceXl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.eco_rounded, size: 48, color: context.colors.primary),
                const SizedBox(height: AppConstants.spaceMd),
                Text('Welcome back', style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppConstants.spaceXs),
                Text(
                  'Log in to continue trading, farming smarter.',
                  style: context.textTheme.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
                ),
                const SizedBox(height: AppConstants.spaceXl),
                AppTextField(
                  controller: _emailController,
                  label: 'Email',
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: Validators.email,
                ),
                const SizedBox(height: AppConstants.spaceMd),
                AppTextField(
                  controller: _passwordController,
                  label: 'Password',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Password is required' : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push(AppRoutes.forgotPassword),
                    child: const Text('Forgot password?'),
                  ),
                ),
                const SizedBox(height: AppConstants.spaceSm),
                AppButton(label: 'Log in', isLoading: _isSubmitting, onPressed: _submit),
                if (biometricEnabled) ...[
                  const SizedBox(height: AppConstants.spaceSm),
                  AppButton(
                    label: 'Log in with biometrics',
                    variant: AppButtonVariant.outlined,
                    icon: Icons.fingerprint_rounded,
                    onPressed: _loginWithBiometrics,
                  ),
                ],
                const SizedBox(height: AppConstants.spaceLg),
                Row(
                  children: [
                    Expanded(child: Divider(color: context.colors.outlineVariant)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceSm),
                      child: Text('or', style: context.textTheme.bodySmall),
                    ),
                    Expanded(child: Divider(color: context.colors.outlineVariant)),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceLg),
                AppButton(
                  label: 'Continue with Google',
                  variant: AppButtonVariant.outlined,
                  icon: Icons.g_mobiledata_rounded,
                  onPressed: _continueWithGoogle,
                ),
                const SizedBox(height: AppConstants.spaceSm),
                AppButton(
                  label: 'Log in with mobile OTP',
                  variant: AppButtonVariant.text,
                  icon: Icons.sms_outlined,
                  onPressed: () => context.push(AppRoutes.otpVerification),
                ),
                const SizedBox(height: AppConstants.spaceLg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    Flexible(
                      child: TextButton(
                        onPressed: () => context.push(AppRoutes.register),
                        child: const Text('Create account'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
