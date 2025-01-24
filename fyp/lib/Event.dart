import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'Event.g.dart';

@HiveType(typeId: 0) // Unique ID for the adapter
class Event {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final TimeOfDay? startTime;

  @HiveField(3)
  final TimeOfDay? endTime;

  @HiveField(4)
  final Duration? duration;


  Event({required this.name, required this.date, this.startTime, this.endTime, this.duration});

  factory Event.fromJson(Map<String, dynamic> json) {

    String name = json['name'];
    DateTime date = DateTime(int.parse(json['date'].split(':')[0]),int.parse(json['date'].split(':')[1]),int.parse(json['date'].split(':')[2]));
    TimeOfDay startTime = TimeOfDay(hour: int.parse(json['startTime'].split(':')[0]), minute: int.parse(json['startTime'].split(':')[1]));
    TimeOfDay endTime = TimeOfDay(hour: int.parse(json['endTime'].split(':')[0]), minute: int.parse(json['endTime'].split(':')[1]));
    Duration duration = Duration(hours: int.parse(json['duration'].split(':')[0]), minutes: int.parse(json['duration'].split(':')[0]),);

    Event event = Event(
      name:  name,
      date:  date,
      startTime: startTime,
      endTime: endTime,
      duration: duration,
    );

    return event;
  }
}