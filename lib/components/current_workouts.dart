import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      key: UniqueKey(),
      stream: FirebaseFirestore.instance
          .collection('workouts_calisthenics')
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(
                  widget.date.year, widget.date.month, widget.date.day)))
          .where('date',
              isLessThan: Timestamp.fromDate(
                  DateTime(widget.date.year, widget.date.month, widget.date.day)
                      .add(const Duration(days: 1))))
          .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: Text('No Exercises Found')),
          );
        } else {
          final data = snapshot.data!;
          return Scrollbar(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: data.docs.length,
              itemBuilder: (context, index) {
                final exercise = data.docs[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  child: Column(
                    children: [
                      SingleWorkout(
                        exercise: exercise,
                        lastWorkout: index == data.docs.length - 1,
                      ),
                      if (widget.showPastExercises)
                        StreamBuilder<QuerySnapshot>(
                          key: UniqueKey(),
                          stream: FirebaseFirestore.instance
                              .collection('workouts_calisthenics')
                              .where('exercise_id',
                                  isEqualTo: exercise['exercise_id'])
                              .orderBy('date', descending: true)
                              .snapshots(),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            }
                            // else if (!snapshot.hasData ||
                            //     snapshot.data!.docs.length <= 1) {
                            //   return const Text('No Previous Exercises');
                            // }
                            else {
                              final data = snapshot.data!;
                              return Column(
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: data.docs.length - 1,
                                    itemBuilder: (context, index) {
                                      final oldExercise = data.docs[index + 1];
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
              },
            ),
          );
        }
      },
    );
  }
}
