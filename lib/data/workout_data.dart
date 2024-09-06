import 'package:flutter/material.dart';
import 'package:workout_tracker_app/data/hive_database.dart';
import 'package:workout_tracker_app/datetime/date_time.dart';
import 'package:workout_tracker_app/models/exercise.dart';
import 'package:workout_tracker_app/models/workout.dart';

class WorkoutData extends ChangeNotifier {
  final db = HiveDatabase();

  List<Workout> workoutList = [
    Workout(
      name: 'Upper Body',
      exercises: [
        Exercise(
          name: 'Biceps Curls',
          weight: '10',
          reps: '10',
          sets: '3',
        )
      ],
    ),
    Workout(
      name: 'Lower Body',
      exercises: [
        Exercise(
          name: 'Squats',
          weight: '10',
          reps: '8',
          sets: '3',
        )
      ],
    )
  ];
// if there are workouts already in database, then get that workout list, otherwise use the default workout
  void initializedWorkoutList() {
    if (db.previousDataExists()) {
      workoutList = db.readFromDataBase();
    } else {
      db.saveToDataBase(workoutList);
    }

  // loadt heat map
    loadHeatMap();
  }

//get the list of workouts
  List<Workout> getWorkoutList() {
    return workoutList;
  }

  int numberOfExercisesInWorkout(String workoutName) {
    Workout relevantWorkout = getRelevantWorkout(workoutName);

    return relevantWorkout.exercises.length;
  }

  void addWorkout(String name) {
    workoutList.add(Workout(name: name, exercises: []));

    notifyListeners();

    
    db.saveToDataBase(workoutList);
  }

  void addExercise(String workoutName, String exerciseName, String weight,
      String reps, String sets) {
    Workout relevantWorkout = getRelevantWorkout(workoutName);

    relevantWorkout.exercises.add(
      Exercise(name: exerciseName, weight: weight, reps: reps, sets: sets),
    );

    notifyListeners();

    db.saveToDataBase(workoutList);
  }

  void checkOffExercise(String workoutName, String exerciseName) {
    Exercise relevantExercise = getRelevantExercise(workoutName, exerciseName);

    relevantExercise.isCompleted = !relevantExercise.isCompleted;

    notifyListeners();

    db.saveToDataBase(workoutList);
    
    loadHeatMap();
  }

  Workout getRelevantWorkout(String workoutName) {
    Workout relevantWorkout =
        workoutList.firstWhere((workout) => workout.name == workoutName);

    return relevantWorkout;
  }

  Exercise getRelevantExercise(String workoutName, String exerciseName) {
    Workout relevantWorkout = getRelevantWorkout(workoutName);

    Exercise relevantExercise = relevantWorkout.exercises
        .firstWhere((exercise) => exercise.name == exerciseName);

    return relevantExercise;
  }

  //get start date
  String getStartDate() {
    return db.getStartDate();
  }

  //HEAT MAP
  Map<DateTime, int> heatMapDataSet = {};

  void loadHeatMap() {
    DateTime startDate = createDateTimeObject(getStartDate());

    //count the number of days to load
    int daysInBetween = DateTime.now().difference(startDate).inDays;

    //go from start date to today and all each completion status
    // 'COMPLETION_STATUS_yyyymmdd' will be the key in the database
    for (int i = 0; i < daysInBetween + 1; i++) {
      String yyyymmdd =
          convertDateTimeToYYYYMMDD(startDate.add(Duration(days: i)));

      //complettion status = 0 or 1
      int completionStatus = db.getCompletedStatus(yyyymmdd);

      //year
      int year = startDate.add(Duration(days: i)).year;
      //month
      int month = startDate.add(Duration(days: i)).month;
      //day
      int day = startDate.add(Duration(days: i)).day;

      final percentForEachDay = <DateTime, int>{
        DateTime(year, month, day): completionStatus
      };
      //add to the heat map dataset
      heatMapDataSet.addEntries(percentForEachDay.entries);
    }
  }
}
