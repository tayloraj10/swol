import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:swole/constants.dart';

class SingleWorkout extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> exercise;
  final Function deleteRep;
  final Function updateRep;
  final Function addSet;
  final bool pastExercise;

  const SingleWorkout(
      {super.key,
      required this.exercise,
      required this.deleteRep,
      required this.updateRep,
      required this.addSet,
      this.pastExercise = false});

  @override
  State<SingleWorkout> createState() => _SingleWorkoutState();
}

class _SingleWorkoutState extends State<SingleWorkout> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.exercise['exercise_name'],
                style: mediumTextStyle,
                textAlign: TextAlign.end,
              ),
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
              spacing: 10,
              runSpacing: 10,
              children:
                  widget.exercise['sets'].asMap().entries.map<Widget>((entry) {
                int index = entry.key;
                var set = entry.value;
                TextEditingController repController = TextEditingController();
                repController.text =
                    set['reps'] == 0 ? "" : set['reps'].toString();
                repController.selection =
                    TextSelection.collapsed(offset: repController.text.length);
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
                                    await widget.deleteRep(
                                      id: widget.exercise.id,
                                      index: index,
                                    ),
                                  }),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                              ),
                            ),
                            child: TextField(
                              autofocus: true,
                              onChanged: (String newvalue) async => {
                                await widget.updateRep(
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
                                focusedErrorBorder: const OutlineInputBorder(),
                                enabledBorder: const OutlineInputBorder(),
                                labelText: 'Set ${index + 1}',
                                counterText: '',
                              ),
                            ),
                          ),
                        ),
                        // Positioned(
                        //   top: 1,
                        //   right: 0,
                        //   child: GestureDetector(
                        //     onTap: (() async => {
                        //           await deleteRep(
                        //             id: exercise.id,
                        //             index: index,
                        //           ),
                        //         }),
                        //     child: const Icon(
                        //       Icons.close,
                        //       size: 16,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Flexible(
            child: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => {widget.addSet(widget.exercise.id)},
        ))
      ],
    );
  }
}
