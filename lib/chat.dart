import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:io';

class ChatHistoryPage extends StatefulWidget {
  const ChatHistoryPage({super.key});

  @override
  State<ChatHistoryPage> createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  List<Map<String, String>> messages = [];

  Future<void> loadMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? stored = prefs.getString('chat_history');
    if (stored != null) {
      List<dynamic> decoded = jsonDecode(stored);
      setState(() {
        messages = decoded.map((e) => Map<String, String>.from(e)).toList();
      });
    }
  }

  Future<void> saveMessagesToFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/chat_history.txt';
      final file = File(filePath);

      String content = messages
          .map((msg) =>
      '${msg['sender'] == 'user' ? '🧍User' : '🤖Bot'}: ${msg['text']}')
          .join('\n\n');

      await file.writeAsString(content, mode: FileMode.writeOnly);
      debugPrint("✅ Chat history saved to $filePath");
    } catch (e) {
      debugPrint("❌ Error saving chat history: $e");
    }
  }

  Future<void> saveMessagesToFirebase() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final chatRef = firestore.collection('chat_histories').doc('user_chat');

      await chatRef.set({
        'timestamp': DateTime.now(),
        'messages': messages,
      });

      debugPrint("✅ Chat history uploaded to Firebase");
    } catch (e) {
      debugPrint("❌ Error uploading chat history: $e");
    }
  }
  Future<void> addMessage(String text, String sender) async {
    setState(() {
      messages.add({'text': text, 'sender': sender});
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('chat_history', jsonEncode(messages));

    // Save both locally and to Firebase
    saveChatEverywhere();
  }

  void saveChatEverywhere() {
    saveMessagesToFile();
    saveMessagesToFirebase();
  }

  @override
  void initState() {
    super.initState();
    loadMessages().then((_) => saveChatEverywhere());
  }

  Widget _buildChatBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : Colors.grey[800],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft:
            isUser ? const Radius.circular(16) : const Radius.circular(0),
            bottomRight:
            isUser ? const Radius.circular(0) : const Radius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text('Chat History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            tooltip: 'Save as Text',
            onPressed: saveChatEverywhere,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final msg = messages[index];
          return _buildChatBubble(msg['text']!, msg['sender'] == 'user');
        },
      ),
    );
  }
}
