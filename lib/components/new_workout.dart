import 'package:flutter/material.dart';
import 'package:swole/constants.dart';

class NewWorkout extends StatefulWidget {
  const NewWorkout({super.key});

  @override
  State<NewWorkout> createState() => _NewWorkoutState();
}

class _NewWorkoutState extends State<NewWorkout> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
            onPressed: () => {},
            child: const Text(
              'New Exercise',
              style: smallTextStyle,
            ))
      ],
    );
  }
}
