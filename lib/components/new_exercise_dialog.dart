import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swole/components/create_exercise_dialog.dart';
import 'package:swole/components/exercise_queue.dart';
import 'package:swole/constants.dart';

class NewExerciseDialog extends StatefulWidget {
  final DateTime date;
  final String type;
  const NewExerciseDialog({super.key, required this.type, required this.date});

  @override
  State<NewExerciseDialog> createState() => _NewExerciseDialogState();
}

class _NewExerciseDialogState extends State<NewExerciseDialog> {
  String? selectedCategory;
  List categories = [];
  List focusExercises = [];
  String filterText = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchFocusExercises();
  }

  fetchFocusExercises() async {
    var docSnapshot = await FirebaseFirestore.instance
        .collection('focus_exercises')
        .doc(getUser()!.uid)
        .get();

    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      setState(() {
        focusExercises = data?['exercises'] ?? [];
      });
    } else {
      setState(() {
        focusExercises = [];
      });
    }
  }

  handleFavorite(String id) async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('focus_exercises')
        .doc(getUser()!.uid)
        .get();
    Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;
    if (data != null) {
      if (data['exercises'] != null && data['exercises'].contains(id)) {
        data['exercises'].remove(id);
      } else {
        data['exercises'] = (data['exercises'] ?? [])..add(id);
      }
    } else {
      data = {
        'exercises': [id]
      };
    }

    await FirebaseFirestore.instance
        .collection('focus_exercises')
        .doc(getUser()!.uid)
        .set(data);

    fetchFocusExercises();
  }

  getWorkoutsCollectionName(String type) {
    if (type == 'weights') {
      return 'workouts_weights';
    } else if (type == 'calisthenics') {
      return 'workouts_calisthenics';
    } else {
      return '';
    }
  }

  getExercisesCollectionName(String type) {
    if (type == 'weights') {
      return 'exercises_weights';
    } else if (type == 'calisthenics') {
      return 'exercises_calisthenics';
    } else {
      return '';
    }
  }

  getCategoriesCollectionName(String type) {
    if (type == 'weights') {
      return 'categories_weights';
    } else if (type == 'calisthenics') {
      return 'categories_calisthenics';
    } else {
      return '';
    }
  }

  createNewWorkout(Map exercise, {bool queue = false}) {
    FirebaseFirestore.instance
        .collection(getWorkoutsCollectionName(widget.type))
        .add({
      'category': exercise['category'],
      'date': widget.date,
      'exercise_id': exercise['id'],
      'exercise_name': exercise['name'],
      'sets': [
        {'reps': 0, 'weight': 0},
        {'reps': 0, 'weight': 0},
        {'reps': 0, 'weight': 0},
      ],
      'notes': '',
      'user_id': FirebaseAuth.instance.currentUser!.uid,
      'queue': queue,
    });
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'Select an Exercise',
                        style: largeTextStyle,
                      ),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CreateExerciseDialog(
                                categories: categories,
                              );
                            },
                          );
                        },
                        icon: const Tooltip(
                          message: "Add a new exercise",
                          child: Icon(Icons.add),
                        ),
                      ),
                    ],
                  ),
                  FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection(getCategoriesCollectionName(widget.type))
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Error loading categories');
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Text('');
                      }

                      var exercises = snapshot.data!.docs;
                      if (exercises.isNotEmpty) {
                        categories =
                            List<String>.from(exercises.first['categories']);
                      }

                      return DropdownButton<String>(
                        hint: const Text('Select Category'),
                        value: selectedCategory,
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('All Categories'),
                          ),
                          ...categories
                              .map<DropdownMenuItem<String>>((category) {
                            return DropdownMenuItem<String>(
                              value: category as String,
                              child: Text(category),
                            );
                          }).toList(),
                        ],
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
              Row(
                children: [
                  SizedBox(
                    width: 250,
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Filter',
                        hintText: 'Type here',
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      ),
                      onChanged: (value) {
                        setState(() {
                          // Store the filter text in a state variable
                          filterText = value.toLowerCase();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width * 0.75,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 5,
                  child: StreamBuilder(
                    stream: selectedCategory != null
                        ? FirebaseFirestore.instance
                            .collection(getExercisesCollectionName(widget.type))
                            .where('category', isEqualTo: selectedCategory)
                            .orderBy('name')
                            .snapshots()
                        : FirebaseFirestore.instance
                            .collection(getExercisesCollectionName(widget.type))
                            .orderBy('category')
                            .orderBy('name')
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Error loading exercises');
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Text('Loading');
                      }
                      var exercises = snapshot.data!.docs;

                      // Filter exercises by filterText
                      var filteredExercises = exercises.where((exercise) {
                        var name =
                            (exercise['name'] ?? '').toString().toLowerCase();
                        return filterText.isEmpty || name.contains(filterText);
                      }).toList();

                      // Group exercises by category
                      Map<String, List<Map<String, dynamic>>> groupedExercises =
                          {};
                      for (var exercise in filteredExercises) {
                        String category = exercise['category'];
                        if (groupedExercises[category] == null) {
                          groupedExercises[category] = [];
                        }
                        var exerciseData = exercise.data();
                        exerciseData['id'] =
                            exercise.id; // Add the id to the exercise data
                        groupedExercises[category]!.add(exerciseData);
                      }

                      // Sort each category's exercises so favorites come first
                      groupedExercises.forEach((category, exList) {
                        exList.sort((a, b) {
                          bool aFav = focusExercises.contains(a['id']);
                          bool bFav = focusExercises.contains(b['id']);
                          if (aFav == bFav) {
                            return a['name']
                                .toString()
                                .compareTo(b['name'].toString());
                          }
                          return bFav ? 1 : -1;
                        });
                      });

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

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: ListView(
                              children: groupedExercises.entries.map((entry) {
                                // Get a color for the category
                                Color categoryColor = categoryColors[
                                    groupedExercises.keys
                                            .toList()
                                            .indexOf(entry.key) %
                                        categoryColors.length];

                                return Container(
                                  color: categoryColor,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                              leading: Tooltip(
                                                message:
                                                    "Add this exercise to your workout",
                                                child: IconButton(
                                                  icon: const Icon(Icons.add),
                                                  onPressed: () {
                                                    createNewWorkout(exercise);
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ),
                                              trailing: LayoutBuilder(
                                                builder:
                                                    (context, constraints) {
                                                  bool isSmallScreen =
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width <
                                                          600;
                                                  if (isSmallScreen) {
                                                    // Show a single popup menu button on small screens
                                                    return PopupMenuButton<int>(
                                                      icon: Icon(
                                                        Icons.more_vert,
                                                        color: focusExercises
                                                                .contains(
                                                                    exercise[
                                                                        'id'])
                                                            ? Colors.yellow
                                                            : null,
                                                      ),
                                                      onSelected: (value) {
                                                        if (value == 0) {
                                                          handleFavorite(
                                                              exercise['id']);
                                                        } else if (value == 1) {
                                                          createNewWorkout(
                                                              exercise,
                                                              queue: true);
                                                        }
                                                      },
                                                      itemBuilder: (context) =>
                                                          [
                                                        PopupMenuItem(
                                                          value: 0,
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                focusExercises.contains(
                                                                        exercise[
                                                                            'id'])
                                                                    ? Icons
                                                                        .favorite
                                                                    : Icons
                                                                        .favorite_border_outlined,
                                                                color: focusExercises.contains(
                                                                        exercise[
                                                                            'id'])
                                                                    ? Colors
                                                                        .yellow
                                                                    : null,
                                                              ),
                                                              const SizedBox(
                                                                  width: 8),
                                                              Text(focusExercises
                                                                      .contains(
                                                                          exercise[
                                                                              'id'])
                                                                  ? "Unfavorite"
                                                                  : "Favorite"),
                                                            ],
                                                          ),
                                                        ),
                                                        PopupMenuItem(
                                                          value: 1,
                                                          child: Row(
                                                            children: const [
                                                              Icon(Icons.queue),
                                                              SizedBox(
                                                                  width: 8),
                                                              Text(
                                                                  "Add to queue"),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  } else {
                                                    // Show all icons on larger screens
                                                    return IntrinsicWidth(
                                                      child: Row(
                                                        children: [
                                                          Tooltip(
                                                            message: focusExercises
                                                                    .contains(
                                                                        exercise[
                                                                            'id'])
                                                                ? "Remove from favorites"
                                                                : "Add to favorites",
                                                            child: IconButton(
                                                              icon: Icon(
                                                                focusExercises.contains(
                                                                        exercise[
                                                                            'id'])
                                                                    ? Icons
                                                                        .favorite
                                                                    : Icons
                                                                        .favorite_border_outlined,
                                                                color: focusExercises.contains(
                                                                        exercise[
                                                                            'id'])
                                                                    ? Colors
                                                                        .yellow
                                                                    : null,
                                                              ),
                                                              onPressed: () =>
                                                                  handleFavorite(
                                                                      exercise[
                                                                          'id']),
                                                            ),
                                                          ),
                                                          Tooltip(
                                                            message:
                                                                "Add this to your workout queue",
                                                            child: IconButton(
                                                              icon: const Icon(
                                                                  Icons.queue),
                                                              onPressed: () {
                                                                createNewWorkout(
                                                                    exercise,
                                                                    queue:
                                                                        true);
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }
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
                          ),
                          // Only show ExerciseQueue on large screens and after loading
                          if (MediaQuery.of(context).size.width > 900)
                            Flexible(
                              child: ExerciseQueue(type: widget.type),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
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
