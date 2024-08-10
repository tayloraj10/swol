import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swole/components/habit_tracking.dart';
import 'package:swole/components/nav_bar.dart';
import 'package:swole/components/todo_list.dart';
import 'package:swole/constants.dart';

class Habits extends StatefulWidget {
  const Habits({super.key});

  @override
  State<Habits> createState() => _HabitsState();
}

class _HabitsState extends State<Habits> {
  DateTime? selectedDate = DateTime.now();

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  isMobile() {
    return MediaQuery.of(context).size.width < 1300;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const NavBar(
          color: Colors.lightGreen,
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isMobile())
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        "TODO List",
                        style: largeTextStyle,
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Flexible(
                        child: TodoList(
                          date: selectedDate!,
                        ),
                      )
                    ],
                  ),
                ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      runSpacing: 10,
                      children: [
                        const Text(
                          'What did you do today?',
                          style: largeTextStyle,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                            onPressed: () => {selectDate(context)},
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            child: Text(
                              DateFormat('yyyy-MM-dd').format(selectedDate!),
                              style: mediumTextStyle,
                            ))
                      ],
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Flexible(
                      child: HabitTracking(
                        date: selectedDate!,
                      ),
                    )
                  ],
                ),
              ),
              if (!isMobile())
                Expanded(
                  child: Column(
                    children: const [
                      Text(
                        "Stats",
                        style: largeTextStyle,
                      )
                    ],
                  ),
                ),
            ],
          ),
        ));
  }
}
