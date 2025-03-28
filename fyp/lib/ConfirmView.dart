import 'package:flutter/material.dart';
import 'package:fyp/ConfirmListViewItem.dart';
import 'package:fyp/EventDatabase.dart';
import 'package:lottie/lottie.dart';
import 'Event.dart';
import 'loadingPage.dart';

class ConfirmView extends StatefulWidget {
  final List<Event> events; // Events to be confirmed
  final Function loadEventCallback;

  const ConfirmView({super.key, required this.events, required this.loadEventCallback}); // Constructor

  @override
  _ConfirmViewState createState() => _ConfirmViewState();
}

class _ConfirmViewState extends State<ConfirmView> {
  late List<Event> _events;
  late Function loadEventCallback;
  bool _isAnimating = false; // Controls animation visibility
  final Duration _animationDuration = Duration(seconds: 2); // Duration to show animation

  @override
  void initState() {
    super.initState();
    _events = List.from(widget.events); // Create a mutable copy
    loadEventCallback = widget.loadEventCallback;
  }

  void AddEventsIntoDatabaseAfterConfirmation(){
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
                setState(() {
                  _isAnimating = true; // Start the animation
                });

                // Delay for the animation duration
                await Future.delayed(_animationDuration);

                // After the delay, hide the animation and close the view
                if (mounted) {
                  setState(() {
                    _isAnimating = false; // Stop the animation
                  });
                }

                // Call the function to add events to the database
                AddEventsIntoDatabaseAfterConfirmation();

                // Run the callback function to trigger calendar update
                loadEventCallback.call();

                // Show the confirmation snackbar
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('You have added the events successfully!'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                    ),
                  );
                }

                if (mounted) {
                  Navigator.pop(context); // Close the ConfirmView
                }
              } else {
                // Show the confirmation snackbar
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('There is no event to confirm.'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Your existing GridView.builder
          Padding(
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
                  eventList: _events,
                  onAdd: (event) {
                    setState(() {
                      _events.add(event);
                    });
                  },
                  onRemove: (event) {
                    setState(() {
                      _events.remove(event);
                    });
                  },
                );
              },
            ),
          ),

          // Lottie animation overlay
          if (_isAnimating)
            Container(
              color: Colors.black54, // Semi-transparent background
              child: Center(
                child: Lottie.asset(
                  'assets/success.json', // Replace with your JSON file path
                  width: 200,
                  height: 200,
                  repeat: false, // Play only once
                ),
              ),
            ),
        ],
      ),
    );
  }
}