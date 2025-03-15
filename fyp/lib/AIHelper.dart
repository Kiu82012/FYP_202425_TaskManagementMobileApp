import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';

class AIHelper {
  static const String _apiKey = 'AIzaSyChwh8mhEpIwXKCwqjJ4uRmFKanYISbw3w'; // Replace with your API key
  static const String _modelName = 'gemini-1.5-flash'; // Use the appropriate model for text
  static const String _visionModelName = 'gemini-2.0-flash'; // Use the appropriate model for text-and-image

  // Function to get a text-based response from the AI
  static Future<String> getAIResponse(String userMessage) async {
    try {
      // Initialize the GenerativeModel
      final model = GenerativeModel(model: _modelName, apiKey: _apiKey);

      // Generate content using the model
      final response = await model.generateContent([Content.text(userMessage)]);

      // Check if the response is valid
      if (response.text != null && response.text!.isNotEmpty) {
        return response.text!;
      } else {
        return "Sorry, I couldn't generate a response.";
      }
    } catch (e) {
      // Handle specific errors
      if (e is GenerativeAIException) {
        return "Error: ${e.message}";
      } else {
        return "An unexpected error occurred.";
      }
    }
  }

  // Function to send text and image to the AI
  static Future<String> sendTextAndImageToAI({
    required String text,
    required List<File> imageFiles,
  }) async {
    try {
      // Initialize the GenerativeModel for vision tasks
      final model = GenerativeModel(model: _visionModelName, apiKey: _apiKey);

      // Convert image files to bytes
      final imageBytes = imageFiles.map((file) => file.readAsBytesSync()).toList();

      // Create the content with text and images
      final response = await model.generateContent([
        Content.multi([
          TextPart(text), // Text prompt
          ...imageBytes.map((bytes) => DataPart('image/jpeg', bytes)), // Image data
        ])
      ]);

      // Return the AI's response
      return response.text ?? "Sorry, I couldn't generate a response.";
    } catch (e) {
      // Handle errors
      return "Error: ${e.toString()}";
    }
  }
}