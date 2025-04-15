import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:fyp/CalendarView.dart';
import 'package:fyp/DurationFunc.dart';
import 'package:fyp/StringFuncs.dart';
import 'package:fyp/AppNotification.dart';
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
  final _eventDescController = TextEditingController();

  // Data
  DateTime? _selectedDate = SelectedDate.date;
  TimeOfDay? _selectedStartTime = TimeOfDay(hour: 12, minute: 0);
  TimeOfDay? _selectedEndTime = TimeOfDay(hour: 13, minute: 0);
  Duration? _selectedDuration = Duration(hours: 1);

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
      Event newEvent = Event(
        name: _eventNameController.text,
        date: _selectedDate!,
        description: _eventDescController.text,
      );

      EventDatabase db = EventDatabase();
      db.addEvent(newEvent);
      _eventNameController.clear();
      _selectedDate = null;
      _selectedStartTime = null;
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
          child: ListView(
            shrinkWrap: true,
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16),
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