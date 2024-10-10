import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swole/components/current_workouts.dart';
import 'package:swole/components/nav_bar.dart';
import 'package:swole/components/new_workout_button.dart';
import 'package:swole/constants.dart';

class CalisthenicsHome extends StatefulWidget {
  const CalisthenicsHome({super.key});

  @override
  State<CalisthenicsHome> createState() => _CalisthenicsHomeState();
}

class _CalisthenicsHomeState extends State<CalisthenicsHome> {
  DateTime selectedDate = DateTime.now();

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
          color: Colors.blue,
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const NewWorkoutButton(),
                  const SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                      onPressed: () => {selectDate(context)},
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      child: Text(
                        DateFormat('yyyy-MM-dd').format(selectedDate),
                        style: mediumTextStyle,
                      ))
                ],
              ),
              CurrentWorkouts(
                date: selectedDate,
              )
            ],
          ),
        )
        // StreamBuilder<QuerySnapshot>(
        //   key: UniqueKey(),
        //   stream: FirebaseFirestore.instance
        //       .collection('exercises_calisthenics')
        //       .snapshots(),
        //   builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        //     if (snapshot.connectionState == ConnectionState.waiting) {
        //       return const Center(child: CircularProgressIndicator());
        //     } else if (snapshot.hasError) {
        //       return Center(child: Text('Error: ${snapshot.error}'));
        //     } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        //       return const Center(child: Text('No Data Available'));
        //     } else {
        //       final data = snapshot.data!;
        //       return ListView.builder(
        //         itemCount: data.docs.length,
        //         itemBuilder: (context, index) {
        //           final user = data.docs[index];
        //           return ListTile(
        //             title: Text(user['name']),
        //             // subtitle: Text('Age: ${user['age']}'),
        //           );
        //         },
        //       );
        //     }
        //   },
        // ),
        );
  }
}
