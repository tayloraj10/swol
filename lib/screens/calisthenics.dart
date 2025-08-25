import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:swole/components/current_workouts.dart';
import 'package:swole/components/date_changer.dart';
import 'package:swole/components/nav_bar.dart';
import 'package:swole/components/new_workout_button.dart';
import 'package:swole/components/progressions_dialog.dart';
import 'package:swole/constants.dart';

class CalisthenicsHome extends StatefulWidget {
  const CalisthenicsHome({super.key});

  @override
  State<CalisthenicsHome> createState() => _CalisthenicsHomeState();
}

class _CalisthenicsHomeState extends State<CalisthenicsHome> {
  DateTime selectedDate = DateTime.now();
  bool showPastExercises = false;

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  fetchData() async {
    final firestore = FirebaseFirestore.instance;
    final collection = firestore
        .collection('exercises_calisthenics')
        .where('graph', isEqualTo: true);

    final snapshot = await collection.get();
    List<Map<String, dynamic>> dataList = [];
    for (var doc in snapshot.docs) {
      final data = doc.data();
      data['id'] = doc.id;
      dataList.add(data);
    }
    return dataList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavBar(
        color: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ElevatedButton(
                      onPressed: () async {
                        List<Map<String, dynamic>> dataList = await fetchData();
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ProgressionsDialog(dataList: dataList);
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        'Progressions',
                        style: mediumTextStyle,
                      ),
                    ),
                  ),
                  NewWorkoutButton(
                    date: selectedDate,
                    type: 'calisthenics',
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  DateChanger(
                    initialDate: selectedDate,
                    onDateChanged: (newDate) {
                      setState(() {
                        selectedDate = newDate;
                      });
                    },
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Show Past 3 Exercises',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Switch(
                        activeColor: Colors.blue,
                        value: showPastExercises,
                        onChanged: (value) {
                          setState(() {
                            showPastExercises = value;
                          });
                        },
                      ),
                    ],
                  )
                ],
              ),
              CurrentWorkouts(
                date: selectedDate,
                showPastExercises: showPastExercises,
                type: 'calisthenics',
              )
            ],
          ),
        ),
      ),
    );
  }
}
