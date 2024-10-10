import 'package:flutter/material.dart';

class NewExerciseDialog extends StatefulWidget {
  const NewExerciseDialog({super.key});

  @override
  State<NewExerciseDialog> createState() => _NewExerciseDialogState();
}

class _NewExerciseDialogState extends State<NewExerciseDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Exercise'),
      content: const Text('Exercise details go here.'),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Create'),
          onPressed: () {
            // createNewWorkout();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
