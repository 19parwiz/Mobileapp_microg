import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/injector.dart';
import '../../../app/router/app_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../domain/entities/ai_chat_message.dart';
import '../domain/usecases/send_ai_chat_message_use_case.dart';

class AIScreen extends StatefulWidget {
  final bool showAppBar;

  const AIScreen({super.key, this.showAppBar = false});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final SendAiChatMessageUseCase _sendAiChatMessageUseCase;

  final List<AiChatMessage> _messages = const [
    AiChatMessage(
      role: 'assistant',
      content: 'Ask me about microgreens, sensors, pH, EC, lighting, or what to do next in your growing room.',
    ),
  ].toList();

  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _sendAiChatMessageUseCase = getIt<SendAiChatMessageUseCase>();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? preset]) async {
    if (_isSending) {
      return;
    }

    final text = (preset ?? _messageController.text).trim();
    if (text.isEmpty) {
      return;
    }

    setState(() {
      _messages.add(AiChatMessage(role: 'user', content: text));
      _isSending = true;
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      final reply = await _sendAiChatMessageUseCase(_messages);
      if (!mounted) {
        return;
      }

      setState(() {
        _messages.add(AiChatMessage(role: 'assistant', content: reply));
      });
    } on DioException catch (e) {
      if (!mounted) {
        return;
      }

      final responseData = e.response?.data;
      String errorMessage = 'Failed to contact AI service.';
      if (responseData is Map<String, dynamic> && responseData['message'] is String) {
        errorMessage = responseData['message'] as String;
      } else if (e.message != null && e.message!.isNotEmpty) {
        errorMessage = e.message!;
      }

      setState(() {
        _messages.add(AiChatMessage(role: 'assistant', content: errorMessage));
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _messages.add(AiChatMessage(
          role: 'assistant',
          content: 'Something went wrong while generating a reply: $e',
        ));
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: AppSizes.spacingM),
            _buildPredictionPlaceholder(context),
            const SizedBox(height: AppSizes.spacingM),
            _buildQuickQuestions(),
            const SizedBox(height: AppSizes.spacingM),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                  border: Border.all(color: AppColors.border),
                ),
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  itemCount: _messages.length + (_isSending ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: AppSizes.spacingM),
                  itemBuilder: (context, index) {
                    if (_isSending && index == _messages.length) {
                      return _buildTypingBubble();
                    }
                    return _buildMessageBubble(context, _messages[index]);
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacingM),
            _buildComposer(),
          ],
        ),
      ),
    );

    if (widget.showAppBar) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () => context.go(AppRouter.home),
          ),
          title: const Text('AI Chat'),
        ),
        body: content,
      );
    }

    return content;
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingS),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppSizes.spacingM),
              Expanded(
                child: Text(
                  'AgroTech AI Assistant',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingS),
          Text(
            'Ask questions about your microgreens, sensor readings, camera observations, and growing decisions.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickQuestions() {
    final prompts = [
      'What is the ideal humidity for microgreens?',
      'How should I react to high pH?',
      'What should I check if growth slows down?',
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: prompts.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSizes.spacingS),
        itemBuilder: (context, index) {
          final prompt = prompts[index];
          return ActionChip(
            label: Text(prompt),
            onPressed: () => _sendMessage(prompt),
            backgroundColor: AppColors.surface,
            side: const BorderSide(color: AppColors.border),
          );
        },
      ),
    );
  }

  Widget _buildPredictionPlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingS),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: const Icon(
              Icons.local_florist,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppSizes.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plant Prediction',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: AppSizes.spacingXS),
                Text(
                  'Your trained plant model will be connected later. For now, this tab is active for AI chat only.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, AiChatMessage message) {
    final isUser = message.role == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            color: isUser ? AppColors.primary : AppColors.backgroundLight,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(AppSizes.radiusL),
              topRight: const Radius.circular(AppSizes.radiusL),
              bottomLeft: Radius.circular(isUser ? AppSizes.radiusL : AppSizes.radiusS),
              bottomRight: Radius.circular(isUser ? AppSizes.radiusS : AppSizes.radiusL),
            ),
            border: isUser ? null : Border.all(color: AppColors.border),
          ),
          child: Text(
            message.content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isUser ? Colors.white : AppColors.textPrimary,
                  height: 1.4,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingS,
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(color: AppColors.border),
        ),
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingS),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: const InputDecoration(
                hintText: 'Ask the AI assistant...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
              ),
            ),
          ),
          IconButton.filled(
            onPressed: _isSending ? null : _sendMessage,
            icon: const Icon(Icons.arrow_upward),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

