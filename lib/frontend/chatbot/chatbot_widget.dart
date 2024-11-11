import 'package:flutter/material.dart';

class ChatbotWidget extends StatefulWidget {
  const ChatbotWidget({super.key});

  @override
  _ChatbotWidgetState createState() => _ChatbotWidgetState();
}

class _ChatbotWidgetState extends State<ChatbotWidget> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];

  void _sendMessage() {
    String userMessage = _controller.text;
    if (userMessage.isEmpty) return;

    setState(() {
      messages.add({"sender": "User ", "text": userMessage});
      _controller.clear();
    });

    // Simulate chatbot response
    _getChatbotResponse(userMessage);
  }

  Future<void> _getChatbotResponse(String userMessage) async {
    // Here you would implement the logic to get a response from the local Python chatbot. Since the chatbot runs locally, you can use a method to call the Python script and get the response.

    // Simulating a response for now
    String response = await _fetchResponseFromChatbot(userMessage);
    
    setState(() {
      messages.add({"sender": "Chatbot", "text": response});
    });
  }

  Future<String> _fetchResponseFromChatbot(String userMessage) async {
    // This function should call the local Python script and return the response
    // For now, we will return a placeholder response
    return "This is a placeholder response.";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('${messages[index]['sender']}: ${messages[index]['text']}'),
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
                  decoration: const InputDecoration(hintText: 'Type your message...'),
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
    );
  }
}