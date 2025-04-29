import 'package:flutter/material.dart';
import 'package:fyp/DurationFunc.dart';
import 'package:fyp/EditListEvent.dart';
import 'package:fyp/StringFuncs.dart';

import 'Event.dart';

class ConfirmListViewItem extends StatelessWidget {
  final Event event;
  final List<Event> eventList;
  final Function(Event) onAdd; // Callback to add an event
  final Function(Event) onRemove; // Callback to remove an event

  const ConfirmListViewItem({super.key, required this.event, required this.eventList,required this.onAdd, required this.onRemove}); // Constructor

  @override
  Widget build(BuildContext context) {
    List<String> date = event.date.toString().split(' ')[0].split('-'); // 0 is YYYY,  1 is MM, 2 is DD

    return GestureDetector(
      onTap: () => _showDeleteConfirmationDialog(context), // Show dialog on tap
      child: Card(
        margin: const EdgeInsets.all(2.0),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.name, overflow: TextOverflow.ellipsis, maxLines: 2, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.left), // Event name
              SizedBox(height: 8),
              Text('Date: ${date[2].trimCharLeft("0")}/${date[1].trimCharLeft("0")}/${date[0]}', style: TextStyle(fontSize: 17, color: Colors.black)), // Rearranged date format
              Text('Starts at: ${event.startTime?.format(context)}', style: TextStyle(fontSize: 17, color: Colors.black)), // Start Time
              Text('Duration: ${event.duration?.Format()}', style: TextStyle(fontSize: 17, color: Colors.black)), // Duration
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditListEvent(selectedEvent: event, eventList: eventList,onAdd: onAdd, onRemove: onRemove,);
      },
    );
  }
}