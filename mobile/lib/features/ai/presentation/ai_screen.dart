import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/injector.dart';
import '../../../app/router/app_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/responsive_constrained.dart';
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
      content:
          'Please select a topic or ask a question about microgreens, sensor values (pH, EC, light), or next steps for your growing room.',
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
    if (_isSending) return;

    final text = (preset ?? _messageController.text).trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(AiChatMessage(role: 'user', content: text));
      _isSending = true;
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      final reply = await _sendAiChatMessageUseCase(_messages);
      if (!mounted) return;

      setState(() {
        _messages.add(AiChatMessage(role: 'assistant', content: reply));
      });
    } on DioException catch (e) {
      if (!mounted) return;

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
      if (!mounted) return;

      setState(() {
        _messages.add(
          AiChatMessage(
            role: 'assistant',
            content: 'Something went wrong while generating a reply: $e',
          ),
        );
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
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 140,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bgTop = isDark ? const Color(0xFF102117) : const Color(0xFFF6F9F0);
    final bgBottom = isDark ? const Color(0xFF0C1912) : const Color(0xFFEEF4E8);
    final card = isDark ? colorScheme.surfaceContainerHigh : Colors.white;
    final border = isDark ? colorScheme.outlineVariant : const Color(0xFFCFE0C7);
    final textPrimary = isDark ? colorScheme.onSurface : AppColors.textPrimary;
    final textSecondary =
        isDark ? colorScheme.onSurfaceVariant : AppColors.textSecondary;

    final content = SafeArea(
      child: ResponsiveConstrained(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [bgTop, bgBottom],
            ),
          ),
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppSizes.paddingL),
            children: [
              _buildHeroCard(theme, isDark),
              const SizedBox(height: AppSizes.spacingL),
              _buildTopicChips(card, border, textPrimary),
              const SizedBox(height: AppSizes.spacingM),
              _buildPredictionCard(card, border, textPrimary, textSecondary, isDark),
              const SizedBox(height: AppSizes.spacingM),
              _buildChatSurface(card, border, textPrimary, textSecondary, isDark),
              const SizedBox(height: AppSizes.spacingM),
              _buildComposer(card, border, textPrimary, textSecondary),
              const SizedBox(height: AppSizes.spacingM),
            ],
          ),
        ),
      ),
    );

    if (widget.showAppBar) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.go(AppRouter.home)),
          title: const Text('AI Assistant'),
        ),
        body: content,
      );
    }

    return content;
  }

  Widget _buildHeroCard(ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF1E5F2C), Color(0xFF0F321A)]
              : const [Color(0xFF2E7D32), Color(0xFF114A20)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.spa_outlined,
                color: Colors.white.withValues(alpha: 0.96),
                size: 26,
              ),
              const SizedBox(width: AppSizes.spacingS),
              Expanded(
                child: Text(
                  'AgroTech AI Assistant\n- Your Intelligent Grow Guide',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingM),
          Text(
            'Consult on microgreens, sensor data analysis, and advanced growing strategies.',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.95),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicChips(Color card, Color border, Color textPrimary) {
    final topics = <(String, IconData, String)>[
      ('Humidity', Icons.water_drop_outlined, 'Analyze humidity trend for last 24h'),
      ('Sensor Health', Icons.monitor_heart_outlined, 'Check if any sensor is unstable'),
      ('Optimal pH', Icons.science_outlined, 'What pH range should I maintain now?'),
      ('AI Predictions', Icons.psychology_outlined, 'Give me next 48h grow recommendations'),
    ];

    return Wrap(
      spacing: AppSizes.spacingS,
      runSpacing: AppSizes.spacingS,
      children: topics
          .map(
            (topic) => ActionChip(
              avatar: Icon(topic.$2, size: 20, color: AppColors.primary),
              label: Text(topic.$1),
              backgroundColor: card,
              side: BorderSide(color: border),
              labelStyle: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.w600,
              ),
              onPressed: () => _sendMessage(topic.$3),
            ),
          )
          .toList(),
    );
  }

  Widget _buildPredictionCard(
    Color card,
    Color border,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.spa, color: AppColors.primary),
          ),
          const SizedBox(width: AppSizes.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Predictions',
                  style: TextStyle(
                    color: textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 24 / 1.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Use Camera -> Capture & Predict for live model results',
                  style: TextStyle(
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatSurface(
    Color card,
    Color border,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    final assistantMessages = _messages.where((m) => m.role == 'assistant').toList();
    final lastAssistant = assistantMessages.isNotEmpty
        ? assistantMessages.last.content
        : 'Ask the AI assistant anything about your growing room.';

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.paddingM),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2A1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              lastAssistant,
              style: TextStyle(
                color: textPrimary,
                fontSize: 16,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingL,
              vertical: AppSizes.paddingM - 2,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C3D2B) : const Color(0xFFE4EDD9),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              'Analyze humidity trend for last 24h',
              style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (_isSending) ...[
            const SizedBox(height: AppSizes.spacingM),
            Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSizes.spacingS),
                Text(
                  'Generating AI response...',
                  style: TextStyle(color: textSecondary),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildComposer(
    Color card,
    Color border,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingS),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
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
              style: TextStyle(color: textPrimary),
              decoration: InputDecoration(
                hintText: 'Ask the AI assistant...',
                hintStyle: TextStyle(color: textSecondary),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingM,
                  vertical: AppSizes.paddingS,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spacingS),
          IconButton(
            onPressed: _isSending ? null : _sendMessage,
            icon: const Icon(Icons.send_rounded),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
              minimumSize: const Size(48, 48),
            ),
          ),
        ],
      ),
    );
  }
}
