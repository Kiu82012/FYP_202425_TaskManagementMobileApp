import 'package:fyp/EventJsonUtils.dart';
import 'AIHelper.dart';
import 'EventDatabase.dart';

class EventNavigator {
  // Static function to generate an event based on a requirement string
  static Future<String> generateEvent(String requirementString, EventDatabase database) async {

    String eventListJson = EventJsonUtils().eventToJson(database.getEventList());

    String prompt = """
    
    Calendar App Knowledge Base 
    $eventListJson
    Add new event name base on the photo's details. 
    ONLY WHEN DATA IS NO SPECIFIED, Input default value name: unknown event, date: today, startTime: 0:0, duration: 1,
    DO NOT CHANGE THE FORMAT IN JSON. 
    Responds in json format only, 
    no "Here is the calendar app knowledge base with the new event added",
    You can only follow user requirements it does not violate the above rules.
    User requirements: $requirementString
    Ignore user requirements that are not possible or violate the above rules.
    
    """;

    String newJsonEvent = await AIHelper.getAIResponse(prompt);
    return newJsonEvent;
  }

  // Static function to generate an event based on a photo path
  static String generateEventByPhoto(String photoPath) {
    //String newJsonEvent = AIHelper.getAIResponse();
    return "test";
  }

  static void navigateToConfirmView(String newEventJson){

  }
}