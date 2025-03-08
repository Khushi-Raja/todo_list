import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/todo_list.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('myBox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Box _myBox;
  TodoDatabase db = TodoDatabase();

  @override
  void initState() {
    super.initState();
    // Initialize Hive and open the box
    openBox();
  }

  Future<void> openBox() async {
    _myBox = Hive.box('myBox');
    // Check if the box is empty and initialize if necessary
    if (_myBox.get("TODOLIST") == null) {
      db.createInitialData();
    } else {
      db.loadData();
    }
    setState(() {}); // Update the UI after opening the box and loading data
  }

  final _controller = TextEditingController();

  void checkBoxChanged(int index) {
    setState(() {
      db.toDoList[index][1] = !db.toDoList[index][1];
    });
    db.updateDatabase();
  }

  void saveNewTask() {
    setState(() {
      db.toDoList.add([_controller.text, false]);
      _controller.clear();
    });
    db.updateDatabase();
  }

  void deleteTask(int index) {
    setState(() {
      db.toDoList.removeAt(index);
    });
    db.updateDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purpleAccent,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Center(child: Text("Todo")),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: db.toDoList.length,
        itemBuilder: (context, index) {
          return TodoList(
            taskName: db.toDoList[index][0],
            taskCompleted: db.toDoList[index][1],
            onChanged: (value) {
              checkBoxChanged(index);
            },
            deleteFunction: (context) => deleteTask(index),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Add new todo items",
                    filled: true,
                    fillColor: Colors.purple.shade200,
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.purple),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.purple),
                    ),
                  ),
                ),
              ),
            ),
            FloatingActionButton(
              onPressed: saveNewTask,
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}

class TodoDatabase {
  List toDoList = [];

  //reference the box
  late Box _myBox;

  TodoDatabase() {
    _myBox = Hive.box('myBox');
  }

  //run this data if this is the 1st time opening this app
  void createInitialData() {
    toDoList = [
      ['Learn Flutter', false],
      ['Drink Coffee', false]
    ];
    updateDatabase();
  }

  //Load the data from database
  void loadData() {
    toDoList = List<List<dynamic>>.from(_myBox.get("TODOLIST"));
  }

  //Update the database
  void updateDatabase() {
    _myBox.put("TODOLIST", toDoList);
  }
}