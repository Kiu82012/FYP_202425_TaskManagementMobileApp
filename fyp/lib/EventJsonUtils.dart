import 'dart:developer';

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
          'description' : event.description,
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

    String trimmedEventJson = trimJson(eventJson);

    print("Formatting Events");

    List<Event> eventList = [];

    try{
        print(trimmedEventJson);
        eventList = eventsFromJson(trimmedEventJson);
    } catch (e){
      log("Json cant convert to event.");
    }

    return eventList;
  }


  String trimJson(String jsonInput) {
    // Trim whitespace and handle empty input
    String trimmed = jsonInput.trim();
    if (trimmed.isEmpty) return '[]';

    // Find first '[' and last ']'
    final firstBracket = trimmed.indexOf('[');
    final lastBracket = trimmed.lastIndexOf(']');

    String processed;

    if (firstBracket != -1 && lastBracket != -1) {
      // Extract content between first [ and last ]
      processed = trimmed.substring(firstBracket, lastBracket + 1);
    } else if (firstBracket != -1) {
      // Add missing closing bracket
      processed = '${trimmed.substring(firstBracket)}]';
    } else if (lastBracket != -1) {
      // Add missing opening bracket
      processed = '[${trimmed.substring(0, lastBracket + 1)}]';
    } else {
      // Wrap entirely if no brackets
      processed = '[$trimmed]';
    }

    // Final validation to ensure brackets exist
    if (!processed.startsWith('[')) processed = '[$processed';
    if (!processed.endsWith(']')) processed = '$processed]';

    return processed;
  }
}