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

  @override
  void initState(){
    //if this is the first time ever opening the app

    if(_myBox.get("TODOLIST")==null){
      db.createInitialData();
    }else{
      //there already exists data
      db.loadData();
    }
    super.initState();
  }

  int _selectedIndex = 0; // Index of the selected tab
  PageController _pageController = PageController();

  //text controller
  final _controller=TextEditingController();

  //checkbox was tapped
  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.toDoList[index][1] = !db.toDoList[index][1];
    });
    db.updateDataBase();
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
      db.toDoList.add([_controller.text,false]);
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

  void deleteTask(int index){
    setState(() {
      db.toDoList.removeAt(index);
    });
    db.updateDataBase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView.builder(
            itemCount: db.toDoList.length,
            itemBuilder: (BuildContext context, int index) {
              return Todolist(
                taskName: db.toDoList[index][0],
                taskCompleted: db.toDoList[index][1],
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
    );
  }
}
