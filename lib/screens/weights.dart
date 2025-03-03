import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swole/components/current_workouts.dart';
import 'package:swole/components/nav_bar.dart';
import 'package:swole/components/new_workout_button.dart';
import 'package:swole/constants.dart';

class WeightsHome extends StatefulWidget {
  const WeightsHome({super.key});

  @override
  State<WeightsHome> createState() => _WeightsHomeState();
}

class _WeightsHomeState extends State<WeightsHome> {
  DateTime selectedDate = DateTime.now();
  bool showPastExercises = false;

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavBar(
        color: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                children: [
                  NewWorkoutButton(
                    date: selectedDate,
                    type: 'weights',
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Previous Day',
                        padding: EdgeInsets.zero,
                        onPressed: () => {
                          setState(() {
                            selectedDate =
                                selectedDate.subtract(const Duration(days: 1));
                          })
                        },
                        icon: const Icon(Icons.arrow_back_ios),
                      ),
                      ElevatedButton(
                          onPressed: () => {selectDate(context)},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: Text(
                            DateFormat('yyyy-MM-dd').format(selectedDate),
                            style: mediumTextStyle,
                          )),
                      IconButton(
                        tooltip: 'Next Day',
                        padding: EdgeInsets.zero,
                        onPressed: () => {
                          setState(() {
                            selectedDate =
                                selectedDate.add(const Duration(days: 1));
                          })
                        },
                        icon: const Icon(Icons.arrow_forward_ios),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Show Past 3 Exercises',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Switch(
                        activeColor: Colors.blue,
                        value: showPastExercises,
                        onChanged: (value) {
                          setState(() {
                            showPastExercises = value;
                          });
                        },
                      ),
                    ],
                  )
                ],
              ),
              CurrentWorkouts(
                date: selectedDate,
                showPastExercises: showPastExercises,
                type: 'weights',
              )
            ],
          ),
        ),
      ),
    );
  }
}
