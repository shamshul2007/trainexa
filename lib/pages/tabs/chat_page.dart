import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:trainexa/services/ai_service.dart';
import 'package:trainexa/services/storage_service.dart';
import 'package:trainexa/auth/supabase_auth_manager.dart';
import 'package:trainexa/models/chat_message.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _ai = AIService();
  final _storage = StorageService();
  final _authManager = SupabaseAuthManager();
  final _controller = TextEditingController();
  final List<_Msg> _messages = [];
  bool _loading = false;
  bool _loadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    final user = _authManager.getCurrentUser();
    if (user == null) {
      setState(() => _loadingHistory = false);
      return;
    }

    try {
      final messages = await _storage.loadChatMessages(user.uid);
      setState(() {
        _messages.clear();
        _messages.addAll(messages.map((m) => _Msg(role: m.role, content: m.content)));
        _loadingHistory = false;
      });
    } catch (e) {
      debugPrint('Failed to load chat history: $e');
      setState(() => _loadingHistory = false);
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    
    final user = _authManager.getCurrentUser();
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to chat with your trainer')),
      );
      return;
    }

    final userMsg = _Msg(role: 'user', content: text);
    setState(() {
      _messages.add(userMsg);
      _controller.clear();
      _loading = true;
    });

    // Save user message to database
    try {
      await _storage.saveChatMessage(ChatMessage(
        id: '', // Will be auto-generated
        userId: user.uid,
        role: 'user',
        content: text,
        createdAt: DateTime.now(),
      ));
    } catch (e) {
      debugPrint('Failed to save user message: $e');
    }

    // Get AI response
    try {
      final res = await _ai.createChatCompletion(messages: [
        {'role': 'system', 'content': 'You are a helpful AI fitness coach. Answer briefly and concretely.'},
        for (final m in _messages) {'role': m.role, 'content': m.content}
      ]);
      final content = ((res['choices'] as List).first['message']['content']) as String;
      final assistantMsg = _Msg(role: 'assistant', content: content);
      setState(() => _messages.add(assistantMsg));

      // Save assistant message to database
      try {
        await _storage.saveChatMessage(ChatMessage(
          id: '', // Will be auto-generated
          userId: user.uid,
          role: 'assistant',
          content: content,
          createdAt: DateTime.now(),
        ));
      } catch (e) {
        debugPrint('Failed to save assistant message: $e');
      }
    } catch (e) {
      final errorMsg = _Msg(role: 'assistant', content: 'Error: $e');
      setState(() => _messages.add(errorMsg));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat History'),
        content: const Text('Are you sure you want to delete all your chat messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final user = _authManager.getCurrentUser();
    if (user == null) return;

    try {
      await _storage.clearChatHistory(user.uid);
      setState(() => _messages.clear());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat history cleared')),
        );
      }
    } catch (e) {
      debugPrint('Failed to clear history: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to clear history: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Ask your AI Trainer', style: Theme.of(context).textTheme.headlineMedium),
            if (_messages.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: _clearHistory,
                tooltip: 'Clear chat history',
              ),
          ],
        ),
      ),
      Expanded(
        child: _messages.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Start a conversation with your AI trainer',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  final m = _messages[i];
                  final isUser = m.role == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isUser ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        m.content,
                        style: TextStyle(color: isUser ? Colors.white : Theme.of(context).colorScheme.onSurface),
                      ),
                    ),
                  );
                },
              ),
      ),
      Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: 'Ask about your workout...'),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(onPressed: _loading ? null : _send, child: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send))
        ]),
      )
    ]);
  }
}

class _Msg {
  final String role;
  final String content;
  _Msg({required this.role, required this.content});
}
