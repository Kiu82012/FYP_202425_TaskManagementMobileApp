import 'package:fyp/AddEvent.dart';
import 'package:fyp/CalendarView.dart';
import 'package:fyp/DurationFunc.dart';

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

    // decode event json into event object
    var events = jsonDecode(eventJson);

    // convert dynamics to a list
    List<Event> eventList = events.map((eventMap) => Event.fromJson(eventMap)).toList();

    return eventList;
  }
}