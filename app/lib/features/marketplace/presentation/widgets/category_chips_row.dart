import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../providers/categories_provider.dart';

/// Maps the backend's Material icon-name strings to actual [IconData], and
/// assigns each category a distinct accent so the row reads as a set of
/// destinations rather than a wall of identical chips.
const Map<String, IconData> _categoryIcons = {
  'grass': Icons.grass_rounded,
  'eco': Icons.eco_rounded,
  'nutrition': Icons.apple_rounded,
  'spa': Icons.spa_rounded,
  'opacity': Icons.opacity_rounded,
  'local_fire_department': Icons.local_fire_department_rounded,
  'payments': Icons.payments_rounded,
  'local_florist': Icons.local_florist_rounded,
  'icecream': Icons.icecream_rounded,
  'more_horiz': Icons.more_horiz_rounded,
};

const List<Color> _categoryAccents = [
  Color(0xFF2E7D4F),
  Color(0xFFE8A33D),
  Color(0xFFD32F2F),
  Color(0xFF8E24AA),
  Color(0xFF0288D1),
  Color(0xFFF9A825),
  Color(0xFF00897B),
  Color(0xFFC2185B),
  Color(0xFF6D4C33),
  Color(0xFF616161),
];

class CategoryChipsRow extends ConsumerWidget {
  const CategoryChipsRow({super.key, required this.selectedCategoryId, required this.onSelected});

  final String? selectedCategoryId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      loading: () => const SizedBox(height: 88),
      error: (_, _) => const SizedBox.shrink(),
      data: (categories) => SizedBox(
        height: 88,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length + 1,
          separatorBuilder: (_, _) => const SizedBox(width: AppConstants.spaceMd),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _CategoryTile(
                label: 'All',
                icon: Icons.apps_rounded,
                color: context.colors.primary,
                selected: selectedCategoryId == null,
                onTap: () => onSelected(null),
              );
            }
            final category = categories[index - 1];
            return _CategoryTile(
              label: category.name,
              icon: _categoryIcons[category.iconName] ?? Icons.category_rounded,
              color: _categoryAccents[(index - 1) % _categoryAccents.length],
              selected: selectedCategoryId == category.id,
              onTap: () => onSelected(category.id),
            );
          },
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: selected ? color : color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: selected ? null : Border.all(color: color.withValues(alpha: 0.25)),
                boxShadow: selected
                    ? [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4))]
                    : null,
              ),
              child: Icon(icon, color: selected ? Colors.white : color, size: 26),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelSmall?.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? color : context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
