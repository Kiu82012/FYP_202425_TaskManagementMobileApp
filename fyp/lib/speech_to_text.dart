import 'package:flutter/material.dart';
import 'package:speech_to_text_continuous/speech_recognition_result.dart';
import 'package:speech_to_text_continuous/speech_to_text.dart';


class SpeechText extends StatefulWidget {
  SpeechText({super.key});
  late Function() stopListening;


  static String wordSpoken = " hihihih";

  @override
  State<SpeechText> createState() =>_SpeechToTextState();


}
class _SpeechToTextState extends State<SpeechText> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;

  bool _isListening = false; // Track listening state
  String _lastRecognized = "";

  @override
  void initState() {
    super.initState();
    widget.stopListening= _stopListening;
    _initSpeech().then((_) {
      if (_speechEnabled) {
        _startListening();
      }
    });
  }

  Future<void> _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    if (!_isListening) { // Prevent multiple starts
      setState(() {
        _isListening = true;
        SpeechText.wordSpoken=" ";
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
      setState(() {
        _isListening = false;
      });
      await _speechToText.stop();
      print("stop");
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (mounted) {
      setState(() {
        String newWords = result.recognizedWords.replaceFirst(
            _lastRecognized, "").trim();
        if (newWords.isNotEmpty) {
          SpeechText.wordSpoken += " " + newWords; // Append only new words
        }
        _lastRecognized = result.recognizedWords; // Update last processed text
      });
    }
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
      shadowColor: Colors.black,
      backgroundColor: Colors.white,
      elevation: 5,
      content: SingleChildScrollView(
        child: Column(
          children: [
            Icon(
              Icons.mic,
              size: 36,
              color: _isListening ? Colors.red : Colors.grey,
            ),
            SizedBox(height: 16),
            Text(SpeechText.wordSpoken.isNotEmpty ? SpeechText.wordSpoken : 'start speaking'),
          ],
        ),
      ),
    );
  }

}