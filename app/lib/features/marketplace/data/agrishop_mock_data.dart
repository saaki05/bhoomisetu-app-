class AgrishopPreview {
  const AgrishopPreview({required this.name, required this.distanceKm, required this.verified});

  final String name;
  final double distanceKm;
  final bool verified;
}

/// Static placeholder list standing in for a real "shops near me" lookup —
/// there's no shop/geolocation backend endpoint yet, so this keeps the
/// section demo-able without one.
const List<AgrishopPreview> nearbyAgrishops = [
  AgrishopPreview(name: 'Shree Krishi Kendra', distanceKm: 4.2, verified: true),
  AgrishopPreview(name: 'Annapurna Agro Store', distanceKm: 7.8, verified: true),
  AgrishopPreview(name: 'Kisan Mitra Agro', distanceKm: 11.5, verified: false),
  AgrishopPreview(name: 'Green Field Traders', distanceKm: 15.3, verified: true),
];
