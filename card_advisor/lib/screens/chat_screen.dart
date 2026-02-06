import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/theme.dart';
import '../providers/card_provider.dart';
import '../models/chat_message.dart';
import '../services/ai_chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  late AIChatService _chatService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initChat();
    });
  }

  void _initChat() {
    final cards = context.read<CardProvider>().cards;
    _chatService = AIChatService(cards);
    // Send initial greeting
    _sendInitialGreeting();
  }

  void _sendInitialGreeting() async {
    final response = await _chatService.getResponse('hello', []);
    setState(() {
      _messages.add(response);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildMessageList()),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.accentPurple, AppTheme.accentBlue],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Purchase Advisor',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Ask me about big purchases',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textDark.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white60),
            onPressed: _clearChat,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isLoading && index == _messages.length) {
          return _buildTypingIndicator();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildMessageBubble(_messages[index]),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.accentPurple, AppTheme.accentBlue],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your AI Purchase Advisor',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Ask me about any purchase you\'re planning.\nI\'ll recommend the best card to use!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textDark.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildSuggestionChip('Best card for dining?'),
                _buildSuggestionChip('Planning a trip'),
                _buildSuggestionChip('Buying a laptop'),
                _buildSuggestionChip('Maximize rewards'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        _messageController.text = text;
        _sendMessage();
      },
      backgroundColor: AppTheme.surfaceColor,
      labelStyle: TextStyle(
        color: AppTheme.textDark.withValues(alpha: 0.7),
        fontSize: 12,
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: [AppTheme.primaryGold, Color(0xFFFFD700)],
                )
              : null,
          color: isUser ? null : AppTheme.cardBackground,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.accentPurple, AppTheme.accentBlue],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'AI Advisor',
                      style: TextStyle(
                        color: AppTheme.accentBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              message.content,
              style: TextStyle(
                color: isUser ? AppTheme.darkBackground : AppTheme.textDark,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(1),
            const SizedBox(width: 4),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 100)),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.accentBlue.withValues(alpha: 0.5 + (value * 0.5)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask about a purchase...',
                filled: true,
                fillColor: AppTheme.surfaceColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
              textInputAction: TextInputAction.send,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryGold, Color(0xFFFFD700)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGold.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: _sendMessage,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.send, color: AppTheme.darkBackground),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage.user(text));
      _isLoading = true;
    });
    _messageController.clear();
    _scrollToBottom();

    // Update chat service with latest cards
    final cards = context.read<CardProvider>().cards;
    _chatService = AIChatService(cards);

    final response = await _chatService.getResponse(text, _messages);

    setState(() {
      _messages.add(response);
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
    });
    _sendInitialGreeting();
  }
}
