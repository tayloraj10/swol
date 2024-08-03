class Workout {
  final String category;
  final String exerciseId;
  final String exerciseName;
  final DateTime date;
  final List<Rep> sets;

  Workout(
      {required this.category,
      required this.exerciseId,
      required this.exerciseName,
      required this.date,
      required this.sets});
}

class Rep {
  final int reps;
  final double weight;

  Map<String, dynamic> toMap() {
    return {
      'reps': reps,
      'weight': weight,
    };
  }

  Rep({required this.reps, this.weight = 0});
}
