import 'package:dartz/dartz.dart';

import '../../../../core/exceptions/failure.dart';
import '../entities/home_summary_entity.dart';

abstract class HomeRepository {
  /// Fetches the Home summary from the network and caches it. Falls back
  /// to the last cached summary when offline instead of surfacing an
  /// error, so the Home screen stays usable without connectivity.
  /// [lat]/[lon], when available, take priority over the profile's saved
  /// district for the weather card.
  Future<Either<Failure, HomeSummaryEntity>> getSummary({double? lat, double? lon});
}
