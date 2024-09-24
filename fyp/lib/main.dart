import 'package:clean_calendar/clean_calendar.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar App',
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
        title: const Text("Calendar"),
      ),
      body: PageView(
        controller: _pageController,
        children:  [
          Center(
            child: Text('Home Page'),

          ),
          CleanCalendar(
            generalDatesProperties: DatesProperties(
              datesDecoration: DatesDecoration(

              ),
              // Configuration for the CleanCalendar widget
            ),
          ),
          Center(
            child: Text('To-Do-List'),
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
        onTap: _onItemTapped,
      ),
    );
  }
}