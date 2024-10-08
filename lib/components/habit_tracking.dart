import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swole/components/manage_tasks_dialog.dart';
import 'package:swole/constants.dart';

class HabitTracking extends StatefulWidget {
  final DateTime date;
  const HabitTracking({super.key, required this.date});

  @override
  State<HabitTracking> createState() => _HabitTrackingState();
}

class _HabitTrackingState extends State<HabitTracking> {
  Map<String, Map> categories = {};
  // static const Map<String, Map> categories = {
  //   'Exercise': {
  //     'tasks': ['Calisthenics', 'Gym'],
  //     'goal': 3
  //   },
  //   'Language': {
  //     'tasks': ['Duolingo'],
  //     'goal': 7
  //   },
  //   'Meditation': {
  //     'tasks': ['Headspace'],
  //     'goal': 3
  //   },
  //   'Stretch': {
  //     'tasks': ['Bend', 'Headspace'],
  //     'goal': 3
  //   },
  //   'Learning / Projects': {
  //     'tasks': ['Brilliant', 'React Tutorial', 'Collective', 'Programming'],
  //     'goal': 3
  //   },
  //   'Brain Training': {
  //     'tasks': ['Elevate', 'Impulse'],
  //     'goal': 3
  //   },
  //   'Creative': {
  //     'tasks': ['TikTok', 'Movie'],
  //     'goal': 5
  //   },
  //   'Music': {
  //     'tasks': ['Guitar', 'Piano'],
  //     'goal': 1
  //   },
  //   'Personal Growth': {
  //     'tasks': ['Podcast', 'Read', 'Journal', 'Jobs'],
  //     'goal': 2
  //   },
  //   'Wellbeing': {
  //     'tasks': [
  //       'Loona',
  //       'Sensa',
  //       'Cold Shower',
  //       'Supplements',
  //       'Hydration (1 gal)'
  //     ],
  //     'goal': 2
  //   },
  //   'Cardio': {
  //     'tasks': [
  //       'Bike',
  //       'Jump Rope',
  //       'Run',
  //       'Tennis',
  //       'Kettlebell Ladder',
  //       'Hike',
  //       'Swim',
  //       'Long Walk'
  //     ],
  //     'goal': 1
  //   }
  // };

  Map<String, String?> selectedValues = {};
  Map<String, num?> weeklyCounts = {};

  @override
  void initState() {
    super.initState();
    categories.forEach((category, tasks) {
      selectedValues[category] = null;
    });
    getCategories();
    getData();
    getWeeklyCounts();
  }

