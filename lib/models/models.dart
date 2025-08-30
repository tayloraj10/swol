class Workout {
  final String category;
  final String exerciseId;
  final String exerciseName;
  final DateTime date;
  final List<Set> sets;

  Workout(
      {required this.category,
      required this.exerciseId,
      required this.exerciseName,
      required this.date,
      required this.sets});
}

class Set {
  final int reps;
  final double weight;

  Map<String, dynamic> toMap() {
    return {
      'reps': reps,
      'weight': weight,
    };
  }

  Set({required this.reps, required this.weight});
}

enum DateChangeType {
  up,
  down,
}
