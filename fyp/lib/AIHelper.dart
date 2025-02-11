import 'package:google_generative_ai/google_generative_ai.dart';

class AIHelper {
  static const String _apiKey = 'AIzaSyChwh8mhEpIwXKCwqjJ4uRmFKanYISbw3w'; // Replace with your API key
  static const String _modelName = 'gemini-pro'; // Use the appropriate model

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
}