import 'package:flutter/material.dart';

extension DurationExtension on Duration {
  String Format() {
    return '${inHours.toString().padLeft(2)}hr ${(inMinutes%60).toString().padLeft(2,)}min';
  }
}