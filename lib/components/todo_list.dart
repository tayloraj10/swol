import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TodoList extends StatefulWidget {
  final DateTime date;
  const TodoList({super.key, required this.date});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  void addTodo() {
    var userID = FirebaseAuth.instance.currentUser!.uid;
    var ref = FirebaseFirestore.instance.collection("todo");
    ref.add({
      "completed": false,
      "task": "",
      "completed_date": null,
      "completed_day": null,
      "user_id": userID,
      "created_date": DateTime.now()
    });
  }

  void updateCompleted(String id, bool value) {
    DateTime? completedDate = value ? DateTime.now() : null;
    String? completedDateFormatted =
        value ? DateFormat('yyyy-MM-dd').format(DateTime.now()) : null;
    FirebaseFirestore.instance.collection("todo").doc(id).update({
      "completed": value,
      "completed_date": completedDate,
      "completed_day": completedDateFormatted
    });
  }

  void updateTask(String id, String value) {
    FirebaseFirestore.instance.collection("todo").doc(id).update({
      "task": value,
    });
  }

  void deleteTodo(String id) {
    FirebaseFirestore.instance.collection("todo").doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: StreamBuilder<QuerySnapshot>(
        key: UniqueKey(),
        stream: FirebaseFirestore.instance
            .collection("todo")
            .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .where(Filter.or(
                Filter("completed_day",
                    isEqualTo: DateFormat('yyyy-MM-dd').format(widget.date)),
                Filter("completed_day", isNull: true)))
            // .orderBy("completed_day")
            .orderBy("created_date")
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            // print(snapshot.error);
            return const Text(
              'Something went wrong',
              style: TextStyle(color: Colors.white),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(
              color: Colors.green,
            );
          }

          var documents = snapshot.data!.docs;

          return ListView.builder(
            shrinkWrap: true,
            itemCount: documents.length + 1,
            itemBuilder: (context, index) {
              if (index == documents.length) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 14, left: 0),
                      child: IconButton(
                        onPressed: () => {addTodo()},
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.add_circle_rounded,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                );
              }

              DocumentSnapshot document = documents[index];
              final data = document.data() as Map<String, dynamic>;
              TextEditingController controller = TextEditingController();
              controller.text = data['task'];
              controller.selection =
                  TextSelection.collapsed(offset: controller.text.length);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IntrinsicWidth(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Checkbox(
                          activeColor: Colors.green,
                          value: data['completed'],
                          onChanged: (newValue) {
                            updateCompleted(document.id, newValue!);
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        onChanged: (value) => {updateTask(document.id, value)},
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: IconButton(
                        onPressed: () => {deleteTodo(document.id)},
                        icon: const Icon(
                          Icons.close,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
