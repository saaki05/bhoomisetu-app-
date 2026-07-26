import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/home_summary_entity.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key, required this.weather});

  final WeatherSnapshot? weather;

  @override
  Widget build(BuildContext context) {
    if (weather == null) {
      return Container(
        padding: const EdgeInsets.all(AppConstants.spaceLg),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
        child: Row(
          children: [
            Icon(Icons.cloud_off_rounded, color: context.colors.onSurfaceVariant),
            const SizedBox(width: AppConstants.spaceMd),
            Expanded(
              child: Text(
                'Weather data is unavailable right now',
                style: context.textTheme.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
              ),
            ),
          ],
        ),
      );
    }

    final w = weather!;
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.skyBlue, AppColors.skyBlue.withValues(alpha: 0.6)],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  w.location,
                  style: context.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '${w.temperatureCelsius.round()}°C · ${w.description}',
                  style: context.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: AppConstants.spaceSm),
                Row(
                  children: [
                    _WeatherStat(icon: Icons.water_drop_outlined, label: '${w.humidityPercent}%'),
                    if (w.windSpeedKmh != null) ...[
                      const SizedBox(width: AppConstants.spaceMd),
                      _WeatherStat(icon: Icons.air_rounded, label: '${w.windSpeedKmh} km/h'),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Icon(_iconFor(w.condition), size: 56, color: Colors.white),
        ],
      ),
    );
  }

  IconData _iconFor(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny_rounded;
      case 'clouds':
        return Icons.cloud_rounded;
      case 'rain':
      case 'drizzle':
        return Icons.grain_rounded;
      case 'thunderstorm':
        return Icons.thunderstorm_rounded;
      case 'snow':
        return Icons.ac_unit_rounded;
      default:
        return Icons.wb_cloudy_rounded;
    }
  }
}

class _WeatherStat extends StatelessWidget {
  const _WeatherStat({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 4),
        Text(label, style: context.textTheme.bodySmall?.copyWith(color: Colors.white70)),
      ],
    );
  }
}
