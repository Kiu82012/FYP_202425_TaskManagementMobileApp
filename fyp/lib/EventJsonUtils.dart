import 'package:fyp/AddEvent.dart';
import 'package:fyp/CalendarView.dart';
import 'package:fyp/DurationFunc.dart';
import 'dart:convert';
import 'Event.dart';
import 'dart:convert';

///
/// Encode and decode events
///
class EventJsonUtils{
  String eventToJson(List<Event> eventList){

    // The list of map that will contain all event data from the parameter
    List<Map<String, String?>> eventMapList = [];

    // Input every data from the parameter into the list of map
    for(Event event in eventList){
      eventMapList.add(
        {
          'name' : event.name,
          'date' : "${event.date.year}:${event.date.month}:${event.date.day}",
          'startTime' : "${event.startTime?.hour.toString()}:${event.startTime?.minute.toString()}",
          'endTime' : "${event.endTime?.hour.toString()}:${event.endTime?.minute.toString()}",
          'duration' : event.duration?.inHours.toString(),
        }
      );
    }
    // To prevent I forgetting anything, the json format is like:
    // [event1, event2, event3, ...]
    //
    // Inside event1:
    // {duration: 10, name: 'dinner', startTime: 00:00, ...}


    // encode event list into json string
    String jsonString = jsonEncode(eventMapList);

    return jsonString;
  }

  List<Event> jsonToEvent(String eventJson){

    String trimmedEventJson = extractFirstJson(eventJson);
    print(trimmedEventJson);
    print("=====================");
    if (!trimmedEventJson.isEmpty){
      return eventsFromJson(trimmedEventJson);
    }
    return [];
  }



  String extractFirstJson(String input) {
    // Remove unwanted prefixes and suffixes
    // This example assumes you want to trim whitespace. Adjust as necessary.
    input = input.trim();

    // Find the first occurrence of '{' and '}'
    int startIndex = input.indexOf('{');
    int endIndex = input.indexOf('}', startIndex);

    // If both indices are found, extract the JSON substring
    if (startIndex != -1 && endIndex != -1) {
      String jsonString = input.substring(startIndex, endIndex + 1);

      // Optionally, validate if it's a proper JSON
      try {
        jsonDecode(jsonString); // This will throw if the JSON is invalid
        return "["+jsonString+"]";
      } catch (e) {
        return 'Invalid JSON';
      }
    }

    return 'No JSON found';
  }
}