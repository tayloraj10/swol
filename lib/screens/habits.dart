import 'package:flutter/material.dart';
import 'package:swole/components/date_changer.dart';
import 'package:swole/components/habit_tracking.dart';
import 'package:swole/components/nav_bar.dart';
import 'package:swole/components/todo_list.dart';
import 'package:swole/components/weekly_stats.dart';
import 'package:swole/constants.dart';

class Habits extends StatefulWidget {
  const Habits({super.key});

  @override
  State<Habits> createState() => _HabitsState();
}

enum HabitsPages {
  habits,
  todo,
  stats,
}

class _HabitsState extends State<Habits> {
  DateTime? selectedDate = DateTime.now();

  HabitsPages selectedPage = HabitsPages.habits;
  Map pageText = {
    HabitsPages.habits: 'Habits',
    HabitsPages.todo: 'To Do',
    HabitsPages.stats: 'Stats'
  };

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const NavBar(
          color: Colors.lightGreen,
        ),
        body: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              if (isMobile(context))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () => {
                                setState(() {
                                  selectedPage =
                                      selectedPage != HabitsPages.todo
                                          ? HabitsPages.todo
                                          : HabitsPages.habits;
                                })
                              },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightGreen),
                          child: Text(
                            selectedPage != HabitsPages.todo
                                ? pageText[HabitsPages.todo]
                                : pageText[HabitsPages.habits],
                            style: mediumTextStyle,
                          )),
                      const SizedBox(
                        width: 20,
                      ),
                      ElevatedButton(
                          onPressed: () => {
                                setState(() {
                                  selectedPage =
                                      selectedPage != HabitsPages.stats
                                          ? HabitsPages.stats
                                          : HabitsPages.habits;
                                })
                              },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightGreen),
                          child: Text(
                            selectedPage != HabitsPages.stats
                                ? pageText[HabitsPages.stats]
                                : pageText[HabitsPages.habits],
                            style: mediumTextStyle,
                          ))
                    ],
                  ),
                ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isMobile(context) ||
                        (isMobile(context) && selectedPage == HabitsPages.todo))
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
                    if (!isMobile(context) ||
                        (isMobile(context) &&
                            selectedPage == HabitsPages.habits))
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              runSpacing: 10,
                              children: [
                                const Text(
                                  'What did you do today?',
                                  style: largeTextStyle,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                DateChanger(
                                  initialDate: selectedDate!,
                                  onDateChanged: (newDate) {
                                    setState(() {
                                      selectedDate = newDate;
                                    });
                                  },
                                )
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
                    if (!isMobile(context) ||
                        (isMobile(context) &&
                            selectedPage == HabitsPages.stats))
                      Expanded(
                        child: Column(
                          children: const [
                            Text(
                              "Stats",
                              style: largeTextStyle,
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            Flexible(
                              child: WeeklyStats(),
                            )
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
