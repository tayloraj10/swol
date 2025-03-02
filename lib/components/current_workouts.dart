import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swole/components/single_workout.dart';

class CurrentWorkouts extends StatefulWidget {
  final DateTime date;
  final bool showPastExercises;

  const CurrentWorkouts(
      {super.key, required this.date, required this.showPastExercises});

  @override
  State<CurrentWorkouts> createState() => _CurrentWorkoutsState();
}

class _CurrentWorkoutsState extends State<CurrentWorkouts> {
  num previousTotal = 0;

  updatePreviousTotal(int total) {
    previousTotal = total;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      key: UniqueKey(),
      stream: FirebaseFirestore.instance
          .collection('workouts_calisthenics')
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(
                  widget.date.year, widget.date.month - 1, widget.date.day)))
          .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Center(child: SelectableText('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: Text('No Exercises Found')),
          );
        } else {
          final data = snapshot.data!;
          Map<String, List<QueryDocumentSnapshot>> groupedData = {};

          for (var doc in data.docs) {
            String date =
                DateFormat('M/dd').format((doc['date'] as Timestamp).toDate());
            if (groupedData[date] == null) {
              groupedData[date] = [];
            }
            groupedData[date]!.add(doc);
          }

          return Scrollbar(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: groupedData.keys.length,
              itemBuilder: (context, index) {
                String date = groupedData.keys.elementAt(index);
                List<QueryDocumentSnapshot> exercises = groupedData[date]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      child: Text(
                        date,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...exercises.map((exercise) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 20),
                        child: Column(
                          children: [
                            SingleWorkout(
                              exercise: exercise,
                              lastWorkout: false,
                              previousTotal: previousTotal,
                            ),
                            if (widget.showPastExercises)
                              StreamBuilder<QuerySnapshot>(
                                key: UniqueKey(),
                                stream: FirebaseFirestore.instance
                                    .collection('workouts_calisthenics')
                                    .where('exercise_id',
                                        isEqualTo: exercise['exercise_id'])
                                    .orderBy('date', descending: true)
                                    .limit(4)
                                    .snapshots(),
                                builder: (context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Center(
                                        child:
                                            Text('Error: ${snapshot.error}'));
                                  } else {
                                    final data = snapshot.data!;
                                    return Column(
                                      children: [
                                        ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: data.docs.length - 1,
                                          itemBuilder: (context, index) {
                                            final oldExercise =
                                                data.docs[index + 1];
                                            if (index == 0) {
                                              int totalReps = 0;
                                              for (var set
                                                  in oldExercise['sets']) {
                                                totalReps +=
                                                    (set['reps'] as int);
                                              }
                                              updatePreviousTotal(totalReps);
                                            }
                                            return SingleWorkout(
                                              exercise: oldExercise,
                                              pastExercise: true,
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          );
        }
      },
    );
  }
}
