import 'dart:async';
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
  bool _isListening = false; // Track listening state

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    if (!_isListening) { // Prevent multiple starts
      setState(() {
        _isListening = true;
      });
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(days: 1), // Extended duration if needed
        pauseFor: const Duration(seconds: 5),
        partialResults: true, // Show partial results as the user speaks
        cancelOnError: true,
      );
    }
  }

  void _stopListening() async {
    if (_isListening) { // Prevent multiple stops
      setState(() {
        _isListening = false;
      });
      await _speechToText.stop();
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _wordSpoken = result.recognizedWords;
    });
  }

  @override
  void dispose() {
    _speechToText.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                _isListening // Use _isListening to update the text
                    ? 'Listening...'
                    : _speechEnabled
                    ? 'Tap the microphone to start listening'
                    : 'Speech not available',
                style: const TextStyle(fontSize: 20.0),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Text(_wordSpoken),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleListening, // Toggle between listening and not listening
        tooltip: 'Listen',
        child: Icon(
          _isListening ? Icons.mic : Icons.mic_off, // Show correct icon
          size: 36,
        ),
      ),
    );
  }

  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }
}