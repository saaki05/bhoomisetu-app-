import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/listing_search_filters.dart';
import '../models/category_model.dart';
import '../models/crop_listing_model.dart';

part 'marketplace_remote_datasource.g.dart';

class MarketplaceRemoteDataSource {
  MarketplaceRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<CategoryModel>> getCategories() {
    return _client.get<List<CategoryModel>>(
      ApiConstants.categories,
      parser: (json) =>
          (json as List).map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<(List<CropListingModel> items, Map<String, dynamic>? meta)> searchListings(
    ListingSearchFilters filters,
  ) {
    return _client.getWithMeta<List<CropListingModel>>(
      ApiConstants.cropListings,
      queryParameters: {
        if (filters.query != null && filters.query!.isNotEmpty) 'q': filters.query,
        if (filters.categoryId != null) 'categoryId': filters.categoryId,
        if (filters.district != null) 'district': filters.district,
        if (filters.state != null) 'state': filters.state,
        if (filters.organicOnly == true) 'organic': 'true',
        if (filters.minPrice != null) 'minPrice': filters.minPrice,
        if (filters.maxPrice != null) 'maxPrice': filters.maxPrice,
        'sortBy': filters.sortBy.apiValue,
        'page': filters.page,
      },
      parser: (json) =>
          (json as List).map((e) => CropListingModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<CropListingModel> getListing(String id) {
    return _client.get<CropListingModel>(
      ApiConstants.cropListing(id),
      parser: (json) => CropListingModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<CropListingModel> createListing(Map<String, dynamic> payload) {
    return _client.post<CropListingModel>(
      ApiConstants.cropListings,
      data: payload,
      parser: (json) => CropListingModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<CropListingModel> updateListing(String id, Map<String, dynamic> payload) {
    return _client.put<CropListingModel>(
      ApiConstants.cropListing(id),
      data: payload,
      parser: (json) => CropListingModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<void> deleteListing(String id) {
    return _client.delete<void>(ApiConstants.cropListing(id));
  }

  Future<List<String>> uploadImages(String listingId, List<MultipartFile> images) async {
    final formData = FormData.fromMap({'images': images});
    return _client.post<List<String>>(
      '${ApiConstants.cropListing(listingId)}/images',
      data: formData,
      parser: (json) => ((json as Map<String, dynamic>)['images'] as List).cast<String>(),
    );
  }

  Future<void> reportListing(String listingId, {required String reason, String? details}) {
    return _client.post<void>(
      '${ApiConstants.cropListing(listingId)}/report',
      data: {'reason': reason, 'details': ?details},
    );
  }

  Future<bool> toggleBookmark(String listingId) {
    return _client.post<bool>(
      '${ApiConstants.cropListing(listingId)}/bookmark',
      parser: (json) => (json as Map<String, dynamic>)['bookmarked'] as bool,
    );
  }

  Future<List<CropListingModel>> getBookmarks() {
    return _client.get<List<CropListingModel>>(
      ApiConstants.bookmarks,
      parser: (json) =>
          (json as List).map((e) => CropListingModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

@Riverpod(keepAlive: true)
MarketplaceRemoteDataSource marketplaceRemoteDataSource(MarketplaceRemoteDataSourceRef ref) =>
    MarketplaceRemoteDataSource(ref.watch(apiClientProvider));
