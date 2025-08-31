import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExerciseQueue extends StatefulWidget {
  final String type;

  const ExerciseQueue({super.key, required this.type});

  @override
  State<ExerciseQueue> createState() => _ExerciseQueueState();
}

class _ExerciseQueueState extends State<ExerciseQueue> {
  getCollectionName(String type) {
    if (type == 'weights') {
      return 'workouts_weights';
    } else if (type == 'calisthenics') {
      return 'workouts_calisthenics';
    } else {
      return '';
    }
  }

  deleteExercise(String id) {
    FirebaseFirestore.instance
        .collection(getCollectionName(widget.type))
        .doc(id)
        .delete();
  }

  addExerciseToWorkout(String id) {
    FirebaseFirestore.instance
        .collection(getCollectionName(widget.type))
        .doc(id)
        .update({'queue': false, 'date': DateTime.now()});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.grey.shade900,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection(getCollectionName(widget.type))
                .where('queue', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              int count = 0;
              if (snapshot.hasData) {
                count = snapshot.data!.docs.length;
              }
              return Center(
                child: Text(
                  'Workout Queue ($count)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(getCollectionName(widget.type))
                .where('queue', isEqualTo: true)
                .orderBy('date', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Error loading queued workouts');
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text('No queued workouts');
              }
              var queuedWorkouts = snapshot.data!.docs;
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade800),
                  color:
                      widget.type == 'calisthenics' ? Colors.blue : Colors.red,
                ),
                child: ListView.builder(
                  itemCount: queuedWorkouts.length,
                  itemBuilder: (context, index) {
                    var workout = queuedWorkouts[index].data();
                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Tooltip(
                                  message: 'Add to workout',
                                  child: IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      addExerciseToWorkout(
                                          queuedWorkouts[index].id);
                                    },
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  workout['exercise_name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Tooltip(
                                  message: 'Remove from queue',
                                  child: IconButton(
                                    icon: const Icon(Icons.remove_circle),
                                    onPressed: () {
                                      deleteExercise(queuedWorkouts[index].id);
                                    },
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (index < queuedWorkouts.length - 1)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Divider(
                              thickness: 1,
                              color: Colors.black,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
