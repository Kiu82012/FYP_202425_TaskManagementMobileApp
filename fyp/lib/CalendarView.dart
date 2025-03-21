import 'dart:collection';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:fyp/EventJsonUtils.dart';
import 'package:fyp/EventNavigator.dart';
import 'package:fyp/loadingPage.dart';
import 'package:image_picker/image_picker.dart';
import 'AddEvent.dart';
import 'ConfirmView.dart';
import 'EditEvent.dart';
import 'Event.dart';
import 'EventDatabase.dart'; // Import your EventDatabase
import 'package:intl/intl.dart';
import 'TimeOfDayFunc.dart';
import 'speech_to_text.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'CameraView.dart';

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
  SpeechText st = SpeechText();
  String spokenWords = "new words";
  bool isSpeaking = false;
  void _showSpeechOverlay(BuildContext context) {
    st = SpeechText();
    _overlayEntry = OverlayEntry(
      builder: (context) => st,
    );



    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeSpeechOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    st.stopListening.call();
    spokenWords = SpeechText.wordSpoken;
    // Open confirm view after this
    PassRequirementsToAI(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoadingPage(lottieAsset: 'assets/loading.json'),
      ),
    );
  }

  void PassRequirementsToAI(BuildContext context) async {
    print("Passing Requirements to AI...");
    // Generate Event using AI
    String newEventListJson =
        await EventNavigator.generateEvent(spokenWords, db);

    print("Converting json into events...");
    // Turn json format into event list
    EventJsonUtils util = EventJsonUtils();
    List<Event> newEventList = util.jsonToEvent(newEventListJson);

    // Empty List Check
    if (newEventList.isEmpty) {
      log("Fail to identify any event");

      // Show the empty list snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Fail to identify any event. Speech must be clear and precise.'),
          duration: Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        ),
      );

      Navigator.of(context).pop();
      return;
    }

    print("Listing events into confirm view...");

    // Navigate to ConfirmView
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ConfirmView(events: newEventList, loadEventCallback: _loadEvents),
      ),
    );
    Navigator.of(context).pop();
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

  ///
  /// THis is camera view choice alert dialogue
  /// returns different string according to choice, then open different camera view.
  ///
  Future<String?> showChoiceDialog(BuildContext context) async {
    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Photo Select Option",
            style: TextStyle(
              color: Colors.blueAccent,
              fontSize: 20,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Open Camera"),
                onTap: () {
                  Navigator.pop(context, "Camera"); // Return "Camera" as the choice
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Select from Gallery"),
                onTap: () {
                  Navigator.pop(context, "Gallery"); // Return "Gallery" as the choice
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without returning a value
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
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

  ///
  /// THis is the end of camera view choice alert dialogue
  ///

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

  ///==============================================================================================================================
  ///==Month View==================================================================================================================
  ///==============================================================================================================================

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
                        child: Icon(Icons.add),
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
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                            color: Colors.lightBlue[50],
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: Colors.grey[400]!,
                              width: 1.7,
                            ),
                          ),
                            child: TextButton(
                            style:ButtonStyle(
                              foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
                            ),
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
                                  overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
                                  maxLines: 2, // Allow text to wrap to a second line if needed
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
                  setState(() => isSpeaking = true);
                  _showSpeechOverlay(context);
                },
                onLongPressEnd: (details) {
                  // Close the dialog when the user releases the mic button
                  print("Stop speaking");
                  setState(() => isSpeaking = false);
                  _closeSpeechOverlay();
                },
                child: AvatarGlow(
                  animate: isSpeaking,
                  glowColor: Colors.blue, // Customize glow color
                  duration: const Duration(milliseconds: 2000),
                  repeat: true,
                  child: FloatingActionButton(
                    onPressed: null,
                    child: Icon(Icons.mic),
                  ),
                ),
              ),
              SizedBox(width: 10), // Add spacing between buttons

              // New Camera button
              FloatingActionButton(
                onPressed: () async {
                  // Show the choice dialog and wait for the user's selection
                  String? choice = await showChoiceDialog(context);

                  if (choice == "Camera") {
                    // Open the CameraView
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CameraView(
                          PassPhotoToAI: () => passPhotoToAI(), // Your callback function
                        ),
                      ),
                    );
                  } else if (choice == "Gallery") {
                    // Handle gallery selection
                    final pickedFile = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
                    if (pickedFile != null) {
                      // Process the selected image
                      print('Selected image path: ${pickedFile.path}');
                      CameraView.Photopath = pickedFile.path;

                      // ADD LOADING ANIMATION HERE
                      // Loading();

                      passPhotoToAI();
                    }
                  }
                },
                child: Icon(Icons.camera_alt),
              ),
              Expanded(child: Container()),

              // Existing Add button
              FloatingActionButton(
                onPressed: () async {
                  SelectedDate.date = DateTime.now();
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddEvent(eventDatabase: db)),
                  );
                  _loadEvents();
                },
                child: Icon(Icons.add),
              ),
            ],
          ),
        ), // speaking button
      ),
    );
  }

  ///==============================================================================================================================
  ///==Week View===================================================================================================================
  ///==============================================================================================================================

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
          eventTileBuilder: (date, events, boundary, start, end) {
            return Container( // Remove SingleChildScrollView
              height: boundary.height,
              decoration: BoxDecoration(
                color: Colors.lightBlue[50],
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: Colors.grey[400]!,
                  width: 1.7,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: events.map((event) {
                    return Container(
                      padding: const EdgeInsets.all(3.0),
                      child: Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
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
                          width: 45), // Add spacing between title and FloatingActionButton
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
                        return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.lightBlue[50],
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                  color: Colors.grey[400]!,
                                  width: 1.7,
                                ),
                              ),
                              child: TextButton(
                                style:ButtonStyle(
                                  foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
                                ),
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
                            )
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
              SizedBox(width: 10), // Add spacing between buttons

              // New Camera button
          FloatingActionButton(
            onPressed: () async {
              // Show the choice dialog and wait for the user's selection
              String? choice = await showChoiceDialog(context);

              if (choice == "Camera") {
                // Open the CameraView
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CameraView(
                      PassPhotoToAI: () => passPhotoToAI(), // Your callback function
                    ),
                  ),
                );
              } else if (choice == "Gallery") {
                // Handle gallery selection
                final pickedFile = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                );
                if (pickedFile != null) {
                  // Process the selected image
                  print('Selected image path: ${pickedFile.path}');
                  CameraView.Photopath = pickedFile.path;

                  // ADD LOADING ANIMATION HERE
                  // Loading();

                  passPhotoToAI();
                }
              }
            },
            child: Icon(Icons.camera_alt),
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

  Future<void> passPhotoToAI() async {
    try {
      String json = await EventNavigator.generateEventByPhoto(
          File(CameraView.Photopath), db);
      EventJsonUtils ForPhoto = EventJsonUtils();
      List<Event> Photoevent = ForPhoto.jsonToEvent(json);

      // Empty List Check
      if (Photoevent.isEmpty){
        log("Fail to identify any event");

        // Show the empty list snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fail to identify any event. Photo must be clear and precise.'),
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          ),
        );


        return;
      }

      if (mounted) { // not yet dispose
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmView(
              events: Photoevent,
              loadEventCallback: _loadEvents,
            ),
          ),
        );
      }
    } catch (e) {
      print("Error processing photo: $e");
    }
  }
}
