import 'package:flutter/material.dart';

import 'Event.dart';

class ConfirmListViewItem extends StatelessWidget {
  final Event event;

  const ConfirmListViewItem({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(event.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // First column
            SizedBox(height: 8),
            Text('Date: ${event.date}', style: TextStyle(color: Colors.grey)), // Date
            Text('Starts at: ${event.startTime}', style: TextStyle(color: Colors.grey)), // Start Time
            Text('Duration: ${event.duration}', style: TextStyle(color: Colors.grey)), // Duration
          ],
        ),
      ),
    );
  }
}