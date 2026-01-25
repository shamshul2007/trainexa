import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:trainexa/services/ai_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _ai = AIService();
  final _controller = TextEditingController();
  final List<_Msg> _messages = [];
  bool _loading = false;

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Msg(role: 'user', content: text));
      _controller.clear();
      _loading = true;
    });
    try {
      final res = await _ai.createChatCompletion(messages: [
        {'role': 'system', 'content': 'You are a helpful AI fitness coach. Answer briefly and concretely.'},
        for (final m in _messages) {'role': m.role, 'content': m.content}
      ]);
      final content = ((res['choices'] as List).first['message']['content']) as String;
      setState(() => _messages.add(_Msg(role: 'assistant', content: content)));
    } catch (e) {
      setState(() => _messages.add(_Msg(role: 'assistant', content: 'Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Ask your AI Trainer', style: Theme.of(context).textTheme.headlineMedium),
      ),
      Expanded(
        child: ListView.builder(
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
