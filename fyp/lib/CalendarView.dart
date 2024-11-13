import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'AddEvent.dart';
import 'EventDatabase.dart'; // Import your EventDatabase

enum CalendarType { week, month }

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  CalendarType type = CalendarType.month;

  // Create an EventDatabase instance
  EventDatabase eventDatabase = EventDatabase(); // Modified

  // Initialize the EventController
  EventController eventController = EventController(); // Modified

  @override
  void initState() {
    super.initState();
    _loadEvents(); // Load events on initialization
  }

  // Load events from the database into the event controller
  void _loadEvents() {
    for (var event in eventDatabase.events) {
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
        endTime: endDateTime,
      ));
    }
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
          startDay: WeekDays.sunday,
          cellAspectRatio: 0.65,
          showWeekTileBorder: true,
          onCellTap: (events, date) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Selected Date"),
                  content: Text("You selected: ${date}"),
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
              MaterialPageRoute(builder: (context) => AddEvent(eventDatabase: eventDatabase)), // Pass eventDatabase
            );
            _loadEvents(); // Reload events after adding a new one
          },
          backgroundColor: Colors.lightBlue,
          child: Icon(Icons.add, color: Colors.white),
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
          heightPerMinute: 0.9,
          startDay: WeekDays.sunday,
          startHour: 6,
          endHour: 23,
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
            // Navigate and add event
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddEvent(eventDatabase: eventDatabase)), // Pass eventDatabase
            );
            _loadEvents(); // Reload events after adding a new one
          },
          backgroundColor: Colors.lightBlue,
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}