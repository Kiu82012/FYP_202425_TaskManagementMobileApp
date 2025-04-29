import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fyp/ConfirmListViewItem.dart';
import 'package:fyp/DurationFunc.dart';
import 'package:hive/hive.dart';

part 'Event.g.dart';

@HiveType(typeId: 0) // Unique ID for the adapter
class Event {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  TimeOfDay? startTime = TimeOfDay(hour: 12, minute: 0);

  @HiveField(3)
  TimeOfDay? endTime = TimeOfDay(hour: 13, minute: 0);

  @HiveField(4)
  Duration? duration = Duration(hours: 1);

  @HiveField(5)
  final String description;

  Event({
    required this.name,
    required this.date,
    this.startTime,
    this.endTime,
    this.duration,
    required this.description,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    String name = json['name'];
    DateTime date = DateTime(
        int.parse(json['date'].split(':')[0]),
          int.parse(json['date'].split(':')[1]),
          int.parse(json['date'].split(':')[2]),);

        TimeOfDay startTime = TimeOfDay(
      hour: int.parse(json['startTime'].split(':')[0]),
      minute: int.parse(json['startTime'].split(':')[1]),
    );

    TimeOfDay endTime = TimeOfDay(
      hour: int.parse(json['endTime'].split(':')[0]),
      minute: int.parse(json['endTime'].split(':')[1]),
    );

    // special treatment for duration
    String formattedDuration = standardizeDuration(json['duration']);

    Duration duration = Duration(
      hours: int.parse(formattedDuration.split(':')[0]),
      minutes: int.parse(formattedDuration.split(':')[1]),
    );

    String description = json['description'];

    return Event(
      name: name,
      date: date,
      startTime: startTime,
      endTime: endTime,
      duration: duration,
      description: description,
    );
  }

  static String standardizeDuration(dynamic duration) {
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

List<Event> eventsFromJson(String jsonString) {
  final List<dynamic> jsonList = json.decode(jsonString);
  return jsonList.map((json) => Event.fromJson(json)).toList();
}

