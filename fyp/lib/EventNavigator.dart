import 'dart:io';

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
    Input default value name: unknown event, date: $todaysDate, startTime: 0:0, endTime:0:0, duration: 1:0, description: .
     as long as the user did not provide one of each value,input the default value of the missing part, otherwise,input the value that given by the user
    User can input more than 1 event. Please notice that if there are two event name. If that happened, you should also generate 1 more event following the above rule I gave you
    Remember the duration should include minutes as well . For example if the user said the duration is 1 hour, input duration: 1:0  , if the user said the duration is 2 hours, 
    input duration 2:0. And so on.
    DO NOT CHANGE THE FORMAT IN JSON. 
    Responds in json format only, 
    no prefix and suffix,
    User requirements: $requirementString
    
    You only have to provide the new added events into the json, events that already in the knowledge base  are not required.
    
    """;

    String newJsonEvent = await AIHelper.getAIResponse(prompt);

    print("Gemini:"+newJsonEvent);

    return newJsonEvent;
  }

  // Static function to generate an event based on a photo path
  static Future<String> generateEventByPhoto(File photoFile, EventDatabase database) async {
    print("Generating event json...");

    print("Formatting Date...");
    String todaysDate = formatDateTime(DateTime.now().toString());

    String thisyear = formatDateTimeExtractYear(DateTime.now().toString());

    String eventListJson = EventJsonUtils().eventToJson(database.getEventList());

    String prompt = """
    
    Calendar App Knowledge Base, DO NOT CHANGE THE DATA FROM THE KNOWLEDGE BASE.
    YOU SHOULD ONLY REVIEW AND AVOID EVENT TIME OVERLAPPING.
    This is the knowledge base: $eventListJson .
    According to the picture, identify  the elements to generate an event or more than one events, then create a json format of event using the elements.
    Input default value name ONLY WHEN DATA IS MISSING FROM AN EVENT: name: unknown event, date: $todaysDate, startTime: 0:0, endTime:0:0, duration: 1:0, description: .
    Remember the duration should include minutes as well . For example if the user said the duration is 1 hour, input duration: 1:0  , if the user said the duration 
    is 2 hours, input duration 2:0. And so on.
    When the year of the event is missing, PLEASE INPUT THE DEFAULT VALUE: $thisyear. 
    For the event date, please just use ":" between year, month, and day but do not use "/". 
    When there is only one event name but TWO date and time, please create two events with same event name. 
    DO NOT CHANGE THE FORMAT IN JSON. 
    Responds in json format only, 
    no prefix and suffix,
    
    You only have to provide the new added events into the json, events that already in the knowledge base  are not required.
    
    """;

    print("Passing Prompt...");

    String newJsonEvent = await AIHelper.sendTextAndImageToAI(text: prompt, imageFiles: [photoFile]);

    print(newJsonEvent);

    return newJsonEvent;
  }

  static void navigateToConfirmView(String newEventJson){

  }

  static String formatDateTime(String dateTime) {
    DateTime parsedDate = DateTime.parse(dateTime);
    String formattedDate = '${parsedDate.year}:${parsedDate.month.toString().padLeft(2, '0')}:${parsedDate.day.toString().padLeft(2, '0')}';
    return formattedDate;
  }

  static String formatDateTimeExtractYear(String dateTime) {
    DateTime parsedDate = DateTime.parse(dateTime);
    String formattedDate = '${parsedDate.year}';
    return formattedDate;
  }
}