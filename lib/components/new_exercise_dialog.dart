import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swole/constants.dart';

class NewExerciseDialog extends StatefulWidget {
  final DateTime date;
  const NewExerciseDialog(this.date, {super.key});

  @override
  State<NewExerciseDialog> createState() => _NewExerciseDialogState();
}

class _NewExerciseDialogState extends State<NewExerciseDialog> {
  String? selectedCategory;

  createNewWorkout(Map exercise) {
    FirebaseFirestore.instance.collection('workouts_calisthenics').add({
      'category': exercise['category'],
      'date': widget.date,
      'exercise_id': exercise['id'],
      'exercise_name': exercise['name'],
      'sets': [],
      'notes': '',
      'user_id': FirebaseAuth.instance.currentUser!.uid,
    });
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Select an Exercise',
                style: largeTextStyle,
              ),
              FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('exercises_calisthenics')
                    .orderBy('category')
                    .get(),
                builder: (context, snapshot) {
                  // if (snapshot.connectionState == ConnectionState.waiting) {
                  //   return const CircularProgressIndicator();
                  // }
                  if (snapshot.hasError) {
                    return const Text('Error loading categories');
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text('');
                  }

                  var exercises = snapshot.data!.docs;
                  var categories =
                      exercises.map((doc) => doc['category']).toSet().toList();

                  return DropdownButton<String>(
                    hint: const Text('Select Category'),
                    value: selectedCategory,
                    items: categories.map<DropdownMenuItem<String>>((category) {
                      return DropdownMenuItem<String>(
                        value: category as String,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue;
                      });
                    },
                  );
                },
              ),
            ],
          ),
          content: FutureBuilder(
            future: selectedCategory != null
                ? FirebaseFirestore.instance
                    .collection('exercises_calisthenics')
                    .where('category', isEqualTo: selectedCategory)
                    .orderBy('name')
                    .get()
                : FirebaseFirestore.instance
                    .collection('exercises_calisthenics')
                    .orderBy('category')
                    .orderBy('name')
                    .get(),
            builder: (context, snapshot) {
              // if (snapshot.connectionState == ConnectionState.waiting) {
              //   // return const Center(child: CircularProgressIndicator());
              //   return SizedBox(
              //     height: MediaQuery.of(context).size.height * 0.5,
              //     width: MediaQuery.of(context).size.width * 0.75,
              //     // child: const Text('Loading Exercises'),
              //   );
              // }
              if (snapshot.hasError) {
                return const Text('Error loading exercises');
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text('Loading');
              }
              var exercises = snapshot.data!.docs;

              // Group exercises by category
              Map<String, List<Map<String, dynamic>>> groupedExercises = {};
              for (var exercise in exercises) {
                String category = exercise['category'];
                if (groupedExercises[category] == null) {
                  groupedExercises[category] = [];
                }
                var exerciseData = exercise.data();
                exerciseData['id'] =
                    exercise.id; // Add the id to the exercise data
                groupedExercises[category]!.add(exerciseData);
              }

              // Define a list of colors to use for the categories
              List<Color> categoryColors = [
                Colors.red,
                Colors.green,
                Colors.blue,
                Colors.orange,
                Colors.purple,
                Colors.teal,
                Colors.amber,
                Colors.pink,
              ];

              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width * 0.75,
                child: ListView(
                  children: groupedExercises.entries.map((entry) {
                    // Get a color for the category
                    Color categoryColor = categoryColors[
                        groupedExercises.keys.toList().indexOf(entry.key) %
                            categoryColors.length];

                    return Container(
                      color: categoryColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...entry.value.map((exercise) {
                            return Column(
                              children: [
                                ListTile(
                                  title: Text(exercise['name']),
                                  leading: IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      createNewWorkout(exercise);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ),
                                const Divider(
                                  color: Colors.black,
                                  indent: 20,
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
