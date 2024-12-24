import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:hive/hive.dart';
import 'AddEvent.dart';
import 'Event.dart';
import 'EventDatabase.dart'; // Import your EventDatabase
import 'package:intl/intl.dart';

enum CalendarType { week, month }

class SelectedDate{
  static DateTime date = DateTime.now();
}

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
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
  void dispose(){
    super.dispose();
    _saveEvents;();
  }

  // Load events from the database into the event controller
  void _loadEvents() {
    db.loadEvents();

    List<Event> events = db.getEventList();
    for (var event in events) {
      DateTime startDateTime = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
        event.time?.hour ?? 0,
        event.time?.minute ?? 0,
      );

      DateTime endDateTime = startDateTime.add(Duration(hours: 1));

      eventController.add(CalendarEventData(
        title: event.name,
        date: event.date,
        startTime: startDateTime,
        endTime: endDateTime,));
    }
  }

  List<Event> _loadEventsOnDate(DateTime selectedDate) {
    db.loadEvents();

    List<Event> events = db.getEventList();
    List<Event> selectedEvents = events.where((event) =>
    event.date.year == selectedDate.year &&
        event.date.month == selectedDate.month &&
        event.date.day == selectedDate.day
    ).toList();
    selectedEvents.forEach((event) {
      print("${event.name} - ${DateFormat.Hm().format(event.date)}");
    });

    return selectedEvents;
  }

  void _saveEvents(){
    db.saveEvents();
  }

  void changeCalendarType(CalendarType newType) {
    setState(() {
      type = newType; // Update the calendar type
    });
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
  //==Month View=================================================================================================================
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
          ],
        ),
        body: MonthView(
          controller: eventController,
          startDay: WeekDays.sunday,
          cellAspectRatio: 0.65,
          showWeekTileBorder: true,
          onCellTap: (events, date) async {
            List<Event> selectedEvents = _loadEventsOnDate(date); // Load events for the selected date
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Row(
                    children: [
                      Text("Events on ${date.day}/${date.month}:"),
                      SizedBox(width: 45),  // Add spacing between title and FloatingActionButton
                      FloatingActionButton(
                        onPressed: () async {

                          SelectedDate.date = date; // update the selected date time, note that this must run before popping add event page.

                          // Add your FloatingActionButton functionality here
                          // For example, you can add a new event
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AddEvent(eventDatabase: db)),
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
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Event Details"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Event Name: ${event.name}"),
                                        Text("Event Time: ${DateFormat.Hm().format(event.date)}"),

                                      ],
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
                            child: Text("${event.name} - ${DateFormat.Hm().format(event.date)}"),
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
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // Navigate and add event
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddEvent(eventDatabase: db)), // Pass eventDatabase
            );
            _loadEvents(); // Reload events after adding a new one
          },

          child: Icon(Icons.add),
        ),
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
          onEventTap: (events, date) { // Modified to handle event taps
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Events"),
                  content: Text("Events on: ${date}"),
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
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            SelectedDate.date = DateTime.now(); // update the selected date time to now, as users are usually looking at today's week
            // Navigate and add event
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddEvent(eventDatabase: db)), // Pass eventDatabase
            );
            _loadEvents(); // Reload events after adding a new one
          },

          child: Icon(Icons.add),
        ),
      ),
    );
  }
}