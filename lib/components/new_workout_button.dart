import 'package:flutter/material.dart';
import 'package:swole/components/new_exercise_dialog.dart';
import 'package:swole/constants.dart';

class NewWorkoutButton extends StatefulWidget {
  final DateTime date;
  final String type;
  const NewWorkoutButton({super.key, required this.type, required this.date});

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
                      return NewExerciseDialog(
                        date: widget.date,
                        type: widget.type,
                      );
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
