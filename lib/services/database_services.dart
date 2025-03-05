import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo/models/todo.dart';


const String TODO_COLLECTON_REF = "todos";

class DatabaseService {

  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _todosRef;

  DatabaseService() {
    _todosRef = _firestore.collection(TODO_COLLECTON_REF).withConverter<Todo>(
      fromFirestore: (snapshots, _) => Todo.fromJson(
        snapshots.data()!,
      ),
      toFirestore: (todo,_) => todo.toJson());
  }

  Stream<QuerySnapshot> getTools(){
    return _todosRef.snapshots();
  }

  void addTodo(Todo todo) async{
    _todosRef.add(todo);
  }

  void updateTodo(String todoId, Todo updatedTodo) async{
    await _todosRef.doc(todoId).update(updatedTodo.toJson());
  }

  void deleteTodo(String todoId) {
    _todosRef.doc(todoId).delete();
  }

}

