
import 'package:flutter/material.dart';
import 'package:speech_to_text_continuous/speech_recognition_result.dart';
import 'package:speech_to_text_continuous/speech_to_text.dart';


class SpeechText extends StatefulWidget {
  const SpeechText({super.key});

  @override
  State<SpeechText> createState() => _SpeechToTextState();
}

class _SpeechToTextState extends State<SpeechText> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _wordSpoken = "";
  bool _isListening = false; // Track listening state
  String _lastRecognized = "";


  @override
  void initState() {
    super.initState();
    _initSpeech().then((_) {
      if (_speechEnabled) {
        _startListening();
      }
    });
  }

  Future<void> _initSpeech() async { // 改為異步初始化
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    if (!_isListening) { // Prevent multiple starts
      setState(() {
        _isListening = true;
        _wordSpoken=" ";
      });
      print("start");
      await _speechToText.listen(
        listenMode: ListenMode.dictation,
        onResult: _onSpeechResult,
        listenFor: const Duration(minutes:5), // Extended duration if needed
        pauseFor: const Duration(seconds: 20),

      );
    }
  }

  void _stopListening() async {
    if (_isListening) { // Prevent multiple stops
      setState(() {
        _isListening = false;
      });
      print("stop");
      await _speechToText.stop();
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      String newWords = result.recognizedWords.replaceFirst(_lastRecognized, "").trim();
      if (newWords.isNotEmpty) {
        _wordSpoken += " " + newWords; // Append only new words
      }
      _lastRecognized = result.recognizedWords; // Update last processed text
    });
  }

  @override
  void dispose() {
    _speechToText.stop();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black12,
      content: SingleChildScrollView(
        child: Column(
          children: [
            Icon(
              Icons.mic,
              size: 36,
              color: _isListening ? Colors.red : Colors.grey,
            ),
            SizedBox(height: 16),
            Text(_wordSpoken.isNotEmpty ? _wordSpoken : 'start speaking'),
          ],
        ),
      ),
    );
  }

}