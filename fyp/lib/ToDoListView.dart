import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'TodoList.dart';
import 'ToDoDataBase.dart';
import 'DialogBox.dart';
import 'package:lottie/lottie.dart';

class ToDoListView extends StatefulWidget {
  const ToDoListView({super.key});

  @override
  _ToDoListView createState() => _ToDoListView();
}

class _ToDoListView extends State<ToDoListView> {
  final _myBox = Hive.box('mybox');

  ToDoDataBase db = ToDoDataBase();
  List _foundToDo = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    //if this is the first time ever opening the app
    if (_myBox.get("TODOLIST") == null) {
      db.createInitialData();
    } else {
      //there already exists data
      db.loadData();
    }
    _foundToDo = List.from(db.toDoList);
    _searchController.addListener(_searchToDo);
    super.initState();
  }

  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchToDo() {
    setState(() {
      final searchTerm = _searchController.text.toLowerCase();
      _foundToDo = db.toDoList
          .where((todo) =>
          (todo[0] as String).toLowerCase().contains(searchTerm))
          .map((todo) => List.from(todo)) // create copies!
          .toList();
    });
  }

  int _selectedIndex = 0; // Index of the selected tab
  PageController _pageController = PageController();

  //text controller
  final _controller = TextEditingController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  //checkbox was tapped
  void checkBoxChanged(bool? value, int index) {
    setState(() {
      _foundToDo[index][1] = value!; // Use the non-nullable value directly
      // Find and update in db.toDoList based on task name
      int originalIndex = db.toDoList.indexWhere(
              (originalTodo) => originalTodo[0] == _foundToDo[index][0]);
      if (originalIndex != -1) {
        db.toDoList[originalIndex][1] = value; // Update in the original list
      }
      _searchToDo(); // Rebuild _foundToDo to reflect changes
    });
    db.updateDataBase();
  }

//save new task
  void saveNewTask() {
    String newTaskName = _controller.text.trim();

    if (newTaskName.isEmpty) {
      // Show an error message if the task name is empty
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Task name cannot be empty!"),
            actions: [
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    // Check if the task name already exists in the list
    bool taskExists = db.toDoList.any((task) => task[0] == newTaskName);

    if (taskExists) {
      // Show an error message if the task name already exists
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text('Task "$newTaskName" already exists!'),
            actions: [
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    setState(() {
      db.toDoList.insert(0, [newTaskName, false]);
      _searchToDo();
      _controller.clear();
    });
    Navigator.of(context).pop();
    db.updateDataBase();
  }

//create a new task
  void createNewTask() {
    showDialog(
        context: context,
        builder: (context) {
          return DialogBox(
            controller: _controller,
            onSave: saveNewTask,
            onCancel: () => Navigator.of(context).pop(),
          );
        });
  }

//delete a task
  void deleteTask(int index) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Start the timer when the dialog is built
            Future.delayed(Duration(seconds: 1), () {
              // Close the dialog after 2 seconds
              Navigator.of(context).pop();

              // Perform the deletion after the dialog is closed
              setState(() {
                // Find and remove from db.toDoList based on task name
                int originalIndex = db.toDoList.indexWhere(
                        (originalTodo) => originalTodo[0] == _foundToDo[index][0]);
                if (originalIndex != -1) {
                  db.toDoList.removeAt(originalIndex);
                }
                _searchToDo(); // Rebuild _foundToDo after deleting
              });
              db.updateDataBase();
            });
            return AlertDialog(
              content: Lottie.asset(
                "assets/delete_animation2.json",
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              ),
            );
          },
        );
      },
    );
  }

  int getCompletedTaskCount() {
    return _foundToDo.where((task) => task[1] == true).length;
  }

  double getProgressValue() {
    if (_foundToDo.isEmpty) {
      return 0.0; // No tasks, no progress
    }
    double completedTasks = getCompletedTaskCount().toDouble();
    double totalTasks = _foundToDo.length.toDouble();
    return completedTasks / totalTasks;
  }

  @override
  Widget build(BuildContext context) {
    int completedTaskCount = getCompletedTaskCount();
    int totalTaskCount = _foundToDo.length;
    double progressValue = getProgressValue();

    return Scaffold(
      resizeToAvoidBottomInset: true, // Changed to true
      backgroundColor: Color(0xFFEEEFF5),
      appBar: AppBar(
        title: Text("To Do List"),
        elevation: 100,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // Search bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(0),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.black,
                            size: 20,
                          ),
                          prefixIconConstraints: BoxConstraints(
                            maxHeight: 20,
                            maxWidth: 25,
                          ),
                          border: InputBorder.none,
                          hintText: "Search",
                          hintStyle: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Header section
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "My Tasks",
                              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Row(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: CircularProgressIndicator(
                                      value: progressValue,
                                      strokeWidth: 5,
                                      backgroundColor: Colors.grey[300],
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 8),
                              Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(bottom: 2),
                                    child: Text(
                                      '$completedTaskCount of $totalTaskCount tasks',
                                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                    ),
                                  ),
                                  Container(
                                    height: 1,
                                    color: Colors.grey[400],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Task list
                    Expanded(
                      child: _foundToDo.isEmpty
                          ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Lottie.asset(
                              "assets/empty_list.json",
                              width: 200,
                              height: 200,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "You Have Done All Tasks! 👍",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                          : ListView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        padding: const EdgeInsets.only(top: 8.0),
                        itemCount: _foundToDo.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Todolist(
                            taskName: _foundToDo[index][0],
                            taskCompleted: _foundToDo[index][1],
                            onChanged: (value) => checkBoxChanged(value, index),
                            deleteFunction: (context) => deleteTask(index),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        child: Icon(Icons.add),
        elevation: 4,
      ),
    );
  }
}