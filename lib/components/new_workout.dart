import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:swole/constants.dart';

class NewWorkout extends StatefulWidget {
  const NewWorkout({super.key});

  @override
  State<NewWorkout> createState() => _NewWorkoutState();
}

class _NewWorkoutState extends State<NewWorkout> {
  createNewWorkout() {
    FirebaseFirestore.instance.collection('workouts_calisthenics').add({
      'category': "Horizontal Pull",
      'date': DateTime.now(),
      'exercise_id': 'j3VVfTOCAlQ4xX3xfg6R',
      'exercise_name': "Tuck Skin the Cat",
      'sets': []
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
            onPressed: () => {createNewWorkout()},
            child: const Text(
              'New Exercise',
              style: mediumTextStyle,
            ))
      ],
    );
  }
}
