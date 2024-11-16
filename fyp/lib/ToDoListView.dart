import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'AddEvent.dart';

class ToDoListView extends StatefulWidget {
  const ToDoListView({super.key});

  @override
  _ToDoListView createState() => _ToDoListView();
}

class _ToDoListView extends State<ToDoListView> {
  @override
  Widget build(BuildContext context) {
    return Stack(
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
  }

}
