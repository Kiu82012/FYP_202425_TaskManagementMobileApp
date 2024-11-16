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
  final TimeOfDay? time;

  Event({required this.name, required this.date, this.time});
}