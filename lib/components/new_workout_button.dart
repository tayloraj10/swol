import 'package:flutter/material.dart';
import 'package:swole/components/new_exercise_dialog.dart';
import 'package:swole/constants.dart';

class NewWorkoutButton extends StatefulWidget {
  final DateTime date;
  const NewWorkoutButton(this.date, {super.key});

  @override
  State<NewWorkoutButton> createState() => _NewWorkoutButtonState();
}

class _NewWorkoutButtonState extends State<NewWorkoutButton> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
            onPressed: () => {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return NewExerciseDialog(widget.date);
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
