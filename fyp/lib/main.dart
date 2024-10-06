import 'package:clean_calendar/clean_calendar.dart';
import 'package:flutter/material.dart';
import 'package:fyp/ToDoList.dart';
import 'package:fyp/dialog_box.dart';

void main() {
  runApp(const MyApp());
}

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

  //text controller
  final _controller=TextEditingController();
  List<DateTime> selectedDates = [];
  List toDoList = [
    ["Make tutorial", false],
    ["Do exercise", false],
  ];
 //checkbox was tapped
  void checkBoxChanged(bool? value, int index) {
    setState(() {
      toDoList[index][1] = !toDoList[index][1];
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }
//save new task
  void saveNewTask(){
    setState(() {
      toDoList.add([_controller.text,false]);
      _controller.clear();
    });
    Navigator.of(context).pop();
  }

//create a new task
  void createNewTask(){
    showDialog(context: context, builder: (context){
        return DialogBox(
          controller: _controller,
          onSave: saveNewTask,
          onCancel: ()=> Navigator.of(context).pop(),);
    });
  }

  //delete a task

  void deleteTask(int index){
    setState(() {
      toDoList.removeAt(index);
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
        children: [
          Center(
            child: Text('Home Page'),
          ),
          CleanCalendar(
            weekdaysSymbol: const Weekdays(
                sunday: "Sun",
                monday: "Mon",
                tuesday: "Tue",
                wednesday: "Wed",
                thursday: "Thur",
                friday: "Fri",
                saturday: "Sat"),
            generalDatesProperties: DatesProperties(
              datesDecoration: DatesDecoration(),
              // Configuration for the CleanCalendar widget
            ),
            currentDateProperties: DatesProperties(
              datesDecoration: DatesDecoration(
                datesBorderColor: Colors.lightGreen.shade700,
                datesTextColor: Colors.lightGreen.shade700,
              ),
            ),
          ),
          Stack(
            children: [
              ListView.builder(
              itemCount: toDoList.length,
                itemBuilder: (BuildContext context, int index) {
               return Todolist(
                 taskName: toDoList[index][0],
                 taskCompleted: toDoList[index][1],
                  onChanged: (value) => checkBoxChanged(value, index),
                deleteFunction: (context)=> deleteTask(index),
               );
            },
              ),
              Positioned(
                bottom: 16.0,
                right: 16.0,
                child:FloatingActionButton(
                onPressed: createNewTask,
                child: Icon(Icons.add),
              ),
              )
          ],
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
