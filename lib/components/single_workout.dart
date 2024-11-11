import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:swole/constants.dart';
import 'package:swole/models/models.dart';

class SingleWorkout extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> exercise;
  final bool lastWorkout;
  final bool pastExercise;

  const SingleWorkout(
      {super.key,
      required this.exercise,
      this.pastExercise = false,
      this.lastWorkout = false});

  @override
  State<SingleWorkout> createState() => _SingleWorkoutState();
}

class _SingleWorkoutState extends State<SingleWorkout> {
  addSet(String id) async {
    var ref =
        FirebaseFirestore.instance.collection("workouts_calisthenics").doc(id);

    DocumentSnapshot docSnapshot = await ref.get();
    List sets = List.from(docSnapshot.get('sets'));
    sets.add(Rep(reps: 0).toMap());

    await ref.update({'sets': sets});
  }

  updateRep({
    required String id,
    required int index,
    required String newValue,
  }) async {
    if (newValue != '') {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('workouts_calisthenics')
          .doc(id)
          .get();

      List sets = List.from(docSnapshot.get('sets'));
      sets[index] = Rep(reps: int.tryParse(newValue)!).toMap();

      await FirebaseFirestore.instance
          .collection('workouts_calisthenics')
          .doc(id)
          .update({'sets': sets});
    }
  }

  deleteRep({
    required String id,
    required int index,
  }) async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('workouts_calisthenics')
        .doc(id)
        .get();

    List sets = List.from(docSnapshot.get('sets'));
    sets.removeAt(index);

    await FirebaseFirestore.instance
        .collection('workouts_calisthenics')
        .doc(id)
        .update({'sets': sets});
  }

  deleteExercise(String id) {
    FirebaseFirestore.instance
        .collection('workouts_calisthenics')
        .doc(id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      margin: EdgeInsets.zero,
      color: widget.pastExercise ? Colors.grey.shade700 : Colors.grey.shade800,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
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
                        .format((widget.exercise['date'] as Timestamp).toDate())
                        .toString(),
                    style: smallTextStyle,
                    textAlign: TextAlign.end,
                  ),
                if (!widget.pastExercise)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => {deleteExercise(widget.exercise.id)},
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
              child: Wrap(
                  direction: Axis.horizontal,
                  spacing: 10,
                  runSpacing: 10,
                  children: widget.exercise['sets']
                      .asMap()
                      .entries
                      .map<Widget>((entry) {
                    int index = entry.key;
                    var set = entry.value;
                    TextEditingController repController =
                        TextEditingController();
                    repController.text =
                        set['reps'] == 0 ? "" : set['reps'].toString();
                    repController.selection = TextSelection.collapsed(
                        offset: repController.text.length);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: SizedBox(
                        width: 60,
                        child: Stack(
                          children: [
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Badge(
                                position: BadgePosition.bottomEnd(),
                                badgeContent: GestureDetector(
                                  onTap: (() async => {
                                        await deleteRep(
                                          id: widget.exercise.id,
                                          index: index,
                                        ),
                                      }),
                                  child: const Icon(
                                    Icons.close,
                                    size: 20,
                                  ),
                                ),
                                child: TextField(
                                  autofocus: widget.lastWorkout &&
                                      index ==
                                          widget.exercise['sets'].length - 1,
                                  onChanged: (String newvalue) async => {
                                    await updateRep(
                                      id: widget.exercise.id,
                                      index: index,
                                      newValue: newvalue,
                                    ),
                                  },
                                  controller: repController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  maxLength: 4,
                                  cursorColor: Colors.black,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    floatingLabelAlignment:
                                        FloatingLabelAlignment.start,
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    floatingLabelStyle:
                                        const TextStyle(color: Colors.white),
                                    border: const OutlineInputBorder(),
                                    focusedBorder: const OutlineInputBorder(),
                                    focusColor: Colors.white,
                                    focusedErrorBorder:
                                        const OutlineInputBorder(),
                                    enabledBorder: const OutlineInputBorder(),
                                    labelText: 'Set ${index + 1}',
                                    counterText: '',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => {addSet(widget.exercise.id)},
          ),
        ],
      ),
    );
  }
}
