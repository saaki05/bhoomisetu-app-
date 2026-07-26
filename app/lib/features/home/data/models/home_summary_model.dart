import 'package:json_annotation/json_annotation.dart';

import '../../../authentication/domain/entities/user_role.dart';
import '../../domain/entities/home_summary_entity.dart';

part 'home_summary_model.g.dart';

@JsonSerializable()
class WeatherSnapshotModel {
  WeatherSnapshotModel({
    required this.location,
    required this.temperatureCelsius,
    required this.feelsLikeCelsius,
    required this.humidityPercent,
    this.windSpeedKmh,
    required this.condition,
    required this.description,
    this.icon,
  });

  factory WeatherSnapshotModel.fromJson(Map<String, dynamic> json) => _$WeatherSnapshotModelFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherSnapshotModelToJson(this);

  final String location;
  final double temperatureCelsius;
  final double feelsLikeCelsius;
  final int humidityPercent;
  final int? windSpeedKmh;
  final String condition;
  final String description;
  final String? icon;

  WeatherSnapshot toEntity() => WeatherSnapshot(
        location: location,
        temperatureCelsius: temperatureCelsius,
        feelsLikeCelsius: feelsLikeCelsius,
        humidityPercent: humidityPercent,
        windSpeedKmh: windSpeedKmh,
        condition: condition,
        description: description,
        icon: icon,
      );
}

@JsonSerializable()
class MarketPriceModel {
  MarketPriceModel({
    required this.id,
    required this.cropName,
    this.category,
    required this.marketName,
    this.district,
    required this.state,
    required this.minPrice,
    required this.maxPrice,
    required this.modalPrice,
    required this.unit,
    required this.priceDate,
  });

  factory MarketPriceModel.fromJson(Map<String, dynamic> json) => _$MarketPriceModelFromJson(json);

  Map<String, dynamic> toJson() => _$MarketPriceModelToJson(this);

  final String id;
  final String cropName;
  final String? category;
  final String marketName;
  final String? district;
  final String state;
  final double minPrice;
  final double maxPrice;
  final double modalPrice;
  final String unit;
  final String priceDate;

  MarketPrice toEntity() => MarketPrice(
        id: id,
        cropName: cropName,
        category: category,
        marketName: marketName,
        district: district,
        state: state,
        minPrice: minPrice,
        maxPrice: maxPrice,
        modalPrice: modalPrice,
        unit: unit,
        priceDate: priceDate,
      );
}

@JsonSerializable()
class GovernmentSchemePreviewModel {
  GovernmentSchemePreviewModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.deadline,
    this.applicationUrl,
  });

  factory GovernmentSchemePreviewModel.fromJson(Map<String, dynamic> json) =>
      _$GovernmentSchemePreviewModelFromJson(json);

  Map<String, dynamic> toJson() => _$GovernmentSchemePreviewModelToJson(this);

  final String id;
  final String title;
  final String description;
  final String category;
  final String? deadline;
  final String? applicationUrl;

  GovernmentSchemePreview toEntity() => GovernmentSchemePreview(
        id: id,
        title: title,
        description: description,
        category: category,
        deadline: deadline,
        applicationUrl: applicationUrl,
      );
}

@JsonSerializable()
class NearbyBuyerModel {
  NearbyBuyerModel({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.village,
    this.district,
    required this.avgRating,
    required this.totalReviews,
  });

  factory NearbyBuyerModel.fromJson(Map<String, dynamic> json) => _$NearbyBuyerModelFromJson(json);

  Map<String, dynamic> toJson() => _$NearbyBuyerModelToJson(this);

  final String id;
  final String fullName;
  final String? avatarUrl;
  final String? village;
  final String? district;
  final double avgRating;
  final int totalReviews;

  NearbyBuyer toEntity() => NearbyBuyer(
        id: id,
        fullName: fullName,
        avatarUrl: avatarUrl,
        village: village,
        district: district,
        avgRating: avgRating,
        totalReviews: totalReviews,
      );
}

@JsonSerializable()
class HomeGreetingModel {
  HomeGreetingModel({required this.fullName, required this.role, this.avatarUrl});

  factory HomeGreetingModel.fromJson(Map<String, dynamic> json) => _$HomeGreetingModelFromJson(json);

  Map<String, dynamic> toJson() => _$HomeGreetingModelToJson(this);

  final String fullName;
  final String role;
  final String? avatarUrl;

  HomeGreeting toEntity() =>
      HomeGreeting(fullName: fullName, role: UserRole.fromApiValue(role), avatarUrl: avatarUrl);
}

@JsonSerializable()
class HomeSummaryModel {
  HomeSummaryModel({
    required this.greeting,
    this.weather,
    required this.marketPrices,
    required this.governmentSchemes,
    required this.nearbyBuyers,
  });

  factory HomeSummaryModel.fromJson(Map<String, dynamic> json) => _$HomeSummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$HomeSummaryModelToJson(this);

  final HomeGreetingModel greeting;
  final WeatherSnapshotModel? weather;
  final List<MarketPriceModel> marketPrices;
  final List<GovernmentSchemePreviewModel> governmentSchemes;
  final List<NearbyBuyerModel> nearbyBuyers;

  HomeSummaryEntity toEntity() => HomeSummaryEntity(
        greeting: greeting.toEntity(),
        weather: weather?.toEntity(),
        marketPrices: marketPrices.map((m) => m.toEntity()).toList(),
        governmentSchemes: governmentSchemes.map((s) => s.toEntity()).toList(),
        nearbyBuyers: nearbyBuyers.map((b) => b.toEntity()).toList(),
      );
}
