import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swole/constants.dart';
import 'package:swole/models/models.dart';
import 'package:badges/badges.dart';

class CurrentWorkouts extends StatefulWidget {
  const CurrentWorkouts({super.key});

  @override
  State<CurrentWorkouts> createState() => _CurrentWorkoutsState();
}

class _CurrentWorkoutsState extends State<CurrentWorkouts> {
  addset(String id) {
    var ref =
        FirebaseFirestore.instance.collection("workouts_calisthenics").doc(id);

    ref.update({
      'sets': FieldValue.arrayUnion([Rep(reps: 0).toMap()])
    });
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      key: UniqueKey(),
      stream: FirebaseFirestore.instance
          .collection('workouts_calisthenics')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No Data Available'));
        } else {
          final data = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true,
            itemCount: data.docs.length,
            itemBuilder: (context, index) {
              final exercise = data.docs[index];
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.blue,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            exercise['exercise_name'],
                            style: mediumTextStyle,
                            textAlign: TextAlign.end,
                          ),
                          Text(
                            exercise['category'],
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
                          children: exercise['sets']
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
                                                  id: exercise.id,
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
                                          onChanged: (String newvalue) async =>
                                              {
                                            await updateRep(
                                              id: exercise.id,
                                              index: index,
                                              newValue: newvalue,
                                            ),
                                          },
                                          controller: repController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
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
                                            floatingLabelStyle: const TextStyle(
                                                color: Colors.white),
                                            border: const OutlineInputBorder(),
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
                      onPressed: () => {addset(exercise.id)},
                    ))
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}
