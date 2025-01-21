import 'package:flutter/material.dart';
import 'package:fyp/ConfirmListViewItem.dart';

import 'Event.dart';  // Import the list view item

class ConfirmView extends StatelessWidget {
  final List<Event> events; // Add a field for events

  const ConfirmView({super.key, required this.events}); // Constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmation'),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.red,
            onPressed: () {
              Navigator.pop(context); // Go back to the previous view
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two columns
            childAspectRatio: 1, // Aspect ratio for the items
          ),
          itemCount: events.length, // Number of items in the list
          itemBuilder: (context, index) {
            return ConfirmListViewItem(event: events[index]); // Create list view item
          },
        ),
      ),
    );
  }
}