import 'package:flutter/material.dart';
import 'package:fyp/ConfirmListViewItem.dart';
import 'package:fyp/EventDatabase.dart';
import 'Event.dart';

class ConfirmView extends StatefulWidget {
  final List<Event> events; // events to be confirmed

  const ConfirmView({super.key, required this.events}); // Constructor

  @override
  _ConfirmViewState createState() => _ConfirmViewState();
}

class _ConfirmViewState extends State<ConfirmView> {
  late List<Event> _events;

  @override
  void initState() {
    super.initState();
    _events = List.from(widget.events); // Create a mutable copy

    // Remove the null check here
  }

  void _removeEvent(Event event) {
    setState(() {
      _events.remove(event); // Remove the unwanted event
    });
  }

  void AddEventsIntoDatabaseAfterConfirmation() async {
    EventDatabase db = EventDatabase();

    // Update database
    for (Event event in _events) {
      db.addEvent(event); // Ensure this is awaited if it's async
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
            onPressed: () async {
              if (_events.isNotEmpty) {
                // Call the function to add events to the database
                AddEventsIntoDatabaseAfterConfirmation();

                // Show the confirmation snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('You have added the events successfully!'),
                    duration: Duration(seconds: 2), // Duration for the snackbar
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 40), // Adjust position
                  ),
                );

                // Navigate back after some delay
                await Future.delayed(Duration(seconds: 2));
                Navigator.pop(context); // Go back to the previous view
              } else {
                // Show the confirmation snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('There is no event to confirm.'),
                    duration: Duration(seconds: 2), // Duration for the snackbar
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 40), // Adjust position
                  ),
                );
              }
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
          itemCount: _events.length, // Number of items in the list
          itemBuilder: (context, index) {
            return ConfirmListViewItem(
              event: _events[index],
              onRemove: _removeEvent, // Pass the remove callback
            ); // Create list view item
          },
        ),
      ),
    );
  }
}