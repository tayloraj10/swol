import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swole/constants.dart';

class ManageTasksDialog extends StatefulWidget {
  final Map<String, Map> categories;
  const ManageTasksDialog({super.key, required this.categories});

  @override
  State<ManageTasksDialog> createState() => _ManageTasksDialogState();
}

class _ManageTasksDialogState extends State<ManageTasksDialog> {
  removeCategory(String category) async {
    // Logic to remove the category
    DocumentSnapshot data = await FirebaseFirestore.instance
        .collection("habits")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    Map<String, dynamic> categoryData = data['categories'];
    categoryData.remove(category);
    await FirebaseFirestore.instance
        .collection("habits")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'categories': categoryData});
  }

  removeTask(String category, String task) async {
    // Logic to remove the task from the category
    DocumentSnapshot data = await FirebaseFirestore.instance
        .collection("habits")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    Map<String, dynamic> categoryData = data['categories'];
    List<dynamic> tasks = categoryData[category]['tasks'];
    tasks.remove(task);
    await FirebaseFirestore.instance
        .collection("habits")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'categories': categoryData});
  }

  addNewTask(String category, String task) async {
    DocumentSnapshot data = await FirebaseFirestore.instance
        .collection("habits")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    Map<String, dynamic> categoryData = data['categories'];
    List<dynamic> tasks = categoryData[category]['tasks'];
    tasks.add(task);
    await FirebaseFirestore.instance
        .collection("habits")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'categories': categoryData});
  }

  addNewCategory(String category) async {
    DocumentSnapshot data = await FirebaseFirestore.instance
        .collection("habits")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    Map<String, dynamic> categoryData = data['categories'];
    int order = categoryData.length + 1;
    categoryData[category] = {'tasks': [], 'goal': 1, 'order': order};
    await FirebaseFirestore.instance
        .collection("habits")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'categories': categoryData});
  }

  updateGoal(String category, int goal) async {
    DocumentSnapshot data = await FirebaseFirestore.instance
        .collection("habits")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    Map<String, dynamic> categoryData = data['categories'];
    categoryData[category]['goal'] = goal;
    await FirebaseFirestore.instance
        .collection("habits")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'categories': categoryData});
  }

  final TextEditingController _categoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Categories and Tasks', style: largeTextStyle),
      content: SingleChildScrollView(
        child: Column(
          children: [
            ...widget.categories.keys.map((category) {
              final TextEditingController taskController =
                  TextEditingController();
              final TextEditingController goalController =
                  TextEditingController();

              goalController.value = TextEditingValue(
                text: widget.categories[category]!['goal'].toString(),
              );
              goalController.selection =
                  TextSelection.collapsed(offset: goalController.text.length);
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SizedBox(
                          width: 50,
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Goal',
                            ),
                            keyboardType: TextInputType.number,
                            controller: goalController,
                            onChanged: (value) {
                              int? newGoal = int.tryParse(value);
                              goalController.selection =
                                  TextSelection.collapsed(
                                      offset: goalController.text.length);
                              updateGoal(category, newGoal!);
                              setState(() {
                                widget.categories[category]!['goal'] = newGoal;
                              });
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          removeCategory(category);
                          setState(() {
                            widget.categories.remove(category);
                          });
                        },
                      ),
                    ],
                  ),
                  ...widget.categories[category]!['tasks'].map<Widget>((task) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            task,
                            style:
                                const TextStyle(color: Colors.lightGreenAccent),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                removeTask(category, task);
                                widget.categories[category]!['tasks']
                                    .remove(task);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Add Task',
                            ),
                            controller: taskController,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            String newTask = taskController.text;
                            if (newTask.isNotEmpty) {
                              addNewTask(category, newTask);
                              setState(() {
                                widget.categories[category]!['tasks']
                                    .add(newTask);
                              });
                              taskController.clear();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                ],
              );
            }).toList(),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Add New Category',
                      ),
                      controller: _categoryController,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      String newCategory = _categoryController.text;
                      if (newCategory.isNotEmpty) {
                        addNewCategory(newCategory);
                        setState(() {
                          widget.categories[newCategory] = {
                            'tasks': [],
                            'goal': 1
                          };
                        });
                        _categoryController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