  @override
  void didUpdateWidget(covariant HabitTracking oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.date != widget.date) {
      setState(() {
        selectedValues = {};
      });
      getData();
      getWeeklyCounts();
    }
  }

  Future<void> getCategories() async {
    Map categoryData;
    if (await checkForCustomCategories()) {
      DocumentSnapshot data = await FirebaseFirestore.instance
          .collection("habits")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      categoryData = data['categories'];
    } else {
      QuerySnapshot data = await FirebaseFirestore.instance
          .collection("habits")
          .where('default', isEqualTo: true)
          .get();
      categoryData = data.docs.first['categories'];
    }

    categoryData.forEach((key, value) {
      categoryData[key]['tasks'] =
          List<String>.from(categoryData[key]['tasks']);
    });
    var sortedData = Map.fromEntries(categoryData.entries.toList()
      ..sort((e1, e2) => categoryData[e1.key]['order']
          .compareTo(categoryData[e2.key]['order'])));
    setState(() {
      categories = Map<String, Map>.from(sortedData);
    });
  }

  void getData() {
    var ref = FirebaseFirestore.instance.collection("habit_tracking");
    var userID = FirebaseAuth.instance.currentUser!.uid;
    var formatedDate = DateFormat('yyyy-MM-dd').format(widget.date);
    var dataRef = ref
        .where('user_id', isEqualTo: userID)
        .where("day", isEqualTo: formatedDate);
    dataRef.get().then((value) => {
          if (value.docs.isNotEmpty)
            {
              updateSelectedValues(value.docs.first.data()['tasks']),
            }
        });
  }

  void getWeeklyCounts() {
    //date calcs
    var weekStart = widget.date.add(Duration(days: -(widget.date.weekday - 1)));
    var weekEnd = widget.date.add(Duration(days: 7 - widget.date.weekday));
    var weekStartFormatted = DateFormat('yyyy-MM-dd').format(weekStart);
    var weekEndFormatted = DateFormat('yyyy-MM-dd').format(weekEnd);

    var userID = FirebaseAuth.instance.currentUser!.uid;
    var ref = FirebaseFirestore.instance.collection("habit_tracking");
    var dataRef = ref
        .where('user_id', isEqualTo: userID)
        .where('day', isGreaterThanOrEqualTo: weekStartFormatted)
        .where('day', isLessThanOrEqualTo: weekEndFormatted);
    dataRef.snapshots().forEach((element) => {
          setState(() {
            weeklyCounts = {};
          }),
          for (var e in element.docs)
            {
              // }
              // element.docs.forEach((e) {
              // print(e.data());
              e.data()['tasks'].forEach((key, value) {
                if (weeklyCounts.containsKey(key)) {
                  setState(() {
                    weeklyCounts[key] = weeklyCounts[key]! + 1;
                  });
                } else {
                  setState(() {
                    weeklyCounts[key] = 1;
                  });
                }
              })
            },
        });
  }

  void updateSelectedValues(Map tasks) {
    tasks.forEach((key, value) {
      setState(() {
        selectedValues[key] = value;
      });
    });
  }

  void sendData() {
    var ref = FirebaseFirestore.instance.collection("habit_tracking");
    var userID = FirebaseAuth.instance.currentUser!.uid;
    var formatedDate = DateFormat('yyyy-MM-dd').format(widget.date);

    var dataRef = ref
        .where('user_id', isEqualTo: userID)
        .where("day", isEqualTo: formatedDate);
    dataRef.get().then((value) => {
          if (value.docs.isEmpty)
            {
              ref.add({
                "user_id": userID,
                "date": widget.date,
                'day': formatedDate,
                "tasks": buildHabitData()
              })
            }
          else if (value.docs.isNotEmpty)
            {
              ref.doc(value.docs.first.id).update({"tasks": buildHabitData()})
            },
        });
  }

  Map<String, String> buildHabitData() {
    Map<String, String> data = {};
    categories.forEach((key, value) {
      if (selectedValues[key] != null) {
        data[key] = selectedValues[key]!;
      }
      if (selectedValues[key] == "" && data[key] != null) {
        data.remove(key);
      }
    });
    return data;
  }

  calcRemainingColor(int input) {
    int minVal = 0;
    int maxVal = 0;
    categories.forEach((key, value) {
      int remaining = categories[key]!['goal'] - (weeklyCounts[key] ?? 0);
      if (remaining > maxVal) maxVal = remaining;
    });
    double ratio = (input - minVal) / (maxVal - minVal);

    return Color.lerp(Colors.green, Colors.red, ratio)!;
  }

  Future<bool> checkForCustomCategories() async {
    var userID = FirebaseAuth.instance.currentUser!.uid;
    var userRef = FirebaseFirestore.instance.collection("habits").doc(userID);
    var userDoc = await userRef.get();

    if (!userDoc.exists) {
      return false;
    }
    return true;
  }

  createCustomCategories() async {
    var userID = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance.collection("habits").doc(userID).set({
      'categories': categories,
    });
  }

  editTasks() async {
    if (!await checkForCustomCategories()) {
      createCustomCategories();
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ManageTasksDialog(
          categories: categories,
        );
      },
    ).then((_) {
      // print('closing');
      getCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: Table(
            border: const TableBorder(
                horizontalInside: BorderSide(color: Colors.lightGreenAccent)),
            defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
            textBaseline: TextBaseline.ideographic,
            defaultColumnWidth: const IntrinsicColumnWidth(),
            children: [
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Category',
                        style: largeTextStyle,
                      ),
                      IconButton(
                          onPressed: () => {editTasks()},
                          icon: const Icon(Icons.edit_sharp)),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: Center(
                    child: Text(
                      'Task',
                      style: largeTextStyle,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: Text(
                    'Remaining',
                    style: largeTextStyle,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: Text(
                    'Goal',
                    style: largeTextStyle,
                  ),
                ),
              ]),
              ...categories.keys.map((category) {
                return TableRow(
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: DropdownButton<String>(
                              // hint: const Text('Select Task'),
                              value: selectedValues[category],
                              onChanged: (newValue) {
                                setState(() {
                                  selectedValues[category] = newValue;
                                });
                                sendData();
                              },
                              items: ([""] + categories[category]!['tasks'])
                                  .map((task) {
                                return DropdownMenuItem<String>(
                                  value: task,
                                  child: Text(task),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          color: calcRemainingColor(
                              categories[category]!['goal'] -
                                  (weeklyCounts[category] ?? 0)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                                "${categories[category]!['goal'] - (weeklyCounts[category] ?? 0)}",
                                style: mediumTextStyle
                                // .copyWith(
                                //     color: calcRemainingColor(
                                //         categories[category]!['goal'] -
                                //             (weeklyCounts[category] ?? 0))),
                                ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "${categories[category]!['goal']}",
                          style: mediumTextStyle,
                        ),
                      ],
                    ),
                  ],
                );
              }).toList()
            ],
          ),
        ),
      ),
    );
  }
}
