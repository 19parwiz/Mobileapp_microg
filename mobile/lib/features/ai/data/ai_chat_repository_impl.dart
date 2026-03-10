import 'package:dio/dio.dart';

import '../domain/entities/ai_chat_message.dart';
import '../domain/repositories/i_ai_chat_repository.dart';

class AiChatRepositoryImpl implements IAiChatRepository {
  final Dio _dio;

  AiChatRepositoryImpl({required Dio dio}) : _dio = dio;

  @override
  Future<String> sendMessages(List<AiChatMessage> messages) async {
    final response = await _dio.post(
      '/ai/chat',
      data: {
        'messages': messages.map((message) => message.toJson()).toList(),
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }

    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      message: 'AI response did not contain a valid message.',
    );
  }
}