import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:fyp/CalendarView.dart';
import 'package:fyp/DurationFunc.dart';
import 'package:fyp/StringFuncs.dart';
import 'Event.dart';
import 'EventDatabase.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

class EditEvent extends StatefulWidget {
  final EventDatabase eventDatabase;
  final Event selectedEvent;

  EditEvent({required this.eventDatabase, required this.selectedEvent});

  @override
  _EditEventState createState() => _EditEventState();
}

class _EditEventState extends State<EditEvent> {
  final _formKey = GlobalKey<FormState>();
  final _eventNameController = TextEditingController();
  final _eventDescController = TextEditingController();

  Event oldEvent = Event(name: "default", date: DateTime.now(), description: "");

  String _selectedName = "";
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  Duration? _selectedDuration;
  String _selectedDescription = "";

  @override
  void initState() {
    super.initState();

    oldEvent = widget.selectedEvent;

    _selectedName = widget.selectedEvent.name;
    _selectedDate = widget.selectedEvent.date;
    _selectedStartTime = widget.selectedEvent.startTime;
    _selectedEndTime = widget.selectedEvent.endTime;
    _selectedDuration = widget.selectedEvent.duration;
    _selectedDescription = widget.selectedEvent.description;
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventDescController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedStartTime) {
      setState(() {
        _selectedStartTime = picked;
      });
    }
  }

  Future<void> _selectDuration(BuildContext context) async {
    final Duration? picked = await showDurationPicker(
        context: context,
        initialTime: Duration(hours: 0)
    );
    if (picked != null && picked != _selectedDuration) {
      setState(() {
        _selectedDuration = picked;
      });
    }
  }

  void _updateEvent() {
    if (_formKey.currentState!.validate()) {
      EventDatabase db = EventDatabase();

      // remove old event
      db.deleteEvent(oldEvent);
      
      // add new event to replace old one
      Event newEvent = Event(
        name: _eventNameController.text,
        date: _selectedDate!,
        startTime: _selectedStartTime,
        endTime: _selectedEndTime,
        duration: _selectedDuration,
        description: _eventNameController.text,
      );
      
      db.addEvent(newEvent);

      _eventNameController.clear();
      _selectedDate = null;
      _selectedStartTime = null;
      Navigator.of(context).pop();
    }
  }

  void _deleteEvent(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      // Show the Lottie animation
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing by tapping outside
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/delete_animation2.json', // Replace with your Lottie asset
                  width: 200,
                  height: 200,
                  repeat: false, // Play only once
                ),
                const SizedBox(height: 16),
                const Text('Deleting event...'), // Optional message
              ],
            ),
          );
        },
      );
      // Perform the deletion and navigate after a delay
      EventDatabase db = EventDatabase();
      await db.deleteEvent(oldEvent); // Await the deletion

      // Delay for a few seconds to show the animation
      Timer(const Duration(seconds: 2), () {
        Navigator.of(context).pop(); // Close the animation dialog
        Navigator.of(context).pop(); // Pop the current page
        Navigator.of(context).pop(); // Pop the previous page (if needed)
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    // rearrange date format
    List<String> date = _selectedDate!.toLocal().toString().split(' ')[0].split('-');// 0 is YYYY,  1 is MM, 2 is DD

    // set default value of text
    _eventNameController.text = _selectedName;
    _eventDescController.text = _selectedDescription;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Event'),
        elevation: 100,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            color: Colors.red,
            tooltip: 'Delete',
            onPressed: () {
              showDialog(
                  context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Delete Event"),
                    content: Text("Are you sure you want to delete this event?"),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Yes'),
                        onPressed: () {
                          _deleteEvent(context);
                        },
                      ),
                      TextButton(
                        child: Text('No'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _eventNameController,
                decoration: InputDecoration(labelText: 'Event Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an event name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              //=======================================\\
              //===============Date====================\\
              //=======================================\\
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Date: ",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Text(
                      textAlign: TextAlign.center,
                      _selectedDate == null ?
                      'Not selected' : '${date[2].trimCharLeft("0")}/${date[1].trimCharLeft("0")}/${date[0]}', // rearranged date format into DD/MM/YYYY
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _selectDate(context),
                    style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                    ),
                    icon: const Icon(Icons.calendar_month),
                    label: Text("select"),
                  ),
                ],
              ),

              //=======================================\\
              //===============Time====================\\
              //=======================================\\
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Time: ",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Text(
                      textAlign: TextAlign.center,
                      _selectedStartTime == null ?
                      'Not selected' : '${_selectedStartTime!.format(context)}',
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 24,

                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _selectTime(context),
                    style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                    ),
                    icon: const Icon(Icons.watch),
                    label: Text("select"),
                  ),
                ],
              ),

              //=======================================\\
              //===============Duration================\\
              //=======================================\\
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Duration: ",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Text(
                      textAlign: TextAlign.center,
                      _selectedDuration == null ?
                      'Not selected' : '${_selectedDuration?.Format()}',
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 24,

                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _selectDuration(context),
                    style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                    ),
                    icon: const Icon(Icons.punch_clock),
                    label: Text("select"),
                  ),
                ],
              ),
              //==========================================\\
              //===============Description================\\
              //==========================================\\
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(2.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description:',
                            style: TextStyle(fontSize: 20),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: _eventDescController,  // Use the class-level controller
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText: 'Enter description...',
                              hintStyle: TextStyle(fontStyle: FontStyle.italic),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(12),
                            ),
                            keyboardType: TextInputType.multiline,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child:ElevatedButton(
                      onPressed: _updateEvent,
                      child: Text('Save changes'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}