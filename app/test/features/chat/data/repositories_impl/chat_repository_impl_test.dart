import 'package:bhoomisetu/core/exceptions/app_exception.dart';
import 'package:bhoomisetu/core/exceptions/failure.dart';
import 'package:bhoomisetu/core/network/socket_client.dart';
import 'package:bhoomisetu/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:bhoomisetu/features/chat/data/models/chat_models.dart';
import 'package:bhoomisetu/features/chat/data/repositories_impl/chat_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockChatRemoteDataSource extends Mock implements ChatRemoteDataSource {}

class _MockSocketClient extends Mock implements SocketClient {}

ChatConversationModel _buildConversationModel() => ChatConversationModel(
      id: 'conversation-1',
      otherParticipant: ChatParticipantModel(id: 'user-2', fullName: 'Test Farmer'),
      createdAt: '2026-07-25T00:00:00.000Z',
    );

void main() {
  late _MockChatRemoteDataSource remote;
  late _MockSocketClient socket;
  late ChatRepositoryImpl repository;

  setUp(() {
    remote = _MockChatRemoteDataSource();
    socket = _MockSocketClient();
    repository = ChatRepositoryImpl(remote, socket);
  });

  group('listConversations', () {
    test('maps the remote list into entities', () async {
      when(() => remote.listConversations()).thenAnswer((_) async => [_buildConversationModel()]);

      final result = await repository.listConversations();

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected Right'), (conversations) {
        expect(conversations, hasLength(1));
        expect(conversations.first.otherParticipant?.fullName, 'Test Farmer');
      });
    });

    test('maps a NetworkException to Failure.network', () async {
      when(() => remote.listConversations()).thenThrow(const NetworkException());

      final result = await repository.listConversations();

      expect(result.isLeft(), isTrue);
      result.fold((failure) => expect(failure, isA<NetworkFailure>()), (_) => fail('expected Left'));
    });
  });

  group('startConversation', () {
    test('forwards the participant and listing id', () async {
      when(() => remote.startConversation(otherUserId: any(named: 'otherUserId'), listingId: any(named: 'listingId')))
          .thenAnswer((_) async => _buildConversationModel());

      final result = await repository.startConversation(otherUserId: 'user-2', listingId: 'listing-1');

      expect(result.isRight(), isTrue);
      verify(() => remote.startConversation(otherUserId: 'user-2', listingId: 'listing-1')).called(1);
    });
  });
}
