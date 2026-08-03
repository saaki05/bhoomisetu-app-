import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/cultivation_reference_data.dart';
import '../screens/farm_tools_screen.dart';

class CultivationTips extends StatefulWidget {
  const CultivationTips({super.key});

  @override
  State<CultivationTips> createState() => _CultivationTipsState();
}

class _CultivationTipsState extends State<CultivationTips> {
  String _crop = 'Wheat';
  final _daysController = TextEditingController(text: '10');
  int? _daysSinceSowing;

  @override
  void initState() {
    super.initState();
    _daysSinceSowing = int.tryParse(_daysController.text);
  }

  @override
  void dispose() {
    _daysController.dispose();
    super.dispose();
  }

  void _showTimeline() {
    setState(() => _daysSinceSowing = int.tryParse(_daysController.text.trim()) ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    final stages = cultivationTimelines[_crop] ?? const [];
    final daysSinceSowing = _daysSinceSowing;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FarmToolCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Your crop', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppConstants.spaceMd),
                DropdownButtonFormField<String>(
                  initialValue: _crop,
                  decoration: const InputDecoration(labelText: 'Crop'),
                  items: cultivationTimelines.keys
                      .map((crop) => DropdownMenuItem(value: crop, child: Text(crop)))
                      .toList(),
                  onChanged: (value) => setState(() => _crop = value ?? _crop),
                ),
                const SizedBox(height: AppConstants.spaceMd),
                TextField(
                  controller: _daysController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Days since sowing', hintText: 'e.g. 10'),
                ),
                const SizedBox(height: AppConstants.spaceLg),
                AppButton(label: 'Show timeline', icon: Icons.timeline_rounded, onPressed: _showTimeline),
              ],
            ),
          ),
          if (daysSinceSowing != null && stages.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spaceLg),
            Text(
              'Cultivation timeline · $_crop',
              style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            ...stages.map((stage) => _StageTile(stage: stage, daysSinceSowing: daysSinceSowing)),
          ],
        ],
      ),
    );
  }
}

class _StageTile extends StatelessWidget {
  const _StageTile({required this.stage, required this.daysSinceSowing});

  final CropStage stage;
  final int daysSinceSowing;

  @override
  Widget build(BuildContext context) {
    final status = stage.statusAt(daysSinceSowing);
    final (badgeLabel, badgeColor) = switch (status) {
      CropStageStatus.completed => ('Done', context.colors.outline),
      CropStageStatus.ongoing => ('Ongoing', context.colors.primary),
      CropStageStatus.upcoming => ('Upcoming', context.colors.secondary),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spaceMd),
      child: IntrinsicHeight(
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: status == CropStageStatus.upcoming ? Colors.transparent : badgeColor,
                  border: Border.all(color: badgeColor, width: 2),
                ),
              ),
              Expanded(
                child: Container(width: 2, color: context.colors.outlineVariant),
              ),
            ],
          ),
          const SizedBox(width: AppConstants.spaceMd),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: AppConstants.spaceSm),
              padding: const EdgeInsets.all(AppConstants.spaceMd),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                border: Border.all(color: context.colors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          stage.title,
                          style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                        ),
                        child: Text(
                          badgeLabel,
                          style: context.textTheme.labelSmall?.copyWith(color: badgeColor, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(stage.subtitle, style: context.textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant)),
                  if (stage.watchFor.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.spaceSm),
                    Text('Watch for', style: context.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: stage.watchFor
                          .map((pest) => Chip(
                                avatar: Icon(pest.icon, size: 16),
                                label: Text(pest.name, style: context.textTheme.labelSmall),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}
