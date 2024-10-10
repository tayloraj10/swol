import 'package:accordion/accordion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:swole/components/single_workout.dart';
import 'package:swole/constants.dart';
import 'package:swole/models/models.dart';

class CurrentWorkouts extends StatefulWidget {
  final DateTime date;

  const CurrentWorkouts({super.key, required this.date});

  @override
  State<CurrentWorkouts> createState() => _CurrentWorkoutsState();
}

class _CurrentWorkoutsState extends State<CurrentWorkouts> {
  addSet(String id) {
    var ref =
        FirebaseFirestore.instance.collection("workouts_calisthenics").doc(id);

    ref.update({
      'sets': FieldValue.arrayUnion([Rep(reps: 0).toMap()])
    });
  }

  updateRep({
    required String id,
    required int index,
    required String newValue,
  }) async {
    if (newValue != '') {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('workouts_calisthenics')
          .doc(id)
          .get();

      List sets = List.from(docSnapshot.get('sets'));
      sets[index] = Rep(reps: int.tryParse(newValue)!).toMap();

      await FirebaseFirestore.instance
          .collection('workouts_calisthenics')
          .doc(id)
          .update({'sets': sets});
    }
  }

  deleteRep({
    required String id,
    required int index,
  }) async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('workouts_calisthenics')
        .doc(id)
        .get();

    List sets = List.from(docSnapshot.get('sets'));
    sets.removeAt(index);

    await FirebaseFirestore.instance
        .collection('workouts_calisthenics')
        .doc(id)
        .update({'sets': sets});
  }

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
          .limit(4)
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
          return ListView.builder(
            shrinkWrap: true,
            itemCount: data.docs.length,
            itemBuilder: (context, index) {
              final exercise = data.docs[index];
              return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Accordion(
                    children: [
                      AccordionSection(
                        headerBackgroundColor: Colors.blue,
                        contentBackgroundColor: Colors.blue[700],
                        header: Padding(
                          padding: const EdgeInsets.all(11),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SingleWorkout(
                                  exercise: exercise,
                                  updateRep: updateRep,
                                  addSet: addSet,
                                  deleteRep: deleteRep),
                            ],
                          ),
                        ),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                'Past Exercises',
                                style: largeTextStyle,
                              ),
                            ),
                            StreamBuilder<QuerySnapshot>(
                              key: UniqueKey(),
                              stream: FirebaseFirestore.instance
                                  .collection('workouts_calisthenics')
                                  .where('exercise_id',
                                      isEqualTo: exercise['exercise_id'])
                                  .orderBy('date', descending: true)
                                  .snapshots(),
                              builder: (context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.docs.isEmpty) {
                                  return const Center(
                                      child: Text('No Data Available'));
                                } else {
                                  final data = snapshot.data!;
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: data.docs.length - 1,
                                    itemBuilder: (context, index) {
                                      final oldExercise = data.docs[index + 1];
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SingleWorkout(
                                            exercise: oldExercise,
                                            deleteRep: deleteRep,
                                            updateRep: updateRep,
                                            addSet: addSet,
                                            pastExercise: true,
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ));
            },
          );
        }
      },
    );
  }
}
