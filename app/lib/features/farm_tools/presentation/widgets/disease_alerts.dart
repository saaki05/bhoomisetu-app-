import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../data/disease_reference_data.dart';
import '../screens/farm_tools_screen.dart';

class DiseaseAlerts extends StatefulWidget {
  const DiseaseAlerts({super.key});

  @override
  State<DiseaseAlerts> createState() => _DiseaseAlertsState();
}

class _DiseaseAlertsState extends State<DiseaseAlerts> {
  String _crop = 'Wheat';

  @override
  Widget build(BuildContext context) {
    final diseases = cropDiseaseAlerts[_crop] ?? const [];
    final alerts = diseases.where((d) => d.trend == DiseaseTrend.alert).toList();
    final topAlert = alerts.isNotEmpty ? alerts.first : (diseases.isNotEmpty ? diseases.first : null);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _crop,
            decoration: const InputDecoration(labelText: 'Crop'),
            items: cropDiseaseAlerts.keys.map((crop) => DropdownMenuItem(value: crop, child: Text(crop))).toList(),
            onChanged: (value) => setState(() => _crop = value ?? _crop),
          ),
          const SizedBox(height: AppConstants.spaceLg),
          if (topAlert != null)
            FarmToolCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                  ),
                  const SizedBox(width: AppConstants.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Disease occurred nearby', style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(
                          "There's been an increased number of ${topAlert.name} cases reported in your area.",
                          style: context.textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
                        ),
                        const SizedBox(height: AppConstants.spaceMd),
                        FilledButton(
                          onPressed: () => _showPreventiveMeasures(context, topAlert),
                          child: const Text('Preventive measures'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppConstants.spaceLg),
          Text('Diseases to watch for · $_crop', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppConstants.spaceMd),
          ...diseases.map((disease) => _DiseaseCard(disease: disease, onPreventiveMeasures: () => _showPreventiveMeasures(context, disease))),
        ],
      ),
    );
  }

  void _showPreventiveMeasures(BuildContext context, CropDisease disease) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(AppConstants.spaceLg, 0, AppConstants.spaceLg, AppConstants.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(disease.name, style: sheetContext.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              '${disease.pathogen.label} · preventive measures',
              style: sheetContext.textTheme.bodySmall?.copyWith(color: sheetContext.colors.onSurfaceVariant),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            ...disease.pathogen.preventiveMeasures.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 18),
                    const SizedBox(width: AppConstants.spaceSm),
                    Expanded(child: Text(tip)),
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

class _DiseaseCard extends StatelessWidget {
  const _DiseaseCard({required this.disease, required this.onPreventiveMeasures});

  final CropDisease disease;
  final VoidCallback onPreventiveMeasures;

  @override
  Widget build(BuildContext context) {
    final trendColor = switch (disease.trend) {
      DiseaseTrend.alert => context.colors.error,
      DiseaseTrend.rising => Colors.orange,
      DiseaseTrend.stable => context.colors.outline,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spaceMd),
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
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: trendColor.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(disease.pathogen.icon, size: 18, color: trendColor),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Expanded(
                child: Text(disease.name, style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: trendColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppConstants.radiusSm)),
                child: Text(
                  disease.trend.label,
                  style: context.textTheme.labelSmall?.copyWith(color: trendColor, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text(disease.symptoms, style: context.textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant)),
          const SizedBox(height: AppConstants.spaceSm),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: onPreventiveMeasures, child: const Text('Preventive measures')),
          ),
        ],
      ),
    );
  }
}
