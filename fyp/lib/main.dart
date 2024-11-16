import 'package:flutter/material.dart';
import 'package:fyp/CalendarView.dart';
import 'package:fyp/ToDoListView.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar App1.1.1',
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
      appBar: AppBar(
        elevation: 2,
        title: const Text("FYP Calendar ver1.1"),
      ),
      body: PageView(
        controller: _pageController,
        children:  [
          Center(
            child: Text('Home Page'),

          ),
          Center(
              child: CalendarView(),
          ),
          Center(
            child: ToDoListView(),
          ),
          Center(
            child: Text('Reminder'),
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
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: 'To-Do-List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Reminder',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}