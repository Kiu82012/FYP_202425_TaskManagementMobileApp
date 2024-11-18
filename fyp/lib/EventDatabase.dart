import 'package:flutter/material.dart';
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

  void deleteEvent(int index) {
    _events.removeAt(index);
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
        print("Loading events: ${event.name}"); // Print the events being loaded
      }

      print("events are loaded");
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
}