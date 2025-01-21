import 'Event.dart';
import 'dart:convert';

///
/// Encode and decode events
///
class EventJsonUtils{
  String eventToJson(List<Event> eventList){

    // The list of map that will contain all event data from the parameter
    List<Map<String, dynamic>> eventMapList = [];

    // Input every data from the parameter into the list of map
    for(Event event in eventList){
      eventMapList.add(
        {
          'duration' : event.duration,
          'name' : event.name,
          'startTime' : event.startTime,
          'endTime' : event.endTime,
          'date' : event.date,
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