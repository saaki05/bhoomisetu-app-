import 'package:flutter/material.dart';

enum DiseasePathogen { fungus, bacteria, virus, insect }

extension DiseasePathogenLabel on DiseasePathogen {
  String get label => switch (this) {
        DiseasePathogen.fungus => 'Fungus',
        DiseasePathogen.bacteria => 'Bacteria',
        DiseasePathogen.virus => 'Virus',
        DiseasePathogen.insect => 'Insect',
      };

  IconData get icon => switch (this) {
        DiseasePathogen.fungus => Icons.grain_outlined,
        DiseasePathogen.bacteria => Icons.bloodtype_outlined,
        DiseasePathogen.virus => Icons.coronavirus_outlined,
        DiseasePathogen.insect => Icons.pest_control_outlined,
      };

  /// Generic, pathogen-class-level guidance — not a diagnosis for any
  /// specific case, just the standard first-response advice extension
  /// services publish for that class of pathogen.
  List<String> get preventiveMeasures => switch (this) {
        DiseasePathogen.fungus => [
            'Apply a recommended fungicide spray at first sign of symptoms.',
            'Avoid overhead irrigation; water at the base of the plant.',
            'Remove and destroy infected plant debris after harvest.',
            'Rotate with a non-host crop next season.',
          ],
        DiseasePathogen.bacteria => [
            'Use copper-based bactericide sprays as a preventive measure.',
            'Avoid working in fields when foliage is wet.',
            'Use certified, disease-free seed or seedlings.',
            'Remove infected plants promptly to limit spread.',
          ],
        DiseasePathogen.virus => [
            'Control the insect vector (aphids/whiteflies) with recommended sprays.',
            'Remove and destroy infected plants — there is no cure once infected.',
            'Use virus-resistant varieties where available.',
            'Avoid planting near already-infected fields.',
          ],
        DiseasePathogen.insect => [
            'Set up pheromone traps to monitor and reduce adult populations.',
            'Apply neem-based or recommended insecticide sprays early.',
            'Encourage natural predators; avoid excess broad-spectrum spraying.',
            'Inspect the field regularly during the vulnerable growth stage.',
          ],
      };
}

enum DiseaseTrend { rising, alert, stable }

extension DiseaseTrendLabel on DiseaseTrend {
  String get label => switch (this) {
        DiseaseTrend.rising => 'Rising',
        DiseaseTrend.alert => 'Alert',
        DiseaseTrend.stable => 'Stable',
      };
}

class CropDisease {
  const CropDisease({
    required this.name,
    required this.pathogen,
    required this.trend,
    required this.symptoms,
  });

  final String name;
  final DiseasePathogen pathogen;
  final DiseaseTrend trend;
  final String symptoms;
}

/// Static, illustrative "what to watch for" reference per crop — mirrors the
/// kind of regional disease-tracker list agri-input apps publish. Not sourced
/// from any live outbreak-reporting feed.
const Map<String, List<CropDisease>> cropDiseaseAlerts = {
  'Wheat': [
    CropDisease(
      name: 'Fusarium Head Blight',
      pathogen: DiseasePathogen.fungus,
      trend: DiseaseTrend.alert,
      symptoms: 'Bleached spikelets with pink-orange spore masses on the head.',
    ),
    CropDisease(
      name: 'Septoria Tritici Blotch',
      pathogen: DiseasePathogen.fungus,
      trend: DiseaseTrend.rising,
      symptoms: 'Yellow-brown lesions with dark specks on lower leaves.',
    ),
    CropDisease(
      name: 'Yellow Rust',
      pathogen: DiseasePathogen.fungus,
      trend: DiseaseTrend.stable,
      symptoms: 'Yellow-orange pustules in stripes along the leaf veins.',
    ),
  ],
  'Cotton': [
    CropDisease(
      name: 'Cotton Leaf Curl Virus',
      pathogen: DiseasePathogen.virus,
      trend: DiseaseTrend.alert,
      symptoms: 'Upward leaf curling, thickened veins, stunted growth.',
    ),
    CropDisease(
      name: 'Bacterial Blight',
      pathogen: DiseasePathogen.bacteria,
      trend: DiseaseTrend.rising,
      symptoms: 'Angular water-soaked spots that turn dark brown on leaves.',
    ),
    CropDisease(
      name: 'Pink Bollworm',
      pathogen: DiseasePathogen.insect,
      trend: DiseaseTrend.stable,
      symptoms: 'Rosette flowers and holes bored into developing bolls.',
    ),
  ],
  'Rice': [
    CropDisease(
      name: 'Bacterial Leaf Blight',
      pathogen: DiseasePathogen.bacteria,
      trend: DiseaseTrend.alert,
      symptoms: 'Water-soaked stripes along leaf margins turning yellow-white.',
    ),
    CropDisease(
      name: 'Rice Blast',
      pathogen: DiseasePathogen.fungus,
      trend: DiseaseTrend.rising,
      symptoms: 'Diamond-shaped lesions with grey centres on leaves.',
    ),
    CropDisease(
      name: 'Brown Planthopper',
      pathogen: DiseasePathogen.insect,
      trend: DiseaseTrend.stable,
      symptoms: 'Yellowing and drying of patches — "hopper burn" in the field.',
    ),
  ],
  'Tomato': [
    CropDisease(
      name: 'Bacterial Spot',
      pathogen: DiseasePathogen.bacteria,
      trend: DiseaseTrend.alert,
      symptoms: 'Small yellow-green lesions that darken on leaves and fruit.',
    ),
    CropDisease(
      name: 'Early Blight',
      pathogen: DiseasePathogen.fungus,
      trend: DiseaseTrend.rising,
      symptoms: 'Concentric-ring brown spots on older, lower leaves.',
    ),
    CropDisease(
      name: 'Tomato Leaf Curl Virus',
      pathogen: DiseasePathogen.virus,
      trend: DiseaseTrend.stable,
      symptoms: 'Upward curling, yellowing leaves and stunted plants.',
    ),
  ],
  'Maize': [
    CropDisease(
      name: 'Fall Armyworm',
      pathogen: DiseasePathogen.insect,
      trend: DiseaseTrend.alert,
      symptoms: 'Ragged "window-pane" feeding holes in the whorl leaves.',
    ),
    CropDisease(
      name: 'Maize Streak Virus',
      pathogen: DiseasePathogen.virus,
      trend: DiseaseTrend.rising,
      symptoms: 'Narrow yellow-white streaks running parallel to leaf veins.',
    ),
    CropDisease(
      name: 'Turcicum Leaf Blight',
      pathogen: DiseasePathogen.fungus,
      trend: DiseaseTrend.stable,
      symptoms: 'Long, cigar-shaped grey-green lesions on leaves.',
    ),
  ],
};
