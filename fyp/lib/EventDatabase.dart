import 'package:flutter/material.dart';

class Event {
  final String name;
  final DateTime date;
  final TimeOfDay? time;

  Event({
    required this.name,
    required this.date,
    this.time,
  });
}

class EventDatabase {
  final List<Event> _events = [];

  List<Event> get events => List.unmodifiable(_events);

  void addEvent(Event event) {
    _events.add(event);
  }

  void deleteEvent(int index) {
    _events.removeAt(index);
  }

  void clearEvents() {
    _events.clear();
  }
}