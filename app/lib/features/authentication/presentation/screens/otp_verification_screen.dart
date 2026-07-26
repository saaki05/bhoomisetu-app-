import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_controller.dart';

/// Two-stage phone login: enter a mobile number and request an OTP, then
/// enter the 6-digit code to verify. Kept as a single screen (rather than
/// two routes) since the back action for stage two is just "edit the
/// number", not real navigation.
class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

enum _OtpStage { enterPhone, enterCode }

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  _OtpStage _stage = _OtpStage.enterPhone;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final result = await ref.read(authControllerProvider.notifier).requestOtp(phone: _phoneController.text.trim());

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold(
      (failure) => context.showSnackBar(failure.message, isError: true),
      (_) => setState(() => _stage = _OtpStage.enterCode),
    );
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final failure = await ref.read(authControllerProvider.notifier).verifyOtp(
          phone: _phoneController.text.trim(),
          otp: _otpController.text.trim(),
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (failure != null) {
      context.showSnackBar(failure.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPhoneStage = _stage == _OtpStage.enterPhone;

    return Scaffold(
      appBar: AppBar(title: const Text('Mobile login')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spaceLg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  isPhoneStage ? Icons.phone_android_rounded : Icons.sms_outlined,
                  size: 48,
                  color: context.colors.primary,
                ),
                const SizedBox(height: AppConstants.spaceMd),
                Text(
                  isPhoneStage ? 'Verify your number' : 'Enter the code',
                  style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppConstants.spaceXs),
                Text(
                  isPhoneStage
                      ? "We'll send a one-time code to your mobile number."
                      : 'Enter the 6-digit code sent to ${_phoneController.text.trim()}',
                  style: context.textTheme.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
                ),
                const SizedBox(height: AppConstants.spaceXl),
                AppTextField(
                  controller: _phoneController,
                  label: 'Mobile number',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  enabled: isPhoneStage,
                  validator: Validators.indianPhone,
                ),
                if (!isPhoneStage) ...[
                  const SizedBox(height: AppConstants.spaceMd),
                  AppTextField(
                    controller: _otpController,
                    label: '6-digit OTP',
                    prefixIcon: Icons.lock_clock_outlined,
                    keyboardType: TextInputType.number,
                    validator: Validators.otp,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => setState(() => _stage = _OtpStage.enterPhone),
                      child: const Text('Change number'),
                    ),
                  ),
                ],
                const SizedBox(height: AppConstants.spaceLg),
                AppButton(
                  label: isPhoneStage ? 'Send OTP' : 'Verify & continue',
                  isLoading: _isSubmitting,
                  onPressed: isPhoneStage ? _requestOtp : _verifyOtp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
