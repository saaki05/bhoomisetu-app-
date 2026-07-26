import 'package:flutter/material.dart';

import '../../domain/entities/user_role.dart';

/// Segmented role picker shown on the registration screen. Deliberately
/// only offers [UserRole.selectableForSignUp] — admin accounts aren't
/// self-registered.
class RoleSelector extends StatelessWidget {
  const RoleSelector({super.key, required this.selected, required this.onChanged});

  final UserRole selected;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: UserRole.selectableForSignUp.map((role) {
        final isSelected = role == selected;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => onChanged(role),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? colors.primaryContainer : colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? colors.primary : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _iconFor(role),
                      color: isSelected ? colors.onPrimaryContainer : colors.onSurfaceVariant,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      role.label,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: isSelected ? colors.onPrimaryContainer : colors.onSurfaceVariant,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _iconFor(UserRole role) => switch (role) {
        UserRole.farmer => Icons.agriculture_rounded,
        UserRole.buyer => Icons.storefront_rounded,
        UserRole.expert => Icons.school_rounded,
        UserRole.admin => Icons.admin_panel_settings_rounded,
      };
}
