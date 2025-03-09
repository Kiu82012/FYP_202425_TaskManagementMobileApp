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
    if (!trimmedEventJson.isEmpty && trimmedEventJson != 'Invalid JSON' && trimmedEventJson != 'No JSON found'){
      return eventsFromJson(trimmedEventJson);
    }
    return [];
  }


  String extractFirstJson(String input) {
    input = input.trim();

    int startIndex = input.indexOf('{');
    int endIndex = input.indexOf('}', startIndex);

    if (startIndex != -1 && endIndex != -1) {
      String jsonString = input.substring(startIndex, endIndex + 1);

      try {
        // Decode the JSON string to a Map
        Map<String, dynamic> jsonMap = jsonDecode(jsonString);

        // Attempt to parse and standardize the duration
        if (jsonMap.containsKey('duration')) {
          jsonMap['duration'] = standardizeDuration(jsonMap['duration']);
        }

        // Encode the modified Map back to a JSON string
        String modifiedJsonString = jsonEncode(jsonMap);

        return "[" + modifiedJsonString + "]";
      } catch (e) {
        print('Error decoding or processing JSON: $e');
        return 'Invalid JSON';
      }
    }

    return 'No JSON found';
  }


  String standardizeDuration(dynamic duration) {
    if (duration is String) {
      if (duration.contains(':')) {
        // Handle "X:Y" or "X:YY" format
        List<String> parts = duration.split(':');
        if (parts.length == 2) {
          int hours = int.tryParse(parts[0]) ?? 0;
          int minutes = int.tryParse(parts[1]) ?? 0;  // Handle missing or invalid minutes
          return '$hours:${minutes.toString().padLeft(2, '0')}'; // Standardize to "X:YY"
        } else {
          return 'Invalid Duration Format'; // More than two parts
        }
      } else {
        // Handle just "X" format (assume hours)
        int hours = int.tryParse(duration) ?? 0;
        return '$hours:00'; // Standardize to "X:00"
      }
    } else if (duration is int) {
      // Handle integer duration (assume hours)
      return '$duration:00';
    } else {
      return 'Invalid Duration Type'; // Not a string or int
    }
  }
}