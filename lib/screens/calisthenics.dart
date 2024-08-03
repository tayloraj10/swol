import 'package:flutter/material.dart';
import 'package:swole/components/current_workouts.dart';
import 'package:swole/components/nav_bar.dart';
import 'package:swole/components/new_workout.dart';

class CalisthenicsHome extends StatefulWidget {
  const CalisthenicsHome({super.key});

  @override
  State<CalisthenicsHome> createState() => _CalisthenicsHomeState();
}

class _CalisthenicsHomeState extends State<CalisthenicsHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const NavBar(),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              SizedBox(
                height: 10,
              ),
              NewWorkout(),
              SizedBox(
                height: 20,
              ),
              CurrentWorkouts()
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
