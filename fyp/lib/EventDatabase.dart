import 'package:fyp/CalendarView.dart';
import 'package:fyp/EventJsonUtils.dart';
import 'package:fyp/TimeOfDayFunc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'Event.dart';

class EventDatabase {

  static List<Event> _events = [];

  final _eventBox = Hive.box('eventBox');

  void addEvent(Event event) {
    _events.add(event);
    print("events are added");
    saveEvents();
  }

  void deleteEvent(Event event) {
    _events.remove(event);
    print("events are deleted");
    saveEvents();
  }

  void clearEvents() {
    _events.clear();
    saveEvents();
  }

  // save event into database
  void saveEvents(){
    for (Event event in _events){
      print("Saving events: ${event.name}"); // Print the events being saved
    }
    _eventBox.put('eventBox', _events);
    print("events are saved");
  }

  // load events from database
  void loadEvents(){
    if (_eventBox.get('eventBox') != null){
      _events = (_eventBox.get('eventBox') as List).map((e) => e as Event).toList();

      for (Event event in _events){
        print("Loading events: ${event.name}: ${event.date}:${event.startTime?.Format()} D:${event.duration?.inMinutes.toString()}"); // Print the events being loaded
      }

      print("events are loaded");

      /// TEST ////// TEST ////// TEST ///
      EventJsonUtils utils = EventJsonUtils();
      print(utils.eventToJson(_events));
      /// TEST ////// TEST ////// TEST ///

    } else{
      _events = [];
      print("events are empty, creating new");
    }
  }

  List<Event> getEventList(){
    List<Event> theEvent = [];
    for (var value in _events){
      theEvent.add(value);
    }
    return theEvent;
  }


  List<Event> getEventsByDate(DateTime date) {
    final events = _eventBox.get('eventBox', defaultValue: []) as List<Event>;

    final eventsOnDate = events.where((event) => event.date == date).toList();

    print('Events on $date: $eventsOnDate');

    return eventsOnDate;
  }
}