import 'package:flutter/material.dart';
import 'package:fyp/CalendarView.dart';
import 'package:fyp/StringFuncs.dart';
import 'Event.dart';
import 'EventDatabase.dart';

class AddEvent extends StatefulWidget {
  final EventDatabase eventDatabase;

  AddEvent({required this.eventDatabase});

  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  final _formKey = GlobalKey<FormState>();
  final _eventNameController = TextEditingController();
  DateTime? _selectedDate = SelectedDate.date;
  TimeOfDay? _selectedTime = TimeOfDay(hour: 12, minute: 0);

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

      Event newEvent = Event(
        name: _eventNameController.text,
        date: _selectedDate!,
        time: _selectedTime,
      );

      EventDatabase db = EventDatabase();
      db.addEvent(newEvent);

      _eventNameController.clear();
      _selectedDate = null;
      _selectedTime = null;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {

    List<String> date = _selectedDate!.toLocal().toString().split(' ')[0].split('-');// 0 is YYYY,  1 is MM, 2 is DD

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Event'),
        elevation: 100,
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
              ElevatedButton(
                onPressed: _updateEvent,
                child: Text('Save events'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}