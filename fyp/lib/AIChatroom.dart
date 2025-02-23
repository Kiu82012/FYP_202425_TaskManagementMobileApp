import 'package:flutter/material.dart';
import 'AIHelper.dart'; // Import your AIHelper.dart

class AIChatroom extends StatefulWidget {
  @override
  _AIChatroomState createState() => _AIChatroomState();
}

class _AIChatroomState extends State<AIChatroom> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    // Add user message
    setState(() {
      messages.add({'role': 'user', 'text': _controller.text});
    });

    // Clear input
    _controller.clear();

    // Get AI response
    final aiResponse = await AIHelper.getAIResponse(messages.last['text']!);

    // Add AI response
    setState(() {
      messages.add({'role': 'ai', 'text': aiResponse});
    });

    // Scroll to the bottom of the list
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Chatroom')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return ChatBubble(
                  role: message['role']!,
                  text: message['text']!,
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
                    onSubmitted: (value) => _sendMessage(), // Send message on Enter key
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

class ChatBubble extends StatelessWidget {
  final String role;
  final String text;

  const ChatBubble({required this.role, required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: role == 'user' ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: role == 'user' ? Colors.blue : Colors.green,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}