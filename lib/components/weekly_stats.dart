import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swole/constants.dart';

class WeeklyStats extends StatefulWidget {
  const WeeklyStats({super.key});

  @override
  State<WeeklyStats> createState() => _WeeklyStatsState();
}

class _WeeklyStatsState extends State<WeeklyStats> {
  @override
  void initState() {
    super.initState();
  }

  getPastWeeksCutoffDate(int numWeeks) {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    startOfWeek = startOfWeek.subtract(Duration(days: 7 * numWeeks));
    return startOfWeek;
  }

  Map<String, dynamic> calculateWeeklyStats(
      List<QueryDocumentSnapshot<Object?>> data) {
    Map<String, dynamic> stats = {};
    for (var doc in data) {
      var data = doc.data() as Map<String, dynamic>;
      // print(data);
      DateTime date = (data['date'] as Timestamp).toDate();
      String weekOfYear = ((date.difference(DateTime(date.year, 1, 1)).inDays +
                  DateTime(date.year, 1, 1).weekday) /
              7)
          .ceil()
          .toString();
      String yearWeek = '${date.year % 100}-$weekOfYear';

      if (stats.containsKey(yearWeek)) {
        data['tasks'].keys.forEach((task) {
          if (stats[yearWeek].containsKey(task)) {
            stats[yearWeek][task] += 1;
          } else {
            stats[yearWeek][task] = 1;
          }
        });
      } else {
        stats[yearWeek] = {};

        data['tasks'].keys.forEach((task) {
          stats[yearWeek][task] = 1;
        });
      }
    }
    return stats;
  }

  List<String> getUniqueCategories(Map<String, dynamic> weeklyStats) {
    List<String> uniqueCategories = [];
    weeklyStats.forEach((week, tasks) {
      tasks.keys.forEach((task) {
        if (!uniqueCategories.contains(task)) {
          uniqueCategories.add(task);
        }
      });
    });
    return uniqueCategories;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('habit_tracking')
          .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where('date', isGreaterThanOrEqualTo: getPastWeeksCutoffDate(5))
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading data'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        Map<String, dynamic> weeklyStats =
            calculateWeeklyStats(snapshot.data!.docs);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              const DataColumn(
                label: Text(
                  'Category',
                  style: smallTextStyle,
                ),
              ),
              ...weeklyStats.keys.map((week) => DataColumn(
                    label: Text(
                      week,
                      style: smallTextStyle,
                    ),
                  )),
            ],
            rows: getUniqueCategories(weeklyStats).map((category) {
              return DataRow(cells: [
                DataCell(Text(
                  category,
                  style: smallTextStyle,
                )),
                ...weeklyStats.keys.map((week) {
                  return DataCell(
                      Text(weeklyStats[week][category]?.toString() ?? '0'));
                }).toList(),
              ]);
            }).toList(),
          ),
        );
      },
    );
  }
}
