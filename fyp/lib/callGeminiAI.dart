import 'package:flutter/material.dart';
import 'package:gemini_flutter/gemini_flutter.dart';
import 'package:gemini_flutter/models/TextOnlyResponseModel.dart';

const apiKey = 'AIzaSyChwh8mhEpIwXKCwqjJ4uRmFKanYISbw3w';

final geminiHandler = GeminiHandler();

void initGemini() {
  geminiHandler.initialize(token: apiKey); // Initialize with your API key

}

Future<TextOnlyResponseModel?> fetchTextResponse(String text) async {
  return await geminiHandler.textOnly(text: text); // Call the textOnly method
}