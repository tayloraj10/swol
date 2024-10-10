import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:swole/components/new_exercise_dialog.dart';
import 'package:swole/constants.dart';

class NewWorkoutButton extends StatefulWidget {
  const NewWorkoutButton({super.key});

  @override
  State<NewWorkoutButton> createState() => _NewWorkoutButtonState();
}

class _NewWorkoutButtonState extends State<NewWorkoutButton> {
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
            onPressed: () => {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const NewExerciseDialog();
                    },
                  ),
                },
            child: const Text(
              'New Exercise',
              style: mediumTextStyle,
            ))
      ],
    );
  }
}
