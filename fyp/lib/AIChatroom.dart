import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // For picking images
import 'dart:io';
import 'AIHelper.dart'; // Import your AIHelper.dart

class AIChatroom extends StatefulWidget {
  @override
  _AIChatroomState createState() => _AIChatroomState();
}

class _AIChatroomState extends State<AIChatroom> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> messages = []; // Store both text and image messages
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    // Add user message
    setState(() {
      messages.add({'role': 'user', 'type': 'text', 'content': _controller.text});
    });

    // Clear input
    _controller.clear();

    // Get AI response
    final aiResponse = await AIHelper.getAIResponse(messages.last['content']!);

    // Add AI response
    setState(() {
      messages.add({'role': 'ai', 'type': 'text', 'content': aiResponse});
    });

    // Scroll to the bottom of the list
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _sendImage() async {
    // Pick an image from the gallery
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);

      // Add user image to the chat
      setState(() {
        messages.add({'role': 'user', 'type': 'image', 'content': imageFile});
      });

      // Get AI response for the image
      final aiResponse = await AIHelper.sendTextAndImageToAI(
        text: _controller.text.isNotEmpty ? _controller.text : "Describe this image",
        imageFiles: [imageFile],
      );

      // Clear input
      _controller.clear();

      // Add AI response
      setState(() {
        messages.add({'role': 'ai', 'type': 'text', 'content': aiResponse});
      });

      // Scroll to the bottom of the list
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
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
                if (message['type'] == 'text') {
                  return ChatBubble(
                    role: message['role'],
                    text: message['content'],
                  );
                } else if (message['type'] == 'image') {
                  return ImageBubble(imageFile: message['content']);
                }
                return SizedBox.shrink();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: _sendImage, // Open image picker
                ),
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

class ImageBubble extends StatelessWidget {
  final File imageFile;

  const ImageBubble({required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Image.file(
            imageFile,
            width: 150,
            height: 150,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}