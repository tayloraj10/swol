import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swole/components/entry_box.dart';
import 'package:swole/constants.dart';
import 'package:swole/models/models.dart';

class SingleWorkout extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> exercise;
  final bool lastWorkout;
  final bool pastExercise;
  final num previousTotal;
  final String type;

  const SingleWorkout(
      {super.key,
      required this.exercise,
      required this.type,
      this.pastExercise = false,
      this.lastWorkout = false,
      this.previousTotal = 0});

  @override
  State<SingleWorkout> createState() => _SingleWorkoutState();
}

class _SingleWorkoutState extends State<SingleWorkout> {
  List focusExercises = [];

  @override
  void initState() {
    super.initState();
    fetchFocusExercises();
  }

  getCollectionName(String type) {
    if (type == 'weights') {
      return 'workouts_weights';
    } else if (type == 'calisthenics') {
      return 'workouts_calisthenics';
    } else {
      return '';
    }
  }

  addSet(String id) async {
    var ref = FirebaseFirestore.instance
        .collection(getCollectionName(widget.type))
        .doc(id);

    DocumentSnapshot docSnapshot = await ref.get();
    List sets = List.from(docSnapshot.get('sets'));
    sets.add(Set(reps: 0, weight: 0).toMap());

    await ref.update({'sets': sets});
  }

  updateRepOrWeight({
    required String id,
    required int index,
    required String newValue,
    required String type,
  }) async {
    if (newValue != '') {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection(getCollectionName(widget.type))
          .doc(id)
          .get();

      List sets = List.from(docSnapshot.get('sets'));
      if (type == 'Reps') {
        sets[index]['reps'] = int.tryParse(newValue)!;
      } else if (type == 'Weight') {
        sets[index]['weight'] = int.tryParse(newValue)!;
      }

      await FirebaseFirestore.instance
          .collection(getCollectionName(widget.type))
          .doc(id)
          .update({'sets': sets});
    }
  }

  updateNotes({required String id, required String newNote}) async {
    await FirebaseFirestore.instance
        .collection(getCollectionName(widget.type))
        .doc(id)
        .update({'notes': newNote});
  }

  deleteRep({
    required String id,
    required int index,
  }) async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection(getCollectionName(widget.type))
        .doc(id)
        .get();

    List sets = List.from(docSnapshot.get('sets'));
    sets.removeAt(index);

