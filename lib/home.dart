// ... all your imports remain the same
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'chat.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool isListening = false;
  bool isThinking = false;
  bool isSpeaking = false;

  String userSpeech = '';
  String botResponse = '';
  List<Map<String, String>> messages = [];

  @override
  void initState() {
    super.initState();
    _initializeTTS();
  }

  Future<void> _initializeTTS() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    String encoded = jsonEncode(messages);
    await prefs.setString('chat_history', encoded);
  }

  Future<void> _clearMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_history');
    setState(() {
      messages.clear();
      userSpeech = '';
      botResponse = '';
    });
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => isListening = false);
        }
      },
      onError: (error) {
        debugPrint('Speech recognition error: $error');
        setState(() => isListening = false);
      },
    );

    if (available) {
      setState(() {
        isListening = true;
        isThinking = false;
        isSpeaking = false;
        userSpeech = '';
        botResponse = '';
      });

      _speech.listen(
        onResult: (result) async {
          if (result.finalResult) {
            userSpeech = result.recognizedWords;
            _speech.stop();
            messages.add({'sender': 'user', 'text': userSpeech});
            await _saveMessages();
            _generateBotResponse(userSpeech);
          }
        },
      );
    }
  }

  Future<void> _generateBotResponse(String input) async {
    setState(() {
      isListening = false;
      isThinking = true;
    });

    await Future.delayed(const Duration(seconds: 2)); // Simulated response time

    botResponse = "Hello, I'm feelAI. How can I assist you today?";

    messages.add({'sender': 'bot', 'text': botResponse});
    await _saveMessages();

    setState(() {
      isThinking = false;
      isSpeaking = true;
    });

    await _flutterTts.speak(botResponse);

    setState(() {
      isSpeaking = false;
    });
  }

  @override
  void dispose() {
    _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('FeelAI', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatHistoryPage()),
              );
            },
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main Animation
              Lottie.asset(
                'assets/animations/blob1.json',
                width: 300,
                height: 300,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),

              // User Speech
              if (userSpeech.isNotEmpty)
                Text(
                  'You: $userSpeech',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 10),

              // Bot Response
              if (botResponse.isNotEmpty)
                Text(
                  'Bot: $botResponse',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),

              // Loading Animation
              if (isThinking)
                Column(
                  children: [
                    const SizedBox(height: 30),
                    Lottie.asset(
                      'assets/animations/loading.json',
                      width: 100,
                      height: 100,
                    ),
                  ],
                ),

              const SizedBox(height: 40),

              // Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Cancel Button
                  ElevatedButton(
                    onPressed: () {
                      _speech.stop();
                      _clearMessages();
                      setState(() => isListening = false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(22),
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 40),

                  // Microphone Button
                  ElevatedButton(
                    onPressed: _startListening,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(10),
                    ),
                    child: SizedBox(
                      width: 65,
                      height: 65,
                      child: isListening
                          ? Lottie.asset(
                        'assets/animations/microphone.json',
                        fit: BoxFit.cover,
                      )
                          : const Icon(Icons.mic, size: 40, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
