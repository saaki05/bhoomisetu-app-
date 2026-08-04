import 'package:flutter_test/flutter_test.dart';

import 'package:bhoomisetu/features/home/data/models/home_summary_model.dart';

void main() {
  test('parses the production home summary contract', () {
    final model = HomeSummaryModel.fromJson({
      'greeting': {
        'fullName': 'BhoomiSetu Final Test',
        'role': 'farmer',
        'avatarUrl': null,
      },
      'weather': null,
      'marketPrices': [
        {
          'id': '942c36ff-f9ec-4c95-9304-29792b7a6f73',
          'cropName': 'Tomato',
          'category': 'Vegetables',
          'marketName': 'Koyambedu Market',
          'district': 'Chennai',
          'state': 'Tamil Nadu',
          'minPrice': 800,
          'maxPrice': 1600,
          'modalPrice': 1200,
          'unit': 'quintal',
          'priceDate': '2026-08-04',
        },
      ],
      'governmentSchemes': [
        {
          'id': '01e3385a-34a5-42bb-8cdd-e1618143dd8b',
          'title': 'PM-KISAN',
          'description': 'Income support for farmers.',
          'category': 'Income Support',
          'deadline': null,
          'applicationUrl': 'https://pmkisan.gov.in',
        },
      ],
      'nearbyBuyers': <Map<String, dynamic>>[],
      'recommendedCrops': <Map<String, dynamic>>[],
    });

    final entity = model.toEntity();
    expect(entity.greeting.fullName, 'BhoomiSetu Final Test');
    expect(entity.marketPrices.single.modalPrice, 1200);
    expect(entity.governmentSchemes.single.title, 'PM-KISAN');
  });
}
