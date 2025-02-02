import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechText extends StatefulWidget {
  const SpeechText({super.key});

  @override
  State<SpeechText> createState() => _SpeechToTextState();
}

class _SpeechToTextState extends State<SpeechText> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _wordSpoken = "";
  bool _isButtonPressed = false;

  void initState() {
    super.initState();
    initSpeech();
  }

  void initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(
        onResult: _onSpeechResult,
        pauseFor: const Duration(seconds: 99999),
        listenFor: const Duration(minutes: 1));
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(result) {
    setState(() {
      _wordSpoken = "${result.recognizedWords}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speech Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                _speechToText.isListening
                    ? 'listening...'
                    : _speechEnabled
                        ? 'Tap the microphone to start listening...'
                        : 'Speech not available',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Text(
                    // If listening is active show the recognized words
                    _wordSpoken),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: GestureDetector(
        onTapDown: (details) {
          setState(() => _isButtonPressed = true);
          _startListening();
        },
        onTapUp: (details) {
          setState(() => _isButtonPressed = false);
          _stopListening();
        },
        onTapCancel: () {
          setState(() => _isButtonPressed = false);
          _stopListening();
        },
        child: Ink(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isButtonPressed ? Colors.blueAccent : Colors.blue,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Icon(
              _isButtonPressed ? Icons.mic : Icons.mic_off,
              size: 36,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
