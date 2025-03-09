import 'package:fyp/EventJsonUtils.dart';
import 'AIHelper.dart';
import 'EventDatabase.dart';

class EventNavigator {
  // Static function to generate an event based on a requirement string
  static Future<String> generateEvent(String requirementString, EventDatabase database) async {
    print(requirementString);
    print("Generating event json...");

    String todaysDate = formatDateTime(DateTime.now().toString());

    String eventListJson = EventJsonUtils().eventToJson(database.getEventList());

    String prompt = """
    
    Calendar App Knowledge Base, DO NOT CHANGE THE DATA FROM THE KNOWLEDGE BASE.
    YOU SHOULD ONLY REVIEW AND AVOID EVENT TIME OVERLAPPING.
    This is the knowledge base: $eventListJson .
    Input default value name: unknown event, date: $todaysDate, startTime: 0:0,endTime:0:0, duration: 1:0) ONLY WHEN DATA IS MISSING FROM AN EVENT,
    Remember the duration should include minutes as well . For example if the user said the duration is 1 hour, input duration: 1:0  , if the user said the duration is 2 hours, input duration 2:0. And so on.
    DO NOT CHANGE THE FORMAT IN JSON. 
    Responds in json format only, 
    no prefix and suffix,
    User requirements: $requirementString
    
    You only have to provide the new added events into the json, events that already in the knowledge base  are not required.
    
    """;

    String newJsonEvent = await AIHelper.getAIResponse(prompt);

    print(newJsonEvent);

    return newJsonEvent;
  }

  // Static function to generate an event based on a photo path
  static String generateEventByPhoto(String photoPath) {
    //String newJsonEvent = AIHelper.getAIResponse();
    return "test";
  }

  static void navigateToConfirmView(String newEventJson){

  }

  static String formatDateTime(String dateTime) {
    DateTime parsedDate = DateTime.parse(dateTime);
    String formattedDate = '${parsedDate.year}:${parsedDate.month.toString().padLeft(2, '0')}:${parsedDate.day.toString().padLeft(2, '0')}';
    return formattedDate;
  }
}