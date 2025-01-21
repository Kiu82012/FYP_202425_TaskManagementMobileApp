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
    return Event(
      name: json['name'],
      date: json['date'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      duration: json['duration'],
    );
  }
}