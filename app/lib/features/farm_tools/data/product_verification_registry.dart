class VerifiedProduct {
  const VerifiedProduct({required this.code, required this.name, required this.brand, required this.category});

  final String code;
  final String name;
  final String brand;
  final String category;
}

/// Static demo registry of "genuine" batch codes — stands in for a real
/// manufacturer verification API. A code not listed here is reported as
/// unverified rather than treated as an error, matching how a farmer would
/// actually experience scanning an unregistered or counterfeit product.
const List<VerifiedProduct> verifiedProductRegistry = [
  VerifiedProduct(code: 'BHS-0001', name: 'Urea 46% N', brand: 'IFFCO', category: 'Fertilizer'),
  VerifiedProduct(code: 'BHS-0002', name: 'DAP 18-46-0', brand: 'IFFCO', category: 'Fertilizer'),
  VerifiedProduct(code: 'BHS-0003', name: 'Bomba Pro Insecticide (Imidacloprid 70% WG)', brand: 'Noble Crop Science', category: 'Crop Protection'),
  VerifiedProduct(code: 'BHS-0004', name: 'NPK 19:19:19', brand: 'Krishi Giri', category: 'Fertilizer'),
  VerifiedProduct(code: 'BHS-0005', name: 'VNR Hybrid Tomato Seeds', brand: 'VNR Seeds', category: 'Seeds'),
  VerifiedProduct(code: 'BHS-0006', name: 'Neem Oil Concentrate', brand: 'EBS Essential Biosciences', category: 'Crop Protection'),
];

VerifiedProduct? lookupVerifiedProduct(String rawCode) {
  final code = rawCode.trim().toUpperCase();
  for (final product in verifiedProductRegistry) {
    if (product.code == code) return product;
  }
  return null;
}
