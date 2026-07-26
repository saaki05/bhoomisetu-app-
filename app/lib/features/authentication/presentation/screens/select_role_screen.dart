import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/user_role.dart';
import '../providers/auth_controller.dart';
import '../widgets/role_selector.dart';

/// Shown once, right after a Google or OTP signup that skipped the role
/// picker on the register form. The router redirects here whenever
/// `user.roleSelected == false` and won't let the user past it until they
/// choose — there's no back/skip action by design.
class SelectRoleScreen extends ConsumerStatefulWidget {
  const SelectRoleScreen({super.key});

  @override
  ConsumerState<SelectRoleScreen> createState() => _SelectRoleScreenState();
}

class _SelectRoleScreenState extends ConsumerState<SelectRoleScreen> {
  UserRole _role = UserRole.farmer;
  bool _isSubmitting = false;

  Future<void> _continue() async {
    setState(() => _isSubmitting = true);
    final failure = await ref.read(authControllerProvider.notifier).selectRole(_role);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (failure != null) {
      context.showSnackBar(failure.message, isError: true);
    }
    // On success the router's redirect reacts to the updated user
    // automatically — no navigation call needed here.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(Icons.eco_rounded, size: 48, color: context.colors.primary),
              const SizedBox(height: AppConstants.spaceMd),
              Text(
                'One last thing',
                style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppConstants.spaceXs),
              Text(
                'How will you be using BhoomiSetu?',
                style: context.textTheme.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
              ),
              const SizedBox(height: AppConstants.spaceXl),
              RoleSelector(selected: _role, onChanged: (role) => setState(() => _role = role)),
              const Spacer(),
              AppButton(label: 'Continue', isLoading: _isSubmitting, onPressed: _continue),
            ],
          ),
        ),
      ),
    );
  }
}
