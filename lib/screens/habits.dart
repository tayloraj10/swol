import 'package:flutter/material.dart';
import 'package:swole/components/habit_tracking.dart';
import 'package:swole/components/nav_bar.dart';
import 'package:swole/constants.dart';

class Habits extends StatefulWidget {
  const Habits({super.key});

  @override
  State<Habits> createState() => _HabitsState();
}

class _HabitsState extends State<Habits> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const NavBar(
          color: Colors.lightGreen,
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              SizedBox(
                height: 10,
              ),
              Text(
                'What did you do today?',
                style: largeTextStyle,
              ),
              SizedBox(
                height: 40,
              ),
              HabitTracking()
            ],
          ),
        ));
  }
}
