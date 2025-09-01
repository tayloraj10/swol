import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swole/components/single_workout.dart';

class CurrentWorkouts extends StatefulWidget {
  final DateTime date;
  final bool showPastExercises;
  final String type;

  const CurrentWorkouts(
      {super.key,
      required this.date,
      required this.showPastExercises,
      required this.type});

  @override
  State<CurrentWorkouts> createState() => _CurrentWorkoutsState();
}

class _CurrentWorkoutsState extends State<CurrentWorkouts> {
  num previousTotal = 0;

  updatePreviousTotal(int total) {
    previousTotal = total;
  }

  getStreamName(String type) {
    if (type == 'weights') {
      return 'workouts_weights';
    } else if (type == 'calisthenics') {
      return 'workouts_calisthenics';
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      key: UniqueKey(),
      stream: FirebaseFirestore.instance
          .collection(getStreamName(widget.type))
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(
                  widget.date.year, widget.date.month - 1, widget.date.day)))
          .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where('queue', isEqualTo: false)
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
              physics: const NeverScrollableScrollPhysics(),
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
                        '$date - ${DateFormat('E').format((exercises.first['date'] as Timestamp).toDate())}',
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
                              type: widget.type,
                            ),
                            if (widget.showPastExercises)
                              StreamBuilder<QuerySnapshot>(
                                key: UniqueKey(),
                                stream: FirebaseFirestore.instance
                                    .collection(getStreamName(widget.type))
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
                                        child: SelectableText(
                                            'Error: ${snapshot.error}'));
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
                                              int total = 0;
                                              for (var set
                                                  in oldExercise['sets']) {
                                                if (widget.type == 'weights') {
                                                  total +=
                                                      (set['weight'] as int) *
                                                          (set['reps'] as int);
                                                } else if (widget.type ==
                                                    'calisthenics') {
                                                  total += (set['reps'] as int);
                                                }
                                              }
                                              updatePreviousTotal(total);
                                            }
                                            if (oldExercise['date']
                                                .toDate()
                                                .isBefore(exercise['date']
                                                    .toDate())) {
                                              return SingleWorkout(
                                                exercise: oldExercise,
                                                pastExercise: true,
                                                type: widget.type,
                                              );
                                            }
                                            return const SizedBox(
                                              height: 0,
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
