import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/language_provider.dart';
import '../base/translation.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<_ChatMessage> _messages = [];

  bool _showQuickReplies = true;

  @override
  void initState() {
    super.initState();

    // 👋 Приветственное сообщение от админа
    _messages.add(
      _ChatMessage(
        text: 'Здравствуйте! Чем можем помочь?',
        isUser: false,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        _ChatMessage(
          text: text.trim(),
          isUser: true,
          createdAt: DateTime.now(),
        ),
      );

      _showQuickReplies = false;
    });

    _messageController.clear();

    /// 🔌 BACKEND HOOK
    /// POST /chat/messages
    /// WebSocket send
  }

  @override
  Widget build(BuildContext context) {
    const redColor = Color(0xFFE53935);

    return Consumer<LanguageProvider>(
      builder: (context, lp, _) {
        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            centerTitle: true,
            title: Text(
              tr(context, 'help'),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: Column(
            children: [
              // ================= MESSAGES =================
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    120, // 👈 отступ сверху, чтобы приветствие было "на уровне глаз"
                    16,
                    16,
                  ),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return _messageBubble(msg);
                  },
                ),
              ),

              // ================= QUICK REPLIES =================
              if (_showQuickReplies)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _quickButton(
                        tr(context, 'Хочу сделать заказ'),
                        () => _sendMessage(
                          tr(context, 'Хочу сделать заказ'),
                        ),
                      ),
                      _quickButton(
                        tr(context, 'Проблема с заказом'),
                        () => _sendMessage(
                          tr(context, 'Проблема с заказом'),
                        ),
                      ),
                      _quickButton(
                        tr(context, 'Вопрос по доставке'),
                        () => _sendMessage(
                          tr(context, 'Вопрос по доставке'),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // ================= INPUT =================
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: tr(context, 'Пишите сообщение...'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send, color: redColor),
                      onPressed: () =>
                          _sendMessage(_messageController.text),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= UI =================

  Widget _quickButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.redAccent),
          color: Colors.white,
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _messageBubble(_ChatMessage msg) {
    const redColor = Color(0xFFE53935);

    final isUser = msg.isUser;

    return Column(
      crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          constraints: const BoxConstraints(maxWidth: 280),
          decoration: BoxDecoration(
            color: isUser ? redColor : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            msg.text,
            style: TextStyle(
              color: isUser ? Colors.white : Colors.black,
            ),
          ),
        ),

        // ⏰ TIMESTAMP
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            DateFormat('HH:mm').format(msg.createdAt),
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }
}

// ================= MODEL =================

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime createdAt;

  _ChatMessage({
    required this.text,
    required this.isUser,
    required this.createdAt,
  });
}
