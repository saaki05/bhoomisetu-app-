import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/crop_listing_entity.dart';

part 'crop_listing_model.g.dart';

@JsonSerializable(createToJson: false)
class ListingFarmerModel {
  ListingFarmerModel({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    required this.avgRating,
    required this.totalReviews,
    this.phone,
  });

  factory ListingFarmerModel.fromJson(Map<String, dynamic> json) => _$ListingFarmerModelFromJson(json);

  final String id;
  final String fullName;
  final String? avatarUrl;
  final double avgRating;
  final int totalReviews;
  final String? phone;

  ListingFarmer toEntity() => ListingFarmer(
        id: id,
        fullName: fullName,
        avatarUrl: avatarUrl,
        avgRating: avgRating,
        totalReviews: totalReviews,
        phone: phone,
      );
}

@JsonSerializable(createToJson: false)
class CropListingModel {
  CropListingModel({
    required this.id,
    required this.farmerId,
    required this.categoryId,
    this.categoryName,
    required this.title,
    this.description,
    required this.status,
    required this.pricePerUnit,
    required this.unit,
    required this.quantityAvailable,
    this.suggestedMarketPrice,
    required this.isOrganic,
    this.harvestDate,
    this.district,
    this.state,
    this.village,
    required this.avgRating,
    required this.totalReviews,
    required this.images,
    this.farmer,
    required this.createdAt,
  });

  factory CropListingModel.fromJson(Map<String, dynamic> json) => _$CropListingModelFromJson(json);

  final String id;
  final String farmerId;
  final String categoryId;
  final String? categoryName;
  final String title;
  final String? description;
  final String status;
  final double pricePerUnit;
  final String unit;
  final double quantityAvailable;
  final double? suggestedMarketPrice;
  final bool isOrganic;
  final String? harvestDate;
  final String? district;
  final String? state;
  final String? village;
  final double avgRating;
  final int totalReviews;
  final List<String> images;
  final ListingFarmerModel? farmer;
  final String createdAt;

  CropListingEntity toEntity() => CropListingEntity(
        id: id,
        farmerId: farmerId,
        categoryId: categoryId,
        categoryName: categoryName,
        title: title,
        description: description,
        status: status,
        pricePerUnit: pricePerUnit,
        unit: unit,
        quantityAvailable: quantityAvailable,
        suggestedMarketPrice: suggestedMarketPrice,
        isOrganic: isOrganic,
        harvestDate: harvestDate,
        district: district,
        state: state,
        village: village,
        avgRating: avgRating,
        totalReviews: totalReviews,
        images: images,
        farmer: farmer?.toEntity(),
        createdAt: createdAt,
      );
}
