import 'dart:collection';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'AddEvent.dart';
import 'ConfirmView.dart';
import 'EditEvent.dart';
import 'Event.dart';
import 'EventDatabase.dart'; // Import your EventDatabase
import 'package:intl/intl.dart';
import 'TimeOfDayFunc.dart';
import 'speech_to_text.dart';

enum CalendarType { week, month }

class SelectedDate {
  static DateTime date = DateTime.now();
}

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  //==============================================================================================================================
  //==Replace showDialog with OverlayEntry==================================================================================================================
  //==============================================================================================================================
  OverlayEntry? _overlayEntry;

  void _showSpeechOverlay(BuildContext context) {
    _overlayEntry = OverlayEntry(
      builder: (context) => SpeechText(),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeSpeechOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  //==============================================================================================================================
  //==Replace showDialog with OverlayEntry==================================================================================================================
  //==============================================================================================================================
  CalendarType type = CalendarType.month;

  // Create an EventDatabase instance
  EventDatabase db = EventDatabase(); // Modified

  // Initialize the EventController
  EventController eventController = EventController(); // Modified

  @override
  void initState() {
    super.initState();
    _loadEvents(); // Load events on initialization
  }

  @override
  void dispose() {
    super.dispose();
    _saveEvents();
  }

  List<CalendarEventData> eventDataList = [];

  // Load events from the database into the event controller
  void _loadEvents() {
    eventController.removeAll(eventDataList);
    db.loadEvents();

    List<Event> events = db.getEventList();
    for (var event in events) {
      // ===================== Event ================================ \\
      DateTime startDateTime = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
        event.startTime?.hour ?? 0,
        event.startTime?.minute ?? 0,
      );

      late DateTime endDateTime;
      if (event.duration != null) {
        Duration d = Duration(seconds: event.duration!.inSeconds);
        endDateTime = startDateTime.add(d);
      } else {
        endDateTime = startDateTime.add(Duration(hours: 1));
      }

      CalendarEventData data = CalendarEventData(
          title: event.name,
          date: event.date,
          startTime: startDateTime,
          endTime: endDateTime);

      // ========================================================== \\

      eventController.add(data);
      eventDataList.add(data);
    }

    print("Reloaded Calendar");
  }

  List<Event> _loadEventsOnDate(DateTime selectedDate) {
    db.loadEvents();

    List<Event> events = db.getEventList();
    List<Event> selectedEvents = events
        .where((event) =>
    event.date.year == selectedDate.year &&
        event.date.month == selectedDate.month &&
        event.date.day == selectedDate.day)
        .toList();
    selectedEvents.forEach((event) {
      print("${event.name} - ${event.startTime?.Format()}");
    });

    return selectedEvents;
  }

  void _saveEvents() {
    db.saveEvents();
  }

  void changeCalendarType(CalendarType newType) {
    setState(() {
      type = newType; // Update the calendar type
    });
  }

  // Helper function to convert TimeOfDay to DateTime
  DateTime _timeOfDayToDateTime(TimeOfDay? time) {
    if (time == null) {
      return DateTime.now(); // Fallback to current time if time is null
    }
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }

  // Helper function to format DateTime as a string
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime); // Example: 10:00 AM
  }

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case CalendarType.month:
        return CalendarControllerProvider(
          controller: eventController, // Provide the eventController
          child: buildMonthViewApp(),
        );
      case CalendarType.week:
        return CalendarControllerProvider(
          controller: eventController, // Provide the eventController
          child: buildWeekViewApp(),
        );
    }
  }

  //==============================================================================================================================
  //==Month View==================================================================================================================
  //==============================================================================================================================

  MaterialApp buildMonthViewApp() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Calendar"),
          elevation: 100,
          actions: [
            IconButton(
              icon: Icon(Icons.change_circle_rounded),
              onPressed: () {
                changeCalendarType(CalendarType.week);
                log("Change to week calendar");
              },
            ),

            /// TEST /////// TEST /////// TEST ////
            IconButton(
              icon: Icon(Icons.directions_run),
              onPressed: () async {
                // Navigate and add event
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ConfirmView(
                            events: db
                                .getEventList())) // Pass eventDatabase, event chosen
                );
                _loadEvents(); // Reload events after adding a new one
              },
            ),

            /// TEST /////// TEST /////// TEST ////
          ],
        ),
        body: MonthView(
          controller: eventController,
          startDay: WeekDays.sunday,
          cellAspectRatio: 0.65,
          showWeekTileBorder: true,
          onCellTap: (events, date) async {
            List<Event> selectedEvents =
            _loadEventsOnDate(date); // Load events for the selected date
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Row(
                    children: [
                      Text("Events on ${date.day}/${date.month}:"),
                      SizedBox(
                          width:
                          45), // Add spacing between title and FloatingActionButton
                      FloatingActionButton(
                        onPressed: () async {
                          SelectedDate.date =
                              date; // update the selected date time, note that this must run before popping add event page.

                          // Add your FloatingActionButton functionality here
                          // For example, you can add a new event
                          Navigator.of(context).pop();
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AddEvent(eventDatabase: db)),
                          );
                          _loadEvents(); // Reload events after adding a new one
                        },
                        backgroundColor: Colors.lightBlue,
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  ),
                  content: Container(
                    width: double.maxFinite,
                    height: 200, // Fixed height for the outer container (optional)
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: selectedEvents.length,
                      itemBuilder: (context, index) {
                        Event event = selectedEvents[index];
                        return IntrinsicHeight( // Make the height flexible
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextButton(
                              onPressed: () async {
                                // Navigate and add event
                                Navigator.of(context).pop();
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditEvent(
                                      eventDatabase: db,
                                      selectedEvent: event,
                                    ),
                                  ), // Pass eventDatabase, event chosen
                                );
                                _loadEvents(); // Reload events after adding a new one
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8), // Add padding for better spacing
                                child: Text(
                                  "${event.name} - ${_formatDateTime(_timeOfDayToDateTime(event.startTime))} to ${_formatDateTime(_timeOfDayToDateTime(event.startTime).add(event.duration ?? Duration.zero))} - Duration: ${event.duration?.inHours ?? 0}h ${event.duration?.inMinutes.remainder(60) ?? 0}m",
                                  maxLines: 2, // Allow text to wrap to a second line if needed
                                  overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Close'),
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
        //Speaking button
        floatingActionButton: Padding(
          padding: EdgeInsets.only(left: 30),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onLongPressStart: (details) {
                  print("I am speaking");
                  _showSpeechOverlay(context);
                },
                onLongPressEnd: (details) {
                  // Close the dialog when the user releases the mic button
                  print("Stop speaking");
                  _closeSpeechOverlay();
                },
                child: FloatingActionButton(
                  onPressed: null,
                  child: Icon(Icons.mic),
                ),
              ),
              Expanded(child: Container()),
              FloatingActionButton(
                onPressed: () async {
                  SelectedDate.date = DateTime
                      .now(); // update the selected date time to now, as users are usually looking at today's week
                  // Navigate and add event
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AddEvent(eventDatabase: db)), // Pass eventDatabase
                  );
                  _loadEvents(); // Reload events after adding a new one
                },
                child: Icon(Icons.add),
              ),
            ],
          ),
        ), // speaking button
      ),
    );
  }

  //==============================================================================================================================
  //==Week View===================================================================================================================
  //==============================================================================================================================

  MaterialApp buildWeekViewApp() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Calendar"),
          elevation: 100,
          actions: [
            IconButton(
              icon: Icon(Icons.change_circle_rounded),
              onPressed: () {
                changeCalendarType(CalendarType.month);
                log("Change to month calendar");
              },
            ),
          ],
        ),
        body: WeekView(
          controller: eventController,
          showLiveTimeLineInAllDays: false,
          heightPerMinute: 1,
          startDay: WeekDays.sunday,
          startHour: 0,
          endHour: 24,
          minDay: DateTime(1990),
          maxDay: DateTime(2070),
          onEventTap: (events, date) {
            // Modified to handle event taps
            List<Event> selectedEvents =
            _loadEventsOnDate(date); // Load events for the selected date
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Row(
                    children: [
                      Text("Events on ${date.day}/${date.month}:"),
                      SizedBox(
                          width:
                          45), // Add spacing between title and FloatingActionButton
                      FloatingActionButton(
                        onPressed: () async {
                          SelectedDate.date =
                              date; // update the selected date time, note that this must run before popping add event page.

                          // Add your FloatingActionButton functionality here
                          // For example, you can add a new event
                          Navigator.of(context).pop();
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AddEvent(eventDatabase: db)),
                          );
                          _loadEvents(); // Reload events after adding a new one
                        },
                        backgroundColor: Colors.lightBlue,
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  ),
                  content: Container(
                    width: double.maxFinite,
                    height: 200,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: selectedEvents.length,
                      itemBuilder: (context, index) {
                        Event event = selectedEvents[index];
                        return Container(
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextButton(
                            onPressed: () async {
                              // Navigate and add event
                              Navigator.of(context).pop();
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditEvent(
                                      eventDatabase: db,
                                      selectedEvent: event,
                                    )), // Pass eventDatabase, event chosen
                              );
                              _loadEvents(); // Reload events after adding a new one
                            },
                            child: Text(
                                "${event.name} - ${event.startTime?.Format()}"),
                          ),
                        );
                      },
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Close'),
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
        floatingActionButton: Padding(
          padding: EdgeInsets.only(left: 30),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SpeechText()),
                  );
                },
                child: Icon(Icons.mic),
              ),
              Expanded(child: Container()),
              FloatingActionButton(
                onPressed: () async {
                  SelectedDate.date = DateTime
                      .now(); // update the selected date time to now, as users are usually looking at today's week
                  // Navigate and add event
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AddEvent(eventDatabase: db)), // Pass eventDatabase
                  );
                  _loadEvents(); // Reload events after adding a new one
                },
                child: Icon(Icons.add),
              ),
            ],
          ),
        ),
      ),
    );
  }
}