import 'package:flutter/material.dart';
import 'package:fyp/CalendarView.dart';
import 'package:fyp/DurationAdapter.dart';
import 'package:fyp/Event.dart';
import 'package:fyp/ToDoDataBase.dart';
import 'package:fyp/ToDoListView.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:fyp/AppNotification.dart';
import 'package:fyp/NotificationTestPage.dart';
import 'package:fyp/CameraView.dart';
import 'package:flutter/material.dart';
import 'AIChatroom.dart';
import 'AIHelper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initial Database
  await Hive.initFlutter();
  //open 2 boxes for separated database
  await Hive.openBox('mybox');
  Hive.registerAdapter(TimeOfDayAdapter());
  Hive.registerAdapter(DurationAdapter());
  Hive.registerAdapter(EventAdapter());
  await Hive.openBox('eventBox');

/*  final notificationService = AppNotification();
  await notificationService.init();*/



  runApp(const MyApp());

}

class MyApp extends StatelessWidget {

  const MyApp({super.key});




  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0; // Index of the selected tab
  PageController _pageController = PageController();

  List<DateTime> selectedDates = [];

  CalendarView calendarView = CalendarView();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          Center(
            child: CalendarView(),
          ),
          Center(
            child: ToDoListView(),
          ),
        ],
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: 'To-Do-List',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,  // Use theme's primary color
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),  // Adaptive color
        onTap: _onItemTapped,
      ),
    );
  }
}
