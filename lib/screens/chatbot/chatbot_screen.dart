import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../config/theme.dart';
import '../../models/message_model.dart';
import '../../services/gemini_service.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/custom_text_field.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final GeminiService _geminiService = GeminiService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<MessageModel> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Welcome message
    _messages.add(MessageModel(
      id: '0',
      content: 'Bonjour ! Je suis votre assistant agricole intelligent. Comment puis-je vous aider aujourd\'hui ?\n\nVous pouvez me poser des questions sur :\n- Les cultures et semences\n- Les techniques agricoles\n- La meteo et son impact\n- Les conseils de saison',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Add user message
    setState(() {
      _messages.add(MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });
    _messageController.clear();
    _scrollToBottom();

    // Get AI response
    try {
      final response = await _geminiService.sendMessage(message);
      
      setState(() {
        _messages.add(MessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isTyping = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(MessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: 'Desole, une erreur s\'est produite. Veuillez reessayer.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isTyping = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.eco,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assistant IA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Toujours disponible',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Text('Effacer la conversation'),
                  content: const Text(
                    'Voulez-vous effacer tous les messages ?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _messages.clear();
                          _messages.add(MessageModel(
                            id: '0',
                            content: 'Conversation effacee. Comment puis-je vous aider ?',
                            isUser: false,
                            timestamp: DateTime.now(),
                          ));
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Effacer'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return FadeIn(child: const TypingIndicator());
                }
                return FadeInUp(
                  duration: const Duration(milliseconds: 300),
                  child: ChatBubble(
                    message: _messages[index].content,
                    isUser: _messages[index].isUser,
                    timestamp: _messages[index].timestamp,
                  ),
                );
              },
            ),
          ),
          
          // Quick suggestions
          if (_messages.length <= 1)
            FadeInUp(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SuggestionChip(
                      label: 'Conseils de plantation',
                      onTap: () {
                        _messageController.text = 'Quels sont vos conseils pour la plantation en cette saison ?';
                        _sendMessage();
                      },
                    ),
                    _SuggestionChip(
                      label: 'Proteger mes cultures',
                      onTap: () {
                        _messageController.text = 'Comment proteger mes cultures des nuisibles ?';
                        _sendMessage();
                      },
                    ),
                    _SuggestionChip(
                      label: 'Ameliorer le sol',
                      onTap: () {
                        _messageController.text = 'Comment ameliorer la qualite de mon sol ?';
                        _sendMessage();
                      },
                    ),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 8),
          
          // Input field
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Posez votre question...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        maxLines: null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _isTyping ? null : _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _isTyping
                            ? AppTheme.primaryGreen.withOpacity(0.5)
                            : AppTheme.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryGreen.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppTheme.primaryGreen,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}