import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';

enum CalendarType { week, month }

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  CalendarType type = CalendarType.month;

  void changeCalendarType(CalendarType newType) {
    setState(() {
      type = newType; // Update the calendar type
    });
  }

  @override
  Widget build(BuildContext context) {
    EventController eventController = EventController();

    switch (type) {
      case CalendarType.month:
        return CalendarControllerProvider(
          controller: eventController,
          child: buildMonthViewApp(eventController),
        );
      case CalendarType.week:
        return CalendarControllerProvider(
            controller: eventController,
            child: buildWeekViewApp(eventController)
        );
    }
  }

  //==============================================================================================================================
  //==Month View=================================================================================================================
  //==============================================================================================================================

  MaterialApp buildMonthViewApp(EventController eventController) {
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
            CalendarEventData eventData = CalendarEventData(title: "add ", date: date);
            eventController.add(eventData);
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
          onPressed: () {
            // Pressed Button add event here
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

  MaterialApp buildWeekViewApp(EventController eventController) {
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
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Pressed Button add event here
          },
          backgroundColor: Colors.lightBlue,
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}