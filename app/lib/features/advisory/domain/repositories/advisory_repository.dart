import 'package:dartz/dartz.dart';

import '../../../../core/exceptions/failure.dart';
import '../entities/advisory_message.dart';

abstract class AdvisoryRepository {
  Future<Either<Failure, String>> sendMessage({
    required String message,
    required List<AdvisoryMessage> history,
  });
}
