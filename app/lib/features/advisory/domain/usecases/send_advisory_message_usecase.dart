import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/failure.dart';
import '../../data/repositories_impl/advisory_repository_impl.dart';
import '../entities/advisory_message.dart';
import '../repositories/advisory_repository.dart';

part 'send_advisory_message_usecase.g.dart';

class SendAdvisoryMessageUseCase {
  SendAdvisoryMessageUseCase(this._repository);

  final AdvisoryRepository _repository;

  Future<Either<Failure, String>> call({required String message, required List<AdvisoryMessage> history}) =>
      _repository.sendMessage(message: message, history: history);
}

@riverpod
SendAdvisoryMessageUseCase sendAdvisoryMessageUseCase(SendAdvisoryMessageUseCaseRef ref) =>
    SendAdvisoryMessageUseCase(ref.watch(advisoryRepositoryProvider));
