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
          .collection(getCollectionName(widget.type))
          .doc(id)
          .get();

      List sets = List.from(docSnapshot.get('sets'));
      sets[index] = Rep(reps: int.tryParse(newValue)!).toMap();

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

  calculateTotal() {
    int totalReps = 0;
    for (var set in widget.exercise['sets']) {
      totalReps += (set['reps'] as int);
    }
    return totalReps;
  }

  caculateTrend() {
    if (widget.previousTotal != 0 && calculateTotal() != 0) {
      num difference = calculateTotal() - widget.previousTotal;
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

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
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
                              repController.text = set['reps'] == 0
                                  ? ""
                                  : set['reps'].toString();
                              repController.selection = TextSelection.collapsed(
                                  offset: repController.text.length);
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
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
                                                    widget.exercise['sets']
                                                            .length -
                                                        1,
                                            onChanged:
                                                (String newvalue) async => {
                                              await updateRep(
                                                id: widget.exercise.id,
                                                index: index,
                                                newValue: newvalue,
                                              ),
                                            },
                                            controller: repController,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <
                                                TextInputFormatter>[
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
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
                                                  const TextStyle(
                                                      color: Colors.white),
                                              border:
                                                  const OutlineInputBorder(),
                                              focusedBorder:
                                                  const OutlineInputBorder(),
                                              focusColor: Colors.white,
                                              focusedErrorBorder:
                                                  const OutlineInputBorder(),
                                              enabledBorder:
                                                  const OutlineInputBorder(),
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
                            }).toList() +
                            [
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => {addSet(widget.exercise.id)},
                              ),
                            ]),
                    if (calculateTotal() > 0)
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text('Total: ${calculateTotal()}',
                                style: mediumTextStyle),
                          ),
                          if (caculateTrend() != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 20, left: 10),
                              child: Icon(
                                caculateTrend() == 1
                                    ? Icons.trending_up
                                    : caculateTrend() == -1
                                        ? Icons.trending_down
                                        : Icons.trending_flat,
                                color: caculateTrend() == 1
                                    ? Colors.green
                                    : caculateTrend() == -1
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
