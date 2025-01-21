import 'package:flutter/material.dart';
import 'package:fyp/ConfirmListViewItem.dart';
import 'package:fyp/EventDatabase.dart';
import 'Event.dart';

class ConfirmView extends StatelessWidget {
  final List<Event> events; // events to be confirmed

  const ConfirmView({super.key, required this.events}); // Constructor

  void AddEventsIntoDatabaseAfterConfirmation() {

    EventDatabase db = EventDatabase();

    // update database
    for(Event event in events){
      db.addEvent(event);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmation'),
        actions: [
          IconButton(
            icon: Icon(Icons.check_rounded),
            color: Colors.green,
            onPressed: () {
              // Call the function to add events to the database
              AddEventsIntoDatabaseAfterConfirmation();

              // Show the confirmation snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('You have added the events successfully!'),
                  duration: Duration(seconds: 2), // Duration for the snackbar
                  behavior: SnackBarBehavior.floating, // Makes it float
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 40), // Adjust position
                ),
              );

              // Optionally navigate back after some delay
              Future.delayed(Duration(seconds: 2), () {
                Navigator.pop(context); // Go back to the previous view
              });
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