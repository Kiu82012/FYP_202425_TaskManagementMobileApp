import 'package:flutter/material.dart';
import 'package:gemini_flutter/gemini_flutter.dart';
import 'package:gemini_flutter/models/TextOnlyResponseModel.dart';
import 'callGeminiAI.dart';


class AIChatroom extends StatefulWidget {
  @override
  _AIChatroomState createState() => _AIChatroomState();
}

class _AIChatroomState extends State<AIChatroom> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    // Add user message
    setState(() {
      messages.add({'role': 'user', 'text': _controller.text});
    });

    // Clear input
    _controller.clear();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Chatroom')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return ListTile(
                  title: Text(message['text']!),
                  subtitle: Text(message['role']!),
                  leading: message['role'] == 'user'
                      ? const Icon(Icons.person)
                      : const Icon(Icons.android),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}