    await FirebaseFirestore.instance
        .collection(getCollectionName(widget.type))
        .doc(id)
        .update({'sets': sets});
  }

  deleteExercise(String id) {
    FirebaseFirestore.instance
        .collection(getCollectionName(widget.type))
        .doc(id)
        .delete();
  }

  calculateTotal(String type) {
    if (type == 'weights') {
      int totalVolume = 0;
      for (var set in widget.exercise['sets']) {
        totalVolume += (set['weight'] as int) * (set['reps'] as int);
      }
      return totalVolume;
    } else if (type == 'calisthenics') {
      int totalReps = 0;
      for (var set in widget.exercise['sets']) {
        totalReps += (set['reps'] as int);
      }
      return totalReps;
    }
  }

  caculateTrend(String type) {
    if (widget.previousTotal != 0 && calculateTotal(type) != 0) {
      num difference = calculateTotal(type) - widget.previousTotal;
      if (difference > 0) {
        return 1;
      } else if (difference < 0) {
        return -1;
      } else {
        return 0;
      }
    }
    return null;
  }

  calculateTotalName(String type) {
    if (type == 'weights') {
      return 'Total Volume';
    } else if (type == 'calisthenics') {
      return 'Total Reps';
    }
  }

  fetchFocusExercises() async {
    var docSnapshot = await FirebaseFirestore.instance
        .collection('focus_exercises')
        .doc(getUser()!.uid)
        .get();

    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      setState(() {
        focusExercises = data?['exercises'] ?? [];
      });
    } else {
      setState(() {
        focusExercises = [];
      });
    }
  }

  handleFavorite(String id) async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('focus_exercises')
        .doc(getUser()!.uid)
        .get();
    Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;
    if (data != null) {
      if (data['exercises'] != null && data['exercises'].contains(id)) {
        data['exercises'].remove(id);
      } else {
        data['exercises'] = (data['exercises'] ?? [])..add(id);
      }
    } else {
      data = {
        'exercises': [id]
      };
    }

    await FirebaseFirestore.instance
        .collection('focus_exercises')
        .doc(getUser()!.uid)
        .set(data);

    fetchFocusExercises();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(
          color: focusExercises.contains(widget.exercise['exercise_id'])
              ? Colors.yellow
              : Colors.transparent,
          width: 3,
        ),
      ),
      margin: EdgeInsets.zero,
      color: widget.pastExercise ? Colors.grey.shade700 : Colors.grey.shade800,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: isMobile(context) ? 100 : 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!widget.pastExercise)
                    Text(
                      widget.exercise['exercise_name'],
                      style: mediumTextStyle,
                      textAlign: TextAlign.end,
                    ),
                  if (!widget.pastExercise)
                    Text(
                      widget.exercise['category'],
                      style: smallTextStyle,
                      textAlign: TextAlign.end,
                    ),
                  if (widget.pastExercise)
                    Text(
                      DateFormat('MM/dd/yy')
                          .format(
                              (widget.exercise['date'] as Timestamp).toDate())
                          .toString(),
                      style: smallTextStyle,
                      textAlign: TextAlign.end,
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!widget.pastExercise)
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => {deleteExercise(widget.exercise.id)},
                        ),
                      if (!widget.pastExercise)
                        IconButton(
                          icon: Icon(
                            focusExercises
                                    .contains(widget.exercise['exercise_id'])
                                ? Icons.favorite
                                : Icons.favorite_border_outlined,
                          ),
                          onPressed: () =>
                              {handleFavorite(widget.exercise['exercise_id'])},
                        ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 100,
              child: VerticalDivider(
                width: 20,
                thickness: 3,
                color: Colors.black,
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                        direction: Axis.horizontal,
                        spacing: widget.type == 'weights' ? 25 : 10,
                        runSpacing: 10,
                        children: widget.exercise['sets']
                                .asMap()
                                .entries
                                .map<Widget>((entry) {
                              int index = entry.key;
                              var set = entry.value;
                              TextEditingController repController =
                                  TextEditingController();
                              TextEditingController weightController =
                                  TextEditingController();
                              repController.text = set['reps'] == 0
                                  ? ""
                                  : set['reps'].toString();
                              repController.selection = TextSelection.collapsed(
                                  offset: repController.text.length);
                              weightController.text = set['weight'] == 0
                                  ? ""
                                  : set['weight'].toString();
                              weightController.selection =
                                  TextSelection.collapsed(
                                      offset: weightController.text.length);
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (widget.type == 'weights') ...[
                                    EntryBox(
                                      deleteRep: deleteRep,
                                      updateValue: updateRepOrWeight,
                                      index: index,
                                      exercise: widget.exercise,
                                      lastWorkout: widget.lastWorkout,
                                      controller: weightController,
                                      type: widget.type,
                                      label: 'Weight',
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  EntryBox(
                                    deleteRep: deleteRep,
                                    updateValue: updateRepOrWeight,
                                    index: index,
                                    exercise: widget.exercise,
                                    lastWorkout: widget.lastWorkout,
                                    controller: repController,
                                    type: widget.type,
                                    label: 'Reps',
                                  ),
                                ],
                              );
                            }).toList() +
                            [
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => {addSet(widget.exercise.id)},
                              ),
                            ]),
                    if (calculateTotal(widget.type) > 0)
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text(
                                '${calculateTotalName(widget.type)}: ${calculateTotal(widget.type)}',
                                style: mediumTextStyle),
                          ),
                          if (caculateTrend(widget.type) != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 20, left: 10),
                              child: Icon(
                                caculateTrend(widget.type) == 1
                                    ? Icons.trending_up
                                    : caculateTrend(widget.type) == -1
                                        ? Icons.trending_down
                                        : Icons.trending_flat,
                                color: caculateTrend(widget.type) == 1
                                    ? Colors.green
                                    : caculateTrend(widget.type) == -1
                                        ? Colors.red
                                        : Colors.blue,
                              ),
                            ),
                        ],
                      ),
                    if ((widget.exercise.data() as Map<String, dynamic>)
                        .containsKey('notes'))
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: TextField(
                          controller: TextEditingController(
                              text: widget.exercise['notes'])
                            ..selection = TextSelection.collapsed(
                                offset: widget.exercise['notes'].length),
                          onChanged: (String newValue) async => {
                            await updateNotes(
                              id: widget.exercise.id,
                              newNote: newValue,
                            ),
                          },
                          maxLines: 1,
                          decoration: const InputDecoration(
                            labelText: 'Notes',
                            border: OutlineInputBorder(),
                          ),
                          style: mediumTextStyle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
