import 'package:flutter/material.dart';
import 'package:fyp/CalendarView.dart';
import 'package:fyp/StringFuncs.dart';
import 'Event.dart';
import 'EventDatabase.dart';

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

  Event oldEvent = Event(name: "default", date: DateTime.now());

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedName = "";

  @override
  void initState() {
    super.initState();

    oldEvent = widget.selectedEvent;

    _selectedDate = widget.selectedEvent.date;
    _selectedTime = widget.selectedEvent.startTime;
    _selectedName = widget.selectedEvent.name;
  }

  @override
  void dispose() {
    _eventNameController.dispose();
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
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
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
        startTime: _selectedTime,
      );
      
      db.addEvent(newEvent);

      _eventNameController.clear();
      _selectedDate = null;
      _selectedTime = null;
      Navigator.of(context).pop();
    }
  }

  void _deleteEvent(){
    if (_formKey.currentState!.validate()) {
      EventDatabase db = EventDatabase();
      db.deleteEvent(oldEvent);

      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {

    // rearrange date format
    List<String> date = _selectedDate!.toLocal().toString().split(' ')[0].split('-');// 0 is YYYY,  1 is MM, 2 is DD

    // set default value of text
    _eventNameController.text = _selectedName;

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
                          _deleteEvent();
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
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Date: ",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
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
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Time: ",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      textAlign: TextAlign.center,
                      _selectedTime == null ?
                      'Not selected' : '${_selectedTime!.format(context)}',
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