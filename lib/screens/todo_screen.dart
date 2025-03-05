import 'package:cloud_firestore/cloud_firestore.dart';
import'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/models/todo.dart';
import 'package:todo/services/database_services.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
 
  final TextEditingController _textEditingController = TextEditingController();

  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Theme.of(context).colorScheme.primary,
    resizeToAvoidBottomInset: false,
      appBar: _appBar(),
      body: _buildUI(),
      floatingActionButton: FloatingActionButton(onPressed: _displayTextInputDialog, backgroundColor: Theme.of(context).colorScheme.primary,
      child: const Icon(
        Icons.add,
        color: Colors.white),
        ),
    );
  }

  PreferredSizeWidget _appBar(){
  return AppBar(
    backgroundColor: Theme.of(context).colorScheme.primary,
    title: const Text(
    "My Todo Work App",
    style: TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.italic
  ),
),
  );
  }

  Widget _buildUI() {
    return SafeArea(
        child: Column(
          children: [
            _messagesListView(),
          ],
        ));
  }

  Widget _messagesListView() {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.80,
      width: MediaQuery.sizeOf(context).width,
      child: StreamBuilder(
       stream: _databaseService.getTools(),
        builder: (context, snapshot) {
         List todos = snapshot.data?.docs ?? [];
         if(todos.isEmpty){
           return const Center(
             child: Text("Add a todo!"),
           );
         }
        return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index){
              Todo todo = todos[index].data();
              String todoId = todos[index].id;
              return Padding(padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 10,
              ),
                child: Card(
                  color: const Color.fromARGB(255, 249, 215, 93),
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100), // Rounded corners
                   ),
                   elevation: 10, // Adds shadow effect
                   margin: const EdgeInsets.symmetric(horizontal: 5), // adjust Horizontal spacing
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(50), // Ensures corners are rounded
                   ),
                    // tileColor: Theme.of(context).colorScheme.primaryContainer, // color is not applied here
                    title: Text(todo.task),
                    subtitle: Text(DateFormat("dd-MM-yyyy h:mm a").format(
                      todo.updatedOn.toDate(),
                    ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value:todo.isDone,
                          onChanged: (value) {
                           Todo updatedTodo = todo.copyWith(
                               isDone: !todo.isDone, updatedOn: Timestamp.now());
                           _databaseService.updateTodo(todoId, updatedTodo);
                          },
                        ),
                        IconButton(
                        icon: const Icon(Icons.edit,),
                        onPressed: () => _showEditDialog(todoId, todo.task),
                         ),
                      ],
                    ),
                    onLongPress: (){
                      _databaseService.deleteTodo(todoId);
                    }
                  ),
                ),
              );
            }
          );
        },
       ),
     );
  }

  void _displayTextInputDialog() async{
  return showDialog(
    context: context, 
    builder: (context){
      return AlertDialog(
        title: const Text("Add a todo"),
       content: TextField(
        controller: _textEditingController,
        decoration: const InputDecoration(hintText: "Write Todo.."),
       ),
       actions: <Widget> [MaterialButton(
        color: Theme.of(context).colorScheme.primary,
        textColor: Colors.white,
        child: const Text("OK"),
        onPressed: (){
          Todo todo = Todo(
              task: _textEditingController.text,
              isDone: false,
              createdOn: Timestamp.now(),
              updatedOn: Timestamp.now());
          _databaseService.addTodo(todo);
          Navigator.pop(context);
          _textEditingController.clear();
        },
       )],
      );
    },
    );
  }


// For Edit Option TextField and Its Dialog Option Setting
  void _showEditDialog(String todoId, String currentTask) {
  TextEditingController editController = TextEditingController(text: currentTask);

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18), // Rounded corners
        ),
        child: Padding(
          padding: const EdgeInsets.all(17.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To avoid excessive height
            children: [
              const Text("Edit Todo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: editController,
                decoration: const InputDecoration(
                  hintText: "Update Your Task Name",
                  border: OutlineInputBorder( // Rounded TextField
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    onPressed: () {
                      String updatedTask = editController.text.trim();
                      if (updatedTask.isNotEmpty) {
                        Todo updatedTodo = Todo(
                          task: updatedTask,
                          isDone: false,
                          createdOn: Timestamp.now(),
                          updatedOn: Timestamp.now(),
                        );
                        _databaseService.updateTodo(todoId, updatedTodo);
                      }
                      Navigator.pop(context);
                    },
                    child: const Text("Save", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
}


