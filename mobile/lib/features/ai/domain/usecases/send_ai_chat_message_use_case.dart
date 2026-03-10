import '../entities/ai_chat_message.dart';
import '../repositories/i_ai_chat_repository.dart';

class SendAiChatMessageUseCase {
  final IAiChatRepository _repository;

  SendAiChatMessageUseCase({required IAiChatRepository repository})
      : _repository = repository;

  Future<String> call(List<AiChatMessage> messages) {
    return _repository.sendMessages(messages);
  }
}