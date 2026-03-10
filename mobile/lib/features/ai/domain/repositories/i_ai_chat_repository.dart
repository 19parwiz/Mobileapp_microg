import '../entities/ai_chat_message.dart';

abstract class IAiChatRepository {
  Future<String> sendMessages(List<AiChatMessage> messages);
}