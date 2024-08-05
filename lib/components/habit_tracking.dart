import 'package:flutter/material.dart';
import 'package:swole/constants.dart';

class HabitTracking extends StatefulWidget {
  const HabitTracking({super.key});

  @override
  State<HabitTracking> createState() => _HabitTrackingState();
}

class _HabitTrackingState extends State<HabitTracking> {
  static const Map<String, Map> categories = {
    'Exercise': {
      'tasks': ['Calisthenics', 'Gym'],
      'goal': 3
    },
    'Language': {
      'tasks': ['Duolingo'],
      'goal': 7
    },
    'Meditation': {
      'tasks': ['Headspace'],
      'goal': 3
    },
    'Stretch': {
      'tasks': ['Bend', 'Headspace'],
      'goal': 3
    },
    'Learning / Projects': {
      'tasks': ['Brilliant', 'React Tutorial', 'Collective', 'Programming'],
      'goal': 3
    },
    'Brain Training': {
      'tasks': ['Elevate', 'Impulse'],
      'goal': 3
    },
    'Creative': {
      'tasks': ['TikTok', 'Movie'],
      'goal': 5
    },
    'Music': {
      'tasks': ['Guitar', 'Piano'],
      'goal': 1
    },
    'Personal Growth': {
      'tasks': ['Podcast', 'Read', 'Journal', 'Jobs'],
      'goal': 2
    },
    'Wellbeing': {
      'tasks': [
        'Loona',
        'Sensa',
        'Cold Shower',
        'Supplements',
        'Hydration (1 gal)'
      ],
      'goal': 2
    },
    'Cardio': {
      'tasks': [
        'Bike',
        'Jump Rope',
        'Run',
        'Tennis',
        'Kettlebell Ladder',
        'Hike',
        'Swim',
        'Long Walk'
      ],
      'goal': 1
    }
  };

  Map<String, String?> selectedValues = {};

  @override
  void initState() {
    super.initState();
    // Initialize the selected values with the first item of each category
    categories.forEach((category, tasks) {
      selectedValues[category] = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: SingleChildScrollView(
        child: Center(
          child: Table(
            border: const TableBorder(
                horizontalInside: BorderSide(color: Colors.lightGreenAccent)),
            defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
            textBaseline: TextBaseline.ideographic,
            defaultColumnWidth: const IntrinsicColumnWidth(),
            children: [
              const TableRow(children: [
                Text(
                  'Category',
                  style: largeTextStyle,
                ),
                SizedBox(
                  width: 20,
                  height: 40,
                ),
                Text(
                  'Task',
                  style: largeTextStyle,
                ),
                SizedBox(
                  width: 20,
                  height: 40,
                ),
                Text(
                  'Goal',
                  style: largeTextStyle,
                ),
                SizedBox(
                  width: 20,
                  height: 40,
                ),
                Text(
                  'Remaining',
                  style: largeTextStyle,
                )
              ]),
              ...categories.keys.map((category) {
                return TableRow(
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: DropdownButton<String>(
                            // hint: const Text('Select Task'),
                            value: selectedValues[category],
                            onChanged: (newValue) {
                              setState(() {
                                selectedValues[category] = newValue;
                              });
                            },
                            items: ([""] + categories[category]!['tasks'])
                                .map((task) {
                              return DropdownMenuItem<String>(
                                value: task,
                                child: Text(task),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "${categories[category]!['goal']}",
                          style: mediumTextStyle,
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "${categories[category]!['goal']}",
                          style: mediumTextStyle,
                        ),
                      ],
                    ),
                    // const Divider(),
                  ],
                );
              }).toList()
            ],
          ),
        ),
      ),
    );
  }
}
