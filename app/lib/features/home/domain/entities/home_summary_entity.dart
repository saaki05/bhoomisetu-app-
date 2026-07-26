import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../authentication/domain/entities/user_role.dart';

part 'home_summary_entity.freezed.dart';

@freezed
abstract class WeatherSnapshot with _$WeatherSnapshot {
  const factory WeatherSnapshot({
    required String location,
    required double temperatureCelsius,
    required double feelsLikeCelsius,
    required int humidityPercent,
    int? windSpeedKmh,
    required String condition,
    required String description,
    String? icon,
  }) = _WeatherSnapshot;
}

@freezed
abstract class MarketPrice with _$MarketPrice {
  const factory MarketPrice({
    required String id,
    required String cropName,
    String? category,
    required String marketName,
    String? district,
    required String state,
    required double minPrice,
    required double maxPrice,
    required double modalPrice,
    required String unit,
    required String priceDate,
  }) = _MarketPrice;
}

@freezed
abstract class GovernmentSchemePreview with _$GovernmentSchemePreview {
  const factory GovernmentSchemePreview({
    required String id,
    required String title,
    required String description,
    required String category,
    String? deadline,
    String? applicationUrl,
  }) = _GovernmentSchemePreview;
}

@freezed
abstract class NearbyBuyer with _$NearbyBuyer {
  const factory NearbyBuyer({
    required String id,
    required String fullName,
    String? avatarUrl,
    String? village,
    String? district,
    required double avgRating,
    required int totalReviews,
  }) = _NearbyBuyer;
}

@freezed
abstract class HomeGreeting with _$HomeGreeting {
  const factory HomeGreeting({
    required String fullName,
    required UserRole role,
    String? avatarUrl,
  }) = _HomeGreeting;
}

@freezed
abstract class HomeSummaryEntity with _$HomeSummaryEntity {
  const factory HomeSummaryEntity({
    required HomeGreeting greeting,
    WeatherSnapshot? weather,
    required List<MarketPrice> marketPrices,
    required List<GovernmentSchemePreview> governmentSchemes,
    required List<NearbyBuyer> nearbyBuyers,
  }) = _HomeSummaryEntity;
}
