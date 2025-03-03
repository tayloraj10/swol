import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EntryBox extends StatefulWidget {
  final Function deleteRep;
  final Function updateValue;
  final QueryDocumentSnapshot<Object?> exercise;
  final int index;
  final bool lastWorkout;
  final TextEditingController controller;
  final String type;
  final String label;
  const EntryBox(
      {super.key,
      required this.deleteRep,
      required this.index,
      required this.lastWorkout,
      required this.updateValue,
      required this.exercise,
      required this.controller,
      required this.type,
      required this.label});

  @override
  State<EntryBox> createState() => _EntryBoxState();
}

class _EntryBoxState extends State<EntryBox> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        width: widget.type == 'weights' ? 70 : 60,
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
                          index: widget.index,
                        )
                      }),
                  child: const Icon(
                    Icons.close,
                    size: 20,
                  ),
                ),
                child: TextField(
                  autofocus: widget.lastWorkout &&
                      widget.index == widget.exercise['sets'].length - 1,
                  onChanged: (String newvalue) async => {
                    await widget.updateValue(
                      id: widget.exercise.id,
                      index: widget.index,
                      newValue: newvalue,
                      type: widget.label,
                    ),
                  },
                  controller: widget.controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  maxLength: 4,
                  cursorColor: Colors.black,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    floatingLabelAlignment: FloatingLabelAlignment.start,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    floatingLabelStyle: const TextStyle(color: Colors.white),
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(),
                    focusColor: Colors.white,
                    focusedErrorBorder: const OutlineInputBorder(),
                    enabledBorder: const OutlineInputBorder(),
                    labelText: widget.type == 'weights'
                        ? widget.label
                        : 'Set ${widget.index + 1}',
                    counterText: '',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
