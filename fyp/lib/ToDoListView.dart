import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'TodoList.dart';
import 'ToDoDataBase.dart';
import 'DialogBox.dart';

class ToDoListView extends StatefulWidget {

  const ToDoListView({super.key});

  @override
  _ToDoListView createState() => _ToDoListView();
}

class _ToDoListView extends State<ToDoListView> {

  final _myBox = Hive.box('mybox');

  ToDoDataBase db=ToDoDataBase();
  List _foundToDo=[];
  TextEditingController _searchController=TextEditingController();
  @override


  void initState(){
    //if this is the first time ever opening the app
    if(_myBox.get("TODOLIST")==null){
      db.createInitialData();
    }else{
      //there already exists data
      db.loadData();
    }
    _foundToDo=List.from(db.toDoList);
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
  final _controller=TextEditingController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  //checkbox was tapped
  void checkBoxChanged(bool? value, int index) {
    setState(() {
      _foundToDo[index][1] = !_foundToDo[index][1];
      // Find and update in db.toDoList based on task name
      int originalIndex = db.toDoList.indexWhere(
              (originalTodo) => originalTodo[0] == _foundToDo[index][0]);
      if (originalIndex != -1) {
        db.toDoList[originalIndex][1] = _foundToDo[index][1];
      }
      _searchToDo(); // Rebuild _foundToDo to reflect changes
    });
    db.updateDataBase();
  }
//save new task
  void saveNewTask(){
    setState(() {
      db.toDoList.insert(0,[_controller.text,false]);
      _searchToDo();
      _controller.clear();
    });
    Navigator.of(context).pop();
    db.updateDataBase();
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
  void deleteTask(int index) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEEEFF5),
      appBar: AppBar(
        title: Text("To Do List"),
        elevation: 100,
      ),
      body: Padding( // Add padding
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(  // Search bar container
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
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft, // Align to the left
                child: Text(
                  "All To Dos",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
              ),
            ),// Add spacing
            Expanded(// Use Expanded to fill available space
              child: _foundToDo.isEmpty
                  ? Center( // Center the empty state message
                child: Text('No task',
                style: TextStyle(fontSize: 20),),
              )
                  : ListView.builder(
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
      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        child: Icon(Icons.add),
      ),
    );
  }
  }